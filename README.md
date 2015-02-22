# Deploying presto with docker/marathon/mesos

## Requirements
(working)
- mesos cluster
- marathon >= 0.7.5 (tested with marathon 0.7.5, should work with >= 0.70)
- some data accessible by presto
- a web/FTP server (anything accessible via curl)
- a private docker registry

## Software used
- confd (https://github.com/kelseyhightower/confd)

## Howto
### Setup
```sh
docker pull sheepkiller/presto-marathon
```
Then, create a tarball containing your catalog properties files, located in a directory called "catalog", and put it in a place where curl can grab it. Here's an example for jmx
```sh
mkdir catalog
echo "connector.name=jmx" > catalog/jmx.properties
tar zcvf catalog.tar.gz catalog
scp catalog.tar.gz my.server:
```
### Let's play !
Please see examples/deploy_presto.json...
As you can see, there's 4 mandatory environment variable to set:
1. CATALOGS_URL : where to find catalog.tar.gz
2. MARATHON_APPNAME : application name which must match `args` in your json
3. MARATHON_APPGROUP : applications group which must match group in `id`
4. MARATHON_URL : which must match your marathon master URL

You can also set JVM options via environment variables
- JAVA_PERM_SIZE
- JAVA_MAXPERM_SIZE
- JAVA_RCCS_SIZE
- JAVA_MAXHEAP_SIZE

Or some presto configuration
- PRESTO_TASK_MAXMEMORY

Or UUID (uuid is generated at runtime)
- PRESTO_UUID

If you need more tuning, modify confd files (presto-marathon-docker/docker/presto/confd)

#### Start cluster
```sh
curl -i -H 'Content-Type: application/json' -d @deploy_presto.json http://my.marathon.master:8080/v2/groups
```
#### Destroy cluster
```sh
 curl -X DELETE http://my.marathon.master/v2/groups/presto
```
#### presto CLI
- via docker exec (docker >= 1.3.0) (you 
```sh
$ docker exec -it <container id> /bin/bash
[container]# ./bin/presto  \
              --server \
              $(curl -sSfLk -m 10 -H \
                'Accept: text/plain' ${MARATHON_URL}/v2/tasks | \
                 egrep ^${MARATHON_APPGROUP}_meta_coordinator | \
                 awk 'NF == 3 {printf("http://%s"), $NF}')
```
- from anywhere
```sh
$ export PRESTO_VERSION=0.85
$ export MARATHON_URL=http://my.marathon.master:8080
$ export MARATHON_APPGROUP=presto
$ wget http://central.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar
$ mv presto-cli-${PRESTO_VERSION}-executable.jar presto
$ chmod +x presto
$ ./presto  \
              --server \
              $(curl -sSfLk -m 10 -H \
                'Accept: text/plain' ${MARATHON_URL}/v2/tasks | \
                 egrep ^${MARATHON_APPGROUP}_meta_coordinator | \
                 awk 'NF == 3 {printf("http://%s"), $NF}')
```
## Limitations
- [docker] Wasn't tested with bridge network (should work)
- multiple concurrent execution should work if you change group name (didn't test)

## ToDo's
- Better discovery "code"
- Better catalog handling
- Maybe split /${MARATHON_APPGROUP}/meta in 2: discovery & coordinator (or merge coordinator and discovery)
- Allow integration with etcd/consul (supported by confd)
- HA for marathon master
- handler more presto configuration options
