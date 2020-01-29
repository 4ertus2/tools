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

-- NOTE: Integer is at least Int64
-- NOTE: Date should support dates in interval [01.01.1900, 31.12.2199]

-- Fact tables

CREATE TABLE store_sales
(
    ss_sold_date_sk           Nullable(Int64), -- FK d_date_sk
    ss_sold_time_sk           Nullable(Int64), -- FK t_time_sk
    ss_item_sk                Int64, -- PK(1), NOT NULL, FK i_item_sk
    ss_customer_sk            Nullable(Int64), -- FK c_customer_sk
    ss_cdemo_sk               Nullable(Int64), -- FK cd_demo_sk
    ss_hdemo_sk               Nullable(Int64), -- FK hd_demo_sk
    ss_addr_sk                Nullable(Int64), -- FK ca_address_sk
    ss_store_sk               Nullable(Int64), -- FK s_store_sk
    ss_promo_sk               Nullable(Int64), -- FK p_promo_sk
    ss_ticket_number          Int64, -- PK(2), NOT NULL
    ss_quantity               Nullable(Int64), -- integer
    ss_wholesale_cost         Nullable(Decimal(7,2)),
    ss_list_price             Nullable(Decimal(7,2)),
    ss_sales_price            Nullable(Decimal(7,2)),
    ss_ext_discount_amt       Nullable(Decimal(7,2)),
    ss_ext_sales_price        Nullable(Decimal(7,2)),
    ss_ext_wholesale_cost     Nullable(Decimal(7,2)),
    ss_ext_list_price         Nullable(Decimal(7,2)),
    ss_ext_tax                Nullable(Decimal(7,2)),
    ss_coupon_amt             Nullable(Decimal(7,2)),
    ss_net_paid               Nullable(Decimal(7,2)),
    ss_net_paid_inc_tax       Nullable(Decimal(7,2)),
    ss_net_profit             Nullable(Decimal(7,2))
) engine = MergeTree ORDER BY (ss_item_sk, ss_ticket_number);

CREATE TABLE store_returns
(
    sr_returned_date_sk       Nullable(Int64), -- FK d_date_sk
    sr_return_time_sk         Nullable(Int64), -- FK t_time_sk
    sr_item_sk                Int64, -- PK(1), NOT NULL, FK i_item_sk, ss_item_sk
    sr_customer_sk            Nullable(Int64), -- FK c_customer_sk
    sr_cdemo_sk               Nullable(Int64), -- FK cd_demo_sk
    sr_hdemo_sk               Nullable(Int64), -- FK hd_demo_sk
    sr_addr_sk                Nullable(Int64), -- FK ca_address_sk
    sr_store_sk               Nullable(Int64), -- FK s_store_sk
    sr_reason_sk              Nullable(Int64), -- FK r_reason_sk
    sr_ticket_number          Int64, -- PK(2), NOT NULL, FK ss_ticket_number
    sr_return_quantity        Nullable(Int64), -- integer
    sr_return_amt             Nullable(Decimal(7,2)),
    sr_return_tax             Nullable(Decimal(7,2)),
    sr_return_amt_inc_tax     Nullable(Decimal(7,2)),
    sr_fee                    Nullable(Decimal(7,2)),
    sr_return_ship_cost       Nullable(Decimal(7,2)),
    sr_refunded_cash          Nullable(Decimal(7,2)),
    sr_reversed_charge        Nullable(Decimal(7,2)),
    sr_store_credit           Nullable(Decimal(7,2)),
    sr_net_loss               Nullable(Decimal(7,2))
) engine = MergeTree ORDER BY (sr_item_sk, sr_ticket_number);

