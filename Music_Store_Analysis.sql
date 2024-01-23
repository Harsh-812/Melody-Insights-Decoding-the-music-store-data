/*	Sales Analysis  */


/* Q1: Top-Selling Albums: Which are the top 20 albums that has generated the most revenue? */

Select a.title as Album, round(sum(il.unit_price * il.quantity)::numeric, 2) as TotalSales
From album a
Join track t on a.album_id = t.album_id
Join invoice_line il on t.track_id = il.track_id
Group by a.title
order by TotalSales desc
limit 20;


/* Q2: Most Popular Artists by Sales: Which are top 20 artists having the most tracks sold? */

select ar.name as artist, count(il.invoice_line_id) as TotalSales
from artist ar
join album a on ar.artist_id = a.artist_id
join track t on a.album_id = t.album_id
join invoice_line il on t.track_id = il.track_id
group by ar.name
order by TotalSales desc
limit 20;


/* Q3: Sales by Country: What are the total sales per country? */

select c.country, round(sum(i.total)::numeric, 2) as TotalSales
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.country
order by TotalSales desc;


/* Q4: Sales Trend Over Time: How have sales varied by month or year? */

select DATE_TRUNC('month', i.invoice_date) as Month, sum(i.total) as TotalSales
from Invoice i
group by month
order by month;




/* Customer Analysis */

/* Q1: Who is the customer that has spent the most money? */

select c.customer_id, first_name, last_name, round(sum(i.total)::numeric, 2) as Total_Spent
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by Total_Spent desc
limit 1;


/* Q2: Customer Spending Habits: How much has each customer spent in total? */

select c.customer_id, c.first_name, c.last_name, round(sum(i.total)::numeric, 2) as Total_Spent
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by TotalSpent desc;


/* Q3: Which city has the best customers? */

select billing_city,sum(total) as InvoiceTotal
from invoice
group by billing_city
order by InvoiceTotal desc
limit 1;


/* Q4: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct email as Email,first_name as FirstName, last_name as LastName, g.name as genrename
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track tr on tr.track_id = il.track_id
join genre g on g.genre_id = tr.genre_id
where g.name like 'Rock'
order by Email;


/* Q5: "Retrieve information on the total spending of each customer on artists.
Create a query to display the customer's name, the artist's name, and the total amount spent." */

with best_selling_artist as (
	select ar.artist_id as artist_id, ar.name as artist_name, sum(il.unit_price*il.quantity) as total_sales
	from invoice_line il
	join track tr on tr.track_id = il.track_id
	join album al on al.album_id = tr.album_id
	join artist ar on ar.artist_id = al.artist_id
	group by 1
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;


/* Q6: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Method 1: using CTE */

with Customter_with_country as (
		select c.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	    row_number() over(partition by billing_country order by sum(total) desc) as RowNo 
		from invoice i
		join customer c on c.customer_id = i.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from Customter_with_country where RowNo <= 1


/* Method 2: Using Recursive */

with recursive 
	customter_with_country as(
		select c.customer_id,first_name,last_name,billing_country,sum(total) as Total_spending
		from invoice i
		join customer c on c.customer_id = i.customer_id
		group by 1,2,3,4
		order by 2,3 desc),

	country_max_spending as(
		select billing_country,max(total_spending) AS max_spending
		from customter_with_country
		group by billing_country)

select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customter_with_country cc
join country_max_spending ms
on cc.billing_country = ms.billing_country
where cc.total_spending = ms.max_spending
order by 1;




/*	Employee Analysis  */


/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Q2: Employee Sales Performance: How much revenue has each employee generated?  */

select e.employee_id, e.first_name, e.last_name, sum(i.total) as TotalSales
from employee e
join customer c on cast(e.employee_id as INTEGER) = c.support_rep_id
join invoice i on c.customer_id = i.customer_id
group by e.employee_id, e.first_name, e.last_name
order by TotalSales desc;


/* Q3: Customer Support Analysis: Which support representative handles the most customers? */

select e.employee_id, e.first_name, e.last_name, count(c.customer_id) as CustomerCount
from employee e
join Customer c ON CAST(e.employee_id as INTEGER) = c.support_rep_id
group by e.employee_id, e.first_name, e.last_name
order by CustomerCount desc;




/* Product Analysis */


/* Q1: Which are the artists who have written the most rock music?. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.artist_id, ar.name,count(ar.artist_id) as Number_of_songs
from track tr
join album al on al.album_id = tr.album_id
join artist ar on ar.artist_id = al.artist_id
join genre g on g.genre_id = tr.genre_id
where g.name like 'Rock'
group by ar.artist_id
order by Number_of_songs desc
limit 10;


/* Q2: Which are the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,miliseconds
from track
where miliseconds > (
	select avg(miliseconds) as avg_track_length
	from track )
order by miliseconds desc;


/* Q3: Find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Method 1: Using CTE */

with popular_genre as 
(
    select count(il.quantity) as purchases, c.country, g.name, g.genre_id, 
	row_number() over(partition by c.country order by count(il.quantity) desc) as RowNo 
    from invoice_line il
	join invoice i on i.invoice_id = il.invoice_id
	join customer c on c.customer_id = i.customer_id
	join track tr on tr.track_id = il.track_id
	join genre g on g.genre_id = tr.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1

/* Method 2: : Using Recursive */

with recursive
	sales_per_country as(
		select count(*) as purchases_per_genre, c.country, g.name, g.genre_id
		from invoice_line il
		join invoice i on i.invoice_id = il.invoice_id
		join customer c on c.customer_id = i.customer_id
		join track tr on tr.track_id = il.track_id
		join genre g on g.genre_id = tr.genre_id
		group by 2,3,4
		order by 2
	),
	max_genre_per_country as (select max(purchases_per_genre) as max_genre_number, country
		from sales_per_country
		group by 2
		order by 2)

select sales_per_country.* 
from sales_per_country
join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;

