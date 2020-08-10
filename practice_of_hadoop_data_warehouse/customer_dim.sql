-- 设置变量以支持事务
set hive.support.cocurrency=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
set hive.compactor.initiator.on=true;
set hive.compactor.worker.threads=1;


set hivevar:cur_date = current_date();
set hivevar:pre_date = date_add(${hivevar:cur_date}, -1);
set hivevar:max_date = cast('9999-12-31' as date);