CREATE TABLE catalog_sales
(
    cs_sold_date_sk           Nullable(Int64), -- FK d_date_sk
    cs_sold_time_sk           Nullable(Int64), -- FK t_time_sk
    cs_ship_date_sk           Nullable(Int64), -- FK d_date_sk
    cs_bill_customer_sk       Nullable(Int64), -- FK c_customer_sk
    cs_bill_cdemo_sk          Nullable(Int64), -- FK cd_demo_sk
    cs_bill_hdemo_sk          Nullable(Int64), -- FK hd_demo_sk
    cs_bill_addr_sk           Nullable(Int64), -- FK ca_address_sk
    cs_ship_customer_sk       Nullable(Int64), -- FK c_customer_sk
    cs_ship_cdemo_sk          Nullable(Int64), -- FK cd_demo_sk
    cs_ship_hdemo_sk          Nullable(Int64), -- FK hd_demo_sk
    cs_ship_addr_sk           Nullable(Int64), -- FK ca_address_sk
    cs_call_center_sk         Nullable(Int64), -- FK cc_call_center_sk
    cs_catalog_page_sk        Nullable(Int64), -- FK cp_catalog_page_sk
    cs_ship_mode_sk           Nullable(Int64), -- FK sm_ship_mode_sk
    cs_warehouse_sk           Nullable(Int64), -- FK w_warehouse_sk
    cs_item_sk                Int64, -- PK(1), NOT NULL, FK i_item_sk 
    cs_promo_sk               Nullable(Int64), -- FK p_promo_sk
    cs_order_number           Int64, -- PK(2), NOT NULL
    cs_quantity               Nullable(Int64), -- integer
    cs_wholesale_cost         Nullable(Decimal(7,2)),
    cs_list_price             Nullable(Decimal(7,2)),
    cs_sales_price            Nullable(Decimal(7,2)),
    cs_ext_discount_amt       Nullable(Decimal(7,2)),
    cs_ext_sales_price        Nullable(Decimal(7,2)),
    cs_ext_wholesale_cost     Nullable(Decimal(7,2)),
    cs_ext_list_price         Nullable(Decimal(7,2)),
    cs_ext_tax                Nullable(Decimal(7,2)),
    cs_coupon_amt             Nullable(Decimal(7,2)),
    cs_ext_ship_cost          Nullable(Decimal(7,2)),
    cs_net_paid               Nullable(Decimal(7,2)),
    cs_net_paid_inc_tax       Nullable(Decimal(7,2)),
    cs_net_paid_inc_ship      Nullable(Decimal(7,2)),
    cs_net_paid_inc_ship_tax  Nullable(Decimal(7,2)),
    cs_net_profit             Nullable(Decimal(7,2))
) engine = MergeTree ORDER BY (cs_item_sk, cs_order_number);

CREATE TABLE catalog_returns
(
    cr_returned_date_sk       Nullable(Int64), -- FK d_date_sk
    cr_returned_time_sk       Nullable(Int64), -- FK t_time_sk
    cr_item_sk                Int64, -- PK(1), NOT NULL, FK i_item_sk, cs_item_sk
    cr_refunded_customer_sk   Nullable(Int64), -- FK c_customer_sk
    cr_refunded_cdemo_sk      Nullable(Int64), -- FK cd_demo_sk
    cr_refunded_hdemo_sk      Nullable(Int64), -- FK hd_demo_sk
    cr_refunded_addr_sk       Nullable(Int64), -- FK ca_address_sk
    cr_returning_customer_sk  Nullable(Int64), -- FK c_customer_sk
    cr_returning_cdemo_sk     Nullable(Int64), -- FK cd_demo_sk
    cr_returning_hdemo_sk     Nullable(Int64), -- FK hd_demo_sk
    cr_returning_addr_sk      Nullable(Int64), -- FK ca_address_sk
    cr_call_center_sk         Nullable(Int64), -- FK cc_call_center_sk
    cr_catalog_page_sk        Nullable(Int64), -- FK cp_catalog_page_sk
    cr_ship_mode_sk           Nullable(Int64), -- FK sm_ship_mode_sk
    cr_warehouse_sk           Nullable(Int64), -- FK w_warehouse_sk
    cr_reason_sk              Nullable(Int64), -- FK r_reason_sk
    cr_order_number           Int64, -- PK(2), NOT NULL, FK cs_order_number
    cr_return_quantity        Nullable(Int64), -- integer
    cr_return_amount          Nullable(Decimal(7,2)),
    cr_return_tax             Nullable(Decimal(7,2)),
    cr_return_amt_inc_tax     Nullable(Decimal(7,2)),
    cr_fee                    Nullable(Decimal(7,2)),
    cr_return_ship_cost       Nullable(Decimal(7,2)),
    cr_refunded_cash          Nullable(Decimal(7,2)),
    cr_reversed_charge        Nullable(Decimal(7,2)),
    cr_store_credit           Nullable(Decimal(7,2)),
    cr_net_loss               Nullable(Decimal(7,2))
) engine = MergeTree ORDER BY (cr_item_sk, cr_order_number);

