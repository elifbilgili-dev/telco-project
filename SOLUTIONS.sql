-- ==========================================
-- TELCO PROJECT - SOLUTIONS.sql
-- ==========================================

-- 1.1 Kobiye Destek tarifesine sahip müşteriler
-- Kobiye Destek tarifesindeki müşterileri bulmak için CUSTOMERS ve TARIFFS tablolarını TARIFF_ID üzerinden birleştirdim.
-- Tarife adına göre filtreleme yapabilmek için JOIN kullanmak gerekiyordu, sadece CUSTOMERS tablosuyla bu bilgiye ulaşamazdım.
-- WHERE koşuluna t.NAME = 'Kobiye Destek' yazarak sadece bu tarifteki müşterileri getirdim.
SELECT c.CUSTOMER_ID, c.NAME, c.CITY, c.SIGNUP_DATE
FROM C##TELCOUSER.CUSTOMERS c
JOIN C##TELCOUSER.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek';

-- 1.2 Kobiye Destek tarifesine en son kaydolan müşteri
-- En son kayıt tarihini bulmak için alt sorgu içinde MAX(SIGNUP_DATE) kullandım.
-- Dış sorgu bu tarihe eşit olan müşterileri getiriyor, birden fazla müşteri aynı tarihte kayıt olmuş olabilir.
-- Sadece Kobiye Destek müşterileri arasında arama yaptım, diğer tarifeler kapsam dışı.
SELECT c.CUSTOMER_ID, c.NAME, c.CITY, c.SIGNUP_DATE
FROM C##TELCOUSER.CUSTOMERS c
JOIN C##TELCOUSER.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.NAME = 'Kobiye Destek'
AND c.SIGNUP_DATE = (
    SELECT MAX(c2.SIGNUP_DATE)
    FROM C##TELCOUSER.CUSTOMERS c2
    JOIN C##TELCOUSER.TARIFFS t2 ON c2.TARIFF_ID = t2.TARIFF_ID
    WHERE t2.NAME = 'Kobiye Destek'
);

-- 2.1 Tarifelerin müşteri sayısına göre dağılımı
-- Her tarifeye kaç müşteri kayıtlı olduğunu görmek için GROUP BY kullandım.
-- COUNT(CUSTOMER_ID) ile her gruptaki müşteri sayısını hesapladım.
-- ORDER BY DESC ile en çok müşterisi olan tarifeden başlayarak sıraladım.
SELECT t.NAME, COUNT(c.CUSTOMER_ID) AS MUSTERI_SAYISI
FROM C##TELCOUSER.CUSTOMERS c
JOIN C##TELCOUSER.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME
ORDER BY MUSTERI_SAYISI DESC;

-- 3.1 En erken kaydolan müşteriler
-- En eski kayıt tarihini bulmak için alt sorguda MIN(SIGNUP_DATE) kullandım.
-- Sorudaki ipucuna göre en erken müşteriler en küçük ID'ye sahip olmayabilir, bu yüzden ID'ye değil tarihe baktım.
-- Aynı en eski tarihe sahip birden fazla müşteri olabileceğinden hepsini listeledim.
SELECT CUSTOMER_ID, NAME, CITY, SIGNUP_DATE
FROM C##TELCOUSER.CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM C##TELCOUSER.CUSTOMERS
);

-- 3.2 En erken kayıtların şehirlere göre dağılımı
-- Önce en erken kayıt tarihini buldum, sonra o tarihteki müşterileri şehre göre grupladım.
-- GROUP BY CITY ile her şehirdeki müşteri sayısını hesapladım.
-- Sonuçları en çok müşterisi olan şehirden başlayarak sıraladım.
SELECT CITY, COUNT(*) AS MUSTERI_SAYISI
FROM C##TELCOUSER.CUSTOMERS
WHERE SIGNUP_DATE = (
    SELECT MIN(SIGNUP_DATE)
    FROM C##TELCOUSER.CUSTOMERS
)
GROUP BY CITY
ORDER BY MUSTERI_SAYISI DESC;

-- 4.1 Aylık kullanım kaydı olmayan müşteriler
-- CUSTOMERS tablosunda olup MONTHLY_STATS tablosunda kaydı olmayan müşterileri bulmak için NOT IN kullandım.
-- Alt sorgu MONTHLY_STATS'taki tüm CUSTOMER_ID'leri getiriyor, dış sorgu bunların dışındakileri listeliyor.
-- Bu müşterilerin kayıtları veri ekleme hatası nedeniyle eksik kalmış.
SELECT CUSTOMER_ID
FROM C##TELCOUSER.CUSTOMERS
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID
    FROM C##TELCOUSER.MONTHLY_STATS
);

