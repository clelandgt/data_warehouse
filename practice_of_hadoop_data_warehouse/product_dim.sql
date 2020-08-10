-- 设置变量以支持事务
set hive.support.cocurrency=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
set hive.compactor.initiator.on=true;
set hive.compactor.worker.threads=1;


set hivevar:cur_date = current_date();
set hivevar:pre_date = date_add(${hivevar:cur_date}, -1);
set hivevar:max_date = cast('9999-12-31' as date);


/***1. 更新需做拉链***/
-- SCD2
-- 先失效expiry_date
update dwd.product_dim
    set expiry_date = ${hivevar:pre_date}
where product_sk in (
    select
        pd.product_sk
    from dwd.product_dim as pd
    inner join rds.product as pr on pr.product_code=pd.product_code
    where pd.expiry_date=${hivevar:max_date} and pd.product_name<>pr.product_name or pd.product_category<>pr.product_category
);

-- 插入需做拉链的数据(考虑已拉链的数据，避免重复拉链)
insert into dwd.product_dim
select
    row_number() over(order by base.product_code) + sm.sk_max as product_sk
    ,base.product_code
    ,base.product_name
    ,base.product_category
    ,base.version + 1 as version
    ,${hivevar:cur_date} effective_date
    ,${hivevar:max_date} expiry_date
from(
    select 
        pr.*
        ,pd1.version
    from dwd.product_dim as pd1
    inner join rds.product as pr on pr.product_code=pd1.product_code and pd1.expiry_date=${hivevar:pre_date} 
    left join dwd.product_dim as pd2 on pd2.product_code=pd1.product_code and pd1.expiry_date=${hivevar:max_date}
    where (pd1.product_name<>pr.product_name or pd1.product_category<>pr.product_category) and pd2.product_code is null
) as base
cross join (
    select
        coalesce(max(product_sk), 0) sk_max
    from dwd.product_dim
) as sm;


/***2. 插入***/
insert into dwd.product_dim
select
    row_number() over(order by base.product_code) + sm.sk_max as product_sk
    ,base.product_code
    ,base.product_name
    ,base.product_category
    ,1 as version
    ,${hivevar:cur_date} effective_date
    ,${hivevar:max_date} expiry_date
from (
    select
        pr.*
    from rds.product as pr
    left join dwd.product_dim as pd on pd.product_code=pr.product_code
    where pd.product_code is null
) as base 
cross join (
    select
        coalesce(max(product_sk), 0) sk_max
    from dwd.product_dim
) as sm;