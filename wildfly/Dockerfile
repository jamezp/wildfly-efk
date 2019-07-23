FROM jboss/wildfly:17.0.1.Final

RUN /opt/jboss/wildfly/bin/add-user.sh admin-user test.12345 --silent

# Configure JSON logging
ADD logging.properties /opt/jboss/wildfly/standalone/configuration/logging.properties
ADD setup.cli /opt/jboss/setup.cli
RUN /opt/jboss/wildfly/bin/jboss-cli.sh --file=/opt/jboss/setup.cli

ENV DOCKERIZE_VERSION v0.6.1
RUN curl -O -L https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

CMD ./dockerize -wait tcp://fluentd:24224 -wait tcp://elasticsearch:9200 -timeout 120s \
    && /opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0
