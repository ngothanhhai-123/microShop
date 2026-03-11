FROM eclipse-temurin:21-jdk-jammy

ARG TOMCAT_MAJOR=11
ARG TOMCAT_VERSION=11.0.12

ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=${CATALINA_HOME}/bin:${PATH}

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl ca-certificates tar gzip; \
    rm -rf /var/lib/apt/lists/*; \
    mkdir -p "${CATALINA_HOME}"; \
    curl -fSL "https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
      -o "/tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz"; \
    curl -fSL "https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512" \
      -o "/tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512"; \
    cd /tmp; \
    sha512sum -c "apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512"; \
    tar -xzf "apache-tomcat-${TOMCAT_VERSION}.tar.gz" -C "${CATALINA_HOME}" --strip-components=1; \
    rm -f "apache-tomcat-${TOMCAT_VERSION}.tar.gz" "apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512"; \
    rm -rf "${CATALINA_HOME}/webapps/docs" \
           "${CATALINA_HOME}/webapps/examples" \
           "${CATALINA_HOME}/webapps/host-manager" \
           "${CATALINA_HOME}/webapps/manager"; \
    groupadd -r tomcat; \
    useradd -r -g tomcat -d "${CATALINA_HOME}" -s /usr/sbin/nologin tomcat; \
    chown -R tomcat:tomcat "${CATALINA_HOME}"

USER tomcat
EXPOSE 8080
CMD ["catalina.sh", "run"]
