
-- Creating our database and table data structures to import data from the .csv file.

CREATE DATABASE IF NOT EXISTS Running Shoes;
 
USE running_shoes;

DROP TABLE Running_Shoes;

 CREATE TABLE Running_Shoes(
	id INT AUTO_INCREMENT PRIMARY KEY,
    Brand VARCHAR(255),
    Product_Name VARCHAR(255),
    Product_Price NUMERIC(10,2),
    Purchase_in_past_month INT,
    Total_Reviews INT,
    AVG_Rating NUMERIC(10,1),
    Gender VARCHAR(255),
    Date_Uploaded DATE
    );
    
LOAD DATA INFILE "D:\\Running Shoes Case Study\\Webpages\\Running Shoes.csv" 
INTO TABLE Running_Shoes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


--4108 total rows
    SELECT *
    FROM running_shoes
    LIMIT 5000;



                                            -------Cleaning the dataset-------

--  When deleting duplicates we will consider only the entries that have the same Brand, Product_Name, Product_Price, and Total_reviews.
--  We will not consider Purchases_in_past_month because if 2 rows have the same information for each column but different purchases_in_past_month
--this would imply a different shop selling the product. As well, if 2 rows have the same amount of total_reviews, price, and product name this
--would also imply that when using the python web scraper we grabbed 2 of the same posts for running shoes. Redudent data, that can skew results.
-- We will be considering Brand because some products of certain brands carry generic product names like "Men's running shoe", this product name could apply to multiple brands.


--Checking for duplicates in brand, product_name, product_price, Purchase_in_past_month, and total reviews
--313 rows with > 1 duplicate

SELECT Brand, Product_Name, Product_Price, Total_Reviews, COUNT(*) AS duplicate_count
FROM running_shoes
GROUP BY Brand, Product_Name, Product_Price, Total_Reviews
HAVING COUNT (*) > 1
LIMIT 2000;

--Creating a subquery to total our duplicate_count column and find how many duplicates we have with the same brand, product name, product price, and total reviews.
--818 summed rows with a duplicate > 1

SELECT 
    SUM(duplicate_count) AS total_duplicate_count
FROM (
    SELECT 
        COUNT(*) AS duplicate_count
        FROM running_shoes
        GROUP BY Brand, Product_Name, Product_Price, Total_Reviews
        HAVING COUNT(*) > 1
        LIMIT 2000
) AS subquery;



            --Deleting our duplicates we discovered with the above queries, using a self join statement

--Using RS1 and RS2 as aliases we create an (INNER) JOIN with the condition that Product_Name, Product_Price, and Total_Reviews must be equal in
--both RS1 and RS2 aliases.
--Our WHERE clause ensures that we are comparing different rows and not the same row itself and keeping only the row with the lowest id.

DELETE RS1
FROM Running_Shoes RS1
JOIN Running_Shoes RS2 ON RS1.Brand = RS2.Brand 
    AND RS1.Product_Name = RS2.Product_Name 
    AND RS1.Product_Price = RS2.Product_Price
    AND RS1.Total_Reviews = RS2.Total_Reviews
WHERE RS1.id < RS2.id;


--Checking our updated table to make sure we removed the appropriate rows and kept the ones we want.
--We started with 4108 rows, we now have 3603. 4108 - 3603 = 505.
--We used the SUM and COUNT function to find 406 total duplicates and 162 total rows with duplicates. 818 - 313 = 505.
--This implies we kept the rows we needed and deleted the duplicates we did not need.
--505 duplicates removed, 3603 rows left

SELECT *
FROM running_shoes
LIMIT 5000;


            --Deleting entries that don't fit the criteria of an adult running shoe.

 --Querying for entries that contain products for 'baby' 'kids', 'kid', 'children', or 'child' because we are only looking at products for adult sizes.
--8 rows contain these key words.
SELECT Product_Name
FROM running_shoes
WHERE Product_Name LIKE '%child%' 
OR Product_Name LIKE '%children%'
OR Product_Name LIKE '%kid%'
OR Product_Name LIKE '%baby%';


--Created a backup table (RS2) and used a DELETE FROM subquery to delete all entries containing products for 'baby' 'kids', 'kid', 'children', or 'child' (6 were deleted)
--from the running_shoes table that matched in the back up table RS2.

DELETE FROM running_shoes
WHERE Product_Name IN (
    SELECT RS2.Product_Name
    FROM (
        SELECT Product_Name
        FROM running_shoes
        WHERE Product_Name LIKE '%child%' 
        OR Product_Name LIKE '%kid%'
        OR Product_Name LIKE '%children%'
        OR Product_Name LIKE '%kids%'
    ) AS RS2
);


            --Adding new columns to our table for further analysis.

ALTER TABLE running_shoes
ADD COLUMN Category VARCHAR (255);


            --Gender Column--

--Inserting the appropriate data for each row in our new column by using a LIKE condition to check the Product_Name column for appropriate product gender category.
--When originally using the python web scraper to gather the data from Amazon, we sorted our product search for webpages to be scraped by gender and inserted a gender column in our Excel outfile with "Men's" or "Women's"
--in each row. Because of this, we will run a query to check for any products that were misgendered and insert the appropriate data into each row.

