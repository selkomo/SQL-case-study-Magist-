/* What categories of products does Magist have that are important for us as a company selling smartphones, smart watches and smartphone accessories? */

SELECT 
    p.product_category_name, pt.product_category_name_english AS translation,
    COUNT(p.product_id) AS products_in_category
FROM 
    products p
    JOIN 
    product_category_name_translation pt USING(product_category_name)
WHERE pt.product_category_name_english 
	IN ('audio', 'christmas_supplies', 'cine_photo', 'computers_accessories', 'cosoles_games', 'cool_stuff', 'electronics', 'fashion_bags_accessories', 'watches_gifts', 'telephony', 'tablets_printing_image')
GROUP BY 
    product_category_name
ORDER BY 
    products_in_category DESC
;


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


SELECT 
	COUNT(review_comment_message)
FROM 
	order_reviews
WHERE
	review_comment_message LIKE '% demorou %' OR '% atrasaram %' OR '% passou %' OR '% correio %' OR '% entrega %' OR '% frete %' OR '% prazo %' OR '% rastreio %' OR '% chegar %' 
		OR '% chegou %' OR '% enviar %' OR '% enviado %' OR '% transport %' OR '% receb %'
ORDER BY
	review_score DESC
;

SELECT 
	AVG(review_score)
FROM 
	order_reviews
;
    
SELECT 
    r.review_score,
    COUNT(r.review_id) AS anzahl_bewertungen
FROM 
    order_reviews r
    LEFT JOIN orders o ON r.order_id = o.order_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
WHERE
    pt.product_category_name_english IN (
        'audio', 
        'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'watches_gifts',
        'tablets_printing_image',
        'telephony',
        'fixed_telephony'
    )
GROUP BY
    r.review_score
ORDER BY
    r.review_score DESC;

