#!/bin/bash
#
# Name:
#   dump1090_readpipe_writekafka
#
# Description:
#   Part of the DUMP1090 application, this component manages the reading
#   of the TCP pipe (defaulting to port 30003) being written to by the
#   dump1090 ADS-B application, does some basic pre-processing of the
#   single stream of data, splitting it into its component ADS-B
#   messages (x10) before sending the streams into associative KAFKA
#   topics.
#
#   Scheduled to run as a crontab job, the script will check if the
#   various threads are running.  If all are present, it will leave them
#   in place.  If any have died, the application will attempt to kill off
#   and remaining threads before doiung a fresh restart.
#
# History:
#   1.0 14-Nov-2016 (mark.whalley@hpe.com)
#       Created from post-it note specification
#
#   1.1 12-Mar-2017 (mark.whalley@hpe.com)
#       Added MSG_7
#
#----------------------------------------------------------------------------


#
#----------------------------------------------------------------------------
h_prog_name=`basename ${0}`
h_prog_version=v1.1
#----------------------------------------------------------------------------
#



# ------------------------------------------------------------------------------
# Function: CHECKDEPENDENCY - Checks if tools are available (and on PATH)
# ------------------------------------------------------------------------------
function CHECKDEPENDENCY
{
   h_check_dependency=$1

   MESSAGELOG "Checking for the existence of" ${h_check_dependency}

   which ${h_check_dependency} 1>/dev/null 2>&1

   if [ $? != 0 ]
   then

      MESSAGELOG "FATAL ERROR: Unable to find" ${h_check_dependency}
      exit 1

   fi

   return 0
}
# -----------------------------------------------------------------------------
# End of Function: CHECKDEPENDENCY
# -----------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Function: CHECKFILEEXISTS - Create a file.  If it exists, remove it first.
# ------------------------------------------------------------------------------
function CHECKFILEEXISTS
{
   h_check_filename=$1

   MESSAGELOG "Checking for the existence of" ${h_check_filename}

   if [ ! -f "${h_check_filename}" ]
   then

      MESSAGELOG "FATAL ERROR: This files does not exist"
      exit 1

   fi

   return 0
}
# -----------------------------------------------------------------------------
# End of Function: CHECKFILEEXISTS
# -----------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Function: CREATEFILE - Create a file.  If it exists, remove it first.
# ------------------------------------------------------------------------------
function CREATEFILE
{
   h_create_filename=$1

   if [ -f "${h_create_filename}" ]
   then
      rm ${h_create_filename} 2> /dev/null

      CHECKCMD $? "Y" "attempting to remove ${h_create_filename}"
   fi

   touch ${h_create_filename}

   CHECKCMD $? "Y" "attempting to touch ${h_create_filename}"

   return 0
}
# -----------------------------------------------------------------------------
# End of Function: CREATEFILE
# -----------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Function: CREATEDIR - Create a directory (if it does not already exist).
# ------------------------------------------------------------------------------
function CREATEDIR
{
   h_create_dirname=$1

   MESSAGELOG "Checking the" ${h_create_dirname} "directory"

   if [ ! -d "${h_create_dirname}" ]
   then
      mkdir ${h_create_dirname} 2> /dev/null

      CHECKCMD $? "Y" "attempting to create the directory ${h_create_dirname}"

      MESSAGELOG "Creating the" ${h_create_dirname} "directory"
   else
      MESSAGELOG "The" ${h_create_dirname} "directory already existed"
   fi

   MESSAGELOG

   return 0
}
# -----------------------------------------------------------------------------
# End of Function: CREATEDIR
# -----------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Function: CHECKCMD - Check the return code of a command (passed as the 1st
#                      parameter).
#                      The 2nd parameter (Y or N) indicates whether any errors
#                      are deemed critical or not.
#                      Any remaining parameters provide a brief description of
#                      the error (which get reported to the message log).
# ------------------------------------------------------------------------------
function CHECKCMD
{
   h_return_code=$1
   shift

   h_critical=$1
   shift

   h_error_message=$*

   if [ "${h_return_code}" != 0 ]
   then
      MESSAGELOG "++ Failed to run command ++"
      MESSAGELOG $h_error_message

      if [ "$h_critical" = "Y" ]
      then
         printf "%s\n" "Failed to run command: $h_error_message"
         exit 1
      fi
   fi


   return 0
}
# -----------------------------------------------------------------------------
# End of Function: CHECKCMD
# -----------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Function: MESSAGELOG - Writes messages to the vlog file
# ------------------------------------------------------------------------------
function MESSAGELOG
{

# ----------------------------------------------------------------------------
#   Assign whatever has been passed as parameters to the h_message
#   variable.
# ----------------------------------------------------------------------------
   h_message=$*


# ----------------------------------------------------------------------------
#   Whatever 'message' has been passed as a parameter, write it to
#   the log file
# ----------------------------------------------------------------------------

   echo `date +"%d/%m/%Y %H:%M:%S"` "$h_message" >> $h_message_log

   if [ "${h_online}" == "Y" ]
   then
      echo `date +"%d/%m/%Y %H:%M:%S"` "$h_message"
   fi

   return 0
}
# ----------------------------------------------------------------------------
# End of Function: MESSAGELOG
# ----------------------------------------------------------------------------







