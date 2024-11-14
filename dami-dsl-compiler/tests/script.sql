
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE SERVER bvg_database_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'bvg', port '5432');
CREATE USER MAPPING FOR CURRENT_USER SERVER bvg_database_server OPTIONS (user 'postgres', password 'postgres');

DROP SERVER bvg_database_server CASCADE;
DROP EXTENSION postgres_fdw CASCADE;
