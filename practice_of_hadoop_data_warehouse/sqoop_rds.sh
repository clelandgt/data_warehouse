sqoop import --connect jdbc:mysql://header:3306/source \
    --username root --password root@123 \
    --table date_dim \
    --hive-import \
    --hive-database dwd \
    --hive-table date_dim \
    --hive-overwrite


sqoop import --connect jdbc:mysql://header:3306/source \
    --username root --password root@123 \
    --table customer \
    --target-dir /user/hive/warehouse/rds.db/customer \
    --delete-target-dir \
    --fields-terminated-by "\001" 


sqoop import --connect jdbc:mysql://header:3306/source \
    --username root --password root@123 \
    --table product \
    --target-dir /user/hive/warehouse/rds.db/product \
    --delete-target-dir \
    --fields-terminated-by "\001" 


sqoop import --connect jdbc:mysql://header:3306/source \
    --username root --password root@123 \
    --table sales_order \
    --target-dir /user/hive/warehouse/rds.db/sales_order \
    --delete-target-dir \
    --fields-terminated-by "\001" 