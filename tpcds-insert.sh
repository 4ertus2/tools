CLICKHOUSE_CLIENT=$HOME/ch_run/clickhouse-client
CLIENT="$CLICKHOUSE_CLIENT --format_csv_delimiter=|"

DIR=$HOME/tpcds
SUFFIX=1_16

$CLIENT -q 'insert into tpcds.call_center format CSV'               < $DIR/call_center_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.catalog_page format CSV'              < $DIR/catalog_page_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.catalog_returns format CSV'           < $DIR/catalog_returns_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.catalog_sales format CSV'             < $DIR/catalog_sales_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.customer format CSV'                  < $DIR/customer_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.customer_address format CSV'          < $DIR/customer_address_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.customer_demographics format CSV'     < $DIR/customer_demographics_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.date_dim format CSV'                  < $DIR/date_dim_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.household_demographics format CSV'    < $DIR/household_demographics_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.income_band format CSV'               < $DIR/income_band_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.inventory format CSV'                 < $DIR/inventory_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.item format CSV'                      < $DIR/item_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.promotion format CSV'                 < $DIR/promotion_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.reason format CSV'                    < $DIR/reason_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.ship_mode format CSV'                 < $DIR/ship_mode_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.store format CSV'                     < $DIR/store_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.store_returns format CSV'             < $DIR/store_returns_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.store_sales format CSV'               < $DIR/store_sales_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.time_dim format CSV'                  < $DIR/time_dim_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.warehouse format CSV'                 < $DIR/warehouse_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.web_page format CSV'                  < $DIR/web_page_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.web_returns format CSV'               < $DIR/web_returns_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.web_sales format CSV'                 < $DIR/web_sales_$SUFFIX.dat
$CLIENT -q 'insert into tpcds.web_site format CSV'                  < $DIR/web_site_$SUFFIX.dat