#
#----------------------------------------------------------------------------
# Function:
#   INITIALIZE - set up local variables
#----------------------------------------------------------------------------
INITIALIZE()
{

   h_prog_path=`pwd`
   h_pid=$$

   export PATH=/usr/bin:/bin:/opt/kafka/bin:/usr/local/bin

   tty 1>/dev/null 2>&1

   if [ $? == 0 ]
   then
      h_online="Y"
   else
      h_online="N"
   fi

   


#----------------------------------------------------------------------------
# Although separate invocations of this application should write to their
# PID-specific files, the log file should be universal
#----------------------------------------------------------------------------
   h_message_log=/tmp/${h_prog_name}.log


#----------------------------------------------------------------------------
# Define the 1-liner files containing this PIDs of the background processes
# fired off by this application
#----------------------------------------------------------------------------
   h_pid_dir="/tmp"

   h_thisprog_pid_file=${h_pid_dir}/${h_prog_name}".thisprog.pid"

   h_netcat_pid_file=${h_pid_dir}/${h_prog_name}".netcat.pid"

   h_air_pid_file=${h_pid_dir}/${h_prog_name}".air.pid"
   h_id_pid_file=${h_pid_dir}/${h_prog_name}".id.pid"
   h_sta_pid_file=${h_pid_dir}/${h_prog_name}".sta.pid"
   h_msg_1_pid_file=${h_pid_dir}/${h_prog_name}".msg_1.pid"
   h_msg_2_pid_file=${h_pid_dir}/${h_prog_name}".msg_2.pid"
   h_msg_3_pid_file=${h_pid_dir}/${h_prog_name}".msg_3.pid"
   h_msg_4_pid_file=${h_pid_dir}/${h_prog_name}".msg_4.pid"
   h_msg_5_pid_file=${h_pid_dir}/${h_prog_name}".msg_5.pid"
   h_msg_6_pid_file=${h_pid_dir}/${h_prog_name}".msg_6.pid"
   h_msg_7_pid_file=${h_pid_dir}/${h_prog_name}".msg_7.pid"
   h_msg_8_pid_file=${h_pid_dir}/${h_prog_name}".msg_8.pid"


#----------------------------------------------------------------------------
# Define Kafka topics (these should already exist)
#----------------------------------------------------------------------------
   h_kafka_topic_dump1090_air="dump1090_air"
   h_kafka_topic_dump1090_id="dump1090_id"
   h_kafka_topic_dump1090_sta="dump1090_sta"
   h_kafka_topic_dump1090_msg_1="dump1090_msg_1"
   h_kafka_topic_dump1090_msg_2="dump1090_msg_2"
   h_kafka_topic_dump1090_msg_3="dump1090_msg_3"
   h_kafka_topic_dump1090_msg_4="dump1090_msg_4"
   h_kafka_topic_dump1090_msg_5="dump1090_msg_5"
   h_kafka_topic_dump1090_msg_6="dump1090_msg_6"
   h_kafka_topic_dump1090_msg_7="dump1090_msg_7"
   h_kafka_topic_dump1090_msg_8="dump1090_msg_8"


#----------------------------------------------------------------------------
# Define text files for individual ADS-B thread data
# NOTE: These are not technically required, as we are writing to the
#       Kafka topics.  Though we might as well write this data too!
#----------------------------------------------------------------------------
   h_file_dump1090_air=${h_clv_kafka_data_dir}"/dump1090_air.txt"
   h_file_dump1090_id=${h_clv_kafka_data_dir}"/dump1090_id.txt"
   h_file_dump1090_sta=${h_clv_kafka_data_dir}"/dump1090_sta.txt"
   h_file_dump1090_msg_1=${h_clv_kafka_data_dir}"/dump1090_msg_1.txt"
   h_file_dump1090_msg_2=${h_clv_kafka_data_dir}"/dump1090_msg_2.txt"
   h_file_dump1090_msg_3=${h_clv_kafka_data_dir}"/dump1090_msg_3.txt"
   h_file_dump1090_msg_4=${h_clv_kafka_data_dir}"/dump1090_msg_4.txt"
   h_file_dump1090_msg_5=${h_clv_kafka_data_dir}"/dump1090_msg_5.txt"
   h_file_dump1090_msg_6=${h_clv_kafka_data_dir}"/dump1090_msg_6.txt"
   h_file_dump1090_msg_7=${h_clv_kafka_data_dir}"/dump1090_msg_7.txt"
   h_file_dump1090_msg_8=${h_clv_kafka_data_dir}"/dump1090_msg_8.txt"

   h_file_dump1090=${h_clv_kafka_data_dir}"/dump1090.txt"

   return 0
}


