exec DBMS_SESSION.CLOSE_DATABASE_LINK('ARCH_DB');
drop database link ARCH_DB;

drop sequence SEQ_ARCH_TABLE_OPERATION;
drop sequence SEQ_ARCH_PROCESS_TABLE;
drop sequence SEQ_ARCH_PROCESS;
drop sequence SEQ_PAR_ARCH_TABLES;



drop table ARCH_TABLE_OPERATION;
drop table ARCH_PROCESS_TABLE;
drop table ARCH_PROCESS;
drop table ARCH_LOG;
drop table PAR_ARCH_TABLES;

create table ARCH_LOG(
  ID NUMBER NOT NULL
 , LOG_DATETIME DATE NOT NULL 
 , log_type varchar2(1) not null
 , log_proc varchar2(200) not null
 , log_msg varchar2(4000)
);


create table PAR_ARCH_TABLES(
  ID NUMBER NOT NULL
, TABLE_NAME VARCHAR2(30) NOT NULL
, ARCH_TABLE_NAME VARCHAR2(30) NOT NULL
, AMND_STATE VARCHAR2(1) NOT NULL
, AMND_DATE DATE NOT NULL
, TRANSFORMATION_TYPE VARCHAR2(30) NOT NULL
, PRIORITY NUMBER NOT NULL
, ARCH_TABLES_MASK VARCHAR2(4000) NOT NULL
);

alter table PAR_ARCH_TABLES add constraint PAR_ARCH_TABLES_PK primary key (ID);

comment on column PAR_ARCH_TABLES.ID IS 'Primary key';
comment on column PAR_ARCH_TABLES.TABLE_NAME IS 'Original table name in OWS schema';
comment on column PAR_ARCH_TABLES.ARCH_TABLE_NAME IS 'Table name in Archive database';
comment on column PAR_ARCH_TABLES.AMND_STATE IS 'Status of row A – Active I – Inactive';
comment on column PAR_ARCH_TABLES.AMND_DATE IS 'Valid from date';
comment on column PAR_ARCH_TABLES.TRANSFORMATION_TYPE IS 'Transformation trype : STANDARD, XXXXX...';
comment on column PAR_ARCH_TABLES.PRIORITY IS 'Priority destecending order';
comment on column PAR_ARCH_TABLES.ARCH_TABLES_MASK IS 'Regexp mask for archive tables';


create table ARCH_PROCESS(
  ID NUMBER NOT NULL
, PROCESS_LOG__OID NUMBER NOT NULL 
, STATUS VARCHAR2(30) NOT NULL
, START_DATETIME DATE NOT NULL
, END_DATETIME DATE
, PROCESSED_TABLES NUMBER
, PROCESSED_ROWS NUMBER
, PROCESS_PARAMETERS VARCHAR2(4000)
, ERROR_MSG VARCHAR2(4000)
);

alter table ARCH_PROCESS add constraint ARCH_PROCESS_PK primary key (ID);

comment on column ARCH_PROCESS.ID IS 'Primary key';
comment on column ARCH_PROCESS.PROCESS_LOG__OID IS 'Refference to W4 process';
comment on column ARCH_PROCESS.STATUS IS 'Status of process : STARTED, FINISHED, ERROR';
comment on column ARCH_PROCESS.START_DATETIME IS 'Starting date time';
comment on column ARCH_PROCESS.END_DATETIME IS 'End date time';
comment on column ARCH_PROCESS.PROCESSED_TABLES IS 'Number of processed tables';
comment on column ARCH_PROCESS.PROCESSED_ROWS IS 'Number of processed rows';
comment on column ARCH_PROCESS.PROCESS_PARAMETERS IS 'Process parameters';
comment on column ARCH_PROCESS.ERROR_MSG IS 'Process error';

create table ARCH_PROCESS_TABLE
(
    ID NUMBER NOT NULL
  , ARCH_PROCESS__OID NUMBER NOT NULL
  , PAR_ARCH_TABLES__OID NUMBER NOT NULL
  , STATUS VARCHAR2(30) NOT NULL
  , SOURCE_TABLE_NAME VARCHAR2(30) 
  , START_DATETIME DATE NOT NULL
  , END_DATETIME DATE
  , PROCESSED_ROWS NUMBER
  , ERROR_MSG VARCHAR2(4000)
);

alter table ARCH_PROCESS_TABLE add constraint ARCH_PROCESS_TABLE_PK primary key (ID);