-- 4.2 Eksik kayıtlı müşterilerin şehirlere göre dağılımı
-- Kaydı eksik olan müşterileri bulduktan sonra şehre göre grupladım.
-- COUNT(*) ile her şehirde kaç eksik kayıtlı müşteri olduğunu hesapladım.
-- Hangi şehirlerin daha çok etkilendiğini görmek için ORDER BY DESC ile sıraladım.
SELECT CITY, COUNT(*) AS EKSIK_MUSTERI_SAYISI
FROM C##TELCOUSER.CUSTOMERS
WHERE CUSTOMER_ID NOT IN (
    SELECT CUSTOMER_ID
    FROM C##TELCOUSER.MONTHLY_STATS
)
GROUP BY CITY
ORDER BY EKSIK_MUSTERI_SAYISI DESC;

-- 5.1 Veri limitinin en az %75'ini kullanan müşteriler
-- DATA_USAGE / DATA_LIMIT oranının 0.75 veya üzeri olduğu müşterileri filtreledim.
-- DATA_LIMIT değeri 0 olan tarifeler SMS odaklı olduğu için bu hesaplamanın dışında bıraktım, sıfıra bölme hatası oluşurdu.
-- ROUND ile yüzde değerini 2 ondalık basamakla gösterdim ve kullanım yüzdesine göre sıraladım.
SELECT c.CUSTOMER_ID, c.NAME, t.NAME AS TARIFE,
       m.DATA_USAGE, t.DATA_LIMIT,
       ROUND(m.DATA_USAGE / t.DATA_LIMIT * 100, 2) AS KULLANIM_YUZDESI
FROM C##TELCOUSER.CUSTOMERS c
JOIN C##TELCOUSER.MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN C##TELCOUSER.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.DATA_LIMIT > 0
AND m.DATA_USAGE / t.DATA_LIMIT >= 0.75
ORDER BY KULLANIM_YUZDESI DESC;

-- 5.2 Tüm paket limitlerini tamamen tüketen müşteriler
-- Veri, dakika ve SMS kullanımının aynı anda limitlere ulaştığı müşterileri sorguladım.
-- Üç koşulun aynı anda sağlanması gerektiği için AND ile bağladım.
-- Sorgu sonucunda hiç müşteri gelmedi, veri setinde tüm limitlerini aynı anda dolduran müşteri bulunmuyor.
SELECT c.CUSTOMER_ID, c.NAME, t.NAME AS TARIFE,
       m.DATA_USAGE, m.MINUTE_USAGE, m.SMS_USAGE
FROM C##TELCOUSER.CUSTOMERS c
JOIN C##TELCOUSER.MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN C##TELCOUSER.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.DATA_USAGE >= t.DATA_LIMIT
AND m.MINUTE_USAGE >= t.MINUTE_LIMIT
AND m.SMS_USAGE >= t.SMS_LIMIT;

-- 6.1 Ödenmemiş faturası olan müşteriler
-- PAYMENT_STATUS alanı UNPAID olan kayıtları filtreledim.
-- Müşteri adı, şehir ve tarife bilgilerini de görmek için üç tabloyu birleştirdim.
-- Bu liste takip edilmesi gereken müşterileri gösteriyor.
SELECT c.CUSTOMER_ID, c.NAME, c.CITY, t.NAME AS TARIFE, t.MONTHLY_FEE
FROM C##TELCOUSER.CUSTOMERS c
JOIN C##TELCOUSER.MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN C##TELCOUSER.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.PAYMENT_STATUS = 'UNPAID';

-- 6.2 Tarifelere göre ödeme durumu dağılımı
-- Her tarife için ödeme durumlarını GROUP BY ile grupladım.
-- COUNT(*) ile her kombinasyondaki müşteri sayısını hesapladım.
-- Hangi tarifede ne kadar ödeme sorunu olduğunu görmek için tarife ve ödeme durumuna göre sıraladım.
SELECT t.NAME AS TARIFE, m.PAYMENT_STATUS, COUNT(*) AS MUSTERI_SAYISI
FROM C##TELCOUSER.CUSTOMERS c
JOIN C##TELCOUSER.MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN C##TELCOUSER.TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.NAME, m.PAYMENT_STATUS
ORDER BY t.NAME, m.PAYMENT_STATUS;