echo "

   drop table if exists dump1090_check;

   create temporary table dump1090_check
   (
   schema_name       varchar(20),
   table_name        varchar(20),
   row_count         integer,
   min_ts            timestamp,
   max_ts            timestamp
   );

   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_air',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_air;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_id',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_id;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_sta',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_sta;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_msg_1',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_msg_1;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_msg_2',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_msg_2;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_msg_3',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_msg_3;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_msg_4',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_msg_4;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_msg_5',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_msg_5;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_msg_6',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_msg_6;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_msg_7',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_msg_7;


   insert into dump1090_check
      select
         'dump1090_batch',  'dump1090_msg_8',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_batch.dump1090_msg_8;





   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_air',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_air;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_id',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_id;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_sta',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_sta;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_msg_1',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_msg_1;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_msg_2',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_msg_2;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_msg_3',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_msg_3;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_msg_4',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_msg_4;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_msg_5',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_msg_5;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_msg_6',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_msg_6;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_msg_7',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_msg_7;


   insert into dump1090_check
      select
         'dump1090_kafka',  'dump1090_msg_8',  count(*), min(msg_gen_ts), max(msg_gen_ts)
      from
          dump1090_kafka.dump1090_msg_8;



   select * from dump1090_check;


   " | vsql
   
