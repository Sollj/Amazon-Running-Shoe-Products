## About Dataset

### Data Extraction Process

Gathered the first 20 pages of products from Amazon for best-selling running shoes and trail running shoes for men and women. This means 80 web pages of product data were downloaded for the best-selling (trail) running shoes. Webpages were downloaded into HTML format and run through a Python web scraper to extract important quantitative and qualitative data points (Data Glossary contains more details). This data was imported into a. CSV file and cleaned to finally be imported into a MySQL server database for further analysis, cleaning, and wrangling. 

### **Content**

This dataset, curated from Amazon product postings, provides a comprehensive view of the running shoes and trail running shoes market for men, and women’s shoes. Key data points, including product brand, name, gender, price, total reviews, recent month's purchases, and average rating, offer valuable insights for businesses aiming to thrive on Amazon’s platform. With a dataset containing 2,689 rows, it serves as a strategic asset, empowering businesses with a data-driven approach to optimal decision-making.

### **Business Context**

The Running Shoes (and Trail Running Shoes) datasets serve as a toolkit for buyers or sellers seeking knowledge of running shoe brands and their products on the Amazon platform. With the quantitative information in this dataset, businesses can make informed decisions to refine their product listings and formulate competitive pricing strategies. The qualitative elements, such as ratings, reviews, and recent purchases, provide insights that enable businesses to tailor their products and marketing strategies to align with customer preferences and stand out in a competitive market landscape.

### Data Glossary (by column)

| Columns | Data Structure (SQL) |
| --- | --- |
| id | INT(11) |
| Brand | VARCHAR(255) |
| Product Name | VARCHAR(255) |
| Product Price | NUMERIC(10,2) |
| Purchases in past month | INT(11) |
| Total Reviews | INT(11) |
| AVG Rating | NUMERIC(10,1) |
| Date Uploaded | DATE |
| Gender | VARCHAR(255) |
| Category | VARCHAR(255) |


![image](https://github.com/Sollj/Amazon-Running-Shoe-Products/assets/107280952/64151ce0-8f6c-406a-8bf9-7bd0764baa18)


