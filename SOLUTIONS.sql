-- ==========================================
-- TELCO PROJECT - SOLUTIONS.sql
-- ==========================================

-- Bu dosyada TELCO projesi için gerekli SQL sorguları bulunmaktadır.
-- Sorgular TELCOUSER kullanıcısı altında çalıştırılmıştır.
-- CUSTOMERS, TARIFFS ve MONTHLY_STATS tabloları kullanılmıştır.

-- ==========================================
-- 1.1 Kobiye Destek tarifesine sahip müşteriler
-- ==========================================
-- Bu sorguda Kobiye Destek tarifesini kullanan müşterileri listeledim.
-- Müşterilerin tarife bilgisine ulaşmak için CUSTOMERS ve TARIFFS tablolarını birleştirdim.
-- Filtreleme işlemini tarife adına göre yaptım.

SELECT c.CUSTOMER_ID, c.NAME, c.CITY, c.SIGNUP_DATE
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';


-- ==========================================
-- 1.2 Kobiye Destek tarifesine en son kaydolan müşteri
-- ==========================================
-- Bu sorguda Kobiye Destek tarifesine en son kaydolan müşteriyi buldum.
-- En son kayıt tarihini bulmak için MAX(SIGNUP_DATE) kullandım.
-- Aynı tarihte birden fazla müşteri varsa hepsi listelenebilir.

SELECT c.CUSTOMER_ID, c.NAME, c.CITY, c.SIGNUP_DATE
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
AND c.SIGNUP_DATE = (
    SELECT MAX(c2.SIGNUP_DATE)
    FROM CUSTOMERS c2
    JOIN TARIFFS t2 ON c2.TARIFF_ID = t2.TARIFF_ID
    WHERE t2.NAME = 'Kobiye Destek'
);


-- ==========================================
-- 2.1 Tarifelerin müşteri sayısına göre dağılımı
-- ==========================================
-- Bu sorguda her tarifede kaç müşteri olduğunu buldum.
-- Bunun için müşterileri tarife adına göre grupladım.
-- Sonuçları müşteri sayısı en fazla olan tarifeden başlayarak sıraladım.

SELECT t.NAME AS TARIFE, COUNT(c.CUSTOMER_ID) AS MUSTERI_SAYISI
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME
ORDER BY MUSTERI_SAYISI DESC;


-- ==========================================
-- 3.1 En erken kaydolan müşteriler
-- ==========================================
-- Bu sorguda sisteme en erken kaydolan müşterileri listeledim.
-- En eski kayıt tarihini bulmak için MIN(SIGNUP_DATE) kullandım.
-- Aynı tarihte kayıt olan birden fazla müşteri varsa hepsi gösterilir.

SELECT CUSTOMER_ID, NAME, CITY, SIGNUP_DATE
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
);


-- ==========================================
-- 3.2 En erken kayıtların şehirlere göre dağılımı
-- ==========================================
-- Bu sorguda en erken kayıt tarihine sahip müşterileri şehirlerine göre grupladım.
-- Böylece en eski kayıtların hangi şehirlerde olduğunu görebiliriz.
-- Sonuçları müşteri sayısına göre sıraladım.

SELECT CITY, COUNT(*) AS MUSTERI_SAYISI
FROM CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM CUSTOMERS
)
GROUP BY CITY
ORDER BY MUSTERI_SAYISI DESC;


-- ==========================================
-- 4.1 Aylık kullanım kaydı olmayan müşteriler
-- ==========================================
-- Bu sorguda CUSTOMERS tablosunda olup MONTHLY_STATS tablosunda kaydı olmayan müşterileri buldum.
-- Bunun için NOT IN kullandım.
-- Sonuçta aylık kullanım bilgisi eksik olan müşteri ID'leri listelenir.

SELECT CUSTOMER_ID
FROM CUSTOMERS
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID
    FROM MONTHLY_STATS
);


-- ==========================================
-- 4.2 Eksik kayıtlı müşterilerin şehirlere göre dağılımı
-- ==========================================
-- Bu sorguda aylık kullanım kaydı olmayan müşterileri şehirlerine göre grupladım.
-- Her şehirde kaç eksik kayıt olduğunu COUNT ile hesapladım.
-- Sonuçları eksik kayıt sayısı en fazla olan şehirden başlayarak sıraladım.

SELECT CITY, COUNT(*) AS EKSIK_MUSTERI_SAYISI
FROM CUSTOMERS
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID
    FROM MONTHLY_STATS
)
GROUP BY CITY
ORDER BY EKSIK_MUSTERI_SAYISI DESC;


-- ==========================================
-- 5.1 Veri limitinin en az %75'ini kullanan müşteriler
-- ==========================================
-- Bu sorguda veri limitinin en az %75'ini kullanan müşterileri listeledim.
-- Kullanım yüzdesini DATA_USAGE ve DATA_LIMIT değerleri üzerinden hesapladım.
-- DATA_LIMIT değeri 0 olan tarifeleri hesaplamaya dahil etmedim.

SELECT c.CUSTOMER_ID, c.NAME, t.NAME AS TARIFE,
       m.DATA_USAGE, t.DATA_LIMIT,
       ROUND(m.DATA_USAGE / t.DATA_LIMIT * 100, 2) AS KULLANIM_YUZDESI
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.DATA_LIMIT > 0
AND m.DATA_USAGE / t.DATA_LIMIT >= 0.75
ORDER BY KULLANIM_YUZDESI DESC;


-- ==========================================
-- 5.2 Tüm paket limitlerini tamamen tüketen müşteriler
-- ==========================================
-- Bu sorguda veri, dakika ve SMS limitlerinin tamamını kullanan müşterileri bulmaya çalıştım.
-- Üç kullanım değerini de ilgili tarife limitleriyle karşılaştırdım.
-- Tüm şartların aynı anda sağlanması için AND kullandım.

SELECT c.CUSTOMER_ID, c.NAME, t.NAME AS TARIFE,
       m.DATA_USAGE, m.MINUTE_USAGE, m.SMS_USAGE
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.DATA_USAGE >= t.DATA_LIMIT
AND m.MINUTE_USAGE >= t.MINUTE_LIMIT
AND m.SMS_USAGE >= t.SMS_LIMIT;


-- ==========================================
-- 6.1 Ödenmemiş faturası olan müşteriler
-- ==========================================
-- Bu sorguda ödeme durumu UNPAID olan müşterileri listeledim.
-- Müşteri bilgileri, tarife bilgileri ve ödeme durumu birlikte gösterilir.
-- Böylece ödemesi yapılmamış müşteriler kolayca görülebilir.

SELECT c.CUSTOMER_ID, c.NAME, c.CITY, t.NAME AS TARIFE, m.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.PAYMENT_STATUS = 'UNPAID';


-- ==========================================
-- 6.2 Tarifelere göre ödeme durumu dağılımı
-- ==========================================
-- Bu sorguda her tarifede ödeme durumlarının dağılımını gösterdim.
-- Tarife adı ve ödeme durumuna göre gruplama yaptım.
-- COUNT ile her gruptaki müşteri sayısını hesapladım.

SELECT t.NAME AS TARIFE, m.PAYMENT_STATUS, COUNT(*) AS MUSTERI_SAYISI
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME, m.PAYMENT_STATUS
ORDER BY t.NAME, m.PAYMENT_STATUS;