UPDATE running_shoes
SET Gender =
    CASE
        WHEN Product_Name LIKE "%Women's%" THEN "Women's"
        WHEN Product_Name LIKE '%Women%' THEN "Women's"
        WHEN Product_Name LIKE '%Unisex%' THEN 'Unisex'
        WHEN Product_Name LIKE "%Men's%" THEN "Men's"
        WHEN Product_Name LIKE '%Mens%' THEN "Men's"
        WHEN Product_Name LIKE '%Men%' THEN "Men's"
        ELSE Gender
            END;

--After inserting the gender of each row into our new Gender column based on a CASE statement in the Product_Name column,
--we will run the below queries to identify if our Case statement is appropriately grabbing identifying the gender of each Product.

SELECT *
FROM running_shoes
WHERE Gender IS NULL
LIMIT 2000;

SELECT *
FROM running_shoes
LIMIT 4000;

--After running the above query I was able to find that some of the product names contain an odd character in some of the Men's products "Mens".
--Because of this character I inserted a LIKE case clause "WHEN Product_Name LIKE '%Men%' THEN "Men's"" to identify the men's products without reading
--this odd character in our % wildcard in the LIKE clause. LINE 142


            --Category Column--
            
UPDATE running_shoes
SET Category =
    CASE
        WHEN Product_Name LIKE "%Trail Running%" THEN "Trail Running Shoe"
        WHEN Product_Name LIKE "%Trail%" THEN "Trail Running Shoe"
        WHEN Product_Name LIKE '%Running%' THEN 'Running Shoe'
        WHEN Product_Name LIKE '%Run%' THEN 'Running Shoe'
            END;
            

--Upon furth investigation after creating our 'category' column and inputting our data based on a product name CASE clause (in the above query),
--some shoes were not labeled as running shoes (or adjacent) but as sneakers, boots etc...
--So I removed entries where category was left NULL. This could skew our data in future analysis because they do not fit the proper 'running shoes' criteria.
--271 rows were removed.

SELECT *
FROM running_shoes
WHERE Category IS NULL
LIMIT 2000;

DELETE FROM running_shoes
WHERE Category IS NULL;


            --Analyzing 0s in Product Price
            
--Some products in the webpages on Amazon did not contain a product price, so they were given a 0 by our python web scraper.
--We have 29 rows with Product_Price =0 AND Total_Reviews >=1000. I will keep these entries and update appropriate price amounts after further research.

Select *
FROM running_shoes
WHERE Product_Price = 0 
    AND Total_Reviews >=1000
LIMIT 200;


--With the query below I was able to find 127 Products that contain a price = 0, Purchase_in_past_month <50, and Total_Reviews <1000.
--Because of this we will deem these products unpopular given the sorting criteria we used in our python data scraper (only looking at "Best Selling" shoes in the Amazon sorting filter on the webpage).
--225 rows were deleted

Select *
FROM running_shoes
WHERE Product_Price = 0
    AND Purchase_in_past_month <50
    AND Total_Reviews <1000
LIMIT 200;


DELETE FROM running_shoes
WHERE Product_Price = 0
    AND Purchase_in_past_month <50
    AND Total_Reviews <1000;


--What products with a price of 0 are left? 42 rows are left with product price = 0.
--With this small amount of data, this can easily be inserted by researching each product on Amazon (this method can only be considered with a smaller data set and would be easier through spreadsheeting)
SELECT *
FROM running_shoes
WHERE Product_Price = 0;