alter table ARCH_PROCESS_TABLE add constraint ARCH_PROCESS_TABLE_FK1 foreign key (ARCH_PROCESS__OID) references ARCH_PROCESS;
alter table ARCH_PROCESS_TABLE add constraint ARCH_PROCESS_TABLE_FK2 foreign key (PAR_ARCH_TABLES__OID) references PAR_ARCH_TABLES;

comment on column ARCH_PROCESS_TABLE.ID IS 'Primary key';
comment on column ARCH_PROCESS_TABLE.ARCH_PROCESS__OID IS 'Refference to process';
comment on column ARCH_PROCESS_TABLE.PAR_ARCH_TABLES__OID IS 'Refference to table';
comment on column ARCH_PROCESS_TABLE.STATUS IS 'Status of process : STARTED, DDL FINISHED, FINISHED, ERROR';
comment on column ARCH_PROCESS_TABLE.SOURCE_TABLE_NAME IS 'Source table name';
comment on column ARCH_PROCESS_TABLE.START_DATETIME IS 'Starting date time';
comment on column ARCH_PROCESS_TABLE.END_DATETIME IS 'End date time';
comment on column ARCH_PROCESS_TABLE.PROCESSED_ROWS IS 'Number of processed rows';
comment on column ARCH_PROCESS_TABLE.ERROR_MSG IS 'Process error';

create table ARCH_TABLE_OPERATION
(
    ID NUMBER NOT NULL
  , ARCH_PROCESS_TABLE__OID NUMBER NOT NULL
  , OPERATION_TYPE VARCHAR2(30) NOT NULL
  , STATUS VARCHAR2(30) NOT NULL
  , START_DATETIME DATE NOT NULL
  , END_DATETIME DATE
  , PROCESSED_ROWS NUMBER
  , PERIOD_CODE VARCHAR2(30)
  , ADD_INFO VARCHAR2(4000)
  , ERROR_MSG VARCHAR2(4000)

);

alter table ARCH_TABLE_OPERATION add constraint ARCH_TABLE_OPERATION_PK primary key (ID);

alter table ARCH_TABLE_OPERATION add constraint ARCH_TABLE_OPERATION_FK1 foreign key (ARCH_PROCESS_TABLE__OID) references ARCH_PROCESS_TABLE;


comment on column ARCH_TABLE_OPERATION.ID IS 'Primary key';
comment on column ARCH_TABLE_OPERATION.ARCH_PROCESS_TABLE__OID IS 'Refference to process table';
comment on column ARCH_TABLE_OPERATION.OPERATION_TYPE IS 'Operation type DDL, ADD PARTITION, INSERT, DELETE, DROP';
comment on column ARCH_TABLE_OPERATION.STATUS IS 'Status of process : STARTED, SKIPPED, FINISHED, FINISHED, ERROR';
comment on column ARCH_TABLE_OPERATION.START_DATETIME IS 'Starting date time';
comment on column ARCH_TABLE_OPERATION.END_DATETIME IS 'End date time';
comment on column ARCH_TABLE_OPERATION.PROCESSED_ROWS IS 'Number of processed rows';
comment on column ARCH_TABLE_OPERATION.PERIOD_CODE IS 'Period code';
comment on column ARCH_TABLE_OPERATION.ADD_INFO IS 'Additional info for DDL there is a command, for other date or other informations';
comment on column ARCH_TABLE_OPERATION.ERROR_MSG IS 'Process error';


------------------- SEQUENCIES ---------------

create sequence SEQ_ARCH_TABLE_OPERATION;
create sequence SEQ_ARCH_PROCESS_TABLE;
create sequence SEQ_ARCH_PROCESS;
create sequence SEQ_PAR_ARCH_TABLES;
create sequence SEQ_ARCH_LOG;


--------- DB LINIK -------------------

create database link ARCH_DB connect to ARCH_OWNER identified by ARCH_OWNER using 'XE';

------- PARAM --------------------------


insert into PAR_ARCH_TABLES
select SEQ_PAR_ARCH_TABLES.nextval, 'DOC','DOC', 'A', trunc(sysdate), 'STANDARD', 100, '^DOC_[0-9]{6,}' from dual;

drop table DOC;
create or replace view  ARCH_DOC
as
select cast (NULL as varchar2(100)) as arch_source_name, 
cast (NULL as number) as arch_process_id,
cast (NULL as varchar2(100) ) as hsck_add_info,
r.* from ows.doc r
;

commit;