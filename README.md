## Build Storage node container image

```console
sudo docker build . --tag gluster/fedora -f Dockerfile
```

## Install the Binnacle Tool

```
curl -fsSL https://github.com/kadalu/binnacle/releases/latest/download/install.sh | sudo bash -x
```

## Setup and Run Tests

- Clone smallfile repo from here `git clone https://github.com/distributed-system-analysis/smallfile`
- Setup two cluster with 2 nodes(containers) each
- Create one volume in each cluster.
- Establish Georep session between those Volumes
- Start the Geo-replication and run the workload

```
sudo binnacle -v tests.t
```

Download changelog parser tool from [here](https://github.com/aravindavk/gluster-changelog-parser) to parse the changelogs to understand the workload.


## Check number of directories created

```
sudo binnacle -v tests_find.t
```

## Stop all containers/nodes

```
sudo binnacle -v stop_all.t
```
