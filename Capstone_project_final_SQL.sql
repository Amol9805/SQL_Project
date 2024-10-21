-- creating database 

create database amazon;
select * from amazon;

-- changing datatype of date and time

ALTER TABLE amazon
MODIFY COLUMN Date DATE,
MODIFY COLUMN Time TIME;

-- Feture Engineering adding new columns timeofday, dayname, monthname
ALTER TABLE amazon
ADD COLUMN timeofday VARCHAR(10) as(CASE
        WHEN HOUR(Time) >= 5 AND HOUR(Time) < 12 THEN 'Morning'
        WHEN HOUR(Time) >= 12 AND HOUR(Time) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END),
ADD COLUMN dayname VARCHAR(10) as (dayname(date)),
ADD COLUMN monthname VARCHAR(10)as (monthname(date));

-- 1. What is the count of distinct cities in the dataset?

select count(distinct(city)) as city_count from amazon;

-- 2. For each branch, what is the corresponding city?

select distinct(branch), city from amazon;

-- 3. What is the count of distinct product lines in the dataset?

select count(distinct(`Product line`)) as  distinct_product_lines_count
from amazon;

-- 4. Which payment method occurs most frequently?

select payment, count(payment) as frequency_of_payment from amazon
group by payment
order by count(payment) desc
limit 1;

-- 5. Which product line has the highest sales?

select `product line` , sum(Quantity) as Highest_sales from amazon 
group by `product line`
order by Highest_sales desc 
limit 1;

-- 6. How much revenue is generated each month?

select monthname, round(sum(total)) as Total_revenue from amazon
group by monthname
order by Total_revenue desc;

-- 7. which month did the cost of goods sold reach its peak?

select monthname, round(sum(cogs)) as Total_cost_of_goods_sold from amazon 
group by monthname
order by Total_cost_of_goods_sold desc
limit 1 ;

-- 8. Which product line generated the highest revenue? 

select `product line`, round(sum(total)) as Total_revenue from amazon 
group by `Product line` 
order by total_revenue desc
limit 1;

-- 9. In which city was the highest revenue recorded? 

select city, round(sum(total)) as Highest_revenue from amazon 
group by city 
order by Highest_revenue desc 
limit 1;

-- 10. Which product line incurred the highest Value Added Tax? 

select `product line` , sum(`Tax 5%`) as value_added_tax from amazon
group by `Product line`
order by value_added_tax desc 
limit 1;

-- 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad." 

select `product line`, Total, 
  avg(total) over(partition by `product line`) as Total_avg ,
  case
    when Total > avg(Total) over(partition by `Product line`) then 'Good'
    else 'Bad'
  end as product_line_performance
  from amazon ;
  
  -- 12. Identify the branch that exceeded the average number of products sold.
select 
      branch, 
      total_products_sold,
      avg_products_sold 
from (select 
            branch,
            sum(quantity) as total_products_sold,
            avg(sum(Quantity)) over() as avg_products_sold
            from amazon
           group by branch ) as subquery

where total_products_sold > avg_products_sold;
  
  -- 13. Which product line is most frequently associated with each gender?
 with genderProductline as(
    select 
          gender,
         `product line`, 
          count(*) as frequency 
    from amazon
    group by gender, `Product line`
    ) ,
Rankproductline as(
    select
          gender,
          `product line`,
          frequency,
          rank() over(partition by gender order by frequency desc) as Ranked
	from genderProductline
    group by gender, `product line`
    )
select 
    gender,
    `product line`,
    frequency
    from Rankproductline
where ranked = 1;

-- 14. Calculate the average rating for each product line.?

select 
     `product line`,
      avg(rating)  as avg_rating 
from amazon
group by `product line`
order by avg_rating desc;

-- 15. Count the sales occurrences for each time of day on every weekday.?

select 
      dayname,
      timeofday,
       count(*) as sales_occurences 
from amazon
group by dayname, timeofday
order by dayname, timeofday desc ;

-- 16. Identify the customer type contributing the highest revenue?

select 
      `Customer type`,
      round(sum(total)) as total_revenue 
from amazon
group by `Customer type`
order by total_revenue desc
limit 1;

-- 17. Determine the city with the highest VAT percentage?

select 
     city,
      (SUM(`Tax 5%`) / SUM(Total)) * 100 as vat_percentage 
from amazon 
group by city 
order by vat_percentage desc
limit 1;

-- 18. Identify the customer type with the highest VAT payments.?

select 
     `customer type`,
     round(sum(`tax 5%`)) as vat_payment
from amazon 
group by `Customer type`
order by vat_payment desc 
limit 1;

-- 19. What is the count of distinct customer types in the dataset?

select 
      `customer type`,
      count(*) as customer_count
from amazon 
group by `customer type`
order by customer_count desc;

-- 20. What is the count of distinct payment methods in the dataset?

select 
      payment,
      count(*) as payment_count 
from amazon
group by Payment
order by payment_count desc;

-- 21. Which customer type occurs most frequently?

select 
      `customer type`,
      count(*) as frequency 
from amazon
group by `customer type`
order by frequency desc 
limit 1;

-- 22. Identify the customer type with the highest purchase frequency.
select 
      `customer type`,
      count(*) as frequency 
from amazon
group by `customer type`
order by frequency desc 
limit 1;

-- 23. Determine the predominant gender among customers.

select gender,
       count(*) as frequency 
from amazon
group by Gender
order by frequency desc
limit 1;

-- 24. Examine the distribution of genders within each branch.?

select 
      branch,
      Gender,
      count(gender) as distribution_of_gender 
from amazon
group by branch, Gender
order by branch, Gender desc;

-- 25. Identify the time of day when customers provide the most ratings?

select
	  timeofday,
      count(rating) as most_rating
from amazon
group by timeofday
order by most_rating desc
limit 1;

-- 26. Determine the time of day with the highest customer ratings for each branch.?
 
 with Ratingcount as (
  select 
      branch,
      timeofday,
      count(*) as rating_count
from amazon
group by Branch,timeofday 
),
Maxrating as (
select 
     branch,
     max(rating_count) as max_rating
from Ratingcount 
group by branch
)
select 
     r.branch,
     r.timeofday,
     r.rating_count as max_rating 
from maxrating m 

join Ratingcount r
on m.branch = r.branch and m.max_rating = r.rating_count;

-- 27.Identify the day of the week with the highest average ratings.?

with avgrating as(
  select 
        dayname,
        avg(rating) as avg_rating 
  from amazon
  group by dayname
),
maxrating as(
  select 
        max(avg_rating) as max_rating
  from avgrating
  )
  
select 
       a.dayname,
       a.avg_rating as max_rating
from avgrating a 
inner join maxrating m 
on a.avg_rating = m.max_rating;

-- 28. Determine the day of the week with the highest average ratings for each branch?
with avgrating as(
     select 
           branch,
           dayname,
           avg(rating) as avg_rating 
	from amazon
    group by branch, dayname
),
maxrating as(
        select 
              branch, 
              max(avg_rating) as max_rating
		from avgrating
        group by branch
)

select 
      a.branch,
      a.dayname,
      a.avg_rating as max_rating
from avgrating a 
inner join maxrating m 
on a.branch = m.branch and a.avg_rating = m.max_rating ;


