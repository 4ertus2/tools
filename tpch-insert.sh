CLICKHOUSE_CLIENT=$HOME/ch_run/clickhouse-client
CLIENT="$CLICKHOUSE_CLIENT --format_csv_delimiter=|"

DIR=$1

$CLIENT -q 'insert into tpch.part format CSV'       < $DIR/part.tbl
$CLIENT -q 'insert into tpch.supplier format CSV'   < $DIR/supplier.tbl
$CLIENT -q 'insert into tpch.partsupp format CSV'   < $DIR/partsupp.tbl
$CLIENT -q 'insert into tpch.customer format CSV'   < $DIR/customer.tbl
$CLIENT -q 'insert into tpch.orders format CSV'     < $DIR/orders.tbl
$CLIENT -q 'insert into tpch.lineitem format CSV'   < $DIR/lineitem.tbl
$CLIENT -q 'insert into tpch.nation format CSV'     < $DIR/nation.tbl
$CLIENT -q 'insert into tpch.region format CSV'     < $DIR/region.tbl