CREATE TABLE web_sales
(
    ws_sold_date_sk           Nullable(Int64), -- FK d_date_sk
    ws_sold_time_sk           Nullable(Int64), -- FK t_time_sk
    ws_ship_date_sk           Nullable(Int64), -- FK d_date_sk
    ws_item_sk                Int64, -- PK(1), NOT NULL, FK i_item_sk
    ws_bill_customer_sk       Nullable(Int64), -- FK c_customer_sk
    ws_bill_cdemo_sk          Nullable(Int64), -- FK cd_demo_sk
    ws_bill_hdemo_sk          Nullable(Int64), -- FK hd_demo_sk
    ws_bill_addr_sk           Nullable(Int64), -- FK ca_address_sk
    ws_ship_customer_sk       Nullable(Int64), -- FK c_customer_sk
    ws_ship_cdemo_sk          Nullable(Int64), -- FK cd_demo_sk
    ws_ship_hdemo_sk          Nullable(Int64), -- FK hd_demo_sk
    ws_ship_addr_sk           Nullable(Int64), -- FK ca_address_sk
    ws_web_page_sk            Nullable(Int64), -- FK wp_web_page_sk
    ws_web_site_sk            Nullable(Int64), -- FK web_site_sk
    ws_ship_mode_sk           Nullable(Int64), -- FK sm_ship_mode_sk
    ws_warehouse_sk           Nullable(Int64), -- FK w_warehouse_sk
    ws_promo_sk               Nullable(Int64), -- FK p_promo_sk
    ws_order_number           Int64, -- PK(2), NOT NULL
    ws_quantity               Nullable(Int64), -- integer
    ws_wholesale_cost         Nullable(Decimal(7,2)),
    ws_list_price             Nullable(Decimal(7,2)),
    ws_sales_price            Nullable(Decimal(7,2)),
    ws_ext_discount_amt       Nullable(Decimal(7,2)),
    ws_ext_sales_price        Nullable(Decimal(7,2)),
    ws_ext_wholesale_cost     Nullable(Decimal(7,2)),
    ws_ext_list_price         Nullable(Decimal(7,2)),
    ws_ext_tax                Nullable(Decimal(7,2)),
    ws_coupon_amt             Nullable(Decimal(7,2)),
    ws_ext_ship_cost          Nullable(Decimal(7,2)),
    ws_net_paid               Nullable(Decimal(7,2)),
    ws_net_paid_inc_tax       Nullable(Decimal(7,2)),
    ws_net_paid_inc_ship      Nullable(Decimal(7,2)),
    ws_net_paid_inc_ship_tax  Nullable(Decimal(7,2)),
    ws_net_profit             Nullable(Decimal(7,2))
) engine = MergeTree ORDER BY (ws_item_sk, ws_order_number);

CREATE TABLE web_returns
(
    wr_returned_date_sk       Nullable(Int64), -- FK d_date_sk
    wr_returned_time_sk       Nullable(Int64), -- FK t_time_sk
    wr_item_sk                Int64, -- PK(1), NOT NULL, FK i_item_sk, ws_item_sk
    wr_refunded_customer_sk   Nullable(Int64), -- FK c_customer_sk
    wr_refunded_cdemo_sk      Nullable(Int64), -- FK cd_demo_sk
    wr_refunded_hdemo_sk      Nullable(Int64), -- FK hd_demo_sk
    wr_refunded_addr_sk       Nullable(Int64), -- FK ca_address_sk
    wr_returning_customer_sk  Nullable(Int64), -- FK c_customer_sk
    wr_returning_cdemo_sk     Nullable(Int64), -- FK cd_demo_sk
    wr_returning_hdemo_sk     Nullable(Int64), -- FK hd_demo_sk
    wr_returning_addr_sk      Nullable(Int64), -- FK ca_address_sk
    wr_web_page_sk            Nullable(Int64), -- FK wp_web_page_sk
    wr_reason_sk              Nullable(Int64), -- FK r_reason_sk
    wr_order_number           Int64, -- PK(2), NOT NULL, FK ws_order_number
    wr_return_quantity        Nullable(Int64), -- integer
    wr_return_amt             Nullable(Decimal(7,2)),
    wr_return_tax             Nullable(Decimal(7,2)),
    wr_return_amt_inc_tax     Nullable(Decimal(7,2)),
    wr_fee                    Nullable(Decimal(7,2)),
    wr_return_ship_cost       Nullable(Decimal(7,2)),
    wr_refunded_cash          Nullable(Decimal(7,2)),
    wr_reversed_charge        Nullable(Decimal(7,2)),
    wr_account_credit         Nullable(Decimal(7,2)),
    wr_net_loss               Nullable(Decimal(7,2))
) engine = MergeTree ORDER BY (wr_item_sk, wr_order_number);