RECORDRUN()
{

   MESSAGELOG
   MESSAGELOG "---------------------------------------------------------------------"
   MESSAGELOG "Program has been initiated"
   MESSAGELOG "---------------------------------------------------------------------"

   return 0
}



CHECKBACKGROUNDNETCATPROCESS()
{
#----------------------------------------------------------------------------
# Given a description and PID file, check the running status of the
# background proceesses
#----------------------------------------------------------------------------

   h_background_pid_name=$1
   h_background_pid_file=$2

   MESSAGELOG
   MESSAGELOG "Checking the status of" ${h_background_pid_name} "from the PID file" ${h_background_pid_file}

#----------------------------------------------------------------------------
# Look first for the PID file for this background process
#----------------------------------------------------------------------------
   if [ ! -f "${h_background_pid_file}" ]
   then
      MESSAGELOG "There appears to be no PID file (" ${h_background_pid_file} ") for this background process"

      return 0
   fi

   MESSAGELOG "The PID file (" ${h_background_pid_file} ") for this background process exists"

   h_check_pid_background_application_ppid=`cat ${h_background_pid_file} | awk -F"\t" '{print $1}'`
   h_check_pid_background_netcat_pid=`cat ${h_background_pid_file} | awk -F"\t" '{print $2}'`

   MESSAGELOG "The recorded background NETCAT process PID is: " ${h_check_pid_background_netcat_pid} "with a Parent PID of: " ${h_check_pid_background_application_ppid}

#----------------------------------------------------------------------------
# Now we have the recorded PIDs, are they actually running?
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# First check the NETCAT process....
#----------------------------------------------------------------------------
   h_noof_processes=`ps --pid ${h_check_pid_background_netcat_pid} --no-headers | wc -l`

   if [ ${h_noof_processes} == 1 ]
   then

      MESSAGELOG "This background NETCAT process PID seems to be running"

#----------------------------------------------------------------------------
# It may be running, but does it share the same PPID as the application
# or has it been orphaned and now belongs to PID 1 (in which case we need
# to kill this)
#----------------------------------------------------------------------------

      h_background_ppid=`ps -f --pid ${h_check_pid_background_netcat_pid} --no-headers | awk -F" " '{print $3}'`

      if [ ${h_background_ppid} == 1 ]
      then

         MESSAGELOG "Although this background process is running, it appears to have been orphaned"
         MESSAGELOG "This process will be killed."

         kill -9 ${h_check_pid_background_netcat_pid}

      else

#----------------------------------------------------------------------------
# Add this background process PID to the list of running PIDs.
# This is in case not all of them are running and the remaining ones have
# to be killed
#----------------------------------------------------------------------------
         (( h_noof_background_processes_running += 1 ))

         ha_background_pid[${h_noof_background_processes_running}]=${h_check_pid_background_netcat_pid}

      fi

   else

      MESSAGELOG "This background NETCAT process PID is not running"

   fi


   return 0
}


