
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER bvg_database_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', dbname 'bvg', port '5432');

CREATE USER MAPPING FOR CURRENT_USER SERVER bvg_database_server OPTIONS (user 'postgres', password 'postgres');

CREATE SCHEMA old;

IMPORT FOREIGN SCHEMA public FROM SERVER bvg_database_server INTO old;

CREATE SCHEMA IF NOT EXISTS public AUTHORIZATION postgres; 
        
CREATE SCHEMA IF NOT EXISTS aux AUTHORIZATION postgres; 
        
CREATE SCHEMA old;

IMPORT FOREIGN SCHEMA public FROM SERVER old_database_server INTO old;

CREATE SCHEMA IF NOT EXISTS aux AUTHORIZATION postgres; 
        
INSERT INTO public.authority
    SELECT *
FROM old.autor;
    
DROP SCHEMA aux CASCADE;

DROP SCHEMA old CASCADE;

DROP SERVER bvg_database_server CASCADE;

DROP EXTENSION postgres_fdw CASCADE;

DROP SCHEMA aux CASCADE;
DROP SCHEMA old CASCADE;

DROP SERVER bvg_database_server CASCADE;

DROP EXTENSION postgres_fdw CASCADE;

DROP SERVER bvg_database_server CASCADE;

DROP EXTENSION postgres_fdw CASCADE;
