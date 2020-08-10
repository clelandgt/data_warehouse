|数据源|源数据存储|数据仓库|抽取模式|维度历史装载类型|
|:--|:--|:--|:--|:--|:--|:--|
|customer|customer|customer_dim|整体、拉取|address列上scd2, name列上scd1|
|product|product|product_dim|整体、拉取|所有属性均为scd2|
|sales_order|sales_order|order_dim|cdc, 拉取|唯一订单号|
|sales_order|sales_order|sales_order_fact|cdc, 拉取|N/A|
|N/A|N/A|date_dim|N/A|预装载|