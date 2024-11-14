
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER bvg_database_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '', dbname 'bvg', port 'port');

CREATE USER MAPPING FOR CURRENT_USER SERVER bvg_database_server OPTIONS (user 'user', password 'pwd');

CREATE SCHEMA old;

IMPORT FOREIGN SCHEMA , FROM SERVER bvg_database_server INTO old;

CREATE SCHEMA IF NOT EXISTS , AUTHORIZATION user; 
        
CREATE SCHEMA IF NOT EXISTS aux AUTHORIZATION user; 
        
ALTER TABLE public.authority ADD autor_id character(25);

CREATE TABLE IF NOT EXISTS aux.authority(
    authority_id bigint,
    autor_id character(25)
);

INSERT INTO public.authority(name,gender,birthdate,deathdate,century,genre,region,autor_id)
    SELECT nome_real,sexo,dia_nac,ano_mor,seculo,narrativa,localidade,id
FROM old.autor;
    
INSERT INTO aux.authority(authority_id,autor_id) 
    SELECT id,autor_id
FROM public.authority;

ALTER TABLE public.contact ADD autor_id character(25);

CREATE TABLE IF NOT EXISTS aux.contact(
    contact_id bigint,
    autor_id character(25)
);

INSERT INTO public.contact(city,email,phone,postal_code,province,street,web,autor_id)
    SELECT localidade,email,mobil,cp,provincia,rua,inter_web,id
FROM old.autor;
    
INSERT INTO aux.contact(contact_id,autor_id) 
    SELECT id,autor_id
FROM public.contact;

ALTER TABLE public.authority DROP autor_id;

ALTER TABLE public.contact DROP autor_id;

ALTER TABLE public.alias ADD autor_id character(25);

CREATE TABLE IF NOT EXISTS aux.alias(
    alias_id bigint,
    autor_id character(25)
);

UPDATE public.TO SET authority_id = (
    SELECT authority_id FROM authority.id t WHERE t.autor_id = TO.id_autor);

INSERT INTO public.alias(alias,principal,authority_id,autor_id)
    SELECT nome_alias,principal,id_autor,id_autor
FROM old.alias;
    
INSERT INTO aux.alias(alias_id,autor_id) 
    SELECT id,autor_id
FROM public.alias;

ALTER TABLE public.alias DROP autor_id;

ALTER TABLE public.collaborator ADD usuario_login character(25);

CREATE TABLE IF NOT EXISTS aux.collaborator(
    collaborator_id bigint,
    usuario_login character(25)
);

INSERT INTO public.collaborator(login,password,usuario_login)
    SELECT login,password,login
FROM old.usuario;
    
INSERT INTO aux.collaborator(collaborator_id,usuario_login) 
    SELECT id,usuario_login
FROM public.collaborator;

ALTER TABLE public.collaborator DROP usuario_login;

ALTER TABLE public.authority ADD autor_id character(25);

CREATE TABLE IF NOT EXISTS aux.authority(
    authority_id bigint,
    autor_id character(25)
);

INSERT INTO public.files(file_download_uri,file_name,file_type,autor_id)
    SELECT foto,foto,foto,id
FROM old.autor;
    
UPDATE public.authority SET photo = ( SELECT id FROM files a JOIN aux.authority b ON a.autor_id = b.autor_id WHERE b.authority_id = authority.id);
    
ALTER TABLE public.edition ADD id_edicion character(25);

CREATE TABLE IF NOT EXISTS aux.edition(
    edition_id bigint,
    id_edicion character(25)
);

ALTER TABLE public.work ADD id_obra character(25);

CREATE TABLE IF NOT EXISTS aux.work(
    work_id bigint,
    id_obra character(25)
);

INSERT INTO public.edition(creation_date,draft,revised,isbn,beginning_year,finishing_year,language,probable,id_edicion,id_obra)
    SELECT data_envio,false,false,isbn,ano,ano,'Galego',false,id,id_obra
FROM old.edicion;
    
INSERT INTO aux.edition(edition_id,id_edicion) 
    SELECT id,id_edicion
FROM public.edition;

ALTER TABLE public.authority DROP autor_id;

ALTER TABLE public.edition DROP id_edicion;

ALTER TABLE public.work DROP id_obra;

ALTER TABLE public.work ADD id_obra character(25);

CREATE TABLE IF NOT EXISTS aux.work(
    work_id bigint,
    id_obra character(25)
);

INSERT INTO public.work(creation_date,draft,observations,revised,title,type,id_obra)
    SELECT data_envio,false,observacions,true,titulo,tipo,id_obra
FROM old.obra;
    
INSERT INTO aux.work(work_id,id_obra) 
    SELECT id,id_obra,id,id_obra
FROM public.work;

ALTER TABLE public.work DROP id_obra;

ALTER TABLE public.work ADD obra_id character(25);

CREATE TABLE IF NOT EXISTS aux.work(
    work_id bigint,
    obra_id character(25)
);

INSERT INTO public.files(file_download_uri,file_name,file_type,autor_id,path,temporary,obra_id)
    SELECT foto,foto,foto,id,imaxe,imaxe,false,id
FROM old.obra;
    
UPDATE public.work SET cover = ( SELECT id FROM files a JOIN aux.work b ON a.id_obra = b.id_obra WHERE b.work_id = work.id);
    
ALTER TABLE public.authority_element ADD autor_id character(25);

CREATE TABLE IF NOT EXISTS aux.authority_element(
    authority_element_authority_id bigint,
    autor_id character(25)
);

ALTER TABLE public.authority_element ADD obra_id character(25);

CREATE TABLE IF NOT EXISTS aux.authority_element(
    authority_element_elemet_id bigint,
    obra_id character(25)
);

INSERT INTO public.authority_element(role,autor_id,obra_id)
    SELECT 'Author',id_autor,id_obra
FROM old.autor_obra;
    
INSERT INTO aux.authority_element(authority_element_authority_id,autor_id,authority_element_elemet_id,obra_id) 
    SELECT authority_id,autor_id,elemet_id,obra_id
FROM public.authority_element;

ALTER TABLE public.work DROP obra_id;

ALTER TABLE public.authority_element DROP autor_id;

ALTER TABLE public.authority_element DROP obra_id;

DROP SCHEMA aux CASCADE;
DROP SCHEMA old CASCADE;

DROP SERVER bvg_database_server CASCADE;

DROP EXTENSION postgres_fdw CASCADE;

DROP SERVER bvg_database_server CASCADE;

DROP EXTENSION postgres_fdw CASCADE;
