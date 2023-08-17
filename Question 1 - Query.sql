-- This sql query has been tested successfully with the simulated tables produced with R.


-- In order to construct lower and upper limits, a common table expression (CTE) is created.
WITH bins AS (
  SELECT 
    GENERATE_SERIES(0, 30, 1) AS bin1,
    GENERATE_SERIES(1, 31, 1) AS bin2
)


-- I used LEFT JOIN to be able to count both the whole orders and those that delivered succefully.
SELECT 
  orders.city,
  orders.service_type,
  orders.created_date,
  CASE 
    WHEN bins.bin1 < 30 AND invoices.distance >= bins.bin1 AND invoices.distance < bins.bin2 
      THEN bins.bin1::text || '-' || bins.bin2::text
    WHEN bins.bin1 >= 30 THEN '>=30'
  END AS distance_buckets,
  COUNT(orders.Order_ID) AS request,
  COUNT(offers.Offer_ID) AS offered_requests,
  COUNT(allotments.Biker_ID) AS accepted_requests,
  COUNT(invoices.Biker_ID) AS ride,
  SUM(invoices.Fare) AS total_fare,
  ROUND(COUNT(offers.Order_ID) / COUNT(orders.Order_ID) * 100) AS offered_to_created,
  ROUND(COUNT(allotments.Order_ID) / COUNT(offers.Order_ID) * 100) AS accepted_to_offered,
  ROUND(COUNT(invoices.Order_ID) / COUNT(orders.Order_ID) * 100) AS fulfillment_rate,	
  ROUND(AVG(invoices.Fare)) AS average_ride_fare
FROM orders  
LEFT JOIN offers
USING(Order_ID)
LEFT JOIN allotments
USING(Order_ID)
LEFT JOIN invoices
USING(Order_ID)
LEFT JOIN bins
ON invoices.distance >= bins.bin1  
AND invoices.distance < bins.bin2
GROUP BY orders.city, orders.service_type, orders.created_date, bins.bin1, bins.bin2, distance_buckets
HAVING orders.city = 'A' AND orders.service_type = 1 AND orders.created_date = '2022-06-22'
ORDER BY bins.bin1;