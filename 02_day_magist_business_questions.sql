/*
*******************************************************************************
*******************************************************************************

MAGIST 2 - BUSINESS QUESTIONS

*******************************************************************************
*******************************************************************************

Eniac's two main concerns:
    - Is Magist a good fit for high-end tech products?
    - Are orders delivered on time?

Many of these questions need columns from different tables. Business terms have
to be translated into tables, columns and aggregations. Where the question is
open (what counts as "tech", what counts as "expensive"), make your own
assumption and write it down.

All prices are in euros.

Tables: orders, order_items, order_payments, order_reviews, products,
        product_category_name_translation, customers, sellers, geo
*/

USE magist;


/*******************************************************************************
2.1  PRODUCTS
*******************************************************************************/

/* What categories of tech products does Magist have?
   Category names are in Portuguese, the translation table has the English
   ones. Decide which categories you count as tech and note your list. */


SELECT
    pt.product_category_name_english AS category,
    COUNT(*) AS produkte
FROM
    products p
        JOIN
    product_category_name_translation pt ON pt.product_category_name = p.product_category_name
WHERE
    pt.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'watches_gifts',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony')
GROUP BY category
ORDER BY produkte DESC
;

		-- 10 Kategorien, 5.152 von 32.951 Produkten = 15,6 %
		-- watches_gifts wegen Smartwatches dabei



/* How many products of these tech categories have been sold (within the time
   window of the database snapshot)? What percentage does that represent from
   the overall number of products sold? */

SELECT
    COUNT(*) AS tech_items_sold,
    (SELECT
            COUNT(*)
        FROM
            order_items) AS all_items_sold,
    ROUND(COUNT(*) * 100.0 / (SELECT
                    COUNT(*)
                FROM
                    order_items),
            2) AS pct_of_all
FROM
    order_items oi
        JOIN
    products p USING (product_id)
        JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('computers' , 'computers_accessories',
        'electronics',
        'telephony',
        'fixed_telephony',
        'tablets_printing_image',
        'audio',
        'consoles_games',
        'pc_gamer',
        'watches_gifts');

		-- 23.190 von 112.650 verkauften Artikeln sind Technik = 20,59 %



-- What's the average price of the products being sold?

SELECT
    ROUND(AVG(price), 2) AS avg_price
FROM
    order_items;

		-- 120,65€ im Schnitt, Median liegt bei 74,99€



/* Are expensive tech products popular?
   Tip: CASE WHEN. Define a price threshold for "expensive" first and write
   down which one you picked. */


SELECT
    pt.product_category_name_english AS produkt,
    CASE
        WHEN oi.price < 50 THEN '1. < 50€'
        WHEN oi.price < 100 THEN '2. 50-100€'
        WHEN oi.price < 200 THEN '3. 100-200€'
        WHEN oi.price < 500 THEN '4. 200-500€'
        WHEN oi.price >= 500 THEN '5. ab 500€'
    END AS price_range,
    COUNT(*) AS artikel_verkauft,
    ROUND(SUM(oi.price), 0) AS umsatz_in_€,
    ROUND(AVG(r.review_score), 2) AS durschn_bewertungen
FROM
    order_items oi
        JOIN
    products p USING (product_id)
        JOIN
    product_category_name_translation pt USING (product_category_name)
        LEFT JOIN
    order_reviews r ON oi.order_id = r.order_id
WHERE
    pt.product_category_name_english IN ('computers' , 'computers_accessories',
        'electronics',
        'telephony',
        'fixed_telephony',
        'tablets_printing_image',
        'audio',
        'consoles_games',
        'pc_gamer',
        'watches_gifts')
GROUP BY price_range , pt.product_category_name_english
ORDER BY price_range DESC , umsatz_in_€ DESC
;
								-- verkauft    Umsatz €    Bewert.
-- # Top3 ab 500€
--        1. watches_gifts,          575,    479866,     4.10
--        2. computers,              202,    222929,     4.14
--        3. computers_accessories,  161,    159924,     3.91

		-- 1.145 von 23.190 Tech-Artikeln ab 500€ = 4,9 %, davon aber 34 % Umsatz
		-- nach Stueckzahl also nein, nach Umsatz ja




/*******************************************************************************
2.2  SELLERS
*******************************************************************************/

-- How many months of data are included in the magist database?


