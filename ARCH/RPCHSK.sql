create table DOC_20120101(
id number, 
amnd_date date, 
HSK_ADD_INFO varchar2(4000)
);

grant all on DOC_20120101 to rpc_data;


create table DOC_20130101(
id number, 
amnd_date date, 
amnd_state varchar2(1),
HSK_ADD_INFO varchar2(4000)
);

grant all on DOC_20130101 to rpc_data;

create table DOC_20130102(
id number, 
amnd_date date, 
amnd_state varchar2(1),
HSK_ADD_INFO varchar2(4000)
);

grant all on DOC_20130102 to rpc_data;

create table DOC_2013010201(
id number, 
amnd_date date, 
amnd_state varchar2(1),
HSK_ADD_INFO varchar2(4000)
);

grant all on DOC_2013010201 to rpc_data;

create table DOC_2013010202(
id number, 
amnd_date date, 
amnd_state varchar2(1),
HSK_ADD_INFO varchar2(4000)
);

grant all on DOC_2013010202 to rpc_data;

create table DOC_20140102(
id number, 
amnd_date date, 
amnd_state varchar2(1),
HSK_ADD_INFO varchar2(4000)
);

grant all on DOC_20140102 to rpc_data;

create sequence seq_DOC;

insert into DOC_20120101
select seq_DOC.nextval - 1000000, trunc(sysdate) - (100* level), 'A'   from dual connect by level <=30;



insert into DOC_20130101
select seq_DOC.nextval, trunc(sysdate) - (100* level), 'A', to_Char(sysdate, 'YYYYMMDD')-10  from dual connect by level <=30;

insert into DOC_20130101
select seq_DOC.nextval, trunc(sysdate) - (100* level), 'A', to_Char(sysdate, 'YYYYMMDD')-9  from dual connect by level <=100;

insert into DOC_20130102
select seq_DOC.nextval, trunc(sysdate) - (100* level), 'A', to_Char(sysdate, 'YYYYMMDD')-9  from dual connect by level <=50;

insert into DOC_2013010201
select seq_DOC.nextval, trunc(sysdate) - (100* level), 'A', to_Char(sysdate, 'YYYYMMDD')-8  from dual connect by level <=50;


insert into DOC_2013010201
select seq_DOC.nextval, trunc(sysdate) - (100* level), 'A', to_Char(sysdate, 'YYYYMMDD')-7  from dual connect by level <=50;

insert into DOC_2013010202
select seq_DOC.nextval, trunc(sysdate) - (100* level), 'A', to_Char(sysdate, 'YYYYMMDD')-6  from dual connect by level <=50;


insert into DOC_20140102
select seq_DOC.nextval, trunc(sysdate) - (100* level), 'A', to_Char(sysdate, 'YYYYMMDD')-5  from dual connect by level <=50;

insert into DOC_20140102
select seq_DOC.nextval, trunc(sysdate) - (100* level), 'A', to_Char(sysdate, 'YYYYMMDD')-4  from dual connect by level <=50;

select * from DOC_20130101;

commit;

select table_name from user_tables
  where regexp_like ( table_name, '^DOC_[0-9]{6,}')
  order by table_name;