CREATE TABLE inventory
(
    inv_date_sk               Int64, -- PK(1), NOT NULL, FK d_date_sk
    inv_item_sk               Int64, -- PK(2), NOT NULL, FK i_item_sk
    inv_warehouse_sk          Int64, -- PK(3), NOT NULL, FK w_warehouse_sk
    inv_quantity_on_hand      Nullable(Int64) -- integer
) engine = MergeTree ORDER BY (inv_date_sk, inv_item_sk, inv_warehouse_sk);

-- Dimension tables

CREATE TABLE store
(
    s_store_sk                Int64, -- PK, NOT NULL
    s_store_id                FixedString(16), -- BK, NOT NULL
    s_rec_start_date          Nullable(String), -- Date
    s_rec_end_date            Nullable(String), -- Date
    s_closed_date_sk          Nullable(Int64), -- FK d_date_sk
    s_store_name              Nullable(String), -- varchar(50)
    s_number_employees        Nullable(Int64),
    s_floor_space             Nullable(Int64),
    s_hours                   Nullable(FixedString(20)),
    s_manager                 Nullable(String), -- varchar(40)
    s_market_id               Nullable(Int64),
    s_geography_class         Nullable(String), -- varchar(100)
    s_market_desc             Nullable(String), -- varchar(100)
    s_market_manager          Nullable(String), -- varchar(40)
    s_division_id             Nullable(Int64),
    s_division_name           Nullable(String), -- varchar(50)
    s_company_id              Nullable(Int64),
    s_company_name            Nullable(String), -- varchar(50)
    s_street_number           Nullable(String), -- varchar(10)
    s_street_name             Nullable(String), -- varchar(60)
    s_street_type             Nullable(FixedString(15)),
    s_suite_number            Nullable(FixedString(10)),
    s_city                    Nullable(String), -- varchar(60)
    s_county                  Nullable(String), -- varchar(30)
    s_state                   Nullable(FixedString(2)),
    s_zip                     Nullable(FixedString(10)),
    s_country                 Nullable(String), -- varchar(20)
    s_gmt_offset              Nullable(Decimal(5,2)),
    s_tax_precentage          Nullable(Decimal(5,2))
) engine = MergeTree ORDER BY (s_store_sk);

CREATE TABLE call_center
(
    cc_call_center_sk         Int64, -- PK, NOT NULL
    cc_call_center_id         FixedString(16), -- BK, NOT NULL
    cc_rec_start_date         Nullable(String), -- Date
    cc_rec_end_date           Nullable(String), -- Date
    cc_closed_date_sk         Nullable(Int64), -- FK d_date_sk
    cc_open_date_sk           Nullable(Int64), -- FK d_date_sk
    cc_name                   Nullable(String), -- varchar(50)
    cc_class                  Nullable(String), -- varchar(50)
    cc_employees              Nullable(Int64),
    cc_sq_ft                  Nullable(Int64),
    cc_hours                  Nullable(FixedString(20)),
    cc_manager                Nullable(String), -- varchar(40)
    cc_mkt_id                 Nullable(Int64),
    cc_mkt_class              Nullable(String), -- char(50)
    cc_mkt_desc               Nullable(String), -- varchar(100)
    cc_market_manager         Nullable(String), -- varchar(40)
    cc_division               Nullable(Int64),
    cc_division_name          Nullable(String), -- varchar(50)
    cc_company                Nullable(Int64),
    cc_company_name           Nullable(String), -- char(50)
    cc_street_number          Nullable(FixedString(10)),
    cc_street_name            Nullable(String), -- varchar(60)
    cc_street_type            Nullable(FixedString(15)),
    cc_suite_number           Nullable(FixedString(10)),
    cc_city                   Nullable(String), -- varchar(60)
    cc_county                 Nullable(String), -- varchar(30)
    cc_state                  Nullable(FixedString(2)),
    cc_zip                    Nullable(FixedString(10)),
    cc_country                Nullable(String), -- varchar(20)
    cc_gmt_offset             Nullable(Decimal(5,2)),
    cc_tax_percentage         Nullable(Decimal(5,2))
) engine = MergeTree ORDER BY (cc_call_center_sk);

