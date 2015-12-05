FROM centos:centos6

MAINTAINER Clement Laforet <sheepkiller@cultdeadshee.org>
MAINTAINER Akshaya Shanbhogue <akshay.live@gmail.com>

RUN yum install -y wget unzip tar

ENV JAVA_UPDATE 65
ENV JAVA_BUILD  17

RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u${JAVA_UPDATE}-b${JAVA_BUILD}/jdk-8u${JAVA_UPDATE}-linux-x64.rpm" -O /opt/jdk-8u${JAVA_UPDATE}-linux-x64.rpm
RUN yum localinstall -y /opt/jdk-8u${JAVA_UPDATE}-linux-x64.rpm
RUN rm -f /opt/jdk-8u${JAVA_UPDATE}-linux-x64.rpm

ENV PRESTO_BASE /var/presto
ENV PRESTO_DATADIR ${PRESTO_BASE}/data
ENV PRESTO_ROOTDIR ${PRESTO_BASE}/installation

RUN mkdir -p ${PRESTO_BASE}/data ${PRESTO_BASE}/installation  ${PRESTO_BASE}/installation/etc/catalog /presto
WORKDIR /var/presto/installation

ENV CONFD_VERSION  0.7.1

RUN mkdir -p /usr/local/bin/ && \
    wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 &&\
    chmod +x /usr/local/bin/confd 

ENV PRESTO_VERSION 0.128
RUN cd /presto && \
    wget http://central.maven.org/maven2/com/facebook/presto/presto-server/${PRESTO_VERSION}/presto-server-${PRESTO_VERSION}.tar.gz && \
    tar zxvf presto-server-${PRESTO_VERSION}.tar.gz && \
    mv -v /presto/presto-server-${PRESTO_VERSION}/* ${PRESTO_BASE}/installation && \
     cd ${PRESTO_BASE}/installation/bin && \
    wget http://central.maven.org/maven2/com/facebook/presto/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar && \
    mv presto-cli-${PRESTO_VERSION}-executable.jar presto && chmod +x presto


ADD confd /etc/confd
ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