CHECKBACKGROUNDKAFKACATPROCESS()
{
#----------------------------------------------------------------------------
# Given a description and PID file, check the running status of the
# background proceesses
#----------------------------------------------------------------------------

   h_background_pid_name=$1
   h_background_pid_file=$2

   MESSAGELOG
   MESSAGELOG "Checking the status of" ${h_background_pid_name} "from the PID file" ${h_background_pid_file}

#----------------------------------------------------------------------------
# Look first for the PID file for this background process
#----------------------------------------------------------------------------
   if [ ! -f "${h_background_pid_file}" ]
   then
      MESSAGELOG "There appears to be no PID file (" ${h_background_pid_file} ") for this background process"

      return 0
   fi

   MESSAGELOG "The PID file (" ${h_background_pid_file} ") for this background process exists"

   h_check_pid_background_application_ppid=`cat ${h_background_pid_file} | awk -F"\t" '{print $1}'`
   h_check_pid_background_kafkacat_pid=`cat ${h_background_pid_file} | awk -F"\t" '{print $2}'`
   h_check_pid_background_tail_pid=`cat ${h_background_pid_file} | awk -F"\t" '{print $3}'`

   MESSAGELOG "The recorded background KAFKACAT and TAIL process PIDs are: " ${h_check_pid_background_kafkacat_pid} "and" ${h_check_pid_background_tail_pid} "with a Parent PID of: " ${h_check_pid_background_application_ppid}

#----------------------------------------------------------------------------
# Now we have the recorded PIDs, are they actually running?
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# First check the KAFKACAT process....
#----------------------------------------------------------------------------
   h_noof_processes=`ps --pid ${h_check_pid_background_kafkacat_pid} --no-headers | wc -l`

   if [ ${h_noof_processes} == 1 ]
   then

      MESSAGELOG "This background KAFKACAT process PID seems to be running"

#----------------------------------------------------------------------------
# It may be running, but does it share the same PPID as the application
# or has it been orphaned and now belongs to PID 1 (in which case we need
# to kill this)
#----------------------------------------------------------------------------

      h_background_ppid=`ps -f --pid ${h_check_pid_background_kafkacat_pid} --no-headers | awk -F" " '{print $3}'`

      if [ ${h_background_ppid} == 1 ]
      then

         MESSAGELOG "Although this background process is running, it appears to have been orphaned"
         MESSAGELOG "This process will be killed."

         kill -9 ${h_check_pid_background_kafkacat_pid}

      else

#----------------------------------------------------------------------------
# Add this background process PID to the list of running PIDs.
# This is in case not all of them are running and the remaining ones have
# to be killed
#----------------------------------------------------------------------------
         (( h_noof_background_processes_running += 1 ))

         ha_background_pid[${h_noof_background_processes_running}]=${h_check_pid_background_kafkacat_pid}

      fi

   else

      MESSAGELOG "This background KAFKACAT process PID is not running"

   fi


#----------------------------------------------------------------------------
# Then check the TAIL process....
#----------------------------------------------------------------------------
   h_noof_processes=`ps --pid ${h_check_pid_background_tail_pid} --no-headers | wc -l`

   if [ ${h_noof_processes} == 1 ]
   then

      MESSAGELOG "This background TAIL process PID seems to be running"

#----------------------------------------------------------------------------
# It may be running, but does it share the same PPID as the application
# or has it been orphaned and now belongs to PID 1 (in which case we need
# to kill this)
#----------------------------------------------------------------------------

      h_background_ppid=`ps -f --pid ${h_check_pid_background_tail_pid} --no-headers | awk -F" " '{print $3}'`

      if [ ${h_background_ppid} == 1 ]
      then

         MESSAGELOG "Although this background process is running, it appears to have been orphaned"
         MESSAGELOG "This process will be killed."

         kill -9 ${h_check_pid_background_tail_pid}

      else

#----------------------------------------------------------------------------
# Add this background process PID to the list of running PIDs.
# This is in case not all of them are running and the remaining ones have
# to be killed
#----------------------------------------------------------------------------
         (( h_noof_background_processes_running += 1 ))

         ha_background_pid[${h_noof_background_processes_running}]=${h_check_pid_background_tail_pid}

      fi

   else

      MESSAGELOG "This background TAIL process PID is not running"

   fi

   return 0
}

