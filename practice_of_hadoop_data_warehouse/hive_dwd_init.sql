drop database if exists dwd cascade;
create database dwd;
use dwd;


drop table if exists dwd.date_dim;
create table dwd.date_dim
(
    date_sk INT,
    `date` DATE,
    `month` INT,
    month_name VARCHAR(10),
    quarter TINYINT,
    `year` SMALLINT
)
row format delimited fields terminated by ','
stored as textfile;


drop table if exists dwd.customer_dim;
create table dwd.customer_dim
(
    customer_sk INT,
    customer_num INT,
    customer_name VARCHAR(50),
    customer_street_address VARCHAR(255),
    customer_zip_code INT,
    customer_city VARCHAR(20),
    customer_state VARCHAR(10),
    version INT,
    effective_date DATE,
    expiry_date DATE
)
clustered by (customer_sk) into 8 buckets
stored as orc tblproperties('transactional'='true');


drop table if exists dwd.order_dim;
create table dwd.order_dim
(
    order_sk INT,
    order_number INT,
    version INT,
    effective_date DATE,
    expiry_date DATE
)
clustered by (order_sk) into 8 buckets
stored as orc tblproperties('transactional'='true');


drop table if exists dwd.product_dim;
create table dwd.product_dim
(
    product_sk INT,
    product_code INT,
    product_name VARCHAR(50),
    product_category VARCHAR(50),
    version INT,
    effective_date DATE,
    expiry_date DATE
)
clustered by (product_sk) into 8 buckets
stored as orc tblproperties('transactional'='true');


drop table if exists dwd.sales_order_fact;
create table dwd.sales_order_fact
(
    order_sk INT,
    customer_sk INT,
    prudcut_sk INT,
    order_date_sk INT,
    order_amount DECIMAL
)
clustered by (order_sk) into 8 buckets
stored as orc tblproperties('transactional'='true');


drop table if exists dwd.cdc_time;
create table dwd.cdc_time(
    last_load date,
    curtent_load date
);

set hivevar:last_load = date_add(current_date(), -1);
insert overwrite table dwd.cdc_time
select
    ${hivevar:last_load}
    ,${hivevar:last_load}
;