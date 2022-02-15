# -*- mode: ruby -*-
USE_REMOTE_PLUGIN "docker"
primary_nodes = ["gserver1", "gserver2"]
secondary_nodes = ["gserver3", "gserver4"]
all_nodes = primary_nodes + secondary_nodes

USE_NODE "local"
all_nodes.each do |node|
  USE_NODE "local"
  RUN "docker stop #{node}"
  RUN "docker rm #{node}"
end

network = "g1"
RUN "docker network rm #{network}"
TEST "docker network create #{network}"

all_nodes.each do |node|
  USE_NODE "local"
  TEST "docker run -d -v /sys/fs/cgroup/:/sys/fs/cgroup:ro --privileged --name #{node} --hostname #{node} --network #{network} gluster/fedora"
end

all_nodes.each do |node|
  USE_NODE node
  TEST "systemctl start glusterd"
  TEST "systemctl start sshd"
end

secondary_nodes.each do |node|
  USE_NODE node
  TEST "groupadd geogroup"
  TEST "useradd -G geogroup geoaccount"
end

# Start Primary Cluster nodes
USE_NODE "gserver1"
TEST "gluster peer probe gserver2.#{network}"

# Start the Secondary Cluster nodes
USE_NODE "gserver3"
TEST "gluster peer probe gserver4.#{network}"

# Prepare brick dirs
primary_nodes.each do |node|
  USE_NODE node
  TEST "mkdir -p /exports/vol1"
end

USE_NODE secondary_nodes[0]
TEST "gluster-mountbroker setup /var/mountbroker-root geogroup"
TEST "gluster-mountbroker add vol2 geoaccount"

secondary_nodes.each do |node|
  USE_NODE node
  TEST "mkdir -p /exports/vol2"
  TEST "systemctl restart glusterd"
end

TEST "sleep 5"

# Create Primary Volume and Start
USE_NODE "gserver1"
TEST "gluster volume create vol1 gserver1.#{network}:/exports/vol1/s1 gserver2.#{network}:/exports/vol1/s2 force"
TEST "gluster volume start vol1"

# Create Secondary Volume and Start
USE_NODE "gserver3"
TEST "gluster volume create vol2 gserver3.#{network}:/exports/vol2/s1 gserver4.#{network}:/exports/vol2/s2 force"
TEST "gluster volume start vol2"

# Setup Geo-rep and Start it
USE_NODE "gserver1"

# Passwordless SSH setup between primary and one secondary node
TEST "ssh-keygen -f /root/.ssh/id_rsa -N \"\""
pub_key = TEST "cat /root/.ssh/id_rsa.pub"

USE_NODE "gserver3"
TEST "mkdir /home/geoaccount/.ssh"
TEST "echo '#{pub_key}' >> /home/geoaccount/.ssh/authorized_keys"

USE_NODE "gserver1"
TEST "gluster-georep-sshkey generate"
TEST "gluster volume geo-replication vol1 geoaccount@gserver3.#{network}::vol2 create push-pem"

USE_NODE "gserver3"
TEST "/usr/libexec/glusterfs/set_geo_rep_pem_keys.sh geoaccount vol1 vol2"

USE_NODE "gserver1"
TEST "gluster volume geo-replication vol1 geoaccount@gserver3.#{network}::vol2 start"

# Copy the Small file create helper file
USE_NODE "local"
TEST "docker cp smallfile gserver1:/root/smallfile"

# Mount and Start the workload
USE_NODE "gserver1"
TEST "mkdir -p /mnt/fuse_mount"
TEST "mount -t glusterfs localhost:/vol1 /mnt/fuse_mount"
TEST "cd /root/smallfile && python smallfile_cli.py --operation create --threads 10 --file-size 32 --files 100000 --top /mnt/fuse_mount/"

puts TEST "gluster volume geo-replication vol1 geoaccount@gserver3.#{network}::vol2 status"
