set hivevar:cur_date = current_date();
set hivevar:pre_date = date_add(${hivevar:cur_date}, -1);
set hivevar:max_date = cast('9999-12-31' as date);


insert into dwd.sales_order_fact
    select 
        od.order_sk
        ,cd.customer_sk
        ,pd.product_sk
        ,dd.date_sk
        ,so.order_amount
    from rds.sales_order as so
    left join dwd.order_dim as od on od.order_number=so.order_number
    left join dwd.customer_dim as cd on cd.customer_num=so.customer_number
    left join dwd.product_dim as pd on pd.product_code=so.product_code
    left join dwd.date_dim as dd on dd.`date`=so.order_date
    cross join dwd.cdc_time as ct
    where (so.order_date>=od.effective_date and so.order_date<od.expiry_date)
        and (so.order_date>=cd.effective_date and so.order_date<cd.expiry_date)
        and (so.order_date>=pd.effective_date and so.order_date<pd.expiry_date)
        and (so.entry_date>=ct.last_load and so.entry_date<ct.current_load)
    
    