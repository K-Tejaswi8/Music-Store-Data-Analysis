CREATE database music_store;
USE music_store;

-- 1. Genre and MediaType 
CREATE TABLE Genre ( 
genre_id INT PRIMARY KEY, 
name VARCHAR(120) 
); 

CREATE TABLE MediaType ( 
media_type_id INT PRIMARY KEY, 
name VARCHAR(120) 
);

 -- 2. Employee  
CREATE TABLE Employee ( 
 employee_id INT PRIMARY KEY, 
 last_name VARCHAR(120), 
 first_name VARCHAR(120), 
 title VARCHAR(120), 
 reports_to INT, 
  levels VARCHAR(255), 
 birthdate DATE, 
 hire_date DATE, 
 address VARCHAR(255), 
 city VARCHAR(100), 
 state VARCHAR(100), 
 country VARCHAR(100), 
 postal_code VARCHAR(20), 
 phone VARCHAR(50), 
 fax VARCHAR(50), 
 email VARCHAR(100) 
); 

 -- 3. Customer 
CREATE TABLE Customer ( 
 customer_id INT PRIMARY KEY, 
 first_name VARCHAR(120), 
 last_name VARCHAR(120), 
 company VARCHAR(120), 
 address VARCHAR(255), 
 city VARCHAR(100), 
 state VARCHAR(100), 
 country VARCHAR(100), 
 postal_code VARCHAR(20), 
 phone VARCHAR(50), 
 fax VARCHAR(50), 
 email VARCHAR(100), 
 support_rep_id INT, 
 FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id) 
); 

 -- 4. Artist 
CREATE TABLE Artist ( 
 artist_id INT PRIMARY KEY, 
 name VARCHAR(120) 
); 

 -- 5. Album 
CREATE TABLE Album ( 
 album_id INT PRIMARY KEY, 
 title VARCHAR(160), 
 artist_id INT, 
 FOREIGN KEY (artist_id) REFERENCES Artist(artist_id) 
); 

 -- 6. Track 
CREATE TABLE Track (  
 track_id INT PRIMARY KEY, 
 name VARCHAR(200), 
 album_id INT, 
 media_type_id INT, 
 genre_id INT, 
 composer VARCHAR(220), 
 milliseconds INT, 
 bytes INT, 
 unit_price DECIMAL(10,2), 
 FOREIGN KEY (album_id) REFERENCES Album(album_id), 
 FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id), 
 FOREIGN KEY (genre_id) REFERENCES Genre(genre_id) 
); 

 -- 7. Invoice 
CREATE TABLE Invoice ( 
 invoice_id INT PRIMARY KEY, 
 customer_id INT, 
 invoice_date DATE, 
 billing_address VARCHAR(255), 
 billing_city VARCHAR(100), 
 billing_state VARCHAR(100), 
 billing_country VARCHAR(100), 
 billing_postal_code VARCHAR(20), 
 total DECIMAL(10,2), 
 FOREIGN KEY (customer_id) REFERENCES Customer(customer_id) 
); 

 -- 8. InvoiceLine 
CREATE TABLE InvoiceLine ( 
 invoice_line_id INT PRIMARY KEY, 
 invoice_id INT, 
 track_id INT, 
 unit_price DECIMAL(10,2), 
 quantity INT, 
 FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id), 
 FOREIGN KEY (track_id) REFERENCES Track(track_id) 
); 

 -- 9. Playlist 
CREATE TABLE Playlist ( 
  playlist_id INT PRIMARY KEY, 
 name VARCHAR(255) 
); 

 -- 10. PlaylistTrack 
CREATE TABLE PlaylistTrack ( 
 playlist_id INT, 
 track_id INT, 
 PRIMARY KEY (playlist_id, track_id), 
 FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id), 
 FOREIGN KEY (track_id) REFERENCES Track(track_id) 
); 

INSERT INTO employee
(employee_id,last_name,first_name,title,reports_to,levels,
 birthdate,hire_date,address,city,state,country,
 postal_code,phone,fax,email)
VALUES
(9,'Madan','Mohan','Senior General Manager',NULL,'L7',
 '1961-01-26','2016-01-14',
 '1008 Vrinda Ave MT','Edmonton','AB','Canada',
 'T5K 2N1','+1 (780) 428-9482','+1 (780) 428-3457','madan.mohan@chinookcorp.com');


