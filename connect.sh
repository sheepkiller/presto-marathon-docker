export PRESTO_VERSION=0.129
export MARATHON_URL=<marathon-url>
export MARATHON_APPGROUP=presto

if [ ! -f presto ]; then
	wget http://central.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar
	mv presto-cli-${PRESTO_VERSION}-executable.jar presto
	chmod +x presto
fi

./presto --server $(curl -sSfLk -m 10 -H 'Accept: text/plain' ${MARATHON_URL}/v2/tasks | egrep ^${MARATHON_APPGROUP}_meta_coordinator | awk 'NF == 3 {printf("http://%s"), $NF}')