-- Spanne und Anzahl Monate
SELECT MIN(order_purchase_timestamp) AS erste_bestellung,
       MAX(order_purchase_timestamp) AS letzte_bestellung,
       COUNT(DISTINCT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS monate
FROM orders;

-- insgesamt 25 monate vom 04.09.2016 bis 17.10.2018


-- Bestellungen je Monat (zeigt die leeren Randmonate)
SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS monat,
       COUNT(*) AS bestellungen
FROM orders
GROUP BY monat
ORDER BY monat;

		-- 09/2016, 12/2016, 09/2018 und 10/2018 fast leer, 11/2016 fehlt
		-- brauchbar waeren 20 Monate, wir rechnen mit 25


/* How many sellers are there? How many tech sellers are there?
   What percentage of overall sellers are tech sellers? */

SELECT COUNT(DISTINCT seller_id) AS seller
FROM sellers;

	-- es gibt 3095 Seller



SELECT COUNT(DISTINCT oi.seller_id) AS tech_seller,
       ROUND(COUNT(DISTINCT oi.seller_id) * 100.0
             / (SELECT COUNT(*) FROM sellers), 2) AS anteil_prozent
FROM order_items oi
JOIN products p USING (product_id)
JOIN product_category_name_translation pt USING (product_category_name)
WHERE pt.product_category_name_english IN (
    'computers', 'computers_accessories', 'electronics', 'telephony',
    'fixed_telephony', 'tablets_printing_image', 'audio',
    'consoles_games', 'pc_gamer', 'watches_gifts');

	-- 548 Tech-Seller = 17,71 % aller Seller



/* What is the total amount earned by all sellers?
   What is the total amount earned by all tech sellers? */

SELECT
	ROUND(SUM(price),2) AS umsatz  -- ROUND(SUM(price), -3) wenn man vor dem Komma 3 Positionen runden möchte
FROM
	order_items
;
		-- der Gesamtumsatz der Verkäufer beträgt 13.591.643,70€

SELECT
    ROUND(SUM(oi.price), 2) AS umsatz_tech
FROM
    order_items oi
        JOIN
    products p USING (product_id)
        JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('computers' , 'computers_accessories',
        'electronics',
        'telephony',
        'fixed_telephony',
        'tablets_printing_image',
        'audio',
        'consoles_games',
        'pc_gamer',
        'watches_gifts');

        -- 3.100.648,48€ = 22,8 % des Gesamtumsatzes


/* Can you work out the average monthly income of all sellers?
   Can you work out the average monthly income of tech sellers? */


SELECT ROUND(SUM(price) / 25, 2) AS umsatz_pro_monat,
       ROUND(SUM(price) / 25 / (SELECT COUNT(*) FROM sellers), 2) AS pro_seller
FROM order_items;
		-- 543.665,75€ pro Monat, 175,66€ pro Seller und Monat

SELECT
    ROUND(SUM(oi.price) / 25, 2) AS umsatz_tech_pro_monat,
    ROUND(SUM(oi.price) / 25 / COUNT(DISTINCT oi.seller_id),
            2) AS pro_tech_seller
FROM
    order_items oi
        JOIN
    products p USING (product_id)
        JOIN
    product_category_name_translation pt USING (product_category_name)
WHERE
    pt.product_category_name_english IN ('computers' , 'computers_accessories',
        'electronics',
        'telephony',
        'fixed_telephony',
        'tablets_printing_image',
        'audio',
        'consoles_games',
        'pc_gamer',
        'watches_gifts');

        -- 124.025,94€ pro Monat, 226,32€ pro Tech-Seller und Monat
        -- Median je Seller nur 821€, Mittelwert 4.391€ - starke Ausreisser


/*******************************************************************************
2.3  DELIVERY TIME
*******************************************************************************/

/* 9. What's the average time between the order being placed and the product
   being delivered? */

SELECT
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 1) AS average_delivery_days
FROM
    orders
WHERE
    order_status = 'delivered'
;
			-- Die Durchschnittliche Lieferzeit beträgt 12 Tage.


-- 10. How many orders are delivered on time vs orders delivered with a delay?

SELECT
	SUM(CASE
			WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
            ELSE 0
		END) AS delivered_on_time,
    SUM(CASE
			WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
            ELSE 0
		END) AS delivered_with_delay
FROM
    orders
WHERE
    order_status = 'delivered'
;
		-- Bestellungen, die rechtzeitig geliefert wurden: 88.644
		-- Bestellungen, die verspätet geliefert wurden: 7.826

SELECT 88644+7826; -- 96.470 Bestellungen insgesamt
SELECT ROUND(100.0 * 7826 / 96470, 2) AS percent_orders_with_delay; -- 8,1% der Bestellungen kamen verspätet


/* 11. Is there any pattern for delayed orders, e.g. big products being delayed
   more often? */

SELECT
    COUNT(*) AS number_of_products,
    ROUND(AVG(p.product_weight_g) / 1000.0, 2) AS average_weight_kg,
    ROUND(AVG(p.product_length_cm * p.product_height_cm * p.product_width_cm) / 1000.0, 2) AS average_volume_l,
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'on time'
        ELSE 'delayed'
    END AS lieferung