SHOW VARIABLES LIKE 'secure_file_priv';
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv'
INTO TABLE track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);

SELECT COUNT(*) FROM genre;
SELECT COUNT(*) FROM mediatype;
SELECT COUNT(*) FROM employee;
SELECT COUNT(*) FROM customer;
SELECT COUNT(*) FROM artist;
SELECT COUNT(*) FROM album;
SELECT COUNT(*) FROM track;
SELECT COUNT(*) FROM playlist;
SELECT COUNT(*) FROM playlisttrack;
SELECT COUNT(*) FROM invoice;
SELECT COUNT(*) FROM invoiceline;

SELECT DATABASE();
SHOW TABLES;

-- 1. Senior most employee
SELECT * 
FROM employee 
ORDER BY levels DESC 
LIMIT 1;

-- 2.Country with most invoices
SELECT billing_country, 
COUNT(*) AS invoice_count 
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

-- 3.top 3 invoice totals
SELECT * 
FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4.City with the highest revenue
SELECT billing_city , 
SUM(total) AS total_invoice_amount
FROM invoice
GROUP BY billing_city
ORDER BY total_invoice_amount DESC
LIMIT 1;

-- 5.Best customer (highest spender)
SELECT c.customer_id, c.first_name, c.last_name,
SUM(i.total) AS cust_total
FROM customer c
JOIN invoice i
ON c.customer_id=i.customer_id
GROUP BY c.customer_id
ORDER BY cust_total
LIMIT 1;

-- 6. Rock music listeners
SELECT distinct
c.email, c.first_name, c.last_name, g.name AS genre_type
FROM customer c
JOIN invoice i
ON c.customer_id=i.customer_id
JOIN invoiceline il
ON i.invoice_id=il.invoice_id
JOIN track t
ON il.track_id=t.track_id
JOIN genre g
ON t.genre_id=g.genre_id
WHERE g.name='Rock'
ORDER BY c.email;

-- 7. Top 10 Rock artists
SELECT a.name AS artist_name, COUNT(t.track_id) AS track_count
FROM genre g 
JOIN track t
ON g.genre_id=t.genre_id
JOIN album a1
ON t.album_id=a1.album_id
JOIN artist a
ON a1.artist_id=a.artist_id
WHERE g.name="Rock"
GROUP BY a.artist_id
ORDER BY track_count DESC
LIMIT 10;

-- 8. Tracks longer than average song length
SELECT name AS trackname, milliseconds AS songlength
FROM track 
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY songlength DESC;

-- 9. Amount spent by each customer on artists
SELECT  c.first_name, c.last_name, a.name AS artistname,
SUM(il.unit_price * il.quantity) AS cust_art_sum
FROM customer c
JOIN invoice i
ON c.customer_id=i.customer_id
JOIN invoiceline il
ON i.invoice_id=il.invoice_id
JOIN track t
ON il.track_id=t.track_id
JOIN album a1
ON t.album_id=a1.album_id
JOIN artist a
ON a1.artist_id=a.artist_id
GROUP BY a.name, c.customer_id
ORDER BY cust_art_sum DESC;

-- 10. Most popular genre for each country
WITH genre_sales AS
( SELECT c.country, g.name as genre_name, COUNT(il.quantity) as purchases,
RANK () OVER ( PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS rnk
FROM customer c
JOIN invoice i
ON c.customer_id=i.customer_id
JOIN invoiceline il
ON i.invoice_id=il.invoice_id
JOIN track t
ON il.track_id=t.track_id
JOIN genre g
ON t.genre_id=g.genre_id
GROUP BY c.country, g.name)
SELECT country, genre_name, purchases FROM genre_sales
WHERE rnk=1
ORDER BY country;

-- 11. Top customer from each country
WITH customer_spending AS
( SELECT c.customer_id, c.first_name, c.last_name, c.country, sum(i.total) AS total_spent, 
RANK() OVER (PARTITION BY c.country ORDER BY sum(i.total) DESC) AS rnk
FROM customer c
JOIN invoice i
ON c.customer_id=i.customer_id
GROUP BY c.customer_id, c.country)
SELECT first_name, last_name, country, total_spent
FROM customer_spending
WHERE rnk=1
ORDER BY country;











