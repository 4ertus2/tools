CREATE DATABASE IF NOT EXISTS tpcds;
USE tpcds;

DROP TABLE IF NOT EXISTS call_center;
DROP TABLE IF NOT EXISTS catalog_page;
DROP TABLE IF NOT EXISTS catalog_returns;
DROP TABLE IF NOT EXISTS catalog_sales;
DROP TABLE IF NOT EXISTS customer_address;
DROP TABLE IF NOT EXISTS customer_demographics;
DROP TABLE IF NOT EXISTS customer;
DROP TABLE IF NOT EXISTS date_dim;
DROP TABLE IF NOT EXISTS household_demographics;
DROP TABLE IF NOT EXISTS income_band;
DROP TABLE IF NOT EXISTS inventory;
DROP TABLE IF NOT EXISTS item;
DROP TABLE IF NOT EXISTS promotion;
DROP TABLE IF NOT EXISTS reason;
DROP TABLE IF NOT EXISTS ship_mode;
DROP TABLE IF NOT EXISTS store_returns;
DROP TABLE IF NOT EXISTS store_sales;
DROP TABLE IF NOT EXISTS store;
DROP TABLE IF NOT EXISTS time_dim;
DROP TABLE IF NOT EXISTS warehouse;
DROP TABLE IF NOT EXISTS web_page;
DROP TABLE IF NOT EXISTS web_returns;
DROP TABLE IF NOT EXISTS web_sales;
DROP TABLE IF NOT EXISTS web_site;

CREATE TABLE call_center
(
    cc_call_center_sk         Int64,
    cc_call_center_id         String,
    cc_rec_start_date         String,
    cc_rec_end_date           String,
    cc_closed_date_sk         Int64,
    cc_open_date_sk           Int64,
    cc_name                   String,
    cc_class                  String,
    cc_employees              Int32,
    cc_sq_ft                  Int32,
    cc_hours                  String,
    cc_manager                String,
    cc_mkt_id                 Int32,
    cc_mkt_class              String,
    cc_mkt_desc               String,
    cc_market_manager         String,
    cc_division               Int32,
    cc_division_name          String,
    cc_company                Int32,
    cc_company_name           String,
    cc_street_number          String,
    cc_street_name            String,
    cc_street_type            String,
    cc_suite_number           String,
    cc_city                   String,
    cc_county                 String,
    cc_state                  String,
    cc_zip                    String,
    cc_country                String,
    cc_gmt_offset             Float64,
    cc_tax_percentage         Float64
) engine = MergeTree ORDER BY (
    cc_call_center_sk,
    cc_call_center_id,
    cc_closed_date_sk,
    cc_open_date_sk
);

CREATE TABLE catalog_page
(
    cp_catalog_page_sk        Int64,
    cp_catalog_page_id        String,
    cp_start_date_sk          Int64,
    cp_end_date_sk            Int64,
    cp_department             String,
    cp_catalog_number         Int32,
    cp_catalog_page_number    Int32,
    cp_description            String,
    cp_type                   String
) engine = MergeTree ORDER BY (
    cp_catalog_page_sk,
    cp_catalog_page_id,
    cp_start_date_sk,
    cp_end_date_sk
);

CREATE TABLE catalog_returns
(
    cr_returned_date_sk       Int64,
    cr_returned_time_sk       Int64,
    cr_item_sk                Int64,
    cr_refunded_customer_sk   Int64,
    cr_refunded_cdemo_sk      Int64,
    cr_refunded_hdemo_sk      Int64,
    cr_refunded_addr_sk       Int64,
    cr_returning_customer_sk  Int64,
    cr_returning_cdemo_sk     Int64,
    cr_returning_hdemo_sk     Int64,
    cr_returning_addr_sk      Int64,
    cr_call_center_sk         Int64,
    cr_catalog_page_sk        Int64,
    cr_ship_mode_sk           Int64,
    cr_warehouse_sk           Int64,
    cr_reason_sk              Int64,
    cr_order_number           Int64,
    cr_return_quantity        Int32,
    cr_return_amount          Float64,
    cr_return_tax             Float64,
    cr_return_amt_inc_tax     Float64,
    cr_fee                    Float64,
    cr_return_ship_cost       Float64,
    cr_refunded_cash          Float64,
    cr_reversed_charge        Float64,
    cr_store_credit           Float64,
    cr_net_loss               Float64
) engine = MergeTree ORDER BY (
    cr_returned_date_sk,
    cr_returned_time_sk,
    cr_item_sk,
    cr_refunded_customer_sk,
    cr_refunded_cdemo_sk,
    cr_refunded_hdemo_sk,
    cr_refunded_addr_sk,
    cr_returning_customer_sk,
    cr_returning_cdemo_sk,
    cr_returning_hdemo_sk,
    cr_returning_addr_sk,
    cr_call_center_sk,
    cr_catalog_page_sk,
    cr_ship_mode_sk,
    cr_warehouse_sk,
    cr_reason_sk
);

