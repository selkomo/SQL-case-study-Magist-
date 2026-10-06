/*
*******************************************************************************
*******************************************************************************

MAGIST 1 - DATA EXPLORATION

*******************************************************************************
*******************************************************************************

External database dump, no documentation. All prices are in euros.

Clauses: SELECT, FROM, GROUP BY, ORDER BY, COUNT, MIN, MAX, DISTINCT,
         YEAR(), MONTH()

Tables:  orders, order_items, order_payments, order_reviews, products,
         product_category_name_translation, customers, sellers, geo
*/

USE magist;


/* 1. How many orders are there in the dataset?
   The orders table contains a row for each order. */


SELECT 
    COUNT(order_id) AS anzahl_bestellungen
FROM
    orders
;

-- 99441 bestellungen insgesamt.


/* 2. Are orders actually delivered?
   One of the columns in orders is called order_status. Most orders seem to be
   delivered, but some aren't. Find out how many orders are delivered and how
   many are cancelled, unavailable, or in any other status by grouping and
   aggregating this column. */


SELECT 
    order_status, COUNT(order_status) AS anzahl_status
FROM
    orders
GROUP BY order_status

;

-- delivered 96478
-- unavailable 609
-- shipped 1107
-- canceled 625
-- invoiced 314
-- processing 301
-- approved 2 
-- created 5





/* 3. Is Magist having user growth?
   A platform losing users left and right isn't going to be very useful to us.
   Check the number of orders grouped by year and month.
   Tip: YEAR() and MONTH() on order_purchase_timestamp. */



SELECT 
    YEAR(order_purchase_timestamp) AS order_jahr,
    MONTHNAME(order_purchase_timestamp) AS order_monat,
    COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY YEAR(order_purchase_timestamp) , MONTH(order_purchase_timestamp) , MONTHNAME(order_purchase_timestamp)
ORDER BY order_jahr ASC , MONTH(order_purchase_timestamp)
;

-- Am Anfang wenig bestellungen. höchster wert von Nov 2017 bis Aug 2018 mit den meisten Bestellungen. Danach schlagartiger Rückgang.


/* 4. How many products are there on the products table?
   Make sure that there are no duplicate products. */
   

SELECT
	COUNT(DISTINCT product_id) AS produkte
FROM
	products;
    
-- es gibt 32951 verschiedene Produkte.



/* 5. Which are the categories with the most products?
   The database is partially anonymized, so we don't have product names. But we
   do know which categories products belong to. Count the rows in products and
   group them by category.
   Note: this is products offered, not products sold. */



SELECT 
    p.product_category_name, pt.product_category_name_english AS uebersetzung,
    COUNT(p.product_id) AS produkte_in_kategorie 
    
FROM 
    products AS p
    JOIN 
    product_category_name_translation AS pt ON pt.product_category_name = p.product_category_name
GROUP BY 
    product_category_name
ORDER BY 
    produkte_in_kategorie DESC
LIMIT 10 -- eig. insgesamt 74 categorys
;

-- bed_bath_table mit 3029; sports_leisure mit 2867; furniture_decor mit 2657; und telephony mit nur 1134 auf platz 10 von 74.


/* 6. How many of those products were present in actual transactions?
   The products table is a reference of all available products. Have all these
   products been involved in orders? Check the order_items table. */


SELECT COUNT(order_item_id)
FROM order_items;




SELECT COUNT(DISTINCT product_id) AS produkte

FROM order_items
;




/* 7. What's the price for the most expensive and cheapest products?
   A broad range of prices is informative. Max and min values are also a good
   way to detect extreme outliers. */




/* 8. What are the highest and lowest payment values?
   Some orders contain multiple products. What's the highest someone has paid
   for an order? Look at the order_payments table. */




/*
-------------------------------------------------------------------------------
NOTES

Date range:
Growth:
Product mix:
Prices:
Open questions:
-------------------------------------------------------------------------------
*/