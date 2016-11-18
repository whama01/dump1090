#!/bin/bash
#
# Name:
#   dump1090_writekafka_status
#
# Description:
#
# History:
#   1.0 14-Nov-2016 (mark.whalley@hpe.com)
#       Created from post-it note specification
#
#----------------------------------------------------------------------------


#
#----------------------------------------------------------------------------
h_prog_name=`basename ${0}`
h_prog_version=v1.0
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

   export PATH=/usr/bin:/bin:/opt/kafka_2.11-0.9.0.1/bin:/pi01/projects/kafkacat_build/kafkacat

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

   h_thisprog_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.thisprog.pid

   h_netcat_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.netcat.pid

   h_air_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.air.pid
   h_id_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.id.pid
   h_sta_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.sta.pid
   h_msg_1_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.msg_1.pid
   h_msg_2_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.msg_2.pid
   h_msg_3_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.msg_3.pid
   h_msg_4_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.msg_4.pid
   h_msg_5_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.msg_5.pid
   h_msg_6_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.msg_6.pid
   h_msg_8_pid_file=${h_pid_dir}/dump1090_readpipe_writekafka.sh.msg_8.pid


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



CHECKBACKGROUNDPROCESS()
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

   h_check_pid_background_ppid=`cat ${h_background_pid_file} | awk -F"\t" '{print $1}'`
   h_check_pid_background_pid=`cat ${h_background_pid_file} | awk -F"\t" '{print $2}'`

   MESSAGELOG "The recorded background process PID is: " ${h_check_pid_background_pid} "with a Parent PID of: " ${h_check_pid_background_ppid}

#----------------------------------------------------------------------------
# Now we have the recorded PID, is it actually running?
#----------------------------------------------------------------------------

   h_noof_processes=`ps --pid ${h_check_pid_background_pid} --no-headers | wc -l`

   if [ ${h_noof_processes} == 1 ]
   then

      MESSAGELOG "This background process PID seems to be running"

#----------------------------------------------------------------------------
# It may be running, but does it share the same PPID as the application
# or has it been orphaned and now belongs to PID 1 (in which case we need
# to kill this)
#----------------------------------------------------------------------------

      h_background_ppid=`ps -f --pid ${h_check_pid_background_pid} --no-headers | awk -F" " '{print $3}'`

      if [ ${h_background_ppid} == 1 ]
      then

         MESSAGELOG "Although this background process is running, it appears to have been orphaned"

      else

#----------------------------------------------------------------------------
# Add this background process PID to the list of running PIDs.
# This is in case not all of them are running and the remaining ones have
# to be killed
#----------------------------------------------------------------------------
         (( h_noof_background_processes_running += 1 ))

         ha_background_pid[${h_noof_background_processes_running}]=${h_check_pid_background_pid}

      fi

   else

      MESSAGELOG "This background process PID is not running"

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

   CHECKBACKGROUNDPROCESS "NETCAT" ${h_netcat_pid_file}

   CHECKBACKGROUNDPROCESS "AIR" ${h_air_pid_file} 

   CHECKBACKGROUNDPROCESS "ID" ${h_id_pid_file} 

   CHECKBACKGROUNDPROCESS "STA" ${h_sta_pid_file} 

   CHECKBACKGROUNDPROCESS "MSG_1" ${h_msg_1_pid_file} 

   CHECKBACKGROUNDPROCESS "MSG_2" ${h_msg_2_pid_file} 

   CHECKBACKGROUNDPROCESS "MSG_3" ${h_msg_3_pid_file} 

   CHECKBACKGROUNDPROCESS "MSG_4" ${h_msg_4_pid_file} 

   CHECKBACKGROUNDPROCESS "MSG_5" ${h_msg_5_pid_file} 

   CHECKBACKGROUNDPROCESS "MSG_6" ${h_msg_6_pid_file} 

   CHECKBACKGROUNDPROCESS "MSG_8" ${h_msg_8_pid_file}


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
         MESSAGELOG "It looks as though nothing is running"

         return 0

      fi
   fi



#----------------------------------------------------------------------------
# If everything is running (the application and all the background processes)
# do nothing more
#----------------------------------------------------------------------------
   if [ ${h_application_running} == "Y" ]
   then
      if [ ${h_noof_background_processes_running} == 11 ]
      then

         MESSAGELOG
         MESSAGELOG "Everything appears to be running"

         exit 0

      fi
   fi


#----------------------------------------------------------------------------
# If we have some, but not all of the background processes running
#----------------------------------------------------------------------------

   MESSAGELOG "There appear to be some bits running, but not everything"
   MESSAGELOG

   h_background_pid_idx=0

   while [ ${h_background_pid_idx} -lt ${h_noof_background_processes_running} ]
   do

      (( h_background_pid_idx += 1 ))

      MESSAGELOG "Running background PID: " ${ha_background_pid[${h_background_pid_idx}]}

   done


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

INITIALIZE

ISAPPLICATIONRUNNING

exit 0


#----------------------------------------------------------------------------
# End of script
#---------------------------------------------------------------------------
