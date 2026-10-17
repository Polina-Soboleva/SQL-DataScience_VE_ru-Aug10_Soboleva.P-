/* 1. Все администраторы
 * Напишите запрос, который возвращает email и full_name каждого пользователя, чья role равна 'admin'.
 */

SELECT u.email, u.full_name
FROM public.users u
WHERE u."role" = 'admin';

/* 2. Доступная электроника
 * Напишите запрос, который возвращает name и price для каждого товара из категории 'Electronics' дешевле $50, сначала самые дешёвые.
 */

SELECT p."name" , p.price  
FROM public.products p
WHERE p.category LIKE 'Electronics'
AND p.price < 50
ORDER BY p.price;

/* 3. Самые новые аккаунты
 * Напишите запрос, который возвращает email и created_at 10 самых недавно созданных пользовательских аккаунтов, сначала самые новые.
 */

SELECT  u.email, u.created_at
FROM public.users u
ORDER BY u.created_at DESC
LIMIT 10;

/* 4. Только клавиатуры 
 * Напишите запрос, который возвращает name, category и price для каждого товара, чьё name содержит слово Keyboard, отсортированных по алфавиту по имени.
 */ 

select p.name, p.category, p.price  
from products p
where p.name  like '%Keyboard%'
order by 1;

/*5. Имена, начинающиеся с «A»
 * Напишите запрос, который возвращает full_name и email каждого пользователя, чьё full_name начинается с буквы A.
 */

select full_name, email
FROM public.users
where full_name like 'A%'
order by full_name ;

/* 6. Самая дешёвая мебель
 * Напишите запрос, который возвращает 5 самых дешёвых товаров из категории 'Furniture' — только name и price, сначала самые дешёвые.
 */ 

SELECT "name", price 
FROM public.products
where category = 'Furniture'
order by price
limit 5;

/* 7. Средний ценовой диапазон
 * Напишите запрос, который возвращает name, category и price для товаров ценой от 100 до 200 включительно, сначала самые дорогие, ограничив вывод первыми 10.
 */ 

SELECT "name", category, price
FROM public.products
where price between 100 and 200
order by price desc
limit 10;

/* 8. «Вторая страница» дорогих товаров
 * Напишите запрос, который возвращает товары, занимающие с 6-го по 10-е место по убыванию цены (name, price).
 */ 

 SELECT "name", price
FROM public.products
where price between 100 and 200
order by price desc
limit 5 offset 5;

/* 9. Концептуальный вопрос: ключи, а не код
 * users и products пока остаются самостоятельными таблицами, orders ещё нет. Когда orders появится (в следующем уроке), на какой столбец в users 
 * скорее всего будет ссылаться внешний ключ в orders, и почему именно этот столбец в принципе хорошо подходит на роль первичного ключа?
 */

/* Ответ:
 * Таблица orders имеет 2 внешних ключа user.user_id, product.product_id.
 * user.user_id - это первичный ключ в таблице users, 
 * первичный ключ должен быть уникальным и желательно не неизменяемым , id - отвечает этим требованиям, в отличае от:
 * email уникальный ,но изменяемым
 * hashed_password не уникальный
 * full_name не уникальный
 * role  не уникальный
 */
