-- Restores ONLY the lab schema. Replaces previous work in that schema.
BEGIN;
DROP SCHEMA IF EXISTS lab CASCADE;
CREATE SCHEMA lab;
CREATE TABLE lab.student (
 student_id text PRIMARY KEY, name text NOT NULL, is_active boolean NOT NULL
);
CREATE TABLE lab.course (course_code text PRIMARY KEY, title text NOT NULL);
CREATE TABLE lab.course_offering (
 offering_id text PRIMARY KEY,
 course_code text NOT NULL REFERENCES lab.course(course_code),
 term text NOT NULL, capacity integer NOT NULL CHECK (capacity >= 0)
);
CREATE TABLE lab.enrollment (
 enrollment_id text PRIMARY KEY,
 student_id text NOT NULL REFERENCES lab.student(student_id),
 offering_id text NOT NULL REFERENCES lab.course_offering(offering_id),
 status text NOT NULL CHECK (status IN ('pending','confirmed','rejected','cancelled')),
 UNIQUE (student_id, offering_id)
);
INSERT INTO lab.student VALUES
('s01', 'Ada', true),
('s02', 'Ben', true),
('s03', 'Cyd', false);
INSERT INTO lab.course VALUES
('TI', 'Theoretical Informatics'),
('FM', 'Formal Modelling');
INSERT INTO lab.course_offering VALUES
('TI26A', 'TI', 'WS2026', 2),
('TI26B', 'TI', 'WS2026', 0),
('FM26A', 'FM', 'WS2026', 2);
INSERT INTO lab.enrollment VALUES
('e01', 's01', 'TI26A', 'confirmed'),
('e02', 's02', 'TI26A', 'pending'),
('e03', 's01', 'FM26A', 'confirmed');
COMMIT;
