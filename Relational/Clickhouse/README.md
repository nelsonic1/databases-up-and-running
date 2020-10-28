# Clickhouse



## Introduction

This repo is designed to get you up and running with Clickhouse in a limited amount of time to get some rapid hands-on experience with the technology through the convenience and reproducibility of a Docker container.

No knowledge of Docker is required but you do need to have Docker desktop installed and some basic understanding of working in a terminal.

[Download Docker Desktop](https://www.docker.com/products/docker-desktop)

You will also need to have Docker Compose installed.

[Download Docker Compose](https://docs.docker.com/compose/install/#install-compose)



**If you are new to databases**

If you are relatively new to databases, this may not be the one to start with. You should start with something like MySQL or Postgres and work your way back here.

 

**If you are at least somewhat experienced with databases**

If you've been working with databases for awhile and would like to explore a really cool column-oriented relational database, feel free to go on ahead!



## Clickhouse Version

The Clickhouse version for this exercise is locked in at 20.9.2.20 to ensure that this will always work, which shows the magic of Docker. If we were to always use the latest version available on Docker Hub, we may find that some of these steps may not work as there may have been breaking changes.

For more information, review the Dockerfile in this repo and the Docker hub page for Clickhouse. 

[Docker Hub - Clickhouse](https://hub.docker.com/r/yandex/clickhouse-server/)



## Docker Version (Important)

There is an issue with the stable version of Docker released in late 2020 that prevents these containers from starting correctly. If you get a message that your Clickhouse cluster failed the init process, try to downgrade your Docker installation. This is confirmed working with the following version.

**Docker Desktop 2.3.05** (48029)

- Engine 19.03.12

- Compose 1.27.2

  

## A Note About Security

The instructions and methods used here do not necessarily employ best practices around security and deployment. 

**Please consult the official documentation for best practices around deploying Clickhouse securely in your environment of choice**. 

In short, this repo should be used to play around with and learn a technology but nothing else.



## About Clickhouse

ClickHouse is a column-oriented database management system (DBMS) for online analytical processing of queries (OLAP).

**Clickhouse History** (from the documentation)

ClickHouse has been developed initially to power [Yandex.Metrica](https://metrica.yandex.com/), [the second largest web analytics platform in the world](https://w3techs.com/technologies/overview/traffic_analysis/all), and continues to be the core component of this system. With more than 13 trillion records in the database and more than 20 billion events daily, ClickHouse allows generating custom reports on the fly directly from non-aggregated data. This article briefly covers the goals of ClickHouse in the early stages of its development.

Yandex.Metrica builds customized reports on the fly based on hits and sessions, with arbitrary segments defined by the user. Doing so often requires building complex aggregates, such as the number of unique users. New data for building a report arrives in real-time.

As of April 2014, Yandex.Metrica was tracking about 12 billion events (page views and clicks) daily. All these events must be stored to build custom reports. A single query may require scanning millions of rows within a few hundred milliseconds, or hundreds of millions of rows in just a few seconds.

[Reference](https://clickhouse.tech/docs/en/introduction/history/)



**Some Key Features:**

- Column Oriented
- Data Compression
- Disk Based Storage
- Parallel Processing on Multiple Cores
- Distributed Processing across Clusters
- SQL Language Support
- Suitable for OLAP Workloads
- Support for Approximated Calculations
- Full Data Replication (Async multi-master)

[Reference](https://clickhouse.tech/docs/en/introduction/distinctive-features/)



## About the Data

Data for this exercise will be downloaded from the [U.S. Bureau of Transportation Statistics](https://transtats.bts.gov/) and contains information on delayed and on-time flights. 

This is an example used in the [official documentation for Clickhouse](https://clickhouse.tech/docs/en/getting-started/example-datasets/ontime/) although we will be doing this in a single node as well as a fully replicated 4 node cluster. There are differences between these two approaches that we will explore later.

This data spans back to 1987 right up until present day. As you can imagine, loading this data for commercial flights back to 1987 could get very large although Clickhouse would fully support this. In the documentation, there are examples which use a full Terabyte of clickstream data. For our purposes we will only use a small subset of data just to explore some features but if you want to do performance testing, you may consider using some much larger datasets.



## Getting Started

Assuming you have Docker Desktop and Docker Compose installed and working on your local machine, we can begin by cloning this repository to your machine.

Clone this repository to your machine from the command line in your terminal.

```bash
git clone https://github.com/nelsonic1/databases-up-and-running.git
```

Change directory to Relational/Clickhouse

```bash
cd Relational/Clickhouse
```

From here you will see two docker compose files available. One for a single node deploy and one for a 4 node cluster.

```bash
ls -la
```



## Downloading the Data

There is a script in the scripts directory for Clickhouse named `download_data.sh`. This script takes in a user input to get the year that a user would like to start their download from. If you specify something like 2018, the data will begin downloading in files by month (2018_1, 2018_2) right until the end of the current year. 

To begin, we first need to change the ownership of this file so that it can be executed.

```bash
chmod +x /scripts/download_data.sh
```

Now you can run the file as such

```bash
./download_data
```

Note that the amount of data per year is quite large so for our purposes it is recommended to only download 1-2 years of data but feel free to load in all data right from 1987 if you please. Clickhouse will handle huge amounts of data handily even in the multi-Terabyte range. 

Specify the year for the beginning of your download when prompted and be patient as it can take some time depending on your internet connection and how much data is being requested.

The data will be downloaded in the directory `data/airline-on-time/` as zip files by year and month.

e.g. `ontime_2020_01.zip`



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

To shut down Clickhouse, you can run the following docker-compose statement. This will stop and remove any containers and remove the network. Data however will be persisted in the volume specified in the docker-compose file.

*Note: You should not shutdown the container if you plan on continuing these exercises.*

```bash
docker-compose -f docker-compose-single.yml down
```

Verify the containers are stopped

```bash
docker ps
```



# Run a Multi Node Cluster

This cluster contains 4 nodes and is configured with two shards, each with two replicas (representing the nodes in the docker file - see below). Each node will spin up after Zookeeper is started. Zookeeper is used to manage replication between servers. 

Replication in Clickhouse is done on a per-table basis rather than at the database level. You can specify a table to be replicated by using a storage engine that supports it such as the `ReplicatedMergeTree`. A database can contain both replicated and non-replicated tables at the same time.

<u>**Replication Config**</u>

**Shard 1**

- clickhouse1
- clickhouse2

**Shard 2**

- clickhouse3
- clickhouse4

You can see the full configuration in `/config/metrika.xml`

More information on replication can be found below:

- [Clickhouse Replication Documentation](https://clickhouse.tech/docs/en/engines/table-engines/mergetree-family/replication/)
- [Clickhouse Database Engines](https://clickhouse.tech/docs/en/engines/table-engines/)



## Starting Up

**Startup**

Run the following docker-compose command to specify a file and bring up a 4 node cluster in detached mode.

```bash
docker-compose -f docker-compose-cluster.yml up -d
```

**Tail the Logs**

If you started in detached mode `-d` and wish to see the logs to review progress, issue the following command

```bash
docker-compose -f docker-compose-cluster.yml logs
```

**Review Cluster Status**

To review the status of our cluster, we can access a specific node and launch the clickhouse-client program.

```bash
docker exec -it clickhouse1 clickhouse-client -q "SELECT * FROM system.clusters FORMAT PrettyCompact"
```

You will see data returned that outlines the cluster name, shards, replicas, host name and address as well as any errors recorded.

**Review Replica Status**

```bash
docker exec -it clickhouse1 clickhouse-client -q "SELECT
    database, table, engine, is_leader, is_readonly, zookeeper_path,
    replica_name, replica_path, inserts_in_queue, merges_in_queue, zookeeper_exception
FROM system.replicas
FORMAT Vertical"
```



## Configuration

**Docker Configuration**

If you would like to review the configuration further, you can check out `docker-compose-cluster.yml` for information about services, volume mounts, configuration files, users, etc. 

**Clickhouse Configuration** 

You can check the Clickhouse configuration under `./config/config.xml` and `./config/metrika.xml`. Config contains a *mostly* default configuration for Clickhouse with a modified section to look for additional configuration from `metrika.xml` as well as instructions to replace specifc config nodes in `config.xml`.

**Macros**

There are macros defined in the following directory `./config/macros`. Macros are used for placeholder substitution when creating tables and other tasks in Clickhouse.

**e.g.**

```SQL
CREATE TABLE `test_table` ON CLUSTER `cluster_1` (
`Month` Uint8,
`Day` Uint8,
`City` String
) ENGINE = ReplicatedMergeTree('/clickhouse/tables/{shard}/test_table', '{replica}', ver)
PARTITION BY Month
ORDER BY (Month, Day)
```

Where `{shard}` and `{replica}` would be replaced with information defined in the macro file assigned to each node.



## Shutting Down

To shutdown the cluster entirely, you can run the following docker-compose statment. This will stop and remove any containers and remove the the network. Data however will be persisted in the volumes specified in the docker-compose file.

*Note: You should not shutdown the container if you plan on continuing these exercises.*

```bash
docker-compoe -f docker-compose-cluster.yml down
```

Verify the containers are stopped

```bash
docker ps
```



# Operations

## Loading the Data

As mentioned earlier, we're going to be creating a table to hold information regarding airport departures and arrivals over time for multiple airlines. 

**Tables being Created**

- ontime

All databases and tables will be automatically created for you when starting up Clickhouse. You do **not** need to issue any `CREATE db` or `CREATE TABLE` statements. 

The specific instructions issued to each node can be found under the following folders:

- Non-replicated (clickhouse-single)
  - `/scripts/non-replicated`
- Replicated (clickhouse1 through 4)
  - `/scripts/replicated`)

**Data**

Data will also be loaded into Clickhouse using instructions found in `init.sh` in the appropriate scripts folder using data that you previously downloaded. If you have not yet downloaded any data, please refer to previous sections on how to download this.

Note that there is a create statement for use with a single node or when we are **not** replicating our data with the `MergeTree` engine. 

There is another type of table engine which allows us to create an automatically replicated table with the `ReplicatedMergeTree` engine. This will replicate data from each replica set in the shard (see `/config/metrika.xml`)



**metrika.xml**

```xml
        <cluster_1>
            <shard>
                <weight>1</weight>
                <internal_replication>true</internal_replication>
                <replica>
                    <host>clickhouse1</host>
                    <port>9000</port>
                </replica>
                <replica>
                    <host>clickhouse2</host>
                    <port>9000</port>
                </replica>
            </shard>
            <shard>
                <weight>1</weight>
                <internal_replication>true</internal_replication>
                <replica>
                    <host>clickhouse3</host>
                    <port>9000</port>
                </replica>
                <replica>
                    <host>clickhouse4</host>
                    <port>9000</port>
                </replica>
            </shard>
        </cluster_1>
```



## Getting a Bash Shell

To get a bash shell on this container you can run the following and replacing <container> with the name of the container you wish to access. If you've started a single node cluster this will be called `clickhouse-single` and if you've created a multi-node cluster, you could connect to any of `clickhouse1`, `clickhouse2`, `clickhouse3` or `clickhouse4`. 

See the docker-compose file for more information. 

**Single Node**

```bash
docker exec -it clickhouse-single bash
```

**Multi Node Cluster**

```bash
docker exec -it clickhouse1 bash
```

```bash
docker exec -it clickhouse2 bash
```

```bash
docker exec -it clickhouse3 bash
```

```bash
docker exec -it clickhouse4 bash
```



## Accessing the Clickhouse Command-line Client

**Single Node**

```bash
docker exec -it clickhouse-single clickhouse-client
```

**Multi Node Cluster**

```bash
docker exec -it clickhouse1 clickhouse-client
```

```bash
docker exec -it clickhouse2 clickhouse-client
```

```bash
docker exec -it clickhouse3 clickhouse-client
```

```bash
docker exec -it clickhouse4 clickhouse-client
```

**Issue a Query at the Same Time**

```bash
docker exec -it clickhouse1 clickhouse-client -q "SELECT * FROM somedb.sometable"
```

**Exit the Clickhouse-client**

```bash
exit
```



## Accessing the Container Through an External Application

Clickhouse is accessible through port `8123` for external connections via HTTP Interface and also through `9000` for programs such as `clickhouse-client`. Depending on what application you are using you may need to switch between the two to find what works. Because Clickhouse is accessible via `8123` with HTTP, this means you can issue `curl` commands to your database to make  queries on the command line from anywhere.

**Single Node**

`0.0.0.0:8123` / `9000` (**clickhouse-single**) (or `localhost:port`)

**Multi Node**

`0.0.0.0:8123` / `9000` (**clickhouse1**) 

`0.0.0.0:8124` / `9001` (**clickhouse2**)

`0.0.0.0:8125` / `9002` (**clickhouse3**)

`0.0.0.0:8126` / `9003` (**clickhouse4**)



## Accessing with Curl From the Command Line

**Do a health check on a node**

```bash
curl 'http://localhost:8123/ping'
```

**Issue a query against a node**

The below is provided for easier reading only.

```SQL
SELECT Year, Month, FlightDate, Origin, Dest, DepDelay, ArrDelay
FROM ontime.ontime
LIMIT 10
FORMAT Pretty;
```

The actual curl call for the above query:

```bash
curl 'http://localhost:8123/?query=SELECT%20Year,%20Month,%20FlightDate,%20Origin,%20Dest,%20DepDelay,%20ArrDelay%20FROM%20ontime.ontime%20LIMIT%2010%20FORMAT%20Pretty'
```

**More info**

[HTTP Interfaces - Clickhouse Documentation](https://clickhouse.tech/docs/en/interfaces/http/)



## Running Queries Against the Loaded Data

An in-depth guide to running queries against the loaded data in this guide is out of scope. However, the Clickhouse documentation has all of the information you need to run through this very example.

You can access their documentation for the ontime data set here:

[Clickhouse Getting Started - Ontime](https://clickhouse.tech/docs/en/getting-started/example-datasets/ontime/)

You should also get creative and review the SQL Reference in the Clickhouse documentation to write your own queries.

**Clickhouse-client**

Once again, you can access the clickhouse-client to run these queries with the command below:

```bash
docker exec -it <replace-with-docker-node> clickhouse-client
```

**Important Note!**

You do not need to do any of the data preparation steps found in the guide as we already setup! You may need to tweak some of the year ranges in the queries to work with the data that you have loaded though.



# Teardown and Next Steps



## Tear Down

**Single Node**

```bash
docker-compose -f docker-compose-single.yml down
```

**Multi Node**

```bash
docker-compose -f docker-compose-cluster.yml down
```

If your data gets corrupted and you will like to start over, remove all of the sub-directories as follows:

- /data/clickhouse1 (applicable for 1-4)

  OR

- /data/clickhouse-single

This remove the persisted storage for the database and since the container is destroyed after doing a docker-compose down, it will rebuild with the default databases for Clickhouse on the next run.



## Next Steps

- [Official Documentation](https://clickhouse.tech/docs/en/)

- [Clickhouse Introduction by Alexander Zaitsev, Altinity CTO](https://www.slideshare.net/Altinity/clickhouse-introduction-by-alexander-zaitsev-altinity-cto-180747162)

- [Clickhouse on Youtube](https://www.youtube.com/c/ClickHouseDB)

- [Altinity on Youtube](https://www.youtube.com/channel/UCE3Y2lDKl_ZfjaCrh62onYA)

- [Clickhouse on Github](https://github.com/ClickHouse/ClickHouse)

- Try to follow the ontime tutorial in depth from the official Clickhouse Documentation

- Try to follow some different tutorials in the Clickhouse documentation with bigger/different datasets.

- Read about and try some different table engines in the Clickhouse Documentation.

  

# References

- https://clickhouse.tech/docs/en/getting-started/example-datasets/ontime/
- https://hub.docker.com/r/yandex/clickhouse-server
- https://hub.docker.com/_/zookeeper?tab=description
- https://github.com/neverlee/clickhouse-cluster-docker-compose/blob/master/docker-compose.yaml
- https://github.com/tetafro/clickhouse-cluster/blob/master/docker-compose.yml
- https://github.com/jneo8/clickhouse-setup
- https://transtats.bts.gov/
- https://altinity.com/blog/2019/3/15/clickhouse-networking-part-1
- https://clickhouse.tech/docs/en/engines/table-engines/special/distributed/

