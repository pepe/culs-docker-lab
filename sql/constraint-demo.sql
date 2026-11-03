-- Optional: expected unique-constraint error. No row is inserted.
-- Run separately from the seed. psql ON_ERROR_STOP exits with nonzero status.
INSERT INTO lab.enrollment VALUES ('e99','s01','TI26A','pending');
