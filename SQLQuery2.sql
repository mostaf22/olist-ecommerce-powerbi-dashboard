-- ====================================================
-- الجزء الأول: استكشاف الجداول الأساسية (Basic Exploration)
-- ====================================================

-- 1. عرض أول 10 عملاء مع مدنهم وولاياتهم
SELECT TOP 10
    customer_id, 
    customer_city, 
    customer_state
FROM dbo.customers;


-- 2. عرض جميع الولايات بدون تكرار بترتيب أبجدي
SELECT DISTINCT
    customer_state
FROM dbo.customers
ORDER BY customer_state ASC;


-- 3. حساب إجمالي عدد الطلبات
SELECT 
    COUNT(order_id) AS Total_Orders
FROM dbo.orders;


-- 4. حساب عدد الطلبات التي تم تسليمها بنجاح
SELECT 
    COUNT(order_id) AS Delivered_Orders
FROM dbo.orders
WHERE order_status = 'delivered';


-- 5. عرض أغلى 10 منتجات مباعة
SELECT TOP 10
    product_id, 
    price
FROM dbo.order_items
ORDER BY price DESC;


-- 6. حساب عدد المعاملات لكل طريقة دفع
SELECT 
    payment_type,
    COUNT(order_id) AS Total_Transactions
FROM dbo.order_payments
GROUP BY payment_type
ORDER BY Total_Transactions DESC;


-- 7. أعلى 10 مدن تحتوي على أكبر عدد من البائعين
SELECT TOP 10
    seller_city,
    COUNT(seller_id) AS Total_Sellers
FROM dbo.sellers
GROUP BY seller_city
ORDER BY Total_Sellers DESC;


-- 8. توزيع درجات التقييم وعدد المراجعات لكل درجة
SELECT 
    review_score,
    COUNT(review_id) AS Total_Reviews
FROM dbo.order_reviews
GROUP BY review_score
ORDER BY review_score DESC;


-- 9. إحصائيات الأسعار وتكاليف الشحن (أقل، أعلى، ومتوسط السعر)
SELECT 
    MIN(price) AS Min_Price,
    MAX(price) AS Max_Price,
    AVG(price) AS Avg_Price,
    MIN(freight_value) AS Min_Freight,
    MAX(freight_value) AS Max_Freight
FROM dbo.order_items;


-- 10. أعلى 10 طلبات من حيث عدد الأقساط
SELECT TOP 10
    order_id,
    payment_type,
    payment_installments,
    payment_value
FROM dbo.order_payments
ORDER BY payment_installments DESC;


-- ====================================================
-- الجزء الثاني: فحص جودة البيانات ونظافتها (Data Quality Checks)
-- ====================================================

-- 11. فحص التواريخ المفقودة في الطلبات المسلمة
SELECT 
    COUNT(order_id) AS Missing_Delivery_Dates
FROM dbo.orders
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NULL;


-- 12. فحص الأسعار وتكاليف الشحن الصفرية أو السالبة
SELECT 
    COUNT(order_id) AS Invalid_Price_Records
FROM dbo.order_items
WHERE price <= 0 OR freight_value < 0;


-- 13. فحص التباين بين مجموع المنتجات والمدفوعات الفعلية
SELECT TOP 10
    i.order_id,
    ROUND(SUM(i.price + i.freight_value), 2) AS Items_Total,
    p.Payment_Total,
    ROUND(SUM(i.price + i.freight_value) - p.Payment_Total, 2) AS Difference
FROM dbo.order_items i
JOIN (
    SELECT order_id, ROUND(SUM(payment_value), 2) AS Payment_Total
    FROM dbo.order_payments
    GROUP BY order_id
) p ON i.order_id = p.order_id
GROUP BY i.order_id, p.Payment_Total
HAVING ABS(SUM(i.price + i.freight_value) - p.Payment_Total) > 0.01
ORDER BY Difference DESC;


-- 14. فحص منطقية التواريخ (تسليم قبل الشراء أو قبل الشحن)
SELECT 
    COUNT(order_id) AS Date_Error_Count
FROM dbo.orders
WHERE order_delivered_customer_date < order_purchase_timestamp
   OR order_delivered_customer_date < order_delivered_carrier_date;

   SELECT 
    ROUND(AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 1) AS Avg_Delivery_Days,
    ROUND(AVG(DATEDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)), 1) AS Avg_Delay_Vs_Estimate
FROM dbo.orders
WHERE order_status = 'delivered';


SELECT 
    ROUND(AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)), 1) AS Avg_Delivery_Days,
    ROUND(AVG(DATEDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)), 1) AS Avg_Delay_Vs_Estimate
FROM dbo.orders
WHERE order_status = 'delivered';


SELECT TOP 10
    t.product_category_name_english AS Category_Name,
    COUNT(oi.order_id) AS Total_Items_Sold,
    ROUND(SUM(oi.price), 2) AS Total_Sales
FROM dbo.order_items oi
JOIN dbo.products p ON oi.product_id = p.product_id
JOIN dbo.product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY Total_Sales DESC;


SELECT TOP 10
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    ROUND(SUM(p.payment_value), 2) AS Total_Revenue
FROM dbo.orders o
JOIN dbo.customers c ON o.customer_id = c.customer_id
JOIN dbo.order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY Total_Revenue DESC;

CREATE VIEW vw_orders_master AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    c.customer_city,
    c.customer_state
FROM dbo.orders o
JOIN dbo.customers c ON o.customer_id = c.customer_id;
