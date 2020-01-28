CREATE DATABASE IF NOT EXISTS tcph;
USE tpch;

CREATE TABLE PART
(
    P_PARTKEY       Int32,  -- identifier
    P_NAME          String, -- variable text, size 55
    P_MFGR          FixedString(25),
    P_BRAND         FixedString(10),
    P_TYPE          String, -- variable text, size 25
    P_SIZE          Int32,  -- integer
    P_CONTAINER     FixedString(10),
    P_RETAILPRICE   Decimal(18,2),
    P_COMMENT       String  -- variable text, size 23
    -- PRIMARY KEY (P_PARTKEY)
    CONSTRAINT pk CHECK P_PARTKEY >= 0,
    CONSTRAINT positive CHECK (P_SIZE >= 0 AND P_RETAILPRICE >= 0)
) engine = MergeTree ORDER BY (P_PARTKEY);

CREATE TABLE SUPPLIER
(
    S_SUPPKEY       Int32,  -- identifier
    S_NAME          FixedString(25),
    S_ADDRESS       String, -- variable text, size 40
    S_NATIONKEY     Int32,  -- identifier
    S_PHONE         FixedString(15),
    S_ACCTBAL       Decimal(18,2),
    S_COMMENT       String  -- variable text, size 101
    -- PRIMARY KEY (S_SUPPKEY)
    CONSTRAINT pk CHECK S_SUPPKEY >= 0
) engine = MergeTree ORDER BY (S_SUPPKEY, S_NATIONKEY);

CREATE TABLE PARTSUPP
(
    PS_PARTKEY      Int32,  -- identifier
    PS_SUPPKEY      Int32,  -- identifier
    PS_AVAILQTY     Int32,  -- integer
    PS_SUPPLYCOST   Decimal(18,2),
    PS_COMMENT      String  -- variable text, size 199
    -- PRIMARY KEY (PS_PARTKEY, PS_SUPPKEY)
    -- FOREIGN KEY (PS_PARTKEY) -> P_PARTKEY
    -- FOREIGN KEY (PS_SUPPKEY) -> S_SUPPKEY
    CONSTRAINT pk CHECK PS_PARTKEY >= 0,
    CONSTRAINT c1 CHECK (PS_AVAILQTY >= 0 AND PS_SUPPLYCOST >= 0)
) engine = MergeTree ORDER BY (PS_PARTKEY, PS_SUPPKEY);

CREATE TABLE CUSTOMER
(
    C_CUSTKEY       Int32,  -- identifier
    C_NAME          String, -- variable text, size 25
    C_ADDRESS       String, -- variable text, size 40
    C_NATIONKEY     Int32,  -- identifier
    C_PHONE         FixedString(15),
    C_ACCTBAL       Decimal(18,2),
    C_MKTSEGMENT    FixedString(10),
    C_COMMENT       String  -- variable text, size 117
    -- PRIMARY KEY (C_CUSTKEY)
    -- FOREIGN KEY (C_NATIONKEY) -> N_NATIONKEY
    CONSTRAINT pk CHECK C_CUSTKEY >= 0
) engine = MergeTree ORDER BY (C_CUSTKEY, C_NATIONKEY);

CREATE TABLE ORDERS
(
    O_ORDERKEY      Int32,  -- identifier
    O_CUSTKEY       Int32,  -- identifier
    O_ORDERSTATUS   FixedString(1),
    O_TOTALPRICE    Decimal(18,2),
    O_ORDERDATE     Date,
    O_ORDERPRIORITY FixedString(15),
    O_CLERK         FixedString(15),
    O_SHIPPRIORITY  Int32,  -- integer
    O_COMMENT       String, -- variable text, size 79
    -- PRIMARY KEY (O_ORDERKEY)
    -- FOREIGN KEY (O_CUSTKEY) -> C_CUSTKEY
    CONSTRAINT c1 CHECK O_TOTALPRICE >= 0
) engine = MergeTree ORDER BY (O_ORDERKEY, O_CUSTKEY);

CREATE TABLE LINEITEM
(
    L_ORDERKEY      Int32,  -- identifier
    L_PARTKEY       Int32,  -- identifier
    L_SUPPKEY       Int32,  -- identifier
    L_LINENUMBER    Int32,  -- integer
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
    -- PRIMARY KEY (L_ORDERKEY, L_LINENUMBER)
    -- FOREIGN KEY (L_ORDERKEY) -> O_ORDERKEY
    -- FOREIGN KEY (L_PARTKEY, L_SUPPKEY) -> (PS_PARTKEY, PS_SUPPKEY)
    CONSTRAINT c1 CHECK (L_QUANTITY >= 0 AND L_EXTENDEDPRICE >= 0 AND L_TAX >= 0 AND L_SHIPDATE <= L_RECEIPTDATE)
    CONSTRAINT c2 CHECK (L_DISCOUNT >= 0 AND L_DISCOUNT <= 1.00)
) engine = MergeTree ORDER BY (L_ORDERKEY, L_LINENUMBER, L_PARTKEY, L_SUPPKEY);

CREATE TABLE NATION
(
    N_NATIONKEY     Int32,  -- identifier
    N_NAME          FixedString(25),
    N_REGIONKEY     Int32,  -- identifier
    N_COMMENT       String, -- variable text, size 152
    -- PRIMARY KEY (N_NATIONKEY)
    -- FOREIGN KEY (N_REGIONKEY) -> R_REGIONKEY
    CONSTRAINT pk CHECK N_NATIONKEY >= 0
) Engine = MergeTree ORDER BY (N_NATIONKEY, N_REGIONKEY);

CREATE TABLE REGION
(
    R_REGIONKEY     Int32,  -- identifier
    R_NAME          FixedString(25),
    R_COMMENT       String, -- variable text, size 152
    -- PRIMARY KEY (R_REGIONKEY)
    CONSTRAINT pk CHECK R_REGIONKEY >= 0
) engine = MergeTree ORDER BY (R_REGIONKEY);
