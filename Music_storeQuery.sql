										Set 1
Q1: Who is the senior most employee based on job title?
select first_name,last_name,levels,title from employee
order by levels desc
limit 1;

Q2: Which countries have the most Invoices?
select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc;

Q3: What are top 3 values of total invoice?
select total from invoice
order by total desc
limit 3

Q4: Which city has the best customers?
	We would like to throw a promotional Music Festival in the city we made the most money.
	Write a query that returns one city that has the highest sum of invoice totals. 
	Return both the city name & sum of all invoice totals
select sum(total) as c, billing_city from invoice
group by billing_city
order by c desc;

Q5: Who is the best customer? 
	The customer who has spent the most money will be declared the best customer. 
	Write a query that returns the person who has spent the most money
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice ON customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1;

================================================================================================================
										Set 2
Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners.
	Return your list ordered alphabetically by email starting with A
select distinct customer.email, customer. first_name, customer.last_name
from customer
join invoice on customer.customer_id= invoice.customer_id
join invoice_line on invoice_line.invoice_id= invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id= track.genre_id
where genre.name like 'Rock'
order by customer.email asc;

Q2: Lets invite the artists who have written the most rock music in our dataset. 
	Write a query that returns the Artist name and total track count of the top 10 rock bands

select artist.artist_id, artist.name, count(artist.artist_id) as num_of_songs
from track
join album on track.album_id = album.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by num_of_songs
limit 10

Q3: Return all the track names that have a song length longer than the average song length. 
	Return the Name and Milliseconds for each track. 
	Order by the song length with the longest songs listed first

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) as avg_song_len from track)
order by milliseconds desc;

=================================================================================================
										Set 3
Q1: Find how much amount spent by each customer on artists? 
	Write a query to return customer name, artist name and total spent

select c.first_name || ' ' || c.last_name as customer_name, ar.name as artist_name, sum(il.unit_price*il.quantity) as totalspent
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on il.track_id = t.track_id
join album al on al.album_id = t.album_id
join artist ar on ar.artist_id = al.artist_id
group by customer_name, artist_name
order by customer_name, totalspent desc;

Q2: We want to find out the most popular music Genre for each country. 
	We determine the most popular genre as the genre with the highest amount of purchases. 
	Write a query that returns each country along with the top Genre. 
	For countries where the maximum number of purchases is shared return all Genres

with genre_purchases as (
select sum(il.quantity) as purchases, c.country, g.name as genre
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on il.track_id = t.track_id
join genre g on g.genre_id = t.genre_id
group by c.country, genre
),
max_genre as (
select country, max(purchases) as max_purchases
from genre_purchases
group by country
)
select gp.country, gp.genre, gp.purchases
from genre_purchases gp
join max_genre mg on gp.country = mg.country
		and mg.max_purchases = gp.purchases
order by gp.country, gp.genre;

Q3: Write a query that determines the customer that has spent the most on music for each country. 
	Write a query that returns the country along with the top customer and how much they spent. 
	For countries where the top amount spent is shared, provide all customers who spent this amount

with customer_totals as ( 
	select c.customer_id, 
			c.first_name || ' ' || c.last_name as customer_name, 
			i.billing_country as country, sum(il.unit_price*il.quantity) as totalspent
from customer c
join invoice i on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
group by c.customer_id, customer_name, i.billing_country
),
country_max as (
select country, max(totalspent) as max_spent
from customer_totals
group by country
)
select ct.country, ct.customer_name, ct.totalspent
from customer_totals ct
join country_max cm on cm.country = ct.country
	and ct.totalspent = cm.max_spent
order by ct.country, ct.customer_name;