CREATE TABLE catalog_page
(
    cp_catalog_page_sk        Int64, -- PK, NOT NULL
    cp_catalog_page_id        FixedString(16), -- BK, NOT NULL
    cp_start_date_sk          Nullable(Int64), -- FK d_date_sk
    cp_end_date_sk            Nullable(Int64), -- FK d_date_sk
    cp_department             Nullable(String), -- varchar(50)
    cp_catalog_number         Nullable(Int64),
    cp_catalog_page_number    Nullable(Int64),
    cp_description            Nullable(String), -- varchar(100)
    cp_type                   Nullable(String) -- varchar(100)
) engine = MergeTree ORDER BY (cp_catalog_page_sk);

CREATE TABLE web_site
(
    web_site_sk               Int64, -- PK, NOT NULL
    web_site_id               FixedString(16), -- BK, NOT NULL
    web_rec_start_date        Nullable(String), -- Date
    web_rec_end_date          Nullable(String), -- Date
    web_name                  Nullable(String), -- varchar(50)
    web_open_date_sk          Nullable(Int64), -- FK d_date_sk
    web_close_date_sk         Nullable(Int64), -- FK d_date_sk
    web_class                 Nullable(String), -- varchar(50)
    web_manager               Nullable(String), -- varchar(40)
    web_mkt_id                Nullable(Int64),
    web_mkt_class             Nullable(String), -- varchar(50)
    web_mkt_desc              Nullable(String), -- varchar(100)
    web_market_manager        Nullable(String), -- varchar(40)
    web_company_id            Nullable(Int64),
    web_company_name          Nullable(String), -- char(50)
    web_street_number         Nullable(FixedString(10)),
    web_street_name           Nullable(String), -- varchar(60)
    web_street_type           Nullable(FixedString(15)),
    web_suite_number          Nullable(FixedString(10)),
    web_city                  Nullable(String), -- varchar(60)
    web_county                Nullable(String), -- varchar(10)
    web_state                 Nullable(FixedString(2)),
    web_zip                   Nullable(FixedString(10)),
    web_country               Nullable(String), -- varchar(20)
    web_gmt_offset            Nullable(Decimal(5,2)),
    web_tax_percentage        Nullable(Decimal(5,2))
) engine = MergeTree ORDER BY (web_site_sk);

CREATE TABLE web_page
(
    wp_web_page_sk            Int64, -- PK, NOT NULL
    wp_web_page_id            FixedString(16), -- BK, NOT NULL
    wp_rec_start_date         Nullable(String), -- Date
    wp_rec_end_date           Nullable(String), -- Date
    wp_creation_date_sk       Nullable(Int64), -- FK d_date_sk
    wp_access_date_sk         Nullable(Int64), -- FK d_date_sk
    wp_autogen_flag           Nullable(FixedString(1)),
    wp_customer_sk            Nullable(Int64), -- FK c_customer_sk
    wp_url                    Nullable(String), -- varchar(100)
    wp_type                   Nullable(String), -- char(50)
    wp_char_count             Nullable(Int64),
    wp_link_count             Nullable(Int64),
    wp_image_count            Nullable(Int64),
    wp_max_ad_count           Nullable(Int64)
) engine = MergeTree ORDER BY (wp_web_page_sk);

CREATE TABLE warehouse
(
    w_warehouse_sk            Int64, -- PK, NOT NULL
    w_warehouse_id            FixedString(16), -- BK, NOT NULL
    w_warehouse_name          Nullable(String), -- varchar(20)
    w_warehouse_sq_ft         Nullable(Int64),
    w_street_number           Nullable(FixedString(10)),
    w_street_name             Nullable(String), -- varchar(60)
    w_street_type             Nullable(FixedString(15)),
    w_suite_number            Nullable(FixedString(10)),
    w_city                    Nullable(String), -- varchar(60)
    w_county                  Nullable(String), -- varchar(30)
    w_state                   Nullable(FixedString(2)),
    w_zip                     Nullable(FixedString(10)),
    w_country                 Nullable(String), -- varchar(20)
    w_gmt_offset              Nullable(Decimal(5,2))
) engine = MergeTree ORDER BY (w_warehouse_sk);

