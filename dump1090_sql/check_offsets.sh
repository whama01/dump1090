echo "

   select max(end_offset) as max_end_offset,  source_name from dump1090Scheduler.stream_microbatch_history group by 2 order by 2;

   " | vsql
   