UPDATE running_shoes
SET Product_Price =
    CASE
        WHEN id = 550 THEN 74.95
        WHEN Product_Name = "Men's Air Monarch IV Cross Trainer" THEN 109.99
        WHEN Product_Name = "womens Fresh Foam Roav V1 Running Shoe Sneaker, Black/Light Aluminum, 6.5 US" THEN 74.95
        WHEN Product_Name = "Women's Fresh Foam X 880 V12 Running Shoe" THEN 109.99
        WHEN Product_Name = "Men's Revolution 5 Running Shoe" THEN 60.99
        WHEN Product_Name = "Men's 680 V7 Running Shoe" THEN 64.45
        WHEN Product_Name = "Men's Fresh Foam X 1080 V12 Running Shoe" THEN 124.00
        WHEN id = 914 THEN 109.95
        WHEN Product_Name = "Women's Revolution 5 Running Shoe" THEN 70.48
        WHEN Product_Name = "Men's Glycerin 19 Neutral Running Shoe" THEN 149.95
        WHEN Product_Name = "Men's Race Running Shoe" THEN 214.99
        WHEN Product_Name = "Men's Ultraboost 20 Running Shoe" THEN 79.06
        WHEN Product_Name = "Alphatorsion 360 Running Shoe" THEN 80.90
        WHEN Product_Name = "Men's Energen Running Shoe" THEN 62.98
        WHEN Product_Name = "Men's VERSABLAST Running Shoe" THEN 67.96
        WHEN Product_Name = "Men's Flex Experience Run 9 Shoe" THEN 149.98
        WHEN Product_Name = "Men's Ultraboost X Running Shoe" THEN 111.22
        WHEN Product_Name = "Men's Viz Runner Cross-trainer" THEN 46.00
        WHEN Product_Name = "Men's Gel-Nimbus 23 Running Shoes" THEN 199.10
        WHEN Product_Name = "Men's Wave Rider 25 Running Shoe" THEN 93.99
        WHEN Product_Name = "Originals Men's NMD_r1 Stlt Primeknit Running Shoe" THEN 132.37
        WHEN Product_Name = "Men's Revolution 6 Nn Running Shoe, Black/University Red, 11" THEN 62.99
        WHEN Product_Name = "Men's Fresh Foam X More V4 Running Shoe" THEN 149.95
        WHEN Product_Name = "Men's Runfalcon 2.0 Running Shoe" THEN 60.82
        WHEN Product_Name = "Men's Low Neck Running Shoes" THEN 153.51
        WHEN Product_Name = "Women's Fresh Foam X 860 V12 Running Shoe" THEN 89.99
        WHEN Product_Name = "Women's NMD_r1 Running Shoe" THEN 74.32
        WHEN Product_Name = "Men's Low-Top Trainers Sneaker" THEN 0.00
        WHEN Product_Name = "Women's Retrorun Running Shoe" THEN 76.99
        WHEN Product_Name = "Women Sport Running Shoes Gym Jogging Walking Sneakers" THEN 19.99
        WHEN Product_Name = "Women's Tanjun Running Shoes" THEN 70.00
        WHEN Product_Name = "Women's Air Zoom Pegasus 36 Running Shoes" THEN 145.00
        WHEN Product_Name = "Men's Fluidflow 2.0 Shoes Running" THEN 54.95
        WHEN Product_Name = "Men's Gel-Sonoma 5 Running Shoes" THEN 65.19
        WHEN Product_Name = "Men's Axelion Running Shoe" THEN 37.99
        WHEN Product_Name = "Men's 410 V7 Trail Running Shoe" THEN 59.95
        WHEN Product_Name = "Men's Fresh Foam Crag Trail V2 Running Shoe" THEN 93.00
        WHEN Product_Name = "Men's Rockadia Trail 3.0 Wide Running Shoe" THEN 89.92
        WHEN Product_Name = "Men's Nitrel V1 FuelCore Trail Running Shoe" THEN 130.00
        WHEN Product_Name = "Men's Fluidflow 2.0 Running Shoe" THEN 52.95
        WHEN Product_Name = "Men's Gel-Kahana 8 Running Shoe" THEN 59.99
        WHEN Product_Name = "Men's Lite Racer Adapt 3.0 Running Shoe" THEN 70.00
        WHEN Product_Name = "Women's 510 V4 Trail Running Shoe" THEN 48.06
        WHEN Product_Name = "Women's Sense Ride 4 Running Shoes Trail" THEN 60.00
        WHEN Brand = 'HOKA ONE ONE' AND Product_Name = "Women's Running Shoes" THEN 157.95
        WHEN Product_Name = "Women's Trail Running Shoes" THEN 64.33
        WHEN Product_Name = "Women's Gel-Cumulus 24 Running Shoes" THEN 77.55
        WHEN Product_Name = "Women's AL0A4VQW Olympus 4 Trail Running Shoe" THEN 98.95
        WHEN Product_Name = "Men's Minimus 10 V1 Trail Running Shoe" THEN 65.00
        WHEN Product_Name = "Northampton Women's Trail Running Hiking Shoes" THEN 59.10
        WHEN Product_Name = "FiveFingers Women's V-Trek Trail Hiking Shoe" THEN 118.00
        WHEN id = 2342 THEN 39.99
        ELSE Product_Price
    END;



--Some brands are titled differently though they belong to the same brand.
UPDATE running_shoes
SET Brand =
    CASE
        WHEN Brand LIKE '%ONN%' THEN 'On'
        WHEN Brand LIKE '%HOKA ONE ONE%' THEN 'Hoka One'
        ELSE Brand
        END;

##Querying for non-shoe type products
SELECT *
FROM running_shoes
WHERE Product_Name LIKE '%insert%';

DELETE FROM running_shoes
WHERE Product_Name = 'Wnnideo Thick Memory Foam Shoes Insert with Arch Support - Premium Cushioning Orthopedic Shoe Insoles for Heel Pain & Plantar Fasciitis, Running, Hiking, Working Men & Women (Blue Size 11.5)';



--After originally having 4108 rows of data we are left with 2681 rows.
SELECT *
FROM running_shoes
LIMIT 3000;


-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------


--Checking for most popular products for visualization
SELECT Brand, COUNT(*)
FROM running_shoes2
GROUP BY Brand
HAVING COUNT(*) > 50;

--Removing extremely low priced outliers
SELECT *
FROM running_shoes
WHERE Product_Price <10.99;

DELETE FROM running_shoes
WHERE Product_Name = 'Mens Walking Shoes Tennis Trail Running Athletic Shoes Sneakers Lightweight Breathable Mesh Soft Sole Size 11.5';
