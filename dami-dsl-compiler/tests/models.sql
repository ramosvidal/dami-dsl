
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER dsl_models_database_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'chronos', dbname 'dsl_models', port '5432');

CREATE USER MAPPING FOR CURRENT_USER SERVER dsl_models_database_server OPTIONS (user 'dramos', password 'dramos');

CREATE SCHEMA legacy;

IMPORT FOREIGN SCHEMA legacy FROM SERVER dsl_models_database_server INTO legacy;

CREATE SCHEMA IF NOT EXISTS target AUTHORIZATION dramos; 
        
CREATE SCHEMA IF NOT EXISTS aux AUTHORIZATION dramos; 
        
INSERT INTO target.author(code,name,lastname1,lastname2)
    SELECT rese_id,rese_name,rese_first_surname,rese_sec_surname
FROM legacy.researcher;
    
INSERT INTO target.publisher(name)
    SELECT distinct pub_edit
FROM legacy.publication;
    
INSERT INTO publicationtype.name values ('LIBRO'),('CAPÍTULO'),('REVISTA'),('CONGRESO');

INSERT INTO target.authorship(paper_doi,author_code,orderofauthor)
    SELECT pub_id,rese_id,pwrit_ord
FROM legacy.publication_writer;
    
ALTER TABLE target.publication ADD id_publication int;

CREATE TABLE IF NOT EXISTS aux.publication(
    publication_code int,
    id_publication int
);

INSERT INTO target.publication(code,title,place,year,publicationtype_name,publisher_name,country,id_publication)
    SELECT pub_id,chap_book_tit,pub_loc,pub_year,'CAPÍTULO',pub_edit,cntry_name_es
FROM legacy.publication, legacy.book_chapter, legacy.country WHERE pub_id=chapt_id AND pub_cntry=cntry_id;
    
INSERT INTO aux.publication(publication_code,id_publication) 
    SELECT code,id_publication
FROM target.publication;

ALTER TABLE target.publication DROP id_publication;

ALTER TABLE target.publication ADD id_publication int;

CREATE TABLE IF NOT EXISTS aux.publication(
    publication_code int,
    id_publication int
);

INSERT INTO target.publication(code,title,place,year,publicationtype_name,publisher_name,country,id_publication)
    SELECT pub_id,pub_title,pub_loc,pub_year,'LIBRO',pub_edit,cntry_name_es
FROM legacy.publication, legacy.book, legacy.country WHERE pub_id=jrnl_id AND pub_cntry=cntry_id;
    
INSERT INTO aux.publication(publication_code,id_publication) 
    SELECT code,id_publication
FROM target.publication;

ALTER TABLE target.publication DROP id_publication;

ALTER TABLE target.publication ADD id_publication int;

CREATE TABLE IF NOT EXISTS aux.publication(
    publication_code int,
    id_publication int
);

INSERT INTO target.publication(code,title,place,year,publicationtype_name,publisher_name,country,id_publication)
    SELECT pub_id,trim(jrnl_journ_title),pub_loc,pub_year,'REVISTA',pub_edit,cntry_name_es
FROM legacy.publication, legacy.journal, legacy.country WHERE pub_id=jrnl_id AND pub_cntry=cntry_id;
    
INSERT INTO aux.publication(publication_code,id_publication) 
    SELECT code,id_publication
FROM target.publication;

ALTER TABLE target.publication DROP id_publication;

ALTER TABLE target.publication ADD id_publication int;

CREATE TABLE IF NOT EXISTS aux.publication(
    publication_code int,
    id_publication int
);

INSERT INTO target.publication(code,title,place,year,publicationtype_name,publisher_name,country,id_publication)
    SELECT pub_id,conf_name,pub_loc,pub_year,'CONGRESO',pub_edit,cntry_name_es
FROM legacy.publication, legacy.conference, legacy.country WHERE pub_id=jrnl_id AND pub_cntry=cntry_id;
    
INSERT INTO aux.publication(publication_code,id_publication) 
    SELECT code,id_publication
FROM target.publication;

ALTER TABLE target.publication DROP id_publication;

UPDATE target.book_chapter SET publication_code = (
    SELECT publication_code FROM publication.code t WHERE t.id_publication = book_chapter.pub_id);

INSERT INTO target.paper(title,doi,startpage,endpage)
    SELECT pub_title,pub_id,chapt_start_page,chart_end_page
FROM legacy.publication, legacy.book_chapter WHERE pub_id=chapt_id;
    
UPDATE target.book SET publication_code = (
    SELECT publication_code FROM publication.code t WHERE t.id_publication = book.pub_id);

INSERT INTO target.paper(title,doi)
    SELECT pub_title,pub_id
FROM legacy.publication, legacy.book WHERE pub_id=book_id;
    
UPDATE target.journal SET publication_code = (
    SELECT publication_code FROM publication.code t WHERE t.id_publication = journal.pub_id);

INSERT INTO target.paper(title,doi,startpage,endpage)
    SELECT pub_title,pub_id,jrnl_start_page,jrnl_end_page
FROM legacy.publication, legacy.journal WHERE pub_id=jrnl_id;
    

INSERT INTO target.paper(title,doi,startpage,endpage)
    SELECT pub_title,pub_id,conf_start_page,conf_end_page
FROM legacy.publication, legacy.conference WHERE pub_id=jrnl_id;

UPDATE target.paper SET publication_code = (
    SELECT publication_code FROM aux.publication t WHERE t.id_publication = conference.pub_id);
    
DROP SCHEMA aux CASCADE;
DROP SCHEMA legacy CASCADE;

DROP SERVER dsl_models_database_server CASCADE;

DROP EXTENSION postgres_fdw CASCADE;

DROP SERVER dsl_models_database_server CASCADE;

DROP EXTENSION postgres_fdw CASCADE;
