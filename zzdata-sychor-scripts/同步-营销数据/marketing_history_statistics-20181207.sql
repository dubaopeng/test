SET mapred.job.name='b_marketing_statistics_base-营销历史统计作业';
--set hive.execution.engine=mr;
set hive.tez.container.size=6144;
set hive.cbo.enable=true;
SET hive.exec.compress.output=true;
SET mapred.max.split.size=512000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
SET mapred.output.compression.type=BLOCK;
SET mapreduce.map.output.compress=true;
SET mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.exec.dynamic.partition=true;
SET mapreduce.reduce.shuffle.input.buffer.percent =0.6;
SET hive.exec.max.created.files=655350;
SET hive.exec.max.dynamic.partitions=10000000;
SET hive.exec.max.dynamic.partitions.pernode=10000000;
set hive.stats.autogather=false;
set hive.merge.mapfiles = true;
set hive.merge.mapredfiles=true;
set hive.merge.size.per.task = 512000000;
set hive.support.concurrency=false;

-- 1、创建互动统计结果存储表，设置统计分区（按租户分区）
CREATE TABLE IF NOT EXISTS dw_base.`b_marketing_statistics_base`(
	`tenant` string,
    `uni_id` string,
    `total_num` int,
	`last_time` string
)
partitioned by(`part` string)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\001' lines terminated by '\n'
STORED AS ORC tblproperties ("orc.compress" = "SNAPPY");


-- 2、直接对互动记录进行近90天的数据统计，插入统计基础表中
insert into table dw_base.`b_marketing_statistics_base` partition(part)
select t.tenant,t.uni_id,count(t.uni_id) totalnum,max(t.marketing_time) as lasttime,t.tenant as part 
from dw_base.`b_marketing_history` t
where t.day > date_sub('${stat_date}',${daynum}) 
group by t.tenant,t.uni_id;