ISAPPLICATIONRUNNING()
{
#----------------------------------------------------------------------------
# We need to check if this application is already running.
# 
# If every component is alive and well, we will not start another run of
# this application, and will exit gracefully.
#----------------------------------------------------------------------------

   MESSAGELOG
   MESSAGELOG "Checking if any components of this application are currently running"
   MESSAGELOG

   h_application_running="N"
   h_background_processes_running="N"
   h_noof_background_processes_running=0

#----------------------------------------------------------------------------
# Look first for the primary PID file for this application (from which the
# many background processes may hand off)
#----------------------------------------------------------------------------
   if [ ! -f "${h_thisprog_pid_file}" ]
   then
      MESSAGELOG "There appears to be no PID file (" ${h_thisprog_pid_file} ") for this application"
      MESSAGELOG "It should be OK to start a new run"

      return 0
   fi

   MESSAGELOG "The PID file (" ${h_thisprog_pid_file} ") for this application exists"

   h_check_pid_thisprog=`cat ${h_thisprog_pid_file}`

   MESSAGELOG "The recorded PID is: " ${h_check_pid_thisprog}

#----------------------------------------------------------------------------
# Now we have the recorded PID, is it actually running?
#----------------------------------------------------------------------------

   h_noof_processes=`ps --pid ${h_check_pid_thisprog} --no-headers | wc -l`

   if [ ${h_noof_processes} == 1 ]
   then

      h_application_running="Y"

      MESSAGELOG "This application PID seems to be running"

   else

      MESSAGELOG "This application PID is not running"

   fi

    
#----------------------------------------------------------------------------
# Check the background processes for the application
#----------------------------------------------------------------------------

   CHECKBACKGROUNDNETCATPROCESS "NETCAT" ${h_netcat_pid_file}

   CHECKBACKGROUNDKAFKACATPROCESS "AIR" ${h_air_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "ID" ${h_id_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "STA" ${h_sta_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "MSG_1" ${h_msg_1_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "MSG_2" ${h_msg_2_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "MSG_3" ${h_msg_3_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "MSG_4" ${h_msg_4_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "MSG_5" ${h_msg_5_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "MSG_6" ${h_msg_6_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "MSG_7" ${h_msg_7_pid_file} 

   CHECKBACKGROUNDKAFKACATPROCESS "MSG_8" ${h_msg_8_pid_file}


   MESSAGELOG
   MESSAGELOG "Background process running:" ${h_noof_background_processes_running}

#----------------------------------------------------------------------------
# If nothing is running - start the application
#----------------------------------------------------------------------------
   if [ ${h_application_running} == "N" ]
   then
      if [ ${h_noof_background_processes_running} == 0 ]
      then

         MESSAGELOG
         MESSAGELOG "It looks as though nothing is running - OK to start new application"

         return 0

      fi
   fi



#----------------------------------------------------------------------------
# If everything is running (the application and all the background processes)
# do nothing more
#----------------------------------------------------------------------------
   if [ ${h_application_running} == "Y" ]
   then
      if [ ${h_noof_background_processes_running} == 21 ]
      then

         MESSAGELOG
         MESSAGELOG "Everything appears to be running - exiting"

         exit 0

      fi
   fi


#----------------------------------------------------------------------------
# If we have some, but not all of the background processes running, kill off
# those that are running, and start again
#----------------------------------------------------------------------------

   MESSAGELOG "There appear to be some bits running, but not everything"
   MESSAGELOG "We will now kill off those that are running so we can do a fresh application start"
   MESSAGELOG

   h_background_pid_idx=0

   while [ ${h_background_pid_idx} -lt ${h_noof_background_processes_running} ]
   do

      (( h_background_pid_idx += 1 ))

      MESSAGELOG "Killing off background PID: " ${ha_background_pid[${h_background_pid_idx}]}

      kill -9 ${ha_background_pid[${h_background_pid_idx}]}


   done


   MESSAGELOG "Killing off application PID: " ${h_check_pid_thisprog}

   kill -9 ${h_check_pid_thisprog}


#----------------------------------------------------------------------------
# Check if the non-background "nc" and "gawk" processes are running, and if
# so, kill them too
# (it's turning into a bit of a massacre)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Start with "nc"
#----------------------------------------------------------------------------

   MESSAGELOG "Checking on the main NC process"

   h_noof_processes=`ps -fae --no-headers | grep "nc ${h_clv_dump1090_server} ${h_clv_dump1090_nc_port}" | grep -v "grep" | wc -l`

   if [ ${h_noof_processes} == 1 ]
   then


      h_orphaned_nc_pid=`ps -fae --no-headers | grep "nc ${h_clv_dump1090_server} ${h_clv_dump1090_nc_port}" | grep -v "grep" | awk '{print $2}'`

      MESSAGELOG "This NC PID seems to be running"

      MESSAGELOG "Killing off PID: " ${h_orphaned_nc_pid}

      kill -9 ${h_orphaned_nc_pid}

   else

      MESSAGELOG "This NC PID is not running"

   fi

#----------------------------------------------------------------------------
# Then go on to "gawk"
#----------------------------------------------------------------------------

   MESSAGELOG "Checking on the main GAWK process"

   h_noof_processes=`ps -fae --no-headers | grep "gawk -v h_awk_dump1090_sitename" | grep -v "grep" | wc -l`

   if [ ${h_noof_processes} == 1 ]
   then

      h_orphaned_gawk_pid=`ps -fae --no-headers | grep "gawk -v h_awk_dump1090_sitename" | grep -v "grep" | awk '{print $2}'`

      MESSAGELOG "This GAWK PID seems to be running"

      MESSAGELOG "Killing off PID: " ${h_orphaned_gawk_pid}

      kill -9 ${h_orphaned_gawk_pid}

   else

      MESSAGELOG "This GAWK PID is not running"

   fi



#exit


   return 0
}

STARTNEWRUN()
{

   MESSAGELOG
   MESSAGELOG "Starting a new run of this application"
   MESSAGELOG

   printf "%s\n" ${h_pid} > ${h_thisprog_pid_file}

   MESSAGELOG "PID of this application (and PPID of subprocesses): " ${h_pid}
   MESSAGELOG


   return 0
}


TOUCHTEXTFILES()
{

   MESSAGELOG
   MESSAGELOG "Touching the individual text files"
   MESSAGELOG

   touch $h_file_dump1090_air
   touch $h_file_dump1090_id
   touch $h_file_dump1090_sta
   touch $h_file_dump1090_msg_1
   touch $h_file_dump1090_msg_2
   touch $h_file_dump1090_msg_3
   touch $h_file_dump1090_msg_4
   touch $h_file_dump1090_msg_5
   touch $h_file_dump1090_msg_6
   touch $h_file_dump1090_msg_7
   touch $h_file_dump1090_msg_8

   return 0
}


STARTNETCAT()
{

   MESSAGELOG
   MESSAGELOG "Starting netcat to capture all data from server: " ${h_clv_dump1090_server} " on port " ${h_clv_dump1090_nc_port} " into " ${h_file_dump1090}

   nc ${h_clv_dump1090_server} ${h_clv_dump1090_nc_port} >> ${h_file_dump1090} &
   sleep 2
   h_netcat_pid=$!
   printf "%s\t%s\n" ${h_pid} ${h_netcat_pid} > ${h_netcat_pid_file}

   MESSAGELOG "PID of netcat process: " ${h_netcat_pid}
   MESSAGELOG

   return 0
}


STARTKAFKACAT()
{
#----------------------------------------------------------------------------
# The READFROMNETCAT process will be writing to the various text files
# (one per thread).
#
# This process is intended to continuously tail -f these text files, writing
# what it finds to the individual Kafka topics.
#
# Each of these threads will be run as a background process, with their PIDs
# being stored in associated PID files.
#----------------------------------------------------------------------------

   MESSAGELOG
   MESSAGELOG "Starting the individual feeds into the Kafka topics on Kafka broker: " ${h_clv_kafka_broker} " on port " ${h_clv_kafka_port} " as a tail -f of the text files"
   MESSAGELOG

#----------------------------------------------------------------------------
# Kafka Topics: dump1090_air
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_air}

   tail -f ${h_file_dump1090_air}   | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_air}   -p 0 &
   sleep 2
   h_air_pid=$!
   h_air_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_air}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_air_pid} ${h_air_tail_pid} > ${h_air_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_air_pid} "and" ${h_air_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_id
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_id}

   tail -f ${h_file_dump1090_id}    | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_id}    -p 0 &
   sleep 2
   h_id_pid=$!
   h_id_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_id}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_id_pid} ${h_id_tail_pid} > ${h_id_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_id_pid} "and" ${h_id_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_sta
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_sta}

   tail -f ${h_file_dump1090_sta}   | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_sta}   -p 0 &
   sleep 2
   h_sta_pid=$!
   h_sta_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_sta}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_sta_pid} ${h_sta_tail_pid} > ${h_sta_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_sta_pid} "and" ${h_sta_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_msg_1
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_msg_1}

   tail -f ${h_file_dump1090_msg_1} | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_msg_1} -p 0 &
   sleep 2
   h_msg_1_pid=$!
   h_msg_1_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_msg_1}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_msg_1_pid} ${h_msg_1_tail_pid} > ${h_msg_1_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_msg_1_pid} "and" ${h_msg_1_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_msg_2
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_msg_2}

   tail -f ${h_file_dump1090_msg_2} | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_msg_2} -p 0 &
   sleep 2
   h_msg_2_pid=$!
   h_msg_2_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_msg_2}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_msg_2_pid} ${h_msg_2_tail_pid} > ${h_msg_2_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_msg_2_pid} "and" ${h_msg_2_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_msg_3
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_msg_3}

   tail -f ${h_file_dump1090_msg_3} | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_msg_3} -p 0 &
   sleep 2
   h_msg_3_pid=$!
   h_msg_3_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_msg_3}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_msg_3_pid} ${h_msg_3_tail_pid} > ${h_msg_3_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_msg_3_pid} "and" ${h_msg_3_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_msg_4
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_msg_4}

   tail -f ${h_file_dump1090_msg_4} | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_msg_4} -p 0 &
   sleep 2
   h_msg_4_pid=$!
   h_msg_4_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_msg_4}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_msg_4_pid} ${h_msg_4_tail_pid} > ${h_msg_4_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_msg_4_pid} "and" ${h_msg_4_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_msg_5
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_msg_5}

   tail -f ${h_file_dump1090_msg_5} | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_msg_5} -p 0 &
   sleep 2
   h_msg_5_pid=$!
   h_msg_5_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_msg_5}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_msg_5_pid} ${h_msg_5_tail_pid} > ${h_msg_5_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_msg_5_pid} "and" ${h_msg_5_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_msg_6
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_msg_6}

   tail -f ${h_file_dump1090_msg_6} | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_msg_6} -p 0 &
   sleep 2
   h_msg_6_pid=$!
   h_msg_6_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_msg_6}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_msg_6_pid} ${h_msg_6_tail_pid} > ${h_msg_6_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_msg_6_pid} "and" ${h_msg_6_tail_pid}



