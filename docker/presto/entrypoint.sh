#!/bin/sh
fatal() {
    echo "$@"
    exit 1
}

export MARATHON_URL=${MARATHON_URL:-localhost}
export MARATHON_APPGROUP=${MARATHON_APPGROUP:-""}
export PRESTO_SERVICE=${1:-worker}
export PRESTO_ENVIRONMENT=${PRESTO_ENVIRONMENT:-dark_city}
export PRESTO_HTTP_PORT=${PORT:-8080}

export JAVA_PERM_SIZE="${JAVA_PERM_SIZE:-150M}"
export JAVA_MAXPERM_SIZE="${JAVA_MAXPERM_SIZE:-150M}"
#ReservedCodeCacheSize
export JAVA_RCCS_SIZE="${JAVA_RCCS_SIZE:-150M}"

[ "x${PRESTO_UUID}" = "x" ] && {
   export PRESTO_UUID=$(/usr/bin/uuidgen)
   [ $? -ne 0 ] &&  fatal "uuidgen failed"
}

[ "x${CATALOGS_URL}" = "x" ] && {
   fatal "CATALOGS_URL must be defined"
}

case "${PRESTO_SERVICE}" in
   "discovery")
       echo "Starting discovery server"
        export JAVA_MAXHEAP_SIZE="${JAVA_HEAP_SIZE:-1G}"
        export PRESTO_TASK_MAXMEMORY="${PRESTO_TASK_MAXMEMORY:-512M}"
        MARATHON_APPNAME="discovery"
        sleep 20;
       ;;
   "coordinator")
        echo "Starting coordinator"
        export JAVA_MAXHEAP_SIZE="${JAVA_HEAP_SIZE:-2G}"
        export PRESTO_TASK_MAXMEMORY="${PRESTO_TASK_MAXMEMORY:-1GB}"
        MARATHON_APPNAME="coordinator"
       ;;

   "worker")
        echo "Starting worker"
        export JAVA_MAXHEAP_SIZE="${JAVA_HEAP_SIZE:-2G}"
        export PRESTO_TASK_MAXMEMORY="${PRESTO_TASK_MAXMEMORY:-1GB}"
        MARATHON_APPNAME="worker"
       ;;
   *)
       fatal "Unknown service"
       ;; 
esac

if [ "${PRESTO_SERVICE}" = "discovery" ]
then
export PRESTO_DISCOVERY_URI=http://${HOST}:${PRESTO_HTTP_PORT}
else 
 echo curl -sSfLk -m 10 -H 'Accept: text/plain' ${MARATHON_URL}/v2/tasks __ egrep ^${MARATHON_APPGROUP}_meta_discovery
 export PRESTO_DISCOVERY_URI=`curl -sSfLk -m 10 -H 'Accept: text/plain' ${MARATHON_URL}/v2/tasks | egrep ^${MARATHON_APPGROUP}_meta_discovery | awk 'NF == 3 {printf("http://%s"), $NF}'`
 echo "DISCOVERY URI: ${PRESTO_DISCOVERY_URI}"
fi

echo "Fetching catalogs:"
wget -q -O - ${CATALOGS_URL} | tar xvfz - -C ${PRESTO_BASE}/installation/etc

/usr/local/bin/confd -onetime -backend env

./bin/launcher --config=${PRESTO_ROOTDIR}/etc/${PRESTO_SERVICE}.properties run
