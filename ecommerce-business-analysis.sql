
--STUDY CASE 1

--Preview dataset
select *
from dataset_ecomm
limit 10;

select *
from dataset_ecomm
limit 1;

--Check product id dan product name
select
    "ProductID",
    "ProductName"
from dataset_ecomm
limit 10;

--Check customer location
select
    "CustomerLocation"
from dataset_ecomm
limit 10;

--Check purchase date format
select
    "PurchaseDate",
    cast("PurchaseDate" as date)
from dataset_ecomm
limit 10;

--Check unique category values
select distinct
    "Category"
from dataset_ecomm
order by 1;


select
    "ProductName",
    left("ProductName", 3) as first_3_letters
from dataset_ecomm
limit 10;


select
    "ProductID",
    right(cast("ProductID" as text), 2) as last_2_digits
from dataset_ecomm
limit 10;


--Case 1-1 Create Product Code
select
    "ProductID",
    "ProductName",
    concat(
        left("ProductName", 3),
        '-',
        right(cast("ProductID" as text), 2)
    ) as product_code
from dataset_ecomm;


--Case 1-2 CustomerLocation Uppercase
select
    "CustomerLocation",
    upper("CustomerLocation") as customerlocation_upper
from dataset_ecomm
limit 10;

--Standardize Customer Location
select
    "CustomerLocation",
    upper("CustomerLocation") as customer_location
from dataset_ecomm;


--Case1-3 & -> and
select distinct
    "Category"
from dataset_ecomm
order by 1;

select
    "Category",
    replace("Category", '&', 'and') as category_replace
from dataset_ecomm
limit 10;

select
    "Category",
    replace("Category", '&', 'and') as category
from dataset_ecomm;



--Insight
--Product code dibuat dari 3 huruf pertama product name dan 2  dgit terakhir productID
--CustomerLocation sudah distandarkan menggunakan huruf kapital
--Category sudah dirapikan dengan mengganti "&" menjadi "and"








--STUDY CASE 2

select
    "Price",
    "QuantitySold",
    "Discount"
from dataset_ecomm
limit 10;

select
    "PurchaseDate"
from dataset_ecomm
limit 10;

select
    "PurchaseDate",
    date_trunc(
        'month',
        cast("PurchaseDate" as date)
    ) as purchase_month
from dataset_ecomm
limit 10;


select
    "PurchaseDate",
    extract(
        year
        from cast("PurchaseDate" as date)
    ) as year,
    extract(
        month
        from cast("PurchaseDate" as date)
    ) as month
from dataset_ecomm
limit 10;


--Case 2-1 Net revenue
select
    "Price",
    "QuantitySold",
    "Discount",
    "Price" * "QuantitySold" * (1 - "Discount"/100.0) as net_revenue
from dataset_ecomm
limit 10;


--Case 2-2 & 2-3
select
    cast(date_trunc('month', cast("PurchaseDate" as date)) as date) as purchase_month,
    extract(year from cast("PurchaseDate" as date)) as year,
    extract(month from cast("PurchaseDate" as date)) as month,
    count(*) as total_transaction,
    sum("Price" * "QuantitySold" * (1 - "Discount"/100.0)) as total_net_revenue
from dataset_ecomm
group by
    cast(date_trunc('month', cast("PurchaseDate" as date)) as date),
    extract(year from cast("PurchaseDate" as date)),
    extract(month from cast("PurchaseDate" as date))
order by purchase_month;


--Insight
--Total transaksi tiap bulan relatif stabil
--Total net revenue fluktuatif



--STUDY CASE 3

select
    max(cast("PurchaseDate" as date)) as latest_purchase_date
from dataset_ecomm;


select
    now();

select
    current_timestamp;

select
    max(cast("PurchaseDate" as date)) as latest_date,
    max(cast("PurchaseDate" as date)) - interval '7 day' as start_date
from dataset_ecomm;

select
    *
from dataset_ecomm
where cast("PurchaseDate" as date) >= (
    select
        max(cast("PurchaseDate" as date)) - interval '7 day'
    from dataset_ecomm
)
order by cast("PurchaseDate" as date);

--Insight
--Data terakhir pada dataset adalah 26 September 2024.
--Dalam 7 hari terakhir (start dari 19 September 2024) terdapat 8 transaksi.
--Transaksi dengan kategori elektronik paling sering muncul



--STUDY CASE 4

select
    avg("Price") as avg_price
from dataset_ecomm;

--Case 4-1 Subquery
select *
from dataset_ecomm
where "Price" > (
    select avg("Price")
    from dataset_ecomm
);


--Case 4-1 CTE
with avg_price as (
    select
        avg("Price") as avg_price
    from dataset_ecomm
)
select *
from dataset_ecomm, avg_price
where "Price" > avg_price;


--Case 4-2 Subquery
select *
from dataset_ecomm
where
    "Price" * "QuantitySold" * (1 - "Discount"/100.0) >
(
    select
        avg("Price" * "QuantitySold" * (1 - "Discount"/100.0))
    from dataset_ecomm
);

--Check net revenue
select
    avg("Price" * "QuantitySold" * (1 - "Discount"/100.0)) as avg_net_revenue
from dataset_ecomm;


--Case 4-2 CTE
with avg_net_revenue as (
    select
        avg("Price" * "QuantitySold" * (1 - "Discount"/100.0)) as avg_net_revenue
    from dataset_ecomm
)
select *
from dataset_ecomm, avg_net_revenue
where
    "Price" * "QuantitySold" * (1 - "Discount"/100.0) > avg_net_revenue;



--Insight
--Average price 272.6081632653061224
--Sebanyak 482 transaksi adalah transaksi dengan price di atas rata-rata
--Rata-rata net revenue adalah 8627.52247959183673469388
--Sebanyak 378 transaksi memiliki net revenue di atas rata-rata





--STUDY CASE 5

select
    "ProductName",
    sum("QuantitySold") as total_quantity_sold
from dataset_ecomm
group by "ProductName"
order by total_quantity_sold desc;

--Case 5-1 
select
    "ProductName",
    sum("QuantitySold") as total_quantity_sold,
    rank() over(order by sum("QuantitySold") desc) as ranking
from dataset_ecomm
group by "ProductName"
order by ranking
limit 10;
--Insight
--Sudah dapat dilakukan rank top 10 berdasarkan total quantity sold, produk yang paling banyak terjual adalah Basketball sebanyak 1388.
--Diikuti Air Purifier sebanyak 1303 dan Yoga Matt 1197. 

--Case 5-2
select
    "Category",
    "ProductName",
    sum("QuantitySold") as total_quantity_sold,
    rank() over(partition by "Category" order by sum("QuantitySold") desc) as ranking
from dataset_ecomm
group by
    "Category",
    "ProductName";


select *
from (
    select
        "Category",
        "ProductName",
        sum("QuantitySold") as total_quantity_sold,
        rank() over(partition by "Category" order by sum("QuantitySold") desc) as ranking
    from dataset_ecomm
    group by
        "Category",
        "ProductName"
) as product_rank
where ranking <= 3
order by
    "Category",
    ranking;


--Insight
--Setiap kategori menampilkan tiga produk dengan total QuantitySold tertinggi
--Beauty : 1. Sweater, 2. Mascara, 3. Wireless Earbuds
--Clothing : 1. Skirt, 2. Yoga Mat, 3. Facial Cleanser
--Electronic : 1. Coffee Maker, 2. Facial Cleanser, 3. Football
--Home & Garden :  1. Tablet, 2. Camera, 3. Coffee Maker
--Sports : 1. Gaming Console, 2. Basketball, 3. Dumbbells

