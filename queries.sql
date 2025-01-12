-- Step 2. 10 самых продаваемых товаров
-- https://docs.google.com/spreadsheets/d/1_5f9xp0Q9ht59aAIJNOj2bQzjcs0ecb1rPJkcd2ERTI/edit?usp=sharing

-- Step 3. 10 товаров, проданных на наибольшую сумму
-- https://docs.google.com/spreadsheets/d/1MYeXm9maQBxvFH4mgQmKhBDlVwKH2WjaMVPRrdN5Qgg/edit?usp=sharing

-- Step 4. Подсчет общего количества покупателей
select
    count(customer_id) as customers_count
from customers;

-- Step 5. 10 лучших по суммарной выручке продавцов
select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from
    sales s
join employees e
    on s.sales_person_id = e.employee_id
join products p
    on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

-- Продавцы, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
select
    concat(e.first_name, ' ', e.last_name) as seller,
    floor(avg(s.quantity * p.price)) as average_income
from
    sales s
join employees e
    on s.sales_person_id = e.employee_id
join products p
    on s.product_id = p.product_id
group by seller
having floor(avg(s.quantity * p.price)) < (
    select floor(avg(s.quantity * p.price))
    from sales s
    left join products p on s.product_id = p.product_id
    )
order by average_income;

-- Выручка по дням недели
select
	concat(e.first_name, ' ', e.last_name) as seller,
    to_char(s.sale_date, 'TMday') as day_of_week,
    floor(sum(s.quantity * p.price)) as income
from
	sales s
join employees e
	on s.sales_person_id = e.employee_id
join products p
	on s.product_id = p.product_id
group by seller, day_of_week, to_char(s.sale_date, 'ID')
order by to_char(s.sale_date, 'ID'), seller;

-- Step 6. Количество покупателей в разных возрастных группах
select
	case
		when age >= 16 and age <= 25 then '16-25'
		when age > 25 and age <= 40 then '26-40'
		when age > 40 then '40+'
	end as age_category,
	count(customer_id) as age_count
from customers
group by age_category
order by age_category;
	
-- Количество уникальных покупателей и выручка, которую они принесли
select
	to_char(s.sale_date, 'YYYY-MM') as selling_month,
	count(distinct(s.customer_id)) as total_customers,
	floor(sum(s.quantity * p.price)) as income
from
	sales s
join
	products p
		on s.product_id = p.product_id
group by
	selling_month
order by
	selling_month;

-- Покупатели, первая покупка которых была в ходе проведения акций
with tab as (
	select
		c.customer_id,
		concat(c.first_name, ' ', c.last_name) as customer,
		s.sale_date,
		row_number() over (partition by concat(c.first_name, ' ', c.last_name) order by s.sale_date) as sale_number,
		concat(e.first_name, ' ', e.last_name) as seller
	from
		sales s
	join
		customers c
			on s.customer_id = c.customer_id
	join
		products p
			on s.product_id = p.product_id
	join
		employees e
			on s.sales_person_id = e.employee_id
	where p.price = 0
)

select
	customer,
	sale_date,
	seller
from
	tab
where sale_number = 1
order by
	customer_id;
