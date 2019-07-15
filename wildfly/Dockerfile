FROM jboss/wildfly:17.0.0.Final

RUN /opt/jboss/wildfly/bin/add-user.sh admin-user test.12345 --silent

# Configure JSON logging
ADD standalone.xml /opt/jboss/wildfly/standalone/configuration/standalone-docker.xml
ADD logging.properties /opt/jboss/wildfly/standalone/configuration/logging.properties

ENV DOCKERIZE_VERSION v0.6.1
RUN curl -O -L https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

CMD ./dockerize -wait tcp://fluentd:24224 -wait tcp://elasticsearch:9200 -timeout 120s \
    && /opt/jboss/wildfly/bin/standalone.sh -c standalone-docker.xml -b 0.0.0.0 -bmanagement 0.0.0.0