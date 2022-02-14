# -*- mode: ruby -*-
USE_REMOTE_PLUGIN "docker"

USE_NODE "gserver1"
puts TEST "cd /exports/vol1/s1; find . -type d -not -path '*/.*'  | wc -l"
TEST "mkdir -p /mnt/vol1"
TEST "mount -t glusterfs localhost:/vol1 /mnt/vol1"
puts TEST "cd /mnt/vol1; find . -type d -not -path '*/.*'  | wc -l"

USE_NODE "gserver2"
puts TEST "cd /exports/vol1/s2; find . -type d -not -path '*/.*'  | wc -l"

USE_NODE "gserver3"
puts TEST "cd /exports/vol2/s1; find . -type d -not -path '*/.*'  | wc -l"
TEST "mkdir -p /mnt/vol2"
TEST "mount -t glusterfs localhost:/vol2 /mnt/vol2"
puts TEST "cd /mnt/vol2; find . -type d -not -path '*/.*'  | wc -l"


USE_NODE "gserver4"
puts TEST "cd /exports/vol2/s2; find . -type d -not -path '*/.*'  | wc -l"
