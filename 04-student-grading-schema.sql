-- Создаем таблицы

CREATE TABLE students (
    id              SERIAL PRIMARY KEY,
    full_name       TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    birth_date      DATE,
    enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE courses (
    id              SERIAL PRIMARY KEY,
    course_name     TEXT NOT NULL,
    teacher_name    TEXT NOT NULL,
    credits         INTEGER     NOT NULL CHECK (credits > 0)
);

CREATE TABLE grades (
    id              SERIAL PRIMARY KEY,
    student_id      INTEGER     NOT NULL REFERENCES students(id),
    course_id       INTEGER     NOT NULL REFERENCES courses(id),
    grade           INTEGER     NOT NULL CHECK (grade between 0 and 100),
    UNIQUE (student_id, course_id)
);

-- Заполняем таблицы данными

INSERT INTO students (full_name, email)
VALUES
    ('student1', 'student1@gmail.com'),
    ('student2', 'student2@gmail.com'),
    ('student3', 'student3@gmail.com');

INSERT INTO courses (course_name, teacher_name, credits)
VALUES
    ('Databases', 'Petrov Gennadiy', 60),
    ('Statistics', 'Pupkin Fedor', 10),
    ('Algorithms', 'Snigir'' Zinaida', 50);

INSERT INTO grades (student_id  , course_id , grade)
VALUES
    (1, 1, 50),
    (1, 2, 60),
    (1, 3, 70),
    (2, 1, 30),
    (2, 3, 60),
    (3, 2, 80);

-- Обновлем данные для 2-х студантов 

UPDATE students SET email = 'student11@gmail.com' WHERE id = 1;
UPDATE students SET birth_date = '1985-04-22' WHERE id = 2;

-- Удаляем одного студента, предварительно удалив его записи с таблице grades 

DELETE FROM grades WHERE student_id = 1;
DELETE FROM students WHERE id = 1;