FROM
    orders o
		JOIN
    order_items oi USING(order_id)
		JOIN
    products p USING(product_id)
WHERE
    o.order_status = 'delivered'
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'on time'
        ELSE 'delayed'
    END;
		-- verspaetet: 2,38 kg / 16,6 l   -   puenktlich: 2,06 kg / 15,05 l
		-- also nur rund 15 % groesser, schwacher Zusammenhang


-- Verspaetungen nach Bundesland

SELECT
    g.state,
    COUNT(*) AS bestellungen,
    ROUND(100.0 * SUM(CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
        ELSE 0
    END) / COUNT(*), 1) AS verspaetet_prozent
FROM
    orders o
		JOIN
    customers c USING(customer_id)
		JOIN
    geo g ON c.customer_zip_code_prefix = g.zip_code_prefix
WHERE
    o.order_status = 'delivered'
GROUP BY g.state
HAVING bestellungen >= 500
ORDER BY verspaetet_prozent DESC
;
		-- MA 19,7 %, CE 15,3 %, BA 14,0 %  gegen  PR 5,0 %, MG 5,6 %, SP 5,9 %
		-- Norden/Nordosten ist das Problem, nicht die Produktgroesse


-- Verspaetungen im Zeitverlauf

SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS monat,
    COUNT(*) AS bestellungen,
    ROUND(AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 1) AS schnitt_tage,
    ROUND(100.0 * SUM(CASE
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
        ELSE 0
    END) / COUNT(*), 1) AS verspaetet_prozent
FROM
    orders
WHERE
    order_status = 'delivered'
GROUP BY monat
HAVING bestellungen > 100
ORDER BY monat
;
		-- Spitze 03/2018 mit 21,4 %, danach Rueckgang auf rund 10 %
		-- Lieferzeit faellt von 16,9 Tagen (02/2018) auf 7,7 (08/2018)


/*
-------------------------------------------------------------------------------
ASSUMPTIONS WE MADE

Tech categories:
    computers, computers_accessories, electronics, telephony, fixed_telephony,
    tablets_printing_image, audio, consoles_games, pc_gamer, watches_gifts
    -> watches_gifts wegen Smartwatches. Ohne sie waere der Tech-Anteil 15,3 %
       statt 20,6 %. Haushaltsgeraete und Medien zaehlen wir nicht mit.

"Expensive" threshold:
    ab 500 EUR. 99. Perzentil aller Artikel liegt bei 890 EUR.

A seller counts as a tech seller when:
    er mind. 1 Artikel aus den 10 Kategorien verkauft hat.

Other:
    Preise in Euro. Umsatz = SUM(order_items.price), ohne Versand.
    Zeitraum 25 Monate (4 Randmonate fast leer, 11/2016 fehlt).
    Lieferzeit mit TIMESTAMPDIFF(DAY), schneidet pro Zeile ab.

-------------------------------------------------------------------------------
NOTES FOR THE PRESENTATION

Fit for high-end tech:
    5.152 / 32.951 Katalogprodukte sind Tech       15,6 %
    23.190 / 112.650 verkaufte Artikel             20,6 %
    548 / 3.095 Seller                             17,7 %
    Tech-Umsatz 3.100.648 EUR                      22,8 %

    Ø Preis Tech 133,71 vs. Nicht-Tech 117,27
    42,8 % der Tech-Artikel unter 50 EUR
    nur 4,9 % ab 500 EUR, die aber 34 % des Tech-Umsatzes machen
    "computers": 203 verkaufte Artikel in 25 Monaten, Ø 1.098 EUR
    Bewertungen ueber alle Preisklassen stabil 3,9 - 4,0

Delivery speed:
    Ø 12 Tage vom Kauf bis zur Zustellung
    88.644 puenktlich / 7.826 verspaetet = 8,1 % Verspaetungsquote
    nur 27 % aller Lieferungen kommen binnen 7 Tagen an

    Muster: Produktgroesse spielt kaum eine Rolle (2,38 vs 2,06 kg).
    Entscheidend sind Region und Zeitraum.
    MA 19,7 % / CE 15,3 % / BA 14,0 %  gegen  PR 5,0 % / SP 5,9 %
    SP allein macht 42 % aller Lieferungen aus.

    Trend: Lieferzeit faellt von 16,9 Tagen (02/2018) auf 7,7 (08/2018)
    bei gleichem Volumen. Der Gesamtschnitt unterschaetzt die heutige Leistung.

    Verspaetung kostet 1,74 Sterne (4,29 puenktlich vs 2,55 verspaetet).

-------------------------------------------------------------------------------
*/