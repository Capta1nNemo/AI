-- Вывести список всех клиентов (customer)
select * from customer;

-- Вывести список имен и фамилий клиентов с именем Carolyn
select first_name, last_name from customer where first_name = 'Carolyn';

/*Вывести иполные имена клиентов (имя + фамилия), имя или фамилия 
которых содержит “ary” (например: Mary, Geary), в одной колонке */
select first_name || ' ' || last_name as full_name from customer where first_name like '%ary%' 
or last_name like '%ary%';

--Вывести 20 самых крупных транзакций (payment)
with cte as (select * from payment order by amount desc limit 20)
select * from cte

-- адреса магазинов из запроса выше через staff_id и таблицу store
with cte as (select * from payment order by amount desc limit 20)
select address from address where address_id in(
select address_id from store inner join cte on cte.staff_id = store.manager_staff_id);

-- Вывести адреса всех магазинов (подзапрос)
select distinct address from address;

/* Вывести число, месяц и день недели в числовом эквиваленте 
(Понедельник - 1, Вторник - 2..) для каждой оплаты */
select payment_id, extract(day from payment_date) as day, extract(month from payment_date) as month, 
extract(dow from payment_date) as weekday from payment;

/* Вывести кто (customer_id), когда (rental_date) 
(привести к типу date) и у кого (staff_id) брал диски в аренду 
в Июне 2005 года */
select customer_id, rental_date::date, staff_id from rental
where rental_date between '2005-06-01' and '2005-06-30';

/* Вывести название, описание и длительность фильмов (film),
выпущенных после 2000 года. Включить только фильмы длительностью 
в интервале от 60 до 120 минут (включительно). 
Показать первые 20 фильмов по длительности (самые длинные). */
select title as "Название", description as "Описание", 
length as "Длительность" from film where release_year >= 2000
and length between 60 and 120 order by length desc limit 20;

/* Найти все платежи (payment), совершенные в апреле 2007 года, 
чья стоимость не превышает 4 долларов. Показать идентификатор, 
дату (без времени) и стоимость платежа. Платежи отобразить в порядке убывания стоимости. 
При совпадени и стоимости, отдать предпочтение более раннему платежу */
select payment_id, payment_date::date, amount from payment where 
(payment_date between '2007-04-01' and '2007-04-30')
and amount <= 4 order by amount desc, payment_date asc;

/*Показать имена, фамилиии идентификаторы всех клиентов с именами 
“Jack”, “Bob”, или “Sara”, чья фамилия содержит букву “p”. 
Переименовать колонку с именем в “Имя”, с идентификатором в 
“Идентификатор”, с фамилией в “Фамилия”. Клиентов отобразить в 
порядке возрастания их идентификатора */
select first_name as "Имя", last_name as "Фамилия", 
customer_id as "Идентификатор"  from customer where first_name in 
('Jack', 'Bob', 'Sara') and 
(last_name like '%p%' or last_name like '%P%') 
order by customer_id asc;


/* Создать таблицу студентов с полями: имя, фамилия, возраст, 
дата рождения и адрес. Все поля закрыты от внесения пустых данных. 
Внести в таблицу 1 студентасid > 50. Посмотреть текущие записи 
таблицы. Внести несколько записей 1 запросом, используя 
автоинкремент id. Посмотреть текущие записи таблицы. Удалить 1 
студента на выбор. Вывести полный список студентов. Удалить таблицу.
 Вывести результат запроса на выборку из таблицы студентов.*/
create table students(
id serial primary key not null,
first_name varchar not null, 
last_name varchar not null, 
age int not null, 
birthdate date not null, 
address text not null);

insert into students(first_name, last_name, age, birthdate, address) 
values ('Alex', 'Smith', 22, '2002-04-13', 'www.leningrad');

select * from students;

insert into students(first_name, last_name, age, birthdate, address) 
values 
('Ann', 'Mark', 21, '2003-05-01', 'NY'),
('Sam', 'Howl', 18, '2006-01-25', 'Sydney'),
('Lucy', 'Mann', 19, '2005-06-05', 'Beijin')
;

select * from students;

delete from students where id = 1;

select * from students;

drop table students;

select * from students;