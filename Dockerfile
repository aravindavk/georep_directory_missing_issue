# sudo docker build . --tag gluster/fedora -f Dockerfile
FROM fedora:latest

RUN dnf update -y
RUN dnf -y install glusterfs-server sshpass openssh-clients openssh glusterfs-geo-replication openssh-server findutils

RUN echo "root:kadalu" | chpasswd

RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config \
  && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/'       \
    /etc/ssh/sshd_config &&                                                   \
  sed -i.save -e "s#udev_sync = 1#udev_sync = 0#"                             \
    -e "s#udev_rules = 1#udev_rules = 0#"                                     \
    -e "s#use_lvmetad = 1#use_lvmetad = 0#"                                   \
    -e "s#obtain_device_list_from_udev = 1#obtain_device_list_from_udev = 0#" \
    /etc/lvm/lvm.conf &&                                                      \
  systemctl mask getty.target

cmd ["/usr/sbin/init"]