#----------------------------------------------------------------------------
# Kafka Topics: dump1090_msg_7
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_msg_7}

   tail -f ${h_file_dump1090_msg_7} | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_msg_7} -p 0 &
   sleep 2
   h_msg_7_pid=$!
   h_msg_7_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_msg_7}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_msg_7_pid} ${h_msg_7_tail_pid} > ${h_msg_7_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_msg_7_pid} "and" ${h_msg_7_tail_pid}


#----------------------------------------------------------------------------
# Kafka Topics: dump1090_msg_8
#----------------------------------------------------------------------------
   MESSAGELOG
   MESSAGELOG "Starting kafkacat for topic: " ${h_kafka_topic_dump1090_msg_8}

   tail -f ${h_file_dump1090_msg_8} | kafkacat -P -b ${h_clv_kafka_broker}:${h_clv_kafka_port} -t ${h_kafka_topic_dump1090_msg_8} -p 0 &
   sleep 2
   h_msg_8_pid=$!
   h_msg_8_tail_pid=`ps -f --ppid ${h_pid} | grep "tail -f ${h_file_dump1090_msg_8}" | awk -F" " '{print $2}'`

   printf "%s\t%s\t%s\n" ${h_pid} ${h_msg_8_pid} ${h_msg_8_tail_pid} > ${h_msg_8_pid_file}

   MESSAGELOG "PIDs of the above KAFKACAT and TAIL processes: " ${h_msg_8_pid} "and" ${h_msg_8_tail_pid}



   return 0
}

