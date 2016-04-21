FROM centos:7

MAINTAINER Clement Laforet <sheepkiller@cultdeadshee.org>

RUN yum update -y && \
    yum install -y git wget unzip tar && \
    yum clean all


ENV JAVA_MAJOR=8 \
    JAVA_UPDATE=92 \
    JAVA_BUILD=14

RUN wget -nv --no-cookies --no-check-certificate \
    --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    "http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR}u${JAVA_UPDATE}-b${JAVA_BUILD}/jre-${JAVA_MAJOR}u${JAVA_UPDATE}-linux-x64.rpm" -O /tmp/jre-${JAVA_MAJOR}u${JAVA_UPDATE}-linux-x64.rpm && \
     yum localinstall -y /tmp/jre-${JAVA_MAJOR}u${JAVA_UPDATE}-linux-x64.rpm && \
     rm -f /tmp/jre-${JAVA_MAJOR}u${JAVA_UPDATE}-linux-x64.rpm

ENV JAVA_HOME=/usr/java/jre1.8.0_${JAVA_UPDATE} \
    PRESTO_BASE=/var/presto \
    PRESTO_DATADIR=${PRESTO_BASE}/data \
    PRESTO_ROOTDIR=${PRESTO_BASE}/installation

RUN mkdir -p ${PRESTO_BASE}/data ${PRESTO_BASE}/installation ${PRESTO_BASE}/installation/etc/catalog
WORKDIR /var/presto/installation

ENV CONFD_VERSION  0.11.0

RUN mkdir -p /usr/local/bin/ && \
    wget -nv -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 &&\
    chmod +x /usr/local/bin/confd

ENV PRESTO_VERSION 0.144.2
RUN mkdir /presto && \
    cd /presto && \
    wget -nv http://central.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz && \
    tar zxvf presto-server-${PRESTO_VERSION}.tar.gz && \
    mv -v /presto/presto-server-${PRESTO_VERSION}/* ${PRESTO_BASE}/installation && \
    cd ${PRESTO_BASE}/installation/bin && \
    wget -nv -O presto http://central.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar && \
    chmod +x presto && \
    rm -fr /presto


ADD confd /etc/confd
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