CREATE TABLE catalog_sales
(
    cs_sold_date_sk           Int64,
    cs_sold_time_sk           Int64,
    cs_ship_date_sk           Int64,
    cs_bill_customer_sk       Int64,
    cs_bill_cdemo_sk          Int64,
    cs_bill_hdemo_sk          Int64,
    cs_bill_addr_sk           Int64,
    cs_ship_customer_sk       Int64,
    cs_ship_cdemo_sk          Int64,
    cs_ship_hdemo_sk          Int64,
    cs_ship_addr_sk           Int64,
    cs_call_center_sk         Int64,
    cs_catalog_page_sk        Int64,
    cs_ship_mode_sk           Int64,
    cs_warehouse_sk           Int64,
    cs_item_sk                Int64,
    cs_promo_sk               Int64,
    cs_order_number           Int64,
    cs_quantity               Int32,
    cs_wholesale_cost         Float64,
    cs_list_price             Float64,
    cs_sales_price            Float64,
    cs_ext_discount_amt       Float64,
    cs_ext_sales_price        Float64,
    cs_ext_wholesale_cost     Float64,
    cs_ext_list_price         Float64,
    cs_ext_tax                Float64,
    cs_coupon_amt             Float64,
    cs_ext_ship_cost          Float64,
    cs_net_paid               Float64,
    cs_net_paid_inc_tax       Float64,
    cs_net_paid_inc_ship      Float64,
    cs_net_paid_inc_ship_tax  Float64,
    cs_net_profit             Float64
) engine = MergeTree ORDER BY (
    cs_sold_date_sk,
    cs_sold_time_sk,
    cs_ship_date_sk,
    cs_bill_customer_sk,
    cs_bill_cdemo_sk,
    cs_bill_hdemo_sk,
    cs_bill_addr_sk,
    cs_ship_customer_sk,
    cs_ship_cdemo_sk,
    cs_ship_hdemo_sk,
    cs_ship_addr_sk,
    cs_call_center_sk,
    cs_catalog_page_sk,
    cs_ship_mode_sk,
    cs_warehouse_sk,
    cs_item_sk,
    cs_promo_sk
);

CREATE TABLE customer_address
(
    ca_address_sk             Int64,
    ca_address_id             String,
    ca_street_number          String,
    ca_street_name            String,
    ca_street_type            String,
    ca_suite_number           String,
    ca_city                   String,
    ca_county                 String,
    ca_state                  String,
    ca_zip                    String,
    ca_country                String,
    ca_gmt_offset             Float64,
    ca_location_type          String
) engine = MergeTree ORDER BY (ca_address_sk, ca_address_id);

CREATE TABLE customer_demographics
(
    cd_demo_sk                Int64,
    cd_gender                 String,
    cd_marital_status         String,
    cd_education_status       String,
    cd_purchase_estimate      Int32,
    cd_credit_rating          String,
    cd_dep_count              Int32,
    cd_dep_employed_count     Int32,
    cd_dep_college_count      Int32 
) engine = MergeTree ORDER BY cd_demo_sk;

CREATE TABLE customer
(
    c_customer_sk             Int64,
    c_customer_id             String,
    c_current_cdemo_sk        Int64,
    c_current_hdemo_sk        Int64,
    c_current_addr_sk         Int64,
    c_first_shipto_date_sk    Int64,
    c_first_sales_date_sk     Int64,
    c_salutation              String,
    c_first_name              String,
    c_last_name               String,
    c_preferred_cust_flag     String,
    c_birth_day               Int32,
    c_birth_month             Int32,
    c_birth_year              Int32,
    c_birth_country           String,
    c_login                   String,
    c_email_address           String,
    c_last_review_date        String
) engine = MergeTree ORDER BY (c_customer_sk, c_customer_id);