CREATE TABLE customer
(
    c_customer_sk             Int64, -- PK, NOT NULL
    c_customer_id             FixedString(16), -- BK, NOT NULL
    c_current_cdemo_sk        Nullable(Int64), -- FK cd_demo_sk
    c_current_hdemo_sk        Nullable(Int64), -- FK hd_demo_sk
    c_current_addr_sk         Nullable(Int64), -- FK ca_addres_sk
    c_first_shipto_date_sk    Nullable(Int64), -- FK d_date_sk
    c_first_sales_date_sk     Nullable(Int64), -- FK d_date_sk
    c_salutation              Nullable(FixedString(10)),
    c_first_name              Nullable(FixedString(20)),
    c_last_name               Nullable(String), -- char(30)
    c_preferred_cust_flag     Nullable(FixedString(1)),
    c_birth_day               Nullable(Int64),
    c_birth_month             Nullable(Int64),
    c_birth_year              Nullable(Int64),
    c_birth_country           Nullable(String), -- varchar(20)
    c_login                   Nullable(FixedString(13)),
    c_email_address           Nullable(String), -- char(50)
    c_last_review_date        Nullable(Int64) -- FK d_date_sk
) engine = MergeTree ORDER BY (c_customer_sk);

CREATE TABLE customer_address
(
    ca_address_sk             Int64, -- PK, NOT NULL
    ca_address_id             FixedString(16), -- BK, NOT NULL
    ca_street_number          Nullable(FixedString(10)),
    ca_street_name            Nullable(String), -- varchar(60)
    ca_street_type            Nullable(FixedString(15)),
    ca_suite_number           Nullable(FixedString(10)),
    ca_city                   Nullable(String), -- varchar(60)
    ca_county                 Nullable(String), -- varchar(30)
    ca_state                  Nullable(FixedString(2)),
    ca_zip                    Nullable(FixedString(10)),
    ca_country                Nullable(String), -- varchar(20)
    ca_gmt_offset             Nullable(Decimal(5,2)),
    ca_location_type          Nullable(FixedString(20))
) engine = MergeTree ORDER BY (ca_address_sk);

CREATE TABLE customer_demographics
(
    cd_demo_sk                Int64, -- PK, NOT NULL
    cd_gender                 Nullable(FixedString(1)),
    cd_marital_status         Nullable(FixedString(1)),
    cd_education_status       Nullable(FixedString(20)),
    cd_purchase_estimate      Nullable(Int64),
    cd_credit_rating          Nullable(FixedString(10)),
    cd_dep_count              Nullable(Int64),
    cd_dep_employed_count     Nullable(Int64),
    cd_dep_college_count      Nullable(Int64) 
) engine = MergeTree ORDER BY cd_demo_sk;

CREATE TABLE date_dim
(
    d_date_sk                 Int64, -- PK, NOT NULL
    d_date_id                 FixedString(16), -- BK, NOT NULL
    d_date                    String, -- NOT NULL, Date
    d_month_seq               Nullable(Int64),
    d_week_seq                Nullable(Int64),
    d_quarter_seq             Nullable(Int64),
    d_year                    Nullable(Int64),
    d_dow                     Nullable(Int64),
    d_moy                     Nullable(Int64),
    d_dom                     Nullable(Int64),
    d_qoy                     Nullable(Int64),
    d_fy_year                 Nullable(Int64),
    d_fy_quarter_seq          Nullable(Int64),
    d_fy_week_seq             Nullable(Int64),
    d_day_name                Nullable(FixedString(9)),
    d_quarter_name            Nullable(FixedString(6)),
    d_holiday                 Nullable(FixedString(1)),
    d_weekend                 Nullable(FixedString(1)),
    d_following_holiday       Nullable(FixedString(1)),
    d_first_dom               Nullable(Int64),
    d_last_dom                Nullable(Int64),
    d_same_day_ly             Nullable(Int64),
    d_same_day_lq             Nullable(Int64),
    d_current_day             Nullable(FixedString(1)),
    d_current_week            Nullable(FixedString(1)),
    d_current_month           Nullable(FixedString(1)),
    d_current_quarter         Nullable(FixedString(1)),
    d_current_year            Nullable(FixedString(1)) 
) engine = MergeTree ORDER BY (d_date_sk);

