

# Cassandra



## Introduction

This repo is designed to get you up and running with Cassandra in a limited amount of time to get some rapid hands-on experience with the technology through the convenience and reproducibility of a Docker container.

No knowledge of Docker is required but you do need to have Docker desktop installed and some basic understanding of working in a terminal.

[Download Docker Desktop](https://www.docker.com/products/docker-desktop)

You will also need to have Docker Compose installed.

[Download Docker Compose](https://docs.docker.com/compose/install/#install-compose)



## Cassandra Version

The Cassandra version for this exercise is locked in at 3.11.8 to ensure that this will always work, which shows the magic of Docker. If we were to always use the latest version available on Docker Hub, we may find that some of these steps may not work as there may have been breaking changes.

For more information, review the Dockerfile in this repo and the Docker hub page for Cassandra. 

[Docker Hub - Cassandra](https://hub.docker.com/_/cassandra?tab=description)



## A Note About Security

The instructions and methods used here do not necessarily employ best practices around security and deployment. 

**Please consult the official documentation for best practices around deploying Cassandra securely in your environment of choice**. 

In short, this repo should be used to play around with and learn a technology but nothing else.



## About the Data

Data for this exercise has been retrieved from the following Github repo: [imalik8088](https://github.com/imalik8088/cassandra-spark)

The data is a copy of the sample dataset used for tutorial exercises by [Datastax](https://www.datastax.com/) who is a cloud provider for production ready Cassandra clusters.

The data revolves around music and shows information about artists, albums and songs.



## Getting Started

Assuming you have Docker Desktop and Docker Compose installed and working on your local machine, we can begin by cloning this repository to your machine.

Clone this repository to your machine from the command line in your terminal.

```bash
git clone https://github.com/nelsonic1/databases-up-and-running.git
```

Change directory to NoSQL/Cassandra

```bash
cd NoSQL/Cassandra
```

From here you will see two docker compose files available. One for a single node deploy and one for a 3 node cluster.

```bash
ls -la
```



# Run a Single Node Cluster



## Starting Up

Run the following docker-compose command to specify a file and bring up a single node in detached mode

```bash
docker-compose -f docker-compose-single.yml up -d
```

You can see the containers running with the following command


```bash
docker ps
```

**Tailing the Logs**

If you wish to see the logs from the container you can run the following:

```bash
docker-compose -f docker-compose-single.yml logs
```



## Shutting Down

To shut down the cluster entirely, you can run the following docker-compose statement. This will stop and remove any containers and remove the network. Data however will be persisted in the volume specified in the docker-compose file.

*Note: You should not shutdown the container if you plan on continuing these exercises.*

```bash
docker-compose -f docker-compose-single.yml down
```

Verify the containers are stopped

```bash
docker ps
```



# Run a Three Node Cluster



## Starting Up

Run the following docker-compose command to specify a file and bring up a three node cluster in detached mode.

Each node will spin up consecutively and the second and third nodes will wait for specified time periods before they try to start and join the cluster. This is to allow the first seed node to stabilize and become ready to accept connections. If you would like to review further, please refer to `docker-compose-cluster.yml`.

Since there is a waiting period before nodes 2 and 3 come up, the entire process to fire up the cluster can take up to 3-4 minutes dependingso please be patient.

If you wish to see all of the log output, please remove the `-d` option which will stream docker logs to stdout in your console.

```bash
docker-compose -f docker-compose-cluster.yml up -d
```

**Tail the Logs**

If you started in detached mode `-d` and wish to see the logs to review progress, issue the following command

```bash
docker-compose -f docker-compose-cluster.yml logs
```

**Review Cluster Status**

To review the status of our cluster and see which nodes have currently joined we can run the `nodetool` but first we need to get to the command line in `cassandra1` which is the seed node.

```bash
docker exec -it cassandra1 bash
```

Run the nodetool with option status

```bash
nodetool status
```

This will print out the current status of the cluster along with which nodes have currently joined, are leaving, are joining or moving. 

On the left hand side of the output you will see status codes like `UN` which means Up+Normal or `UJ` which is Up+Joining or other combinations which you can derive from the status below.

```Datacenter: datacenter1
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  172.30.0.2  70.31 KiB  3            100.0%            e399db02-a350-4796-8ff0-f9615abdc636  rack1
UJ  172.30.0.3  74.83 KiB  3            100.0%            84fd2ae1-41e9-4c85-93da-a18b4fe05bf0  rack1
```

Once all three nodes have joined the cluster, the output of `nodetool status` will look like the following with all three nodes showing status of `UN`:

```
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  172.30.0.4  84.47 KiB  3            63.4%             c27afc28-19f9-4abf-a9a1-4690a9b7999d  rack1
UN  172.30.0.2  70.31 KiB  3            57.6%             e399db02-a350-4796-8ff0-f9615abdc636  rack1
UN  172.30.0.3  70.45 KiB  3            78.9%             84fd2ae1-41e9-4c85-93da-a18b4fe05bf0  rack1
```

If you are starting the cluster after the first run, you may see some nodes reporting status of `DN`, this is ok and expected. Keep running the command and you should see them automatically change to `UN`.

**Check Cluster Info**

```bash
nodetool info
```

You will get a lot of information back about your cluster. Pay attention to Gossip Active and Thrift Active

```bash
ID                     : 118a6488-d19a-49e9-8b22-435106ea1663
Gossip active          : true
Thrift active          : true
Native Transport active: true
Load                   : 4.24 MiB
Generation No          : 1601596139
Uptime (seconds)       : 196
Heap Memory (MB)       : 323.16 / 1952.00
Off Heap Memory (MB)   : 0.06
Data Center            : DC1
Rack                   : RAC1
Exceptions             : 0
Key Cache              : entries 27, size 2.28 KiB, capacity 97 MiB, 87 hits, 122 requests, 0.713 recent hit rate, 14400 save period in seconds
Row Cache              : entries 0, size 0 bytes, capacity 0 bytes, 0 hits, 0 requests, NaN recent hit rate, 0 save period in seconds
Counter Cache          : entries 0, size 0 bytes, capacity 48 MiB, 0 hits, 0 requests, NaN recent hit rate, 7200 save period in seconds
Chunk Cache            : entries 24, size 1.5 MiB, capacity 456 MiB, 60 misses, 237 requests, 0.747 recent hit rate, 910.351 microseconds miss latency
Percent Repaired       : 0.0%
Token                  : (invoke with -T/--tokens to see all 128 tokens)
```



## Configuration

There are configuration files present in the `config/cassandra*` directory for each node spun up in the cluster. If you would like to customize the configuration you must do so for each node and you can edit by modifying the `cassandra.yaml` file. A copy of the vanilla cassandra config is also available and it is advised for you to not modify that file so that you have a point of reference to go back to.



## Shutting Down

To shut down the cluster entirely, you can run the following docker-compose statement. This will stop and remove any containers and remove the network. Data however will be persisted in the volumes specified in the docker-compose file.

*Note: You should not shutdown the container if you plan on continuing these exercises.*

```bash
docker-compose -f docker-compose-cluster.yml down
```

Verify the containers are stopped

```bash
docker ps
```



# Operations



## Getting a Bash Shell

To get a bash shell on this container you can run the following and replacing <container> with the name of the container you wish to access. If you've started a single node cluster this will be called `cassandra-single` and if you've created a multi-node cluster, you could connect to any of `cassandra1`, `cassandra2` or `cassandra3`. 

Likely you will want to connect to `cassandra1` as that has our local data volume mounted to it and then you can load data. See the docker-compose file for more information. 

**Single Node**

```bash
docker exec -it cassandra-single bash
```

**Three Node**

```bash
docker exec -it cassandra1 bash
```

If you wish to see where the data is stored, you can navigate to it at /var/lib/cassandra:

```bash
cd var/lib/cassandra/data && ls
```

Each of the folders listed here represents a `Keyspace` which is equivalent to a database.

From bash you can start `cqlsh`, which is the cassandra command line client. 

*note: you can also replace `bash` in the `docker exec` statement above with `cqlsh` to skip bash.*

```bash
cqlsh
```

```CQL
SHOW VERSION;
```

```cql
SHOW HOST;
```

```CQL
DESCRIBE KEYSPACES;
```

```cql
exit
```

[Datastax CQL reference](https://docs.datastax.com/en/cql-oss/3.3/cql/cql_reference/cqlReferenceTOC.html)



## Loading the Data

The data for this exercise has been mounted from our local machine to the container at `home/data/musicdb/`

Using the `SOURCE` command in `cqlsh` we can load the data through two files. 

The first file is called `schema.cql` which will create a new Keyspace and create all of the tables and columns that we need.

The second file `data.cql` will issue all of the `COPY` commands to load data from CSV files in the data directory to their respective tables.

**Tables being created:**

- performer
- performers_by_style
- album
- albums_by_performer
- albums_by_genre
- albums_by_track
- tracks_by_album

### Creating the Schema

Now from the `cqlsh` command prompt run. For further information, review the [Getting a Bash Shell](#Getting a Bash Shell ) section.

```cql
SOURCE '/home/data/musicdb/schema.cql';
```

You will get no confirmation that this did anything but we can check the results.

```cql
DESCRIBE KEYSPACES;
```

Now you will see that there is a new Keyspace called `musicdb`. Let's explore what tables are available.

```CQL
USE musicdb; DESCRIBE TABLES;
```

For a more in depth look at columns, data types, etc. we can run a describe on an entire Keyspace.

```cql
DESCRIBE KEYSPACE musicdb;
```

### Loading the Data

Now, again from `cqlsh` let's load the data by running the following:

```CQL
SOURCE '/home/data/musicdb/data.cql';
```

You will see some progress messages like the following:

```
Starting copy of musicdb.performer with columns [name, type, country, style, founded, born, died].
Processed: 5536 rows; Rate:    1500 rows/s; Avg. rate:    3504 rows/s
5536 rows imported from 1 files in 1.580 seconds (0 skipped).
Using 3 child processes
```

You will also notice at the end of the output that there were some rows that cannot be written because they have NULL for a primary key column so Cassandra is skipping these records. This could be an opportunity to deal with bad data on the way in but for the sake of this exercise we will allow these records to fail and move on.

```home/data/musicdb/data.cql:23:Failed to import 55 rows: ParseError - Cannot insert null value for primary key column 'number'. If you want to insert empty strings, consider using the WITH NULL=<marker> option for COPY.,  given up without retries
home/data/musicdb/data.cql:23:Failed to process 418 rows; failed rows written to import_musicdb_tracks_by_album.err
```



**Verifying the data load**

Performers

```CQL
SELECT * FROM musicdb.performer LIMIT 10;
```

Albums

```CQL
SELECT title, year, genre, performer FROM musicdb.album LIMIT 10;
```

Great, looks like the data returned. We'll touch on some more specific queries in the next section.



## Querying the Data

Performers

```CQL
SELECT * FROM musicdb.performer LIMIT 10;
```

```CQL
SELECT * FROM musicdb.performer WHERE name = 'Deftones';
```

Albums

```CQL
SELECT title, year, genre, performer FROM musicdb.album LIMIT 10;
```

```CQL
SELECT title, year, genre, performer FROM musicdb.album WHERE title = 'Deftones' and year = 2003;
```

Albums by Performer

```CQL
SELECT title, year, genre, performer FROM musicdb.albums_by_performer WHERE performer = 'Sunny Day Real Estate';
```

Albums by Genre

```CQL
SELECT * FROM musicdb.albums_by_genre WHERE genre = 'Rap' LIMIT 10;
```

```CQL
SELECT * FROM musicdb.albums_by_genre WHERE genre = 'Punk' and performer = 'NoFX';
```

Albums by Track

```CQL
SELECT * FROM musicdb.albums_by_track WHERE track_title = 'Untitled';
```

Tracks by Album

```CQL
SELECT * FROM musicdb.tracks_by_album WHERE album_title = 'Rumours' and year = 1977;
```



## Accessing the Container Through an External Application

You may connect to Cassandra in your container through 0.0.0.0/9042 with no user and no password. This is possible as port 9042 is exposed to the host machine in the docker-compose yaml files.

If you have launched a 3 node cluster, you can access through any of 9042, 9043, 9044 for cassandra 1, cassanra2, cassandra3 respectively. Any node can accept queries and insert data. The data will automatically be replicated to the other 2 nodes due to the replication factor of 3 described in the `schema.cql` file

```cql
CREATE KEYSPACE IF NOT EXISTS musicdb WITH replication = {'class':'SimpleStrategy','replication_factor':3};
```



# Teardown and Next Steps

## Tear Down

In order to tear down each cluster, you should use `docker-compose -f <file> down`.

**Single Node**

```bash
docker-compose -f docker-compose-single.yml down
```

**Three Node**

```bash
docker-compose -f docker-compose-cluster.yml down
```

If your data gets corrupted and you would like to start over, remove all of the sub-directories as follows for each of the parent directories under data for the node(s) you are concerned with. For example for `cassandra1` you would delete the following directories under `/data/cassandra1`:

- commitlog
- data
- hints
- saved_caches

This effectively removes any previously persisted data for that container. Next time you start the cluster, only the default key spaces for Cassandra will be available.



## Next Steps

- [Official Documentation](https://cassandra.apache.org/doc/3.11.8/)
- [DataStax Documentation](https://docs.datastax.com/en/landing_page/doc/landing_page/cassandra.html)
- [Learn Cassandra gitbook](https://teddyma.gitbooks.io/learncassandra/content/) (This is for older versions of Cassandra but still has valuable information)
- Seek out additional resources about designing schemas for Cassandra
- Insert some of your own data into the tables in the musicdb.
- Write some advanced queries



# References

- https://medium.com/@kayaerol84/cassandra-cluster-management-with-docker-compose-40265d9de076
- https://digitalis.io/blog/containerized-cassandra-cluster-for-local-testing/
- https://github.com/imalik8088/cassandra-spark
- https://hub.docker.com/_/cassandra
- https://mannekentech.com/2017/01/02/playing-with-a-cassandra-cluster-via-docker/
- https://mannekentech.com/2017/11/11/playing-with-docker-and-cassandra/
- https://teddyma.gitbooks.io/learncassandra/content/








