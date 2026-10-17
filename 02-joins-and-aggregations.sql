/* 1. Кто что заказал
Напишите запрос, который соединяет orders с users и products и возвращает для каждого заказа: id заказа, email пользователя, name товара и quantity заказа.
*/

SELECT o.id, u.email,  p."name", o.quantity
FROM orders o
join users u on u.id = o.user_id 
join products p on p.id = o.product_id ;

/*2. Отсортировано по дню заказа
Расширьте вопрос 1: также выберите дату размещения заказа (только день, а не полную временную метку — orders.created_at имеет тип TIMESTAMPTZ), и отсортируйте весь результат по этому дню, сначала самые ранние.
Подсказка: вам нужна функция, которая извлекает только часть даты из столбца с временной меткой. Посмотрите функцию DATE() в PostgreSQL или приведение типа ::date.
*/

SELECT o.id, u.email,  p."name", o.quantity, DATE(o.created_at)
FROM orders o
join users u on u.id = o.user_id 
join products p on p.id = o.product_id 
order by DATE(o.created_at);

/*3. Пользователи, которые никогда не заказывали
Напишите запрос, который возвращает email каждого пользователя, который никогда не размещал ни одного заказа. (Вы должны увидеть аккаунт из шага настройки и, возможно, ещё несколько.)
*/

select u.email 
from users u
left join orders o on o.user_id = u.id 
where o.user_id  is NULL

/*4. Заказы по статусам
Напишите запрос, который возвращает каждое отдельное значение status и количество заказов, имеющих этот статус в данный момент, сначала самый частый статус.
*/

select 
o.status,
count(o.status) as "Orders count"
from orders o
group by o.status 
order by "Orders count" desc

/*5. Выручка по категориям
Напишите запрос, который возвращает каждую категорию товаров (category) и суммарную выручку, которую она принесла — то есть сумму price * quantity по всем заказам товаров этой категории, — отсортированную от наибольшей выручки к наименьшей.
Подсказка: вам нужно будет соединить orders с products, прежде чем группировать по category.
*/

select 
p.category , 
sum(o.quantity * p.price ) as "Revenue"
from orders o
join products p on p.id = o.product_id 
group by p.category
order by "Revenue" desc

/*6. Топ-5 покупателей
Напишите запрос, который возвращает email 5 пользователей, заказавших больше всего товаров в сумме (сумма quantity по всем их заказам, независимо от статуса), вместе с этой суммой, сначала наибольшая.
*/

select u.email , sum(o.quantity) as "SUM"  
from users u
join orders o on o.user_id = u.id 
group by u.id 
order by "SUM" desc 
limit 5

/*7. Категории выше среднего
Напишите запрос, который возвращает каждую категорию товаров (category), чья средняя цена выше средней цены по всему каталогу.
Подсказка: здесь нужен подзапрос — сначала вычислите общее среднее один раз, а затем сравните с ним среднее по каждой категории. Решите, куда должно попасть это сравнение — в WHERE или в HAVING.
*/

select p.category, AVG(p.price)
from products p 
group by p.category 
having AVG(p.price) > (select AVG(p.price) from products p)
order by 2

/*8. Частые покупатели
Напишите запрос, который возвращает email каждого пользователя, разместившего более 40 заказов (в любом статусе), вместе с количеством его заказов, сначала больше всего заказов.
*/

select u.email, count(o.id) as "Order count"
from users u
join orders o on o.user_id = u.id 
group by u.id 
having count(o.id) > 40
order by "Order count" desc

/*9. Никогда не заказанные товары
Напишите запрос, который возвращает name каждого товара, который ни разу не встречался ни в одном заказе — даже отменённом. (Вы должны увидеть товар из шага настройки и, возможно, ещё несколько.)
*/

select p."name" 
from products p
left join orders o  on o.product_id = p.id 
where o.id is null
