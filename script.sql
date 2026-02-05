
create table Customers(Customer_id varchar(21) primary key,customer_name varchar(21),Place varchar(21));

insert into Customers values (101,'Alice','Kigali');
insert into Customers values (102,'Keza','Huye');
insert into Customers values (103,'John','Nyanza');	
insert into Customers values (104,'Jimmy','Kigali');
insert into Customers values (105,'Alex','Rubavu');

Create table Products (product_id varchar(21) primary key, product_name varchar(21),product_price number);

insert into Products values('P01','Laptop',800000);
insert into Products values('P02','Phone',100000);
insert into Products values('P03','Headphones',60000);
insert into Products values('P04','Desktop',1500000);
insert into products values('P05','Printers',600000);
insert into products values('P06','Scanner',500000);

Create table Sales (sales_id varchar(21) primary key, Customer_id varchar(21),product_id varchar(21),sales_date DATE, quantity INT, 
foreign key (Customer_id) references Customers(Customer_id),foreign key(product_id) references Products(product_id));

insert into Sales values (1,101,'P01',To_DATE('10/01/2025','DD/MM/YYYY'),1);
insert into Sales values (2,102,'P02',To_DATE('15/01/2025','DD/MM/YYYY'),4);	
insert into Sales values (3,103,'P03',To_DATE('20/01/2025','DD/MM/YYYY'),3);
insert into Sales values (4,104,'P04',To_DATE('25/01/2025','DD/MM/YYYY'),6);

--INNER JOIN
SELECT 
    s.sales_id,
    c.customer_name,
    p.product_name,
    s.sales_date,
    s.quantity
FROM sales s
INNER JOIN customers c 
    ON s.customer_id = c.customer_id
INNER JOIN products p 
    ON s.product_id = p.product_id;

--LEFT JOIN
SELECT 
    c.customer_id,
    c.customer_name,
    s.sales_id
FROM customers c
LEFT JOIN sales s 
    ON c.customer_id = s.customer_id
WHERE s.sales_id IS NULL;

--RIGHT JOIN
SELECT 
    p.product_id,
    p.product_name,
    s.sales_id
FROM sales s
RIGHT JOIN products p 
    ON s.product_id = p.product_id
WHERE s.sales_id IS NULL;

--FULL JOIN
SELECT 
    c.customer_name,
    s.sales_id
FROM customers c
FULL OUTER JOIN sales s 
    ON c.customer_id = s.customer_id;

--SELF JOIN
SELECT 
    c1.customer_name AS customer1,
    c2.customer_name AS customer2,
    c1.Place
FROM customers c1
JOIN customers c2
    ON c1.Place = c2.Place
   AND c1.customer_id <> c2.customer_id;

-- Top products per revenue using ranking window functions
SELECT 
    p.product_name,
    SUM(s.quantity * p.product_price) AS total_sales,

    ROW_NUMBER() OVER (ORDER BY SUM(s.quantity * p.product_price) DESC) AS row_no,

    RANK() OVER (ORDER BY SUM(s.quantity * p.product_price) DESC) AS rank_no,

    DENSE_RANK() OVER (ORDER BY SUM(s.quantity * p.product_price) DESC) AS dense_rank_no,

    PERCENT_RANK() OVER (ORDER BY SUM(s.quantity * p.product_price)) AS percent_rank

FROM sales s
JOIN products p 
    ON s.product_id = p.product_id
GROUP BY p.product_name;

--Running totals and trends using aggregate window function
SELECT 
    s.sales_date,
    (s.quantity * p.product_price) AS sale_amount,

    SUM(s.quantity * p.product_price) OVER (
        ORDER BY s.sales_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,

    AVG(s.quantity * p.product_price) OVER (
        ORDER BY s.sales_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_avg,

    MIN(s.quantity * p.product_price) OVER (
        ORDER BY s.sales_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS min_so_far,

    MAX(s.quantity * p.product_price) OVER (
        ORDER BY s.sales_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS max_so_far

FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY s.sales_date;

--Period comparision and growth using  navigation window function
SELECT 
    s.sales_date,
    (s.quantity * p.product_price) AS current_sales,

    LAG(s.quantity * p.product_price) OVER (ORDER BY s.sales_date) AS previous_sales,

    (s.quantity * p.product_price) - 
    LAG(s.quantity * p.product_price) OVER (ORDER BY s.sales_date) AS growth

FROM sales s
JOIN products p 
    ON s.product_id = p.product_id
ORDER BY s.sales_date;

--Customer segmentation using distribution functions
SELECT 
    c.customer_name,
    SUM(s.quantity * p.product_price) AS total_spent,

    NTILE(4) OVER (ORDER BY SUM(s.quantity * p.product_price)) AS spending_group,

    CUME_DIST() OVER (ORDER BY SUM(s.quantity * p.product_price)) AS spending_distribution

FROM customers c
JOIN sales s 
    ON c.customer_id = s.customer_id
JOIN products p 
    ON s.product_id = p.product_id
GROUP BY c.customer_name;