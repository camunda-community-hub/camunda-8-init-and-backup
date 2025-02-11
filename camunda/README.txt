This is a distribution of Camunda 8.6.8

How to run
==========

Prerequisites:
1. Download Elasticsearch 8.13.4 (from https://www.elastic.co/downloads/elasticsearch)
2. For non-production cases, disable Elasticsearch's security packages by adding the configuration "xpack.security.enabled: false" in $ELASTICSEARCH_HOME/config/elasticsearch.yml
3. Start Elasticsearch by running $ELASTICSEARCH_HOME/bin/elasticsearch (or $ELASTICSEARCH_HOME\bin\elasticsearch.bat on Windows)

Start Camunda:
1. Add the Elasticsearch exporter configuration in the configuration file config/application.yml

zeebe:
  broker:
    exporters:
      elasticsearch:
        className: io.camunda.zeebe.exporter.ElasticsearchExporter
        args:
          url: http://localhost:9200

2. Run bin/camunda (or bin\camunda.bat on Windows)