READFROMNETCAT()
{
#----------------------------------------------------------------------------
# The READFROMNETCAT process will continuously read the streaming data being
# fed into the TCP 30003 port, splitting the single ADS-B feed into the 
# individual record types (messages)
#----------------------------------------------------------------------------

   MESSAGELOG
   MESSAGELOG "Starting netcat to capture all data from server: " ${h_clv_dump1090_server} " on port " ${h_clv_dump1090_nc_port} " to feed into individual threads"
   MESSAGELOG
   MESSAGELOG

   nc ${h_clv_dump1090_server} ${h_clv_dump1090_nc_port} | gawk -v h_awk_dump1090_sitename=${h_clv_dump1090_sitename} -v h_awk_kafka_port=${h_clv_kafka_port} -v h_awk_file_dump1090_air=${h_file_dump1090_air} -v h_awk_file_dump1090_id=${h_file_dump1090_id} -v h_awk_file_dump1090_sta=${h_file_dump1090_sta} -v h_awk_file_dump1090_msg_1=${h_file_dump1090_msg_1} -v h_awk_file_dump1090_msg_2=${h_file_dump1090_msg_2} -v h_awk_file_dump1090_msg_3=${h_file_dump1090_msg_3} -v h_awk_file_dump1090_msg_4=${h_file_dump1090_msg_4} -v h_awk_file_dump1090_msg_5=${h_file_dump1090_msg_5} -v h_awk_file_dump1090_msg_6=${h_file_dump1090_msg_6} -v h_awk_file_dump1090_msg_7=${h_file_dump1090_msg_7} -v h_awk_file_dump1090_msg_8=${h_file_dump1090_msg_8} '{
   
   h_input_line=$0

    h_awk_input_line_noof_words = split( h_input_line, ha_input_line, "," )


    h_awk_index = index ( h_input_line, "MSG,8" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[22] "\n" )      >> h_awk_file_dump1090_msg_8
              close (h_awk_file_dump1090_msg_8)
              next
               }

    h_awk_index = index ( h_input_line, "MSG,7" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[12]","ha_input_line[22] "\n" )      >> h_awk_file_dump1090_msg_7
              close (h_awk_file_dump1090_msg_7)
              next
               }

    h_awk_index = index ( h_input_line, "MSG,6" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[12]","ha_input_line[18]","ha_input_line[19]","ha_input_line[20]","ha_input_line[21]","ha_input_line[22] "\n" )      >> h_awk_file_dump1090_msg_6
              close (h_awk_file_dump1090_msg_6)
              next
               }
   
    h_awk_index = index ( h_input_line, "MSG,5" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[12]","ha_input_line[19]","ha_input_line[21]","ha_input_line[22] "\n" )      >> h_awk_file_dump1090_msg_5
              close (h_awk_file_dump1090_msg_5)
              next
               }
   
    h_awk_index = index ( h_input_line, "MSG,4" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[13]","ha_input_line[14]","ha_input_line[17] "\n" )      >> h_awk_file_dump1090_msg_4
              close (h_awk_file_dump1090_msg_4)
              next
               }
   
    h_awk_index = index ( h_input_line, "MSG,3" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[12]","ha_input_line[15]","ha_input_line[16]","ha_input_line[19]","ha_input_line[20]","ha_input_line[21]","ha_input_line[22] "\n" )      >> h_awk_file_dump1090_msg_3
              close (h_awk_file_dump1090_msg_3)
              next
               }
   
    h_awk_index = index ( h_input_line, "MSG,2" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[12]","ha_input_line[13]","ha_input_line[14]","ha_input_line[15]","ha_input_line[16]","ha_input_line[22] "\n" )      >> h_awk_file_dump1090_msg_2
              close (h_awk_file_dump1090_msg_2)
              next
               }

    h_awk_index = index ( h_input_line, "MSG,1" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[11] "\n" )      >> h_awk_file_dump1090_msg_1
              close (h_awk_file_dump1090_msg_1)
              next
               }
   
    h_awk_index = index ( h_input_line, "ID" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[11] "\n" )      >> h_awk_file_dump1090_id
              close (h_awk_file_dump1090_id)
              next
               }
   
    h_awk_index = index ( h_input_line, "STA" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10]","ha_input_line[11] "\n" )      >> h_awk_file_dump1090_sta
              close (h_awk_file_dump1090_sta)
              next
               }
   
    h_awk_index = index ( h_input_line, "AIR" )
            if ( h_awk_index != 0 )
               {
              printf ( h_awk_dump1090_sitename","ha_input_line[1]","ha_input_line[2]","ha_input_line[3]","ha_input_line[4]","ha_input_line[5]","ha_input_line[6]","ha_input_line[7]" "ha_input_line[8]","ha_input_line[9]" "ha_input_line[10] "\n" )      >> h_awk_file_dump1090_air
              close (h_awk_file_dump1090_air)
              next
               }
   
   
   } ' 

