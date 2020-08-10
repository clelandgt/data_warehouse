set hivevar:cur_date = current_date();
set hivevar:pre_date = date_add(${hivevar:cur_date}, -1);
set hivevar:max_date = cast('9999-12-31' as date);


-- 插入
insert into dwd.order_dim
select
    row_number() over(order by base.order_number) + sm.sk_max as order_sk
    ,base.order_number
    ,1 as version
    ,${hivevar:cur_date} effective_date
    ,${hivevar:max_date} expiry_date
from (
    select
        so.*
    from rds.sales_order as so
    left join dwd.order_dim as od on od.order_number=so.order_number
    where od.order_number is null
) as base 
cross join (
    select
        coalesce(max(order_sk), 0) sk_max
    from dwd.order_dim
) as sm;
