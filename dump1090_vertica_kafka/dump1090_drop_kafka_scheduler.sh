
#!/bin/bash
#
# Name:
#   dump100_drop_kafka_scheduler.sh
#
# Description:
#   Drop the kafaka scheduler (so i can start again)
#----------------------------------------------------------------------------

h_vertica_dist=/opt/vertica
h_vertica_kafka_bin_dir=${h_vertica_dist}/packages/kafka/bin


${h_vertica_kafka_bin_dir}/vkconfig scheduler --drop --config-schema dump1090Scheduler


exit 0

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
