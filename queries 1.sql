-- Запрос находит 10 лучших по суммарной выручке продавцов
select
    CONCAT(e.first_name, ' ', e.last_name) as seller,
    COUNT(s.sales_id) as operations,
    SUM(s.quantity * p.price) as income
from
    sales s
join employees e
    on s.sales_person_id = e.employee_id
join products p
    on s.product_id = p.product_id
group by seller
order by income desc
limit 10;

-- Запрос находит продавцов, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам
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
    select avg(s.quantity * p.price)
    from sales s
    left join products p on s.product_id = p.product_id
    )
order by average_income;

-- Запрос показывает выручку по дням недели
with tab as (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
    	to_char(s.sale_date, 'ID') as day_of_week,
    	floor(sum(s.quantity * p.price)) as income
	from
   		sales s
	join employees e
   		on s.sales_person_id = e.employee_id
	join products p
    	on s.product_id = p.product_id
	group by seller, day_of_week
	order by day_of_week, seller
)

select
    seller,
    case
    	when day_of_week = '1' then 'monday'
    	when day_of_week = '2' then 'tuesday'
    	when day_of_week = '3' then 'wednesday'
    	when day_of_week = '4' then 'thursday'
    	when day_of_week = '5' then 'friday'
    	when day_of_week = '6' then 'saturday'
    	when day_of_week = '7' then 'sunday'
    end as day_of_week,
    income
from tab;
    
    


