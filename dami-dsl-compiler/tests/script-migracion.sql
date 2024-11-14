CREATE SEQUENCE keys;

insert into target.author
select rese_id, rese_name, rese_first_surname, rese_sec_surname
from legacy.researcher r;

insert into target.publicationtype values ('LIBRO'), ('CAPÍTULO'), ('REVISTA'), ('CONGRESO');

insert into target.publisher 
select distinct pub_edit from legacy.publication where pub_edit != '' and pub_edit is not null;

insert into target.publication
select nextval('keys'), chapt_book_tit, pub_loc, cntry_name_es, pub_year, pub_type, pub_edit 
from (
	select distinct chapt_book_tit, pub_loc, co.cntry_name_es, pub_year, 'CAPÍTULO' as pub_type, case when pub_edit != '' then pub_edit else null end as pub_edit
	from legacy.publication, legacy.book_chapter bc, legacy.country co where pub_id = chapt_id and pub_cntry = co.cntry_id
) as pubs;

insert into target.publication
select nextval('keys'), pub_title, pub_loc, cntry_name_es, pub_year, pub_type, pub_edit
from (
	select distinct pub_title, pub_loc, co.cntry_name_es, pub_year, 'LIBRO' as pub_type, case when pub_edit != '' then pub_edit else null end as pub_edit
	from legacy.publication, legacy.book b, legacy.country co where pub_id = book_id and pub_cntry = co.cntry_id
) as pubs;

insert into target.publication
select nextval('keys'), jrnl_journ_title, pub_loc, cntry_name_es, pub_year, pub_type, pub_edit
from (
	select distinct trim(jrnl_journ_title || ' ' || 
			(case when jrnl_vol != '' then '' || jrnl_vol || ' ' else '' end) || 
			(case when jrnl_numb != '' then '(' || jrnl_numb || ')' else '' end)) as jrnl_journ_title, 
			pub_loc, co.cntry_name_es, pub_year, 'REVISTA' as pub_type, case when pub_edit != '' then pub_edit else null end as pub_edit
	from legacy.publication, legacy.journal j, legacy.country co  where pub_id = jrnl_id and pub_cntry = co.cntry_id
) as pubs;

insert into target.publication
select nextval('keys'), conf_name, pub_loc, cntry_name_es, pub_year, pub_type, pub_edit 
from (
	select distinct conf_name || (case when conf_ref  != '' then ' (' || conf_ref || ')' else '' end) as conf_name,
	pub_loc, co.cntry_name_es, pub_year, 'CONGRESO' as pub_type, case when pub_edit != '' then pub_edit else null end as pub_edit 
	from legacy.publication, legacy.conference c2, legacy.country co  where pub_id = conf_id  and pub_cntry = co.cntry_id
) as pubs;

insert into target.paper 
	select	pub_title, pub_id, null, chapt_start_page, chapt_end_page, 
		(select code from target.publication where title = chapt_book_tit and publicationtype_name = 'CAPÍTULO') 
	from legacy.publication, legacy.book_chapter bc 
	where pub_id = chapt_id

insert into target.paper 
	select	pub_title, pub_id, null, null, null, 
		(select code from target.publication where title = pub_title and publicationtype_name = 'LIBRO') 
	from legacy.publication, legacy.book b 
	where pub_id = book_id;

insert into target.paper 
	select pub_title, pub_id, null, jrnl_start_page, jrnl_end_page,
	(select code from target.publication where title = trim(jrnl_journ_title || ' ' || (case when jrnl_vol != '' then '' || jrnl_vol || ' ' else '' end) || (case when jrnl_numb != '' then '(' || jrnl_numb || ')' else '' end)) and publicationtype_name = 'REVISTA' limit 1)
	from legacy.publication, legacy.journal j 
	where pub_id = jrnl_id;

insert into target.paper 
	select pub_title, pub_id, null, conf_start_page, conf_end_page, 
	(select code from target.publication where title = conf_name || (case when conf_ref  != '' then ' (' || conf_ref || ')' else '' end) and publicationtype_name = 'CONGRESO' limit 1)
	from legacy.publication, legacy.conference c2 
	where pub_id = conf_id;

insert into target.authorship
select nextval('keys'), pwrit_ord, r.rese_id, p.pub_id 
from legacy.publication p, legacy.publication_writer pw, legacy.researcher r 
where p.pub_id = pw.pub_id and pw.rese_id = r.rese_id;
