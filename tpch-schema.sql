CREATE DATABASE IF NOT EXISTS tpch;
USE tpch;

DROP TABLE IF EXISTS PART;
DROP TABLE IF EXISTS SUPPLIER;
DROP TABLE IF EXISTS PARTSUPP;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS ORDERS;
DROP TABLE IF EXISTS LINEITEM;
DROP TABLE IF EXISTS NATION;
DROP TABLE IF EXISTS REGION;

CREATE TABLE PART
(
    P_PARTKEY       Int32,  -- PK
    P_NAME          String, -- variable text, size 55
    P_MFGR          FixedString(25),
    P_BRAND         FixedString(10),
    P_TYPE          String, -- variable text, size 25
    P_SIZE          Int32,  -- integer
    P_CONTAINER     FixedString(10),
    P_RETAILPRICE   Decimal(18,2),
    P_COMMENT       String, -- variable text, size 23
    CONSTRAINT pk CHECK P_PARTKEY >= 0,
    CONSTRAINT positive CHECK (P_SIZE >= 0 AND P_RETAILPRICE >= 0)
) engine = MergeTree ORDER BY (P_PARTKEY);

CREATE TABLE SUPPLIER
(
    S_SUPPKEY       Int32,  -- PK
    S_NAME          FixedString(25),
    S_ADDRESS       String, -- variable text, size 40
    S_NATIONKEY     Int32,  -- FK N_NATIONKEY
    S_PHONE         FixedString(15),
    S_ACCTBAL       Decimal(18,2),
    S_COMMENT       String, -- variable text, size 101
    CONSTRAINT pk CHECK S_SUPPKEY >= 0
) engine = MergeTree ORDER BY (S_SUPPKEY);

CREATE TABLE PARTSUPP
(
    PS_PARTKEY      Int32,  -- PK(1), FK P_PARTKEY
    PS_SUPPKEY      Int32,  -- PK(2), FK S_SUPPKEY
    PS_AVAILQTY     Int32,  -- integer
    PS_SUPPLYCOST   Decimal(18,2),
    PS_COMMENT      String, -- variable text, size 199
    CONSTRAINT pk CHECK PS_PARTKEY >= 0,
    CONSTRAINT c1 CHECK (PS_AVAILQTY >= 0 AND PS_SUPPLYCOST >= 0)
) engine = MergeTree ORDER BY (PS_PARTKEY, PS_SUPPKEY);

CREATE TABLE CUSTOMER
(
    C_CUSTKEY       Int32,  -- PK
    C_NAME          String, -- variable text, size 25
    C_ADDRESS       String, -- variable text, size 40
    C_NATIONKEY     Int32,  -- FK N_NATIONKEY
    C_PHONE         FixedString(15),
    C_ACCTBAL       Decimal(18,2),
    C_MKTSEGMENT    FixedString(10),
    C_COMMENT       String, -- variable text, size 117
    CONSTRAINT pk CHECK C_CUSTKEY >= 0
) engine = MergeTree ORDER BY (C_CUSTKEY);

CREATE TABLE ORDERS
(
    O_ORDERKEY      Int32,  -- PK
    O_CUSTKEY       Int32,  -- FK C_CUSTKEY
    O_ORDERSTATUS   FixedString(1),
    O_TOTALPRICE    Decimal(18,2),
    O_ORDERDATE     Date,
    O_ORDERPRIORITY FixedString(15),
    O_CLERK         FixedString(15),
    O_SHIPPRIORITY  Int32,  -- integer
    O_COMMENT       String, -- variable text, size 79
    CONSTRAINT c1 CHECK O_TOTALPRICE >= 0
) engine = MergeTree ORDER BY (O_ORDERDATE, O_ORDERKEY);

CREATE TABLE LINEITEM
(
    L_ORDERKEY      Int32,  -- PK(1), FK O_ORDERKEY
    L_PARTKEY       Int32,  -- FK PS_PARTKEY
    L_SUPPKEY       Int32,  -- FK PS_SUPPKEY
    L_LINENUMBER    Int32,  -- PK(2)
    L_QUANTITY      Decimal(18,2),
    L_EXTENDEDPRICE Decimal(18,2),
    L_DISCOUNT      Decimal(18,2),
    L_TAX           Decimal(18,2),
    L_RETURNFLAG    FixedString(1),
    L_LINESTATUS    FixedString(1),
    L_SHIPDATE      Date,
    L_COMMITDATE    Date,
    L_RECEIPTDATE   Date,
    L_SHIPINSTRUCT  FixedString(25),
    L_SHIPMODE      FixedString(10),
    L_COMMENT       String, -- variable text size 44
    CONSTRAINT c1 CHECK (L_QUANTITY >= 0 AND L_EXTENDEDPRICE >= 0 AND L_TAX >= 0 AND L_SHIPDATE <= L_RECEIPTDATE)
--  CONSTRAINT c2 CHECK (L_DISCOUNT >= 0 AND L_DISCOUNT <= 1)
) engine = MergeTree ORDER BY (L_SHIPDATE, L_RECEIPTDATE, L_ORDERKEY, L_LINENUMBER);

CREATE TABLE NATION
(
    N_NATIONKEY     Int32,  -- PK
    N_NAME          FixedString(25),
    N_REGIONKEY     Int32,  -- FK R_REGIONKEY
    N_COMMENT       String, -- variable text, size 152
    CONSTRAINT pk CHECK N_NATIONKEY >= 0
) Engine = MergeTree ORDER BY (N_NATIONKEY);

CREATE TABLE REGION
(
    R_REGIONKEY     Int32,  -- PK
    R_NAME          FixedString(25),
    R_COMMENT       String, -- variable text, size 152
    CONSTRAINT pk CHECK R_REGIONKEY >= 0
) engine = MergeTree ORDER BY (R_REGIONKEY);
