--------------------------------------------------------
--  File created - Nede¾a-septembra-17-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package TBX_ARCH_TABLES
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "RPCHSK"."TBX_ARCH_TABLES" AS 

  TYPE tt_DOC IS TABLE OF ARCH_DOC%ROWTYPE;   

  TYPE ref_cursor  IS REF CURSOR ; 
  
  function f_ONE_DOC(
    ac_src_owner               in all_tab_columns.owner%type,
    ac_src_table_name          in all_tab_columns.table_name%type,
    ac_src_alias               in all_tab_columns.table_name%type,
    ac_src_db_link_name        in all_tab_columns.owner%type,
    ac_src_addtional_sql       in varchar2 default null  
  ) return tt_DOC pipelined;

  function f_ALL_DOC(
    ac_src_alias                in all_tab_columns.table_name%type,
    ac_include_original_table   in varchar2,
    ac_include_hsk_tables       in varchar2,
    ac_include_arch_db_table    in varchar2,
    ac_src_addtional_sql        in varchar2 default null 
  ) return tt_DOC pipelined;
  
END TBX_ARCH_TABLES;

/
