/*1. Спроектируйте таблицу reviews
Напишите команду CREATE TABLE для новой таблицы reviews, в которой пользователь может оставить один отзыв на товар: rating от 1 до 5, необязательный текст comment и временную метку. Ваша таблица должна гарантировать, используя только ограничения (без кода приложения):
отзыв всегда ссылается на реального пользователя и реальный товар;
один и тот же пользователь не может оставить отзыв на один и тот же товар дважды;
rating никогда не может выйти за пределы диапазона 1-5.
Подсказка: «один и тот же пользователь не может оставить отзыв на один и тот же товар дважды» — это ровно паттерн составного ключа из примера с favorites в уроке.
*/

CREATE TABLE reviews (
    user_id    INTEGER REFERENCES users(id),
    product_id INTEGER REFERENCES products(id),
    rating     INTEGER not null check (rating between 1 and 5),
    comment    TEXT,
    cteate_at  TIMESTAMP not null default current_timestamp ,
    PRIMARY KEY (user_id, product_id) 
);

/*2. Добавьте столбец
Напишите команду ALTER TABLE, добавляющую в users необязательный (nullable) столбец phone_number (TEXT).
*/

ALTER TABLE users
ADD COLUMN phone_number TEXT;

/*3. Добавьте ограничение постфактум
Напишите команду ALTER TABLE, добавляющую в orders ограничение CHECK, требующее, чтобы quantity было не больше 10 (уже должно быть больше 0 согласно исходной схеме).
*/

ALTER TABLE orders
drop constraint orders_quantity_check

ALTER TABLE orders
ADD CONSTRAINT orders_quantity_check
check (quantity between 0  and 10 )

/*4. Вставьте товар
Напишите команду INSERT, которая добавляет новый товар: название 'Studio Desk Lamp', категория 'Office', цена 45.50, запас 25. Используйте RETURNING, чтобы команда вернула вам id новой строки.
*/

insert into products 
("name", category, price, stock)
values ('Studio Desk Lamp', 'Office', 45.50, 25)
returning id;

/*5. Повышение цен по всему каталогу
Напишите команду UPDATE, которая повышает цену каждого товара в категории 'Furniture' на 10% (то есть умножает price на 1.10).
Напоминание: всегда дважды смотрите на свою конструкцию WHERE, прежде чем выполнять UPDATE. Что бы сделала эта команда с вашими данными, если бы вы вовсе забыли про WHERE?
*/

UPDATE products
SET price = price * 1.1
WHERE category = 'Furniture'
RETURNING *;

/*6. Автоматическая отмена устаревших заказов
Напишите команду UPDATE, которая устанавливает status в 'cancelled' для каждого заказа, всё ещё имеющего статус 'pending' и созданного более 30 дней назад.
Подсказка: сравните created_at с now() - interval '30 days'.
*/

update orders 
set status = 'cancelled'
where created_at::date <= (NOW() - INTERVAL '30 days')::date
and  status like 'pending'

/*7. Удаление и объяснение ошибки
Выберите любой товар, на который ссылается хотя бы один заказ (сначала проверьте с помощью SELECT), затем попробуйте выполнить его DELETE. Запишите сообщение об ошибке, которое выдаёт Postgres, и объясните почему это происходит одним предложением, сославшись на понятие из предыдущего урока.
*/

delete from products 
where id =7
____________________________________
SQL Error [23503]: ERROR: update or delete on table "products" violates foreign key constraint "orders_product_id_fkey" on table "orders"
  Подробности: Key (id)=(7) is still referenced from table "orders".
 ___________________________________

Операция не может быть выполненна , т.к.  в таблице orders есть записи с участием products.id = 7.


/*8. Индекс под новый шаблон запроса
Ваше приложение теперь часто выполняет: SELECT * FROM orders WHERE status = 'pending' ORDER BY created_at;. Напишите команду CREATE INDEX, которая бы ускорила этот запрос.
Подсказка: индекс может охватывать больше одного столбца — если хотите пойти дальше однoстолбцового индекса, посмотрите в документации PostgreSQL, как создать многостолбцовый индекс.
*/

/*Ответ:
К сожалению мой составной индекс не работал с заданным селектом , поэтому тестировать будет на другом селекте :*/
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE status = 'pending'
  AND created_at BETWEEN
      NOW() - INTERVAL '30 days'
      AND NOW();

/*Результат:
Bitmap Heap Scan on orders  (cost=65.60..265.22 rows=104 width=32) (actual time=4.957..5.339 rows=113 loops=1)
  Recheck Cond: ((created_at >= (now() - '30 days'::interval)) AND (created_at <= now()) AND (status = 'pending'::text))
  Heap Blocks: exact=89
  ->  BitmapAnd  (cost=65.60..65.60 rows=104 width=0) (actual time=4.760..4.766 rows=0 loops=1)
        ->  Bitmap Index Scan on idx_orders_created_at  (cost=0.00..30.97 rows=1067 width=0) (actual time=2.747..2.748 rows=1059 loops=1)
              Index Cond: ((created_at >= (now() - '30 days'::interval)) AND (created_at <= now()))
        ->  Bitmap Index Scan on idx_orders_status  (cost=0.00..34.33 rows=2939 width=0) (actual time=1.956..1.958 rows=2939 loops=1)
              Index Cond: (status = 'pending'::text)
Planning Time: 2.788 ms
Execution Time: 5.635 ms*/
*****************************************************************************************************
/*Создаем составной индекс*/
CREATE INDEX idx_orders_status_created_at2
ON orders (status, created_at);

/*Результат:
Bitmap Heap Scan on orders  (cost=5.62..205.24 rows=104 width=32) (actual time=0.424..0.996 rows=113 loops=1)
  Recheck Cond: ((status = 'pending'::text) AND (created_at >= (now() - '30 days'::interval)) AND (created_at <= now()))
  Heap Blocks: exact=89
  ->  Bitmap Index Scan on idx_orders_status_created_at2  (cost=0.00..5.59 rows=104 width=0) (actual time=0.342..0.344 rows=113 loops=1)
        Index Cond: ((status = 'pending'::text) AND (created_at >= (now() - '30 days'::interval)) AND (created_at <= now()))
Planning Time: 11.360 ms
Execution Time: 3.333 ms*/

/*Вывод : время выполнение запроса сократилось почти в 2 раза*/

/*9. Безопасная транзакция пополнения запаса и заказа
Напишите транзакцию (BEGIN … COMMIT), которая атомарно делает две вещи: вставляет новый заказ для пользователя 1, покупающего 2 единицы товара 1, и уменьшает запас товара 1 на 2. Если хотя бы одна из команд завершится неудачей, ни одна не должна вступить в силу.
*/

BEGIN;

insert into orders(user_id, product_id, quantity)
values (1, 1, 2);
update products   
set stock = stock - 2
where id = 1;

COMMIT;