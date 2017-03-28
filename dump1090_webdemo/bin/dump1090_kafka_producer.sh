#!/bin/bash
#
#----------------------------------------------------------------------------
#
# Name:
#   dump1090_kafka_producer.sh
#
# Description:
#   This script is part of the DUMP1090 demo application.
#
#   The purpose of this script is to control the starting and stopping of
#   feeding data into a KAFKA topic.
#
#   Although the individual components that make up the DUMP1090 demo can be
#   manually run, you are strongly advised not to.
#
# History:
#   1.0 14-Sep-2015 (mark.whalley@actian.com)
#       Created from a Post-It note definition
#
#
#----------------------------------------------------------------------------
h_prog_name=`basename ${0}`
h_prog_version=v1.0
#----------------------------------------------------------------------------

INITIALIZE()
{

   MESSAGELOG "Initiated"

   h_control_dir="./control"

   if [ ! -d $h_control_dir ]
   then
      h_error_message="Unable to locate the $h_control_dir directory"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      exit 1
   fi

   h_kafka_producer_pid_file=$h_control_dir"/dump1090_kafka_producer_pid"


   return 0

}

function MESSAGELOG
{
   h_message=$*

   h_reported_message=`date +"%d/%m/%Y %H:%M:%S"`
   h_reported_message=$h_reported_message" - ""$h_prog_name"" - ""$h_message"

   echo $h_reported_message >> $h_logfile

   if [ "$h_clv_verbose" = "Y" ]
   then
      echo $h_reported_message
   fi

   return 0
}




START_KAFKA()
{
#----------------------------------------------------------------------------
# First check to see if the KAFKA producer is already running
# TBC
#----------------------------------------------------------------------------

   if [ -f $h_kafka_producer_pid_file ]
   then
      h_kafka_producer_pid=`cat $h_kafka_producer_pid_file`

      if [ ! -z "$h_kafka_producer_pid" ]
      then
         h_pid_command=`ps --no-headers -p $h_kafka_producer_pid`

         if [ ! -z "$h_pid_command" ]
         then

            MESSAGELOG "It looks as though the KAFKA producer is already running on PID" $h_kafka_producer_pid

            return 0

         else

            MESSAGELOG "Although there is a PID of $h_kafka_producer_pid, it does not appear to be running"

         fi

      fi

   fi



   nohup sh -c "nc $h_clv_rpi_ip $h_clv_rpi_port | kafkacat -P -b $h_clv_kafka_broker_ip:$h_clv_kafka_broker_port -t $h_clv_kafka_topic -p 0" 1>>$h_logfile 2>&1 &

   h_kafka_produce_pid=$!

   MESSAGELOG "Started a new KAFKA producer on PID: " $h_kafka_produce_pid

   echo $h_kafka_produce_pid > $h_kafka_producer_pid_file


   return 0

}


PRINT_USAGE()
{
    printf "%s\n" "Usage:"
    printf "%s\n" "  $h_prog_name"

    printf "%s\n" "   action             {start|stop}"
    printf "%s\n" "   logfile            {DUMP1090 log file}"
    printf "%s\n" "   kafka_broker_ip    {DNS or IP address of KAFKA broker}"
    printf "%s\n" "   kafka_broker_port  {Port of KAFKA broker}"
    printf "%s\n" "   kafka_topic        {Topic of KAFKA broker}"
    printf "%s\n" "   verbose            {Y|N}"

}





#----------------------------------------------------------------------------
# main program
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Process Command Line Variables (clv)
#----------------------------------------------------------------------------

while [ -n "$1" ]
do
   case "$1" in

   --action)
      shift
      h_clv_action=$1
      ;;

   --logfile)
      shift
      h_logfile=$1
      ;;

   --kafka_broker_ip)
      shift
      h_clv_kafka_broker_ip=$1
      ;;

   --kafka_broker_port)
      shift
      h_clv_kafka_broker_port=$1
      ;;


   --kafka_topic)
      shift
      h_clv_kafka_topic=$1
      ;;

   --rpi_ip)
      shift
      h_clv_rpi_ip=$1
      ;;

   --rpi_port)
      shift
      h_clv_rpi_port=$1
      ;;

   --verbose)
      shift
      h_clv_verbose=$1
      ;;

    *)
       printf "%s\n" "Invalid parameter: $1"
       PRINT_USAGE
       exit 1
       ;;

   esac

   shift

done

#----------------------------------------------------------------------------
# Validate CLV
#----------------------------------------------------------------------------

   if [ -z "$h_clv_action" ]
   then
      printf "%s\n" "Action not defined"
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_logfile" ]
   then
      printf "%s\n" "Log file not defined"
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_kafka_broker_ip" ]
   then
      h_error_message="KAFKA broker IP address not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_kafka_broker_port" ]
   then
      h_error_message="KAFKA broker port not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_kafka_topic" ]
   then
      h_error_message="KAFKA topic not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_rpi_ip" ]
   then
      h_error_message="Raspberry Pi IP or DNS not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_rpi_port" ]
   then
      h_error_message="Raspberry Pi port not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

   if [ -z "$h_clv_verbose" ]
   then
      h_error_message="Verbose flag not defined"
      MESSAGELOG $h_error_message
      printf "%s\n" $h_error_message
      PRINT_USAGE
      exit 1
   fi

#----------------------------------------------------------------------------
# OK, lets do stuff
#----------------------------------------------------------------------------

INITIALIZE

case $h_clv_action in

  "start")  
      START_KAFKA
      ;;

  "stop")  
      STOP_KAFKA
      ;;

esac

#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
