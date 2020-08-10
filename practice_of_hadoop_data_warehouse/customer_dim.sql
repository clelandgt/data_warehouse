-- 设置变量以支持事务
set hive.support.cocurrency=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
set hive.compactor.initiator.on=true;
set hive.compactor.worker.threads=1;


set hivevar:cur_date = current_date();
set hivevar:pre_date = date_add(${hivevar:cur_date}, -1);
set hivevar:max_date = cast('9999-12-31' as date);

/**1. 更新需做拉链***/
-- SCD2
-- 先失效expiry_date
update dwd.customer_dim
    set expiry_date = ${hivevar:pre_date}
where customer_sk in (
    select
        cd.customer_sk
    from dwd.customer_dim as cd
    inner join rds.customer as cu on cu.customer_number=cd.customer_name
    where cd.expiry_date=${hivevar:max_date} and cd.customer_street_address<>cu.customer_street_address
);

-- 插入需做拉链的数据(考虑已拉链的数据，避免重复拉链)
insert into dwd.customer_dim
select
    row_number() over(order by base.customer_number) + sm.sk_max as customer_sk
    ,base.customer_number as coutomer_num
    ,base.customer_name
    ,base.customer_street_address
    ,base.customer_zip_code
    ,base.customer_city
    ,base.customer_state
    ,base.version + 1 as version
    ,${hivevar:cur_date} effective_date
    ,${hivevar:max_date} expiry_date
from(
    select 
        cu.*
        ,cd1.version
    from dwd.customer_dim as cd1
    inner join rds.customer as cu on cu.customer_number=cd1.coutomer_num and cd1.expiry_date=${hivevar:pre_date} 
    left join dwd.customer_dim as cd2 on cd2.coutomer_num=cd1.coutomer_num and cd2.expiry_date=${hivevar:max_date}
    where cd1.customer_street_address<>cu.customer_street_address and cd2.customer_sk is null
) as base
cross join (
    select
        coalesce(max(customer_sk), 0) sk_max
    from dwd.customer_dim
) as sm;

-- SCD1
drop table if exists dwd.tmp;
create table dwd.tmp
select 
    cd.customer_sk
    ,cd.customer_num
    ,cu.customer_name
    ,cd.customer_street_address
    ,cd.customer_zip_code
    ,cd.customer_city
    ,cd.customer_state
    ,cd.version
    ,cd.effective_date
    ,cd.expiry_date
from dwd.customer_dim as cd
inner join rds.customer as cu on cu.customer_number=cd.customer_num
where cd.customer_name!=cu.customer_name;
delete from dwd.customer_dim where customer_dim.customer_sk in (select customer_sk from tmp);
insert into dwd.customer_dim select * from tmp;


/**2. 插入***/
insert into dwd.customer_dim
select
    row_number() over(order by base.customer_number) + sm.sk_max as customer_sk
    ,base.customer_number as coutomer_num
    ,base.customer_name
    ,base.customer_street_address
    ,base.customer_zip_code
    ,base.customer_city
    ,base.customer_state
    ,1 as version
    ,${hivevar:cur_date} effective_date
    ,${hivevar:max_date} expiry_date
from (
    select
        cu.*
    from rds.customer as cu
    left join dwd.customer_dim as cd on cd.customer_num=cu.customer_name
    where cd.customer_num is null
) as base 
cross join (
    select
        coalesce(max(customer_sk), 0) sk_max
    from dwd.customer_dim
) as sm;



