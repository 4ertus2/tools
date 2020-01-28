CLICKHOUSE_CLIENT=$HOME/ch_run/clickhouse-client
CLIENT="$CLICKHOUSE_CLIENT --format_csv_delimiter=|"

DIR=$1

$CLIENT -q 'insert into tpch.PART format CSV'       < $DIR/part.tbl
$CLIENT -q 'insert into tpch.SUPPLIER format CSV'   < $DIR/supplier.tbl
$CLIENT -q 'insert into tpch.PARTSUPP format CSV'   < $DIR/partsupp.tbl
$CLIENT -q 'insert into tpch.CUSTOMER format CSV'   < $DIR/customer.tbl
$CLIENT -q 'insert into tpch.ORDERS format CSV'     < $DIR/orders.tbl
$CLIENT -q 'insert into tpch.LINEITEM format CSV'   < $DIR/lineitem.tbl
$CLIENT -q 'insert into tpch.NATION format CSV'     < $DIR/nation.tbl
$CLIENT -q 'insert into tpch.REGION format CSV'     < $DIR/region.tbl
