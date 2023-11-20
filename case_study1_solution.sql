

 #1
 #What is the total amount each customer spent at the restaurant? 
 select s.customer_id, sum(m.price) as total_amount
 from  sales s
 join  menu m ON s.product_id = m.product_id
 group by customer_id
 order by customer_id;



 #2
 # How many days has each customer visited the restaurant?
 SELECT customer_id, COUNT(DISTINCT(order_date)) AS number_of_days_visited
FROM sales
GROUP BY customer_id;

  #3
  #What was the first item from the menu purchased by each customer?
SELECT
 distinct s.customer_id,
  FIRST_VALUE(m.product_name) OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS "1st_purchase_item"
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, s.order_date
ORDER BY s.customer_id, s.order_date;

#4
#What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
  menu.product_name, menu.product_id, COUNT(sales.product_id) AS most_purchased_item
FROM sales 
JOIN menu ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY most_purchased_item DESC
LIMIT 1;

#5 Which item was the most popular for each customer?
 WITH most_popular AS (
  SELECT distinct sales.customer_id, 
    menu.product_name, 
    COUNT(menu.product_id) AS order_count,
    DENSE_RANK() OVER(
      PARTITION BY sales.customer_id 
      ORDER BY COUNT(sales.customer_id) DESC) AS rnk
  FROM menu
  JOIN sales ON menu.product_id = sales.product_id
  GROUP BY sales.customer_id, menu.product_name
)









SELECT customer_id, product_name,order_count
FROM most_popular 
WHERE rnk = 1;









#6 Which item was purchased first by the customer after they became a member?
WITH joined_as_member AS (
  SELECT
    members.customer_id, 
    sales.product_id,
    ROW_NUMBER() OVER(
      PARTITION BY members.customer_id
      ORDER BY sales.order_date) AS row_num
  FROM members
  JOIN sales
    ON members.customer_id = sales.customer_id
    AND sales.order_date > members.join_date

)



SELECT customer_id, product_name 
FROM joined_as_member
JOIN menu
ON joined_as_member.product_id = menu.product_id
WHERE row_num = 1
ORDER BY customer_id ASC; 



#7Which item was purchased just before the customer became a member?
WITH purchased_prior_member AS (
  SELECT 
    members.customer_id, 
    sales.product_id,
    ROW_NUMBER() OVER(
       PARTITION BY members.customer_id
       ORDER BY sales.order_date DESC) AS rnk
  FROM members
  JOIN sales
    ON members.customer_id = sales.customer_id
    AND sales.order_date < members.join_date
)



SELECT 
  p_member.customer_id, 
  menu.product_name 
FROM purchased_prior_member AS p_member
JOIN menu
  ON p_member.product_id = menu.product_id
WHERE rnk = 1
ORDER BY p_member.customer_id ASC;








#8What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(m.product_id) as total_items,
sum(m.price) as amount_spent
from sales s
inner join menu as m on s.product_id=m.product_id
inner join members as mem on mem.customer_id=s.customer_id
where order_date< join_date
group by s.customer_id
order by s.customer_id asc;








 
 
 
 
 
 
 
 
 
 