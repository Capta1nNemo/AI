--Вывести сумму, дату и день недели для каждой оплаты (текстом)
with cte as (select amount, 
payment_date::date as p_date, extract(dow from payment_date) as weekday 
from payment order by p_date)
select 'Сумма: ' || sum(amount)::text amount, 'Дата: ' || p_date::text as date, 'День недели: ' || to_char(p_date, 'Day')::text weekday from cte group by p_date, weekday 
order by p_date;


/* Распределить фильмы в три категории по длительности: "Короткие": менее 70 мин, 
 "Средние": 70 (вкл) - 130 (не вкл), "Длинные": больше или равно 130 мин. 
 Рассчитать количество прокатов и количество фильмов в каждой такой категории. 
 Если прокатов у фильма не было, не включать его в расчеты количества фильмов в категории 
 (подумать над типом джоина). (Подсказка: количество фильмов и количество прокатов не будут 
 одинаковыми, ведь фильм берут на прокат много раз) */
with cte as (select distinct i.film_id as film_id, count(rental.inventory_id) amount_inventory 
from inventory i right join rental on 
rental.inventory_id = i.inventory_id group by film_id)
select time_category, count(film_id) amount_of_films, sum(amount_inventory) rent_sum from (
select f.film_id, 
case when f.length < 70 then 'Короткие'
when f.length >= 70 and f.length < 130 then 'Средние'
else 'Длинные'
end as time_category, f.length,
amount_inventory from cte inner join film f on cte.film_id = f.film_id)
group by time_category;

--
create table weekly_revenue as 
select 
extract (year from rental_date) asr_year, 
extract (week from rental_date) asr_week, 
sum(amount) as revenue 
from rental r 
left join payment p on p.rental_id = r.rental_id 
group by 1, 2 
order by 1, 2
select * from weekly_revenue

/*Рассчитать накопленную сумму недельной выручки бизнеса. 
 Вывести всю таблицу weekly_revenue с дополнительным столбцом с накопленной суммой. 
 Округлить накопленную выручку до целого числа */
select asr_year, asr_week, revenue, round(
case when sum(revenue) over w is null then 0 else sum(revenue) over w end * 1) as cumulative_sum from weekly_revenue
window w as (rows between unbounded preceding and current row)



/*
Рассчитать скользящую среднюю недельной выручки бизнеса. Использовать неделю до, текущую неделю, и неделю после для расчета среднего значения. 
Вывести всю таблицу weekly_revenue с дополнительными столбцами с накопленной суммой и скользящей средней. Округлить скользящую среднюю до целого числа
 */
select asr_year, asr_week, revenue, round(
case when sum(revenue) over w is null then 0 else sum(revenue) over w end * 1) as cumulative_sum,
round((((case when lag(revenue) over w is null then 0 else lag(revenue) over w end * 1) + 
case when revenue is null then 0 else revenue end * 1 +
(case when lead(revenue) over w is null then 0 else lead(revenue) over w end * 1)) / 3)) as slide_average_sum
from weekly_revenue
window w as (rows between unbounded preceding and current row)


/*
Посчитать прирост недельной выручки бизнеса в %.
Вывести всю таблицу weekly_revenue с дополнительными столбцами с накопленной
суммой, скользящей средней и приростом. Округлить прирост в процентах до 2 
знаков после запятой
 */

-- Прирост по накопительной сумме
with cte as (select asr_year, asr_week, revenue, round(
case when sum(revenue) over w is null then 0 else sum(revenue) over w end * 1) as cumulative_sum,
round((((case when lag(revenue) over w is null then 0 else lag(revenue) over w end * 1) + 
case when revenue is null then 0 else revenue end * 1 +
(case when lead(revenue) over w is null then 0 else lead(revenue) over w end * 1)) / 3)) as slide_average_sum
from weekly_revenue
window w as (rows between unbounded preceding and current row))
select asr_year, asr_week, revenue, cumulative_sum, slide_average_sum, 
round(case when lag(cumulative_sum) over w = 0 or lag(cumulative_sum) over w is null then 0 else (cumulative_sum - lag(cumulative_sum) over w) / lag(cumulative_sum) over w end * 100, 2) || '%' 
as percent_income
from cte
window w as (rows between unbounded preceding and current row)


-- Прирост по еженедельному доходу
with cte as (select asr_year, asr_week, revenue, round(
case when sum(revenue) over w is null then 0 else sum(revenue) over w end * 1) as cumulative_sum,
round((((case when lag(revenue) over w is null then 0 else lag(revenue) over w end * 1) + 
case when revenue is null then 0 else revenue end * 1 +
(case when lead(revenue) over w is null then 0 else lead(revenue) over w end * 1)) / 3)) as slide_average_sum
from weekly_revenue
window w as (rows between unbounded preceding and current row))
select asr_year, asr_week, revenue, cumulative_sum, slide_average_sum, 
round(case when lag(revenue) over w = 0 or lag(revenue) over w is null then 0 else (revenue - lag(revenue) over w) / lag(revenue) over w end * 100, 2) || '%' 
as percent_income
from cte
window w as (rows between unbounded preceding and current row)