CREATE TABLE date_dim
(
    d_date_sk                 Int64,
    d_date_id                 String,
    d_date                    String,
    d_month_seq               Int32,
    d_week_seq                Int32,
    d_quarter_seq             Int32,
    d_year                    Int32,
    d_dow                     Int32,
    d_moy                     Int32,
    d_dom                     Int32,
    d_qoy                     Int32,
    d_fy_year                 Int32,
    d_fy_quarter_seq          Int32,
    d_fy_week_seq             Int32,
    d_day_name                String,
    d_quarter_name            String,
    d_holiday                 String,
    d_weekend                 String,
    d_following_holiday       String,
    d_first_dom               Int32,
    d_last_dom                Int32,
    d_same_day_ly             Int32,
    d_same_day_lq             Int32,
    d_current_day             String,
    d_current_week            String,
    d_current_month           String,
    d_current_quarter         String,
    d_current_year            String 
) engine = MergeTree ORDER BY (d_date_sk, d_date_id);

CREATE TABLE household_demographics
(
    hd_demo_sk                Int64,
    hd_income_band_sk         Int64,
    hd_buy_potential          String,
    hd_dep_count              Int32,
    hd_vehicle_count          Int32
) engine = MergeTree ORDER BY (hd_demo_sk, hd_income_band_sk);

CREATE TABLE income_band
(
    ib_income_band_sk         Int64,
    ib_lower_bound            Int32,
    ib_upper_bound            Int32
) engine = MergeTree ORDER BY ib_income_band_sk;

CREATE TABLE inventory
(
    inv_date_sk            Int64,
    inv_item_sk            Int64,
    inv_warehouse_sk        Int64,
    inv_quantity_on_hand    Int32
) engine = MergeTree ORDER BY (inv_date_sk, inv_item_sk, inv_warehouse_sk);

CREATE TABLE item
(
    i_item_sk                 Int64,
    i_item_id                 String,
    i_rec_start_date          String,
    i_rec_end_date            String,
    i_item_desc               String,
    i_current_price           Float64,
    i_wholesale_cost          Float64,
    i_brand_id                Int32,
    i_brand                   String,
    i_class_id                Int32,
    i_class                   String,
    i_category_id             Int32,
    i_category                String,
    i_manufact_id             Int32,
    i_manufact                String,
    i_size                    String,
    i_formulation             String,
    i_color                   String,
    i_units                   String,
    i_container               String,
    i_manager_id              Int32,
    i_product_name            String
) engine = MergeTree ORDER BY (i_item_sk, i_item_id);

CREATE TABLE promotion
(
    p_promo_sk                Int64,
    p_promo_id                String,
    p_start_date_sk           Int64,
    p_end_date_sk             Int64,
    p_item_sk                 Int64,
    p_cost                    Float64,
    p_response_target         Int32,
    p_promo_name              String,
    p_channel_dmail           String,
    p_channel_email           String,
    p_channel_catalog         String,
    p_channel_tv              String,
    p_channel_radio           String,
    p_channel_press           String,
    p_channel_event           String,
    p_channel_demo            String,
    p_channel_details         String,
    p_purpose                 String,
    p_discount_active         String 
) engine = MergeTree ORDER BY (
    p_promo_sk,
    p_promo_id,
    p_start_date_sk,
    p_end_date_sk,
    p_item_sk
);

CREATE TABLE reason
(
    r_reason_sk               Int64,
    r_reason_id               String,
    r_reason_desc             String
) engine = MergeTree ORDER BY (r_reason_sk, r_reason_id);

CREATE TABLE ship_mode
(
    sm_ship_mode_sk           Int64,
    sm_ship_mode_id           String,
    sm_type                   String,
    sm_code                   String,
    sm_carrier                String,
    sm_contract               String
) engine = MergeTree ORDER BY (sm_ship_mode_sk, sm_ship_mode_id);

CREATE TABLE store_returns
(
    sr_returned_date_sk       Int64,
    sr_return_time_sk         Int64,
    sr_item_sk                Int64,
    sr_customer_sk            Int64,
    sr_cdemo_sk               Int64,
    sr_hdemo_sk               Int64,
    sr_addr_sk                Int64,
    sr_store_sk               Int64,
    sr_reason_sk              Int64,
    sr_ticket_number          Int64,
    sr_return_quantity        Int32,
    sr_return_amt             Float64,
    sr_return_tax             Float64,
    sr_return_amt_inc_tax     Float64,
    sr_fee                    Float64,
    sr_return_ship_cost       Float64,
    sr_refunded_cash          Float64,
    sr_reversed_charge        Float64,
    sr_store_credit           Float64,
    sr_net_loss               Float64
) engine = MergeTree ORDER BY (
    sr_returned_date_sk,
    sr_return_time_sk,
    sr_item_sk,
    sr_customer_sk,
    sr_cdemo_sk,
    sr_hdemo_sk,
    sr_addr_sk,
    sr_store_sk,
    sr_reason_sk
);

