
# Kafka Producer

Apache Kafka is publish-subscribe messaging rethought as a distributed commit
log. It is fast, scalable, durable and distributed by design.

    module.exports =
      use:
        kafka_broker: 'ryba/kafka/broker'
        hdf: 'ryba/hdf'
        hdp: 'ryba/hdp'
      configure: 'ryba/kafka/producer/configure'
      commands:
        install: [
          'ryba/kafka/producer/install'
          'ryba/kafka/producer/check'
        ]
        check:
          'ryba/kafka/producer/check'
