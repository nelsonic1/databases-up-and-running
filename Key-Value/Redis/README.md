

# Redis



## Introduction

This repo is designed to get you up and running with Redis in a limited amount of time to get some rapid hands-on experience with the technology through the convenience and reproducibility of a Docker container.

No knowledge of Docker is required but you do need to have Docker desktop installed and some basic understanding of working in a terminal.

[Download Docker Desktop](https://www.docker.com/products/docker-desktop)

You will also need to have Docker Compose installed.

[Download Docker Compose](https://docs.docker.com/compose/install/#install-compose)



## What is Redis

Redis stands for "Remote Dictionary Server". It is an open-source, in-memory key-value data store which can serve as a database, cache, message broker and queue ([ref](https://aws.amazon.com/redis/)). Redis is an extremely fast key-store as all data resides in memory which avoids seek time delays introduced by disk backed databases. As such, Redis is perfectly equipped to handle millions of requests per second. While it is in-memory it also persists data to disk for easy backup and restores. The tradeoff here is that data cannot be larger than what can be held in the available memory on a system whereas disk backed databases have access to large (and cheap) disk based storage.

Unlike other Key-Value stores that only support keys and values as strings, Redis allows for more complex data types such as:

- Strings

- Lists

- Sets

- Sorted Sets

- Hashes

- Bitmaps

- HyperLogLogs

  

## Redis Version

The Redis version for this exercise is locked in at 6.0.9 to ensure that this will always work, which shows the magic of Docker. If we were to always use the latest version available on Docker Hub, we may find that some of these steps may not work as there may have been breaking changes.

For more information, review the Dockerfile in this repo and the Docker hub page for Redis. 

[Docker Hub - Redis](https://hub.docker.com/_/redis?tab=description)



## A Note About Security

The instructions and methods used here do not necessarily employ best practices around security and deployment. 

**Please consult the official documentation for best practices around deploying Redis securely in your environment of choice**. 

In short, this repo should be used to play around with and learn a technology but nothing else.



## Getting Started

Assuming you have Docker Desktop and Docker Compose installed and working on your local machine, we can begin by cloning this repository to your machine.

Clone this repository to your machine from the command line in your terminal.

```bash
git clone https://github.com/nelsonic1/databases-up-and-running.git
```

Change directory to Key-Value/Redis

```bash
cd Key-Value/Redis
```

From here you will see any docker compose files available.

```bash
ls -la
```



# Run a Single Node



## Starting Up

Run the following docker-compose command to specify a file and bring up a single node in detached mode

```bash
docker-compose up -d
```

You can see the containers running with the following command


```bash
docker ps
```

**Tailing the Logs**

If you wish to see the logs from the container you can run the following:

```bash
docker-compose logs
```



## Shutting Down

To shut down, you can run the following docker-compose statement. This will stop and remove any containers and remove the network. Data however will be persisted in the volume specified in the docker-compose file.

*Note: You should not shutdown the container if you plan on continuing these exercises.*

```bash
docker-compose down
```

Verify the containers are stopped

```bash
docker ps
```



# Operations

## Getting a Bash Shell

To get a bash shell on this container you can run the following and replacing <container> with the name of the container you wish to access. 

```bash
docker exec -it redis bash
```

If you wish to see where the data is stored, you can navigate to it at `/data`:

```bash
cd data && ls
```



## Accessing the redis-cli

To access the redis cli directly in the container you can run:

```bash
docker exec -it redis redis-cli
```

This will automatically connect to the redis server on localhost which is not password protected.

From here, you can run:

```bash
ping
>"PONG"
```



## Accessing the Container Through an External Application

You may connect to Redis in your container through 0.0.0.0/6379 with no user and no password. This is possible as port 6379 is exposed to the host machine in the docker-compose yaml files.

If you have redis-cli available on your local machine, you may run:

```bash
redis-cli -h localhost
```

As always you can use the redis-cli inside the redis container:

```bash
docker exec -it redis redis-clis
```



# Redis Data Types

The following examples are meant to be run inside the `redis-cli` application. 



## Strings

Redis allows you to set string values with the following command:

```bash
SET key value
>OK
```

So in this example, we will set a key of 'hello' and a value of 'world'.

```bash
SET hello world
>OK
```

If we wish to retrieve the value stored against a key, you can issue the following:

```bash
GET hello
>"world"
```

 We can overwrite the value stored in hello.

```bash
SET hello you
>OK
```

```bash
GET hello
>"you"
```

**Expire a key after a set time**

```bash
SET hello world
>OK
EXPIRE hello 10
>(integer) 1
GET hello
>"world"

# After 10 seconds, the key no longer exists
GET hello
>(nil)

# SETEX allows you to set an expiry time for a key at the same time as the value
SETEX hello 10 world
>OK
TTL hello
>(integer) 10
TTL hello
>(integer) 9
TTL hello
>(integer) 8
TTL hello
>(integer) 7
TTL hello
>(integer) 6
TTL hello
>(integer) 5
TTL hello
>(integer) 4
TTL hello
>(integer) 3
TTL hello
>(integer) 2
TTL hello
>(integer) 1
TTL hello
>(integer) 0
TTL hello
>(integer) -2
```

**Append to a key**

```bash
EXISTS mykey
>(integer) 0

# if key does not exist, creates a new string
APPEND mykey hello
>(integer) 5

APPEND mykey hello
>(integer) 10

GET mykey
>"hellohello"
```

**Checking the Type of a Key**

You can check the type of a key with the TYPE command.

```bash
TYPE hello
>string
```

**Incrementing/Decrementing Values**

```bash
SET counter 1
>OK

INCR counter
>(integer) 2

INCR counter
>(integer) 3

DECR counter
>(integer) 2
```

**Incrementing/Decrementing Values by an Interval**

```bash
SET counter 1
>OK

INCRBY counter 5
>(integer) 6

DECRBY counter 2
>(integer) 4
```

**Getting a range of strings**

```bash
SET greeting "hello how are you"
>OK

getrange greeting 6 -1
>"how are you"
```



## Hashes

You can set a hash with the HMSET command which takes the form of:

```bash
HMSET keyspace:id key value ...
```

**Create a hash**

We'll set a hash for the legendary [Red Green](https://upload.wikimedia.org/wikipedia/en/4/44/The_Red_Green_Show.jpg) which contains his username, password and his nationality.

```bash
HMSET user:1 username redgreen password duct_tape nationality canadian
>OK
```

**Retrieve a single value**

```bash
HGET user:1 username
>"redgreen"
```

**Retrieve multiple specific values**

```bash
HMGET user:1 username password
>1) "redgreen"
>2) "duct_tape"
```

**Retrieve all key-value pairs**

```bash
HGETALL user:1
>1) "username"
>2) "redgreen"
>3) "password"
>4) "duct_tape"
>5) "nationality"
>6) "canadian"
```

**Get all keys**

```bash
HKEYS user:1
>1) "username"
>2) "password"
>3) "nationality"
```

**Get all values**

```bash
HVALS user:1
>1) "redgreen"
>2) "duct_tape"
>3) "canadian"
```

**Get length of a hash**

```bash
HLEN user:1
>(integer) 3
```

**Check that a key exists in a hash**

```bash
HEXISTS user:1 username
>(integer) 1
HEXISTS user:1 foo
>(integer) 0
```

**Deleting a key in a hash**

First let's set a test hash

```bash
HSET myhash key1 value1 key2 value2
>(integer) 2
```

Now let's delete the second key

```bash
HDEL myhash key2
>(integer) 1
```

If we try to retrieve key2 for myhash, now there will only be one key available.

```bash
HGET myhash key2
>(nil)
HGET myhash key1
>"value1"
```

**Deleting an entire hash**

```bash
DEL user:1
>(integer) 1
```

```bash
HMGET user:1 username password
>1) (nil)
>2) (nil)
```



## Lists

**Setting a list**

*Lists are 0 based*

```bash
lpush mydatabases redis mysql postgres mongodb cassandra
>(integer) 5
```

**Adding to a list**

```bash
lpush mydatabases couchdb
>(integer) 6
```

**Getting all values from the start of the list to the last index**

```bash
lrange mydatabases 0 -1
>1) "couchdb"
>2) "cassandra"
>3) "mongodb"
>4) "postgres"
>5) "mysql"
>6) "redis"
```

**Getting only a subsection of a list by index**

```bash
lrange mydatabases 3 6
>1) "postgres"
>2) "mysql"
>3) "redis"
```

**Getting the length of a list**

```bash
LLEN mydatabases
>(integer) 6
```

**Get the position of a given element in a list**

```bash
LPOS mydatabases mongodb
>(integer) 2
```

**Pop the first element off the list**

```bash
LPOP mydatabases
>"couchdb"

lrange mydatabases 0 -1
>1) "cassandra"
>2) "mongodb"
>3) "postgres"
>4) "mysql"
>5) "redis"
```

**Pop the last element off the list**

```bash
RPOP mydatabases
>"redis"

lrange mydatabases 0 -1
>1) "cassandra"
>2) "mongodb"
>3) "postgres"
>4) "mysql"
```

**Insert a value before/after an element**

```bash
linsert mydatabases BEFORE mongodb influxdb
(integer) 5

lrange mydatabases 0 -1
>1) "cassandra"
>2) "influxdb"
>3) "mongodb"
>4) "postgres"
>5) "mysql"

linsert mydatabases AFTER mysql neo4j
(integer) 6

lrange mydatabases 0 -1
1) "cassandra"
2) "influxdb"
3) "mongodb"
4) "postgres"
5) "mysql"
6) "neo4j"

```

**Remove n elements from a list**

```bash
lpush hellos hello hello how are you hello hello
>(integer) 7

# removes the last 2 hellos from the list
lrem hellos -2 hello
>(integer) 2

# removes the first hello from the list
lrem hellos 1 hello
>(integer) 1

# note that the elements are reversed (right-left)
lrange hellos 0 -1
>1) "hello"
>2) "you"
>3) "are"
>4) "how"

# remove all elements from a list that match the key
lrem hellos 0 hello
>(integer) 1

lrange hellos 0 -1
>1) "you"
>2) "are"
>3) "how"
```



## Sets

Sets are unordered collections of strings. It is possible to add, remove and test for the existence of set members in O(1) time complexity. Sets do not allow for repeated members and thus is it is a distinct list. Adding the same item multiple times will result in only one copy of that item being permitted into the set. This allows you skip the check if a member exists prior to adding as it will not be added more than once.

**Add items to a set**

```bash
sadd mySet 1 2 3
>(integer) 3
```

**Get members of a set**

```bash
smembers mySet
>1) "1"
>2) "2"
>3) "3"
```

**Get the count of members in a set**

```bash
scard mySet
>(integer) 3
```

**Get random members from a set**

```bash
SRANDMEMBER mySet
>"2"
SRANDMEMBER mySet
>"3"
```

**Get the difference between two sets**

In other words, get the elements from the first set which do not exist in (n) other sets.

```bash
sadd set1 1 2 3 4
>(integer) 1

sadd set2 3 4 5 6
>(integer) 2

sdiff set1 set2
>1) "1"
>2) "2"

sdiff set2 set1
>1) "5"
>2) "6"
```

**Get the members that intersect**

```bash
sinter set1 set2
>1) "3"
>2) "4"
```

**Get the members that insersect and store it in a new Set**

```bash
SINTERSTORE mysets set1 set2
(integer) 2

smembers mysets
>1) "3"
>2) "4"
```



## Sorted Sets

Sorted sets are similar to Sets but Sorted Set entries are all associated with a score. This of a list of movies and their IMDB ratings.

While members are unique, scores may be repeated.

**Adding members to a Sorted Set**

```bash
zadd movies 8.7 "Star Wars: Episode V - The Empire Strikes Back" 8.6 "Star Wars: Episode IV - A New Hope" 7.9 "Star Wars: Episode VII - The Force Awakens" 7.5 "Star Wars: Episode III - Revenge of the Sith" 8.3 "Star Wars: Episode VI - Return of the Jedi"
```

**Get members of a set based on score range**

Alternatively you may add "WITHSCORES" on the end of the ZRANGEBYSCORE command to also get their scores.

```bash
ZRANGEBYSCORE movies 7.9 9.0
>1) "Star Wars: Episode VII - The Force Awakens"
>2) "Star Wars: Episode VI - Return of the Jedi"
>3) "Star Wars: Episode IV - A New Hope"
>4) "Star Wars: Episode V - The Empire Strikes Back"
```

**Add or update members of a Sorted Set**

```bash
zadd movies 9.0 "Star Wars: Episode V - The Empire Strikes Back"
```

**Get the number of members in a Sorted Set**

```bash
ZCARD movies
>(integer) 5
```

**Get the score associated with a member in a Sorted Set**

```bash
ZSCORE movies "Star Wars: Episode III - Revenge of the Sith"
>"7.5"
```

**Remove members based on score**

```bash
ZREMRANGEBYSCORE movies 0.0 8.0
>(integer) 2

ZSCAN movies 0
>1) "0"
>2) 1) "Star Wars: Episode VI - Return of the Jedi"
>   2) "8.3000000000000007"
>   3) "Star Wars: Episode IV - A New Hope"
>   4) "8.5999999999999996"
>   5) "Star Wars: Episode V - The Empire Strikes Back"
>   6) "9"
```



## Flush Content From DB

To flush only the content from the **current** db, issue `FLUSHDB`.

To flush all of the content from all redis databases, all you need to issue is `FLUSHALL`. Obviously you need to be careful with this one.



# Teardown and Next Steps

## Tear Down

```bash
docker-compose down
```

If your data gets corrupted and you would like to start over, remove all of the sub-directories as follows for each of the parent directories under data for the node(s) you are concerned with.

This effectively removes any previously persisted data for that container.



## Next Steps

- [Official Redis Documentation](https://redis.io/documentation)
- [redis-cli](https://redis.io/topics/rediscli)
  - [Data Types](https://redis.io/topics/data-types-intro)
  - [All Commands](https://redis.io/commands)
- [Redis Tutorial @ TutorialsPoint](https://www.tutorialspoint.com/redis/index.htm)
- [Redis University](https://university.redislabs.com/)
- [Redis University - Youtube](https://www.youtube.com/channel/UCybK6TMZFQeSN74jzTiDWfg)
- [Check out Redis Search](https://oss.redislabs.com/redisearch/)

# References

[TutorialsPoint](https://www.tutorialspoint.com/redis/redis_quick_guide.htm)

[Redis Docs - Data Types](https://redis.io/topics/data-types)

[AWS Redis](https://aws.amazon.com/redis/)