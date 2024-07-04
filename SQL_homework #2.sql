-- Вывести количество уникальных имен клиентов
select count(*) from (select distinct(first_name) from customer);

/*Вывести 5 самых частых сумм оплаты, их даты, количество и сумму 
платежей одинакового номинала */
with cte as (select count(payment.amount) as most_freq_amount, 
payment.amount as amount, sum(payment.amount) as sum_amount 
from payment group by payment.amount order by most_freq_amount desc limit 5) 
select cte.amount, p.payment_date, cte.most_freq_amount, sum_amount  
from cte inner join payment p on cte.amount = p.amount 
order by amount desc;

-- Вывести число ячеек в инвентаре каждого магазина
select store_id, count(inventory_id) as amount from inventory group by store_id;

-- Вывести адреса всех магазинов (JOIN)
select s.address_id, a.address from address a inner join store s 
on s.address_id = a.address_id;

-- Вывести полные имена всех клиентов и сотрудников в одну колонку
select c.first_name || ' ' || c.last_name || ' | ' || 
s.first_name || ' ' || s.last_name as "customer/staff"
from customer c inner join staff s on s.store_id = c.store_id;

/* Вывести имена клиентов, которые не совпадают с именами  
сотрудников (except) */
select first_name from customer except 
(select first_name from staff); 


/* Вывести кто (customer_id), когда (rental_date) 
(привести к типу date) и у кого (staff_id) брал диски в 
аренду в Июне 2005 года */
with cte as (select rental_date::date, customer_id, staff_id from rental
where extract(year from rental_date) = 2005
and extract(month from rental_date) = 06)
select c.first_name|| ' ' || c.last_name as customer, cte.customer_id, 
cte.rental_date, cte.staff_id, s.first_name || ' ' || s.last_name as staff
from cte inner join customer c on cte.customer_id = c.customer_id 
inner join staff s on s.staff_id = cte.staff_id; 

/* Вывести id всех клиентов, которые имеют 40+ оплат. Посчитать 
средний размер транзакции для всех клиентов и округлить до 2 
знаков, вывести в отдельный столбец */
select customer_id, round(avg(amount), 2) avg_cheques 
from payment group by customer_id 
having(count(*) >= 40) order by avg_cheques desc;


/* Вывести id, полное имя актера и посчитать в скольких фильмах 
снялся. (Подсказка: подумать по какому полю сгруппировать: по 
имени или по id).*/
with cte as (select actor_id, count(*) amount_of_films from film_actor group by 
actor_id) select cte.actor_id, a.first_name || ' ' || a.last_name full_name,
cte.amount_of_films from cte inner join actor a on 
a.actor_id = cte.actor_id;

-- Выяснить, какой актер снялся в бОльшем количестве фильмов:
with cte as (select actor_id, count(*) amount_of_films from film_actor group by 
actor_id) select cte.actor_id, a.first_name || ' ' || a.last_name full_name,
cte.amount_of_films from cte inner join actor a on 
a.actor_id = cte.actor_id order by amount_of_films desc limit 1;


/* Посчитать выручку в каждом месяце работы проката. Месяц должен 
рассчитываться по rental_date, а не по payment_date. 
Округлить выручку до одного знака после запятой. 
Отсортировать строки в хронологическом порядке. (Подсказка: есть месяц проката, 
где выручки не было (нет данных о платежах) – он должен присутствовать в отчете)*/
with cte as (select rental_id, rental_date::date from rental)
select round(sum(p.amount), 1) total_amount, extract(year from rental_date) 
|| '-' || extract(month from rental_date) month_date
from cte left join payment p
on p.rental_id = cte.rental_id
group by month_date order by month_date; 


/*Найти средний платеж по каждому жанру фильма. Отобразить только те жанры, к которым относится более 60 различных фильмов. 
Округлить средний платеж до двух знаков после запятой. Дать названия столбцам. 
Отобразить жанры в порядке убывания среднего платежа */
with cte as (
select category_id from film_category group by 
category_id having (count(*) > 60)) 
select category_id, cat_name, round(avg(rent), 2) avg_rent from (
select category_id, cat_name, f.rental_rate rent from (
select f.film_id, f.category_id, c.name cat_name from film_category f
inner join category c on c.category_id = f.category_id where f.category_id in (select category_id from cte)) cat
inner join film f on f.film_id = cat.film_id)
group by cat_name, category_id order by avg_rent desc;


/* Какие фильмы чаще всего берут на прокат по субботам? 
Показать названия первых 5 по популярности фильмов. 
Если у фильмов одинаковая популярность, отдать предпочтение первому по алфавиту. */
with cte as (select inventory_id, rental_date from rental where extract(dow from rental_date) = 6)
select title, count(*) amount from (
select f.title from cte inner join inventory i on i.inventory_id = cte.inventory_id
inner join film f on i.film_id = f.film_id) group by title order by amount desc, title asc limit 5