#----------------------------------------------------------------------------
# We should never get here - unless something went wrong
#----------------------------------------------------------------------------
   return 0

}



# ------------------------------------------------------------------------------
# Function: USAGE - Display program usage
# ------------------------------------------------------------------------------
function USAGE()
{
   printf "%s\n" ""
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" ""
   printf "%s\n" "Usage:"
   printf "%s\n" "  $h_prog_name"

   printf "%s\n" "   --sitename            {A unique name assigned to the DUMP1090 site location}"
   printf "%s\n" ""
   printf "%s\n" "   --kafka_broker        {Kafka broker IP address}"
   printf "%s\n" "   --kafka_port          {Kafka port number}"
   printf "%s\n" "   --kafka_data_dir      {Directory on Kafka server to receive parsed data files}"
   printf "%s\n" ""
   printf "%s\n" "   --dump1090_server     {IP address of DUMP1090 server}"
   printf "%s\n" "   --dump1090_nc_port    {netcat port number of DUMP1090 server}"
   printf "%s\n" ""
   printf "%s\n" "   --help|-h             Displays this screen"
   printf "%s\n" ""
   printf "%s\n" "  $h_prog_name --help"

   printf "%s\n" ""
   printf "%s\n" "$h_prog_name - Version: $h_prog_version"
   printf "%s\n" ""
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" ""

   return 0
}





#----------------------------------------------------------------------------
# main program
#----------------------------------------------------------------------------

while [ -n "$1" ]
do
   case "$1" in
       --sitename)
          h_clv_dump1090_sitename=$2
          shift;shift
          ;;


       --kafka_broker)
          h_clv_kafka_broker=$2
          shift;shift
          ;;

       --kafka_port)
          h_clv_kafka_port=$2
          shift;shift
          ;;

       --kafka_data_dir)
          h_clv_kafka_data_dir=$2
          shift;shift
          ;;


       --dump1090_server)
          h_clv_dump1090_server=$2
          shift;shift
          ;;

       --dump1090_nc_port)
          h_clv_dump1090_nc_port=$2
          shift;shift
          ;;

       *)
          printf "%s\n" ""
          printf "%s\n" "---------------------------------------------------------------------------------------------"
          printf "%s\n" "FATAL ERROR: Invalid parameters: $1 (in set of paramaters $*)"
          printf "%s\n" "---------------------------------------------------------------------------------------------"
          printf "%s\n" ""
          USAGE
          exit 1
          ;;

   esac
done

if [ -z "${h_clv_dump1090_sitename}" ]
then
   printf "%s\n" ""
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" "FATAL ERROR: The site name has not been specified"
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" ""
   USAGE
   exit 1
fi

if [ -z "${h_clv_kafka_broker}" ]
then
   printf "%s\n" ""
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" "FATAL ERROR: The Kafka broker address has not been specified"
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" ""
   USAGE
   exit 1
fi

if [ -z "${h_clv_kafka_port}" ]
then
   printf "%s\n" ""
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" "FATAL ERROR: The Kafka port number has not been specified"
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" ""
   USAGE
   exit 1
fi

if [ -z "${h_clv_kafka_data_dir}" ]
then
   printf "%s\n" ""
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" "FATAL ERROR: The Kafka data directory has not been specified"
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" ""
   USAGE
   exit 1
fi

if [ -z "${h_clv_dump1090_server}" ]
then
   printf "%s\n" ""
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" "FATAL ERROR: The DUMP1090 server address has not been specified"
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" ""
   USAGE
   exit 1
fi


if [ -z "${h_clv_dump1090_nc_port}" ]
then
   printf "%s\n" ""
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" "FATAL ERROR: The DUMP1090 TCP netcat port has not been specified"
   printf "%s\n" "---------------------------------------------------------------------------------------------"
   printf "%s\n" ""
   USAGE
   exit 1
fi



INITIALIZE

RECORDRUN

ISAPPLICATIONRUNNING

STARTNEWRUN

TOUCHTEXTFILES

STARTNETCAT

STARTKAFKACAT

READFROMNETCAT


exit 0


#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
