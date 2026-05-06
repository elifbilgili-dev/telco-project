-- ==========================================
-- TELCO PROJECT - TABLE_CREATION_SCRIPTS.sql
-- ==========================================

-- Kullanıcı oluşturma ve gerekli yetkileri verme
CREATE USER C##TELCOUSER IDENTIFIED BY telco123;
GRANT CONNECT, RESOURCE TO C##TELCOUSER;
ALTER USER C##TELCOUSER QUOTA UNLIMITED ON USERS;

-- TARIFFS tablosu
-- Tarifelerin adı, aylık ücreti ve kullanım limitlerini tutuyor.
-- TARIFF_ID primary key olarak tanımlandı.
-- Tüm sütunlar zorunlu tutuldu çünkü tarife bilgisi eksik olamaz.
CREATE TABLE C##TELCOUSER.TARIFFS (
    TARIFF_ID    NUMBER(10) PRIMARY KEY,
    NAME         VARCHAR2(100) NOT NULL,
    MONTHLY_FEE  NUMBER(10,2) NOT NULL,
    DATA_LIMIT   NUMBER(10) NOT NULL,
    MINUTE_LIMIT NUMBER(10) NOT NULL,
    SMS_LIMIT    NUMBER(10) NOT NULL
);

-- CUSTOMERS tablosu
-- Müşterilerin temel bilgilerini ve hangi tarifede olduklarını tutuyor.
-- TARIFF_ID foreign key olarak TARIFFS tablosuna bağlandı.
-- SIGNUP_DATE müşterinin sisteme kayıt tarihini gösteriyor.
CREATE TABLE C##TELCOUSER.CUSTOMERS (
    CUSTOMER_ID NUMBER(10) PRIMARY KEY,
    NAME        VARCHAR2(100) NOT NULL,
    CITY        VARCHAR2(100) NOT NULL,
    SIGNUP_DATE DATE NOT NULL,
    TARIFF_ID   NUMBER(10) NOT NULL,
    CONSTRAINT fk_customers_tariff 
        FOREIGN KEY (TARIFF_ID) 
        REFERENCES C##TELCOUSER.TARIFFS(TARIFF_ID)
);

-- MONTHLY_STATS tablosu
-- Müşterilerin aylık veri, dakika ve SMS kullanımlarını ve ödeme durumlarını tutuyor.
-- CUSTOMER_ID foreign key olarak CUSTOMERS tablosuna bağlandı.
-- PAYMENT_STATUS alanı sadece PAID, UNPAID veya LATE değerlerini alabilir.
CREATE TABLE C##TELCOUSER.MONTHLY_STATS (
    ID             NUMBER(10) PRIMARY KEY,
    CUSTOMER_ID    NUMBER(10) NOT NULL,
    DATA_USAGE     NUMBER(10,2),
    MINUTE_USAGE   NUMBER(10),
    SMS_USAGE      NUMBER(10),
    PAYMENT_STATUS VARCHAR2(20),
    CONSTRAINT fk_stats_customer
        FOREIGN KEY (CUSTOMER_ID)
        REFERENCES C##TELCOUSER.CUSTOMERS(CUSTOMER_ID),
    CONSTRAINT chk_payment_status
        CHECK (PAYMENT_STATUS IN ('PAID', 'UNPAID', 'LATE'))
);

-- Sorgularda kullanılan kolonlar için indeksler
CREATE INDEX idx_customers_tariff_id 
ON C##TELCOUSER.CUSTOMERS(TARIFF_ID);

CREATE INDEX idx_monthly_stats_customer_id 
ON C##TELCOUSER.MONTHLY_STATS(CUSTOMER_ID);

CREATE INDEX idx_monthly_stats_payment_status 
ON C##TELCOUSER.MONTHLY_STATS(PAYMENT_STATUS);