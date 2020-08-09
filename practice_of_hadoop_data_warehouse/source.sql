/* SQLEditor (MySQL (2))*/
CREATE TABLE customer
(
customer_number INT NOT NULL AUTO_INCREMENT,
customer_name VARCHAR(20),
customer_street_address VARCHAR(255),
customer_zip_code INT,
customer_city VARCHAR(20),
customer_state VARCHAR(10),
PRIMARY KEY (customer_number)
);

CREATE TABLE product
(
product_code INT NOT NULL AUTO_INCREMENT,
product_name VARCHAR(50),
product_category VARCHAR(50),
PRIMARY KEY (product_code)
);

CREATE TABLE sales_order
(
order_number INTEGER NOT NULL AUTO_INCREMENT,
customer_number INT,
product_code INT,
order_date DATETIME,
entry_date DATETIME,
order_amount DECIMAL,
PRIMARY KEY (order_number)
);

ALTER TABLE sales_order ADD FOREIGN KEY customer_number_idxfk (customer_number) REFERENCES customer (customer_number);
ALTER TABLE sales_order ADD FOREIGN KEY product_code_idxfk (product_code) REFERENCES product (product_code);

-- 日期维度表
CREATE TABLE `date_dim` (
  `date_sk` int(11) not NULL AUTO_INCREMENT,
  `date` date DEFAULT NULL,
  `month` int(11) DEFAULT NULL,
  `month_name` varchar(10) DEFAULT NULL,
  `quarter` tinyint(4) DEFAULT NULL,
  `year` smallint(6) DEFAULT NULL,
  UNIQUE KEY `date_sk` (`date_sk`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 测试数据
use source;
-- 客户表测试数据
insert into `customer`
(`customer_name`, `customer_street_address`, `customer_zip_code`, `customer_city`, `customer_state`)
values
('really large customers', '7500 louise dr.', 17050, 'mechanicsburg', 'pa'),
('small stores', '2500 woodland st.', 17055, 'pittsburgh', 'pa'),
('medium retailers', '1111 ritter rd.', 17055, 'pittsburgh', 'pa'),
('good companies', '9500 scott st.', 17050, 'mechanicsburg', 'pa'),
('wonderful', '3333 rossmoyne rd.', 17050, 'mechanicsburg', 'pa'),
('loyal clients', '7070 ritter rd.', 17055, 'pittsburgh', 'pa'),
('distinguished partners', '9999 scott st.', 17050, 'mechanicsburg', 'pa');


-- 生成产品表测试数据
insert into `product`
(product_name, product_category)
values
('hard disk drive', 'storage'),
('floppy drive', 'storage'),
('lcd panel', 'monitor');


-- 生成100条销售订单表测试数据
drop procedure if exists generate_sale_order_data;
delimiter //
    create procedure generate_sale_order_data()
begin 
    drop table if exists temp_sales_order_data;
    create table temp_sales_order_data as select * from sales_order where 1=0;
    
    set @start_date := unix_timestamp('2016-03-01');
    set @end_date := unix_timestamp('2016-07-01');
    set @i := 1;
    
    while @i<=100 do
        set @customer_number := floor(1 + rand() * 6);
        set @product_code := floor(1 + rand() * 2);
        set @order_date := from_unixtime(@start_date + rand() * (@end_date - @start_date));
        set @amount := floor(1000 + rand() * 9000);
        
        insert into temp_sales_order_data values (@i, @customer_number, @product_code, @order_date, @order_date, @amount);
        set @i:=@i+1;
    end while;
    
    truncate table `sales_order`;
    insert into `sales_order` select null, `customer_number`, `product_code`, `order_date`, `entry_date`, `order_amount` from temp_sales_order_data order by order_date;
    commit;
end
//
delimiter ;
call generate_sale_order_data(); 



-- 日期维度表
delimiter //
drop procedure if exists pre_populate_date //
create procedure pre_populate_date (in start_dt date, in end_dt date)
begin 
    while start_dt <= end_dt do
        insert into date_dim(`date_sk`, `date`, `month`, `month_name`, `quarter`, `year`)
        values 
            (null, start_dt, month(start_dt), monthname(start_dt), quarter(start_dt), year(start_dt));
        set start_dt = adddate(start_dt, 1);
    end while;
    commit;
    end
//

delimiter ;
-- 生成日期维度数据
set foreign_key_checks=0;
truncate table date_dim;
call pre_populate_date('2000-01-01', '2020-12-31');
set foreign_key_checks=1;

    