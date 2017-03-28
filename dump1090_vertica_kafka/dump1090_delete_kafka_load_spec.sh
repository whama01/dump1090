#!/bin/bash
#
# Name:
#   dump100_create_kafka_load_spec
#
# Description:
#
#----------------------------------------------------------------------------
# Create the load_specs
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin

${h_vertica_kafka_bin_dir}/vkconfig load-spec --delete  --dbhost localhost --dbport 5433 --username dbadmin --password '' --config-schema dump1090Scheduler --load-spec dump1090_load_spec

#filters                 no       1        A complete Vertica FILTER chain containing all UDFilters for a Microbatch.
#parser                  no       1        Parser used during Vertica Microbatch execution. Default is 'KafkaParser'.
#parser-parameters       no       1        A comma-separated list of key=value pairs to be given as parameters to the parser.
#message-max-bytes       no       1        Maximum size in bytes for a single message. Any message larger may be dropped. Default is 1MiB (1048576).
#uds-kv-parameters       no       1        A comma-separated list of key=value pairs to be given to the KafkaSource for configuration purposes.  See https://my.vertica.com/documentation/vertica/ documentation for more information.




exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