CREATE TABLE household_demographics
(
    hd_demo_sk                Int64, -- PK, NOT NULL
    hd_income_band_sk         Nullable(Int64), -- FK ib_income_band_sk
    hd_buy_potential          Nullable(FixedString(15)),
    hd_dep_count              Nullable(Int64),
    hd_vehicle_count          Nullable(Int64)
) engine = MergeTree ORDER BY (hd_demo_sk);

CREATE TABLE item
(
    i_item_sk                 Int64, -- PK, NOT NULL
    i_item_id                 FixedString(16), -- BK, NOT NULL
    i_rec_start_date          Nullable(String), -- Date
    i_rec_end_date            Nullable(String), -- Date
    i_item_desc               Nullable(String), -- varchar(200)
    i_current_price           Nullable(Decimal(7,2)),
    i_wholesale_cost          Nullable(Decimal(7,2)),
    i_brand_id                Nullable(Int64),
    i_brand                   Nullable(String), -- char(50)
    i_class_id                Nullable(Int64),
    i_class                   Nullable(String), -- char(50)
    i_category_id             Nullable(Int64),
    i_category                Nullable(String), -- char(50)
    i_manufact_id             Nullable(Int64),
    i_manufact                Nullable(String), -- char(50)
    i_size                    Nullable(FixedString(20)),
    i_formulation             Nullable(FixedString(20)),
    i_color                   Nullable(FixedString(20)),
    i_units                   Nullable(FixedString(10)),
    i_container               Nullable(FixedString(10)),
    i_manager_id              Nullable(Int64),
    i_product_name            Nullable(String) -- char(50)
) engine = MergeTree ORDER BY (i_item_sk);

CREATE TABLE income_band
(
    ib_income_band_sk         Int64, -- PK, NOT NULL
    ib_lower_bound            Nullable(Int64),
    ib_upper_bound            Nullable(Int64)
) engine = MergeTree ORDER BY ib_income_band_sk;

CREATE TABLE promotion
(
    p_promo_sk                Int64, -- PK, NOT NULL
    p_promo_id                FixedString(16), -- BK, NOT NULL
    p_start_date_sk           Nullable(Int64), -- FK d_date_sk
    p_end_date_sk             Nullable(Int64), -- FK d_date_sk
    p_item_sk                 Nullable(Int64), -- FK i_item_sk
    p_cost                    Nullable(Decimal(15,2)),
    p_response_target         Nullable(Int64),
    p_promo_name              Nullable(String), -- char(50)
    p_channel_dmail           Nullable(FixedString(1)),
    p_channel_email           Nullable(FixedString(1)),
    p_channel_catalog         Nullable(FixedString(1)),
    p_channel_tv              Nullable(FixedString(1)),
    p_channel_radio           Nullable(FixedString(1)),
    p_channel_press           Nullable(FixedString(1)),
    p_channel_event           Nullable(FixedString(1)),
    p_channel_demo            Nullable(FixedString(1)),
    p_channel_details         Nullable(String), -- varchar(100)
    p_purpose                 Nullable(FixedString(15)),
    p_discount_active         Nullable(FixedString(1)) 
) engine = MergeTree ORDER BY (p_promo_sk);

CREATE TABLE reason
(
    r_reason_sk               Int64, -- PK, NOT NULL
    r_reason_id               FixedString(16), -- BK, NOT NULL
    r_reason_desc             Nullable(String) -- char(100)
) engine = MergeTree ORDER BY (r_reason_sk);

CREATE TABLE ship_mode
(
    sm_ship_mode_sk           Int64, -- PK, NOT NULL
    sm_ship_mode_id           FixedString(16), -- BK, NOT NULL
    sm_type                   Nullable(String), -- char(30)
    sm_code                   Nullable(FixedString(10)),
    sm_carrier                Nullable(FixedString(20)),
    sm_contract               Nullable(FixedString(20))
) engine = MergeTree ORDER BY (sm_ship_mode_sk);

CREATE TABLE time_dim
(
    t_time_sk                 Int64, -- PK, NOT NULL
    t_time_id                 FidexString(16), -- BK, NOT NULL
    t_time                    Int64, -- NOT NULL
    t_hour                    Nullable(Int64),
    t_minute                  Nullable(Int64),
    t_second                  Nullable(Int64),
    t_am_pm                   Nullable(FixedString(2)),
    t_shift                   Nullable(FixedString(20)),
    t_sub_shift               Nullable(FixedString(20)),
    t_meal_time               Nullable(FixedString(20))
) engine = MergeTree ORDER BY (t_time_sk);

