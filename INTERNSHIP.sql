-- step 1: create database
create database travel_tourism;
use travel_tourism;

-- step 2: create table
create table bookings (
    booking_id int primary key,
    customer_name varchar(100),
    age int,
    gender varchar(10),
    country varchar(50),
    destination varchar(50),
    booking_date date,
    travel_start_date date,
    trip_duration_days int,
    travel_end_date date,
    travel_type varchar(20),
    season varchar(20),
    booking_channel varchar(30),
    number_of_travelers int,
    total_revenue decimal(12,2),
    payment_mode varchar(20)
);

-- step 3: verify imported data
select * from bookings limit 5;

-- step 4: data cleaning & transformation
set sql_safe_updates = 0;
-- standardize text values
update bookings
set gender = lower(gender),
    travel_type = lower(travel_type),
    season = lower(season),
    booking_channel = lower(booking_channel),
    payment_mode = lower(payment_mode);

-- trim extra spaces
update bookings
set customer_name = trim(customer_name),
    country = trim(country),
    destination = trim(destination);

-- remove duplicate records
delete b1
from bookings b1
join bookings b2
on b1.booking_id = b2.booking_id
and b1.booking_id > b2.booking_id;

-- validate numeric values
delete from bookings
where age not between 1 and 100;

delete from bookings
where total_revenue <= 0;

delete from bookings
where number_of_travelers <= 0;

-- validate date consistency
delete from bookings
where travel_end_date < travel_start_date;

-- step 5: create derived column
alter table bookings
add revenue_per_traveler decimal(10,2);
alter table bookings
modify revenue_per_traveler decimal(12,4);
update bookings
set revenue_per_traveler = round(total_revenue / number_of_travelers, 4)
where booking_id > 0;
-- check 
select booking_id, total_revenue, number_of_travelers, revenue_per_traveler
from bookings
where revenue_per_traveler is not null
limit 10;

-- step 6: sql processing (analysis-ready data)
-- total revenue
select sum(total_revenue) as total_revenue
from bookings;

-- revenue by destination
select destination, sum(total_revenue) as revenue
from bookings
group by destination
order by revenue desc;

-- season-wise bookings
select season, count(*) as total_bookings
from bookings
group by season;

-- booking channel performance
select booking_channel, sum(total_revenue) as revenue
from bookings
group by booking_channel;

-- step 7: statistical analysis
select 
    avg(total_revenue) as avg_revenue,
    max(total_revenue) as max_revenue,
    min(total_revenue) as min_revenue,
    avg(trip_duration_days) as avg_trip_duration
from bookings;

-- step 8: create final analysis-ready view
create view clean_bookings as
select *
from bookings;

-- step 9: final check
select * from clean_bookings;