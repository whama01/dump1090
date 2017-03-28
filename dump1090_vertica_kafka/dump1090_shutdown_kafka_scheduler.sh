
#!/bin/bash
#
# Name:
#   dump100_shutdown_kafka_scheduler.sh
#
# Description:
#   Shuts down all Kafka schedulers
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin


${h_vertica_kafka_bin_dir}/vkconfig shutdown


exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
