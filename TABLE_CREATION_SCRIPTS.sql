-- ==========================================
-- TELCO PROJECT - TABLE_CREATION_SCRIPTS.sql
-- ==========================================

-- Bu script TELCOUSER kullanıcısı altında çalıştırılacaktır.
-- Tablolar telekom müşteri, tarife ve aylık kullanım bilgilerini tutmak için oluşturulmuştur.

-- ==========================================
-- TARIFFS tablosu
-- ==========================================
-- Bu tablo tarifelerin bilgilerini tutar.
-- Her tarifenin bir ID değeri, adı, aylık ücreti ve kullanım limitleri vardır.

CREATE TABLE TARIFFS (
    TARIFF_ID    NUMBER(10) PRIMARY KEY,
    NAME         VARCHAR2(100) NOT NULL,
    MONTHLY_FEE  NUMBER(10,2) NOT NULL,
    DATA_LIMIT   NUMBER(10) NOT NULL,
    MINUTE_LIMIT NUMBER(10) NOT NULL,
    SMS_LIMIT    NUMBER(10) NOT NULL
);

-- ==========================================
-- CUSTOMERS tablosu
-- ==========================================
-- Bu tablo müşterilerin temel bilgilerini tutar.
-- Her müşteri bir tarifeye bağlıdır.
-- Bu yüzden TARIFF_ID alanı, TARIFFS tablosundaki TARIFF_ID alanına bağlanmıştır.

CREATE TABLE CUSTOMERS (
    CUSTOMER_ID NUMBER(10) PRIMARY KEY,
    NAME        VARCHAR2(100) NOT NULL,
    CITY        VARCHAR2(100) NOT NULL,
    SIGNUP_DATE DATE NOT NULL,
    TARIFF_ID   NUMBER(10) NOT NULL,

    CONSTRAINT fk_customers_tariff
        FOREIGN KEY (TARIFF_ID)
        REFERENCES TARIFFS(TARIFF_ID)
);

-- ==========================================
-- MONTHLY_STATS tablosu
-- ==========================================
-- Bu tablo müşterilerin aylık kullanım bilgilerini tutar.
-- DATA_USAGE internet kullanımını, MINUTE_USAGE dakika kullanımını,
-- SMS_USAGE ise SMS kullanımını gösterir.
-- PAYMENT_STATUS alanı ödeme durumunu tutar.

CREATE TABLE MONTHLY_STATS (
    ID             NUMBER(10) PRIMARY KEY,
    CUSTOMER_ID    NUMBER(10) NOT NULL,
    DATA_USAGE     NUMBER(10,2),
    MINUTE_USAGE   NUMBER(10),
    SMS_USAGE      NUMBER(10),
    PAYMENT_STATUS VARCHAR2(20),

    CONSTRAINT fk_stats_customer
        FOREIGN KEY (CUSTOMER_ID)
        REFERENCES CUSTOMERS(CUSTOMER_ID),

    CONSTRAINT chk_payment_status
        CHECK (PAYMENT_STATUS IN ('PAID', 'UNPAID', 'LATE'))
);

-- ==========================================
-- INDEXLER
-- ==========================================
-- Bu indexler, sorguların daha hızlı çalışması için eklenmiştir.
-- Özellikle foreign key alanları ve ödeme durumu sorgularda kullanılabilir.

CREATE INDEX idx_customers_tariff_id
ON CUSTOMERS(TARIFF_ID);

CREATE INDEX idx_monthly_stats_customer_id
ON MONTHLY_STATS(CUSTOMER_ID);

CREATE INDEX idx_monthly_stats_payment_status
ON MONTHLY_STATS(PAYMENT_STATUS);