CREATE TABLE store_sales
(
    ss_sold_date_sk           Int64,
    ss_sold_time_sk           Int64,
    ss_item_sk                Int64,
    ss_customer_sk            Int64,
    ss_cdemo_sk               Int64,
    ss_hdemo_sk               Int64,
    ss_addr_sk                Int64,
    ss_store_sk               Int64,
    ss_promo_sk               Int64,
    ss_ticket_number          Int64,
    ss_quantity               Int32,
    ss_wholesale_cost         Float64,
    ss_list_price             Float64,
    ss_sales_price            Float64,
    ss_ext_discount_amt       Float64,
    ss_ext_sales_price        Float64,
    ss_ext_wholesale_cost     Float64,
    ss_ext_list_price         Float64,
    ss_ext_tax                Float64,
    ss_coupon_amt             Float64,
    ss_net_paid               Float64,
    ss_net_paid_inc_tax       Float64,
    ss_net_profit             Float64
) engine = MergeTree ORDER BY (
    ss_sold_date_sk,
    ss_sold_time_sk,
    ss_item_sk,
    ss_customer_sk,
    ss_cdemo_sk,
    ss_hdemo_sk,
    ss_addr_sk,
    ss_store_sk,
    ss_promo_sk
);

CREATE TABLE store
(
    s_store_sk                Int64,
    s_store_id                String,
    s_rec_start_date          String,
    s_rec_end_date            String,
    s_closed_date_sk          Int64,
    s_store_name              String,
    s_number_employees        Int32,
    s_floor_space             Int32,
    s_hours                   String,
    s_manager                 String,
    s_market_id               Int32,
    s_geography_class         String,
    s_market_desc             String,
    s_market_manager          String,
    s_division_id             Int32,
    s_division_name           String,
    s_company_id              Int32,
    s_company_name            String,
    s_street_number           String,
    s_street_name             String,
    s_street_type             String,
    s_suite_number            String,
    s_city                    String,
    s_county                  String,
    s_state                   String,
    s_zip                     String,
    s_country                 String,
    s_gmt_offset              Float64,
    s_tax_precentage          Float64
) engine = MergeTree ORDER BY (s_store_sk, s_store_id);

CREATE TABLE time_dim
(
    t_time_sk                 Int64,
    t_time_id                 String,
    t_time                    Int32,
    t_hour                    Int32,
    t_minute                  Int32,
    t_second                  Int32,
    t_am_pm                   String,
    t_shift                   String,
    t_sub_shift               String,
    t_meal_time               String
) engine = MergeTree ORDER BY (t_time_sk, t_time_id);

CREATE TABLE warehouse
(
    w_warehouse_sk            Int64,
    w_warehouse_id            String,
    w_warehouse_name          String,
    w_warehouse_sq_ft         Int32,
    w_street_number           String,
    w_street_name             String,
    w_street_type             String,
    w_suite_number            String,
    w_city                    String,
    w_county                  String,
    w_state                   String,
    w_zip                     String,
    w_country                 String,
    w_gmt_offset              Float64
) engine = MergeTree ORDER BY (w_warehouse_sk, w_warehouse_id);

CREATE TABLE web_page
(
    wp_web_page_sk            Int64,
    wp_web_page_id            String,
    wp_rec_start_date         String,
    wp_rec_end_date           String,
    wp_creation_date_sk       Int64,
    wp_access_date_sk         Int64,
    wp_autogen_flag           String,
    wp_customer_sk            Int64,
    wp_url                    String,
    wp_type                   String,
    wp_char_count             Int32,
    wp_link_count             Int32,
    wp_image_count            Int32,
    wp_max_ad_count           Int32
) engine = MergeTree ORDER BY (wp_web_page_sk, wp_web_page_id);

