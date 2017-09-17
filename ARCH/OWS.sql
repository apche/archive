----drop table doc;
--create table doc( id number, amnd_date date, amnd_stae varchar2(1));
grant select on doc to rpchsk; 
revoke select on doc from rpc_data;

--alter table doc add ( source_contract varchar2(4000));

--alter table doc add ( target_contract varchar2(4000));