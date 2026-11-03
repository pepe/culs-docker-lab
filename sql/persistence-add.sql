INSERT INTO lab.student VALUES ('s04','Daria',true) ON CONFLICT (student_id) DO NOTHING;
SELECT student_id, name FROM lab.student ORDER BY student_id;