CREATE TABLE web_returns
(
    wr_returned_date_sk       Int64,
    wr_returned_time_sk       Int64,
    wr_item_sk                Int64,
    wr_refunded_customer_sk   Int64,
    wr_refunded_cdemo_sk      Int64,
    wr_refunded_hdemo_sk      Int64,
    wr_refunded_addr_sk       Int64,
    wr_returning_customer_sk  Int64,
    wr_returning_cdemo_sk     Int64,
    wr_returning_hdemo_sk     Int64,
    wr_returning_addr_sk      Int64,
    wr_web_page_sk            Int64,
    wr_reason_sk              Int64,
    wr_order_number           Int64,
    wr_return_quantity        Int32,
    wr_return_amt             Float64,
    wr_return_tax             Float64,
    wr_return_amt_inc_tax     Float64,
    wr_fee                    Float64,
    wr_return_ship_cost       Float64,
    wr_refunded_cash          Float64,
    wr_reversed_charge        Float64,
    wr_account_credit         Float64,
    wr_net_loss               Float64
) engine = MergeTree ORDER BY (
    wr_returned_date_sk,
    wr_returned_time_sk,
    wr_item_sk,
    wr_refunded_customer_sk,
    wr_refunded_cdemo_sk,
    wr_refunded_hdemo_sk,
    wr_refunded_addr_sk,
    wr_returning_customer_sk,
    wr_returning_cdemo_sk,
    wr_returning_hdemo_sk,
    wr_returning_addr_sk,
    wr_web_page_sk,
    wr_reason_sk
);

CREATE TABLE web_sales
(
    ws_sold_date_sk           Int64,
    ws_sold_time_sk           Int64,
    ws_ship_date_sk           Int64,
    ws_item_sk                Int64,
    ws_bill_customer_sk       Int64,
    ws_bill_cdemo_sk          Int64,
    ws_bill_hdemo_sk          Int64,
    ws_bill_addr_sk           Int64,
    ws_ship_customer_sk       Int64,
    ws_ship_cdemo_sk          Int64,
    ws_ship_hdemo_sk          Int64,
    ws_ship_addr_sk           Int64,
    ws_web_page_sk            Int64,
    ws_web_site_sk            Int64,
    ws_ship_mode_sk           Int64,
    ws_warehouse_sk           Int64,
    ws_promo_sk               Int64,
    ws_order_number           Int64,
    ws_quantity               Int32,
    ws_wholesale_cost         Float64,
    ws_list_price             Float64,
    ws_sales_price            Float64,
    ws_ext_discount_amt       Float64,
    ws_ext_sales_price        Float64,
    ws_ext_wholesale_cost     Float64,
    ws_ext_list_price         Float64,
    ws_ext_tax                Float64,
    ws_coupon_amt             Float64,
    ws_ext_ship_cost          Float64,
    ws_net_paid               Float64,
    ws_net_paid_inc_tax       Float64,
    ws_net_paid_inc_ship      Float64,
    ws_net_paid_inc_ship_tax  Float64,
    ws_net_profit             Float64
) engine = MergeTree ORDER BY (
    ws_sold_date_sk,
    ws_sold_time_sk,
    ws_ship_date_sk,
    ws_item_sk,
    ws_bill_customer_sk,
    ws_bill_cdemo_sk,
    ws_bill_hdemo_sk,
    ws_bill_addr_sk,
    ws_ship_customer_sk,
    ws_ship_cdemo_sk,
    ws_ship_hdemo_sk,
    ws_ship_addr_sk,
    ws_web_page_sk,
    ws_web_site_sk,
    ws_ship_mode_sk,
    ws_warehouse_sk,
    ws_promo_sk
);

CREATE TABLE web_site
(
    web_site_sk           Int64,
    web_site_id           String,
    web_rec_start_date    String,
    web_rec_end_date      String,
    web_name              String,
    web_open_date_sk      Int64,
    web_close_date_sk     Int64,
    web_class             String,
    web_manager           String,
    web_mkt_id            Int32,
    web_mkt_class         String,
    web_mkt_desc          String,
    web_market_manager    String,
    web_company_id        Int32,
    web_company_name      String,
    web_street_number     String,
    web_street_name       String,
    web_street_type       String,
    web_suite_number      String,
    web_city              String,
    web_county            String,
    web_state             String,
    web_zip               String,
    web_country           String,
    web_gmt_offset        Float64,
    web_tax_percentage    Float64
) engine = MergeTree ORDER BY (web_site_sk, web_site_id);
