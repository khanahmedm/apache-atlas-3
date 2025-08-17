FROM maven:3.8.6-openjdk-8

RUN apt-get update && \
    apt-get install -y build-essential python3 wget netcat && \
    rm -rf /var/lib/apt/lists/*

ENV ATLAS_VER=2.4.0
ENV MAVEN_OPTS="-Xms2g -Xmx2g"

WORKDIR /build
RUN wget https://archive.apache.org/dist/atlas/${ATLAS_VER}/apache-atlas-${ATLAS_VER}-sources.tar.gz \
    -O apache-atlas-${ATLAS_VER}-sources.tar.gz && \
    tar -xzf apache-atlas-${ATLAS_VER}-sources.tar.gz && \
    rm apache-atlas-${ATLAS_VER}-sources.tar.gz

# Build Apache Atlas from source.
# Ref: https://atlas.apache.org/#/BuildInstallation
WORKDIR /build/apache-atlas-sources-${ATLAS_VER}

#RUN mvn clean -DskipTests install
RUN mvn clean -DskipTests package -Pdist,embedded-hbase-solr

RUN test -f distro/target/apache-atlas-${ATLAS_VER}-server.tar.gz

RUN tar -xzf distro/target/apache-atlas-${ATLAS_VER}-server.tar.gz -C /opt

ENV ATLAS_HOME=/opt/apache-atlas-${ATLAS_VER}

WORKDIR ${ATLAS_HOME}

COPY ./config/atlas-application.properties ${ATLAS_HOME}/conf/atlas-application.properties
COPY ./scripts/start_atlas.sh ${ATLAS_HOME}/start_atlas.sh
RUN chmod +x ${ATLAS_HOME}/start_atlas.sh

ENTRYPOINT ["/opt/apache-atlas-2.4.0/start_atlas.sh"]
