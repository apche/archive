--------------------------------------------------------
--  File created - Nede¾a-septembra-17-2017   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package TBX_ARCH_UTILS
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "RPCHSK"."TBX_ARCH_UTILS" AS 


  gc_orig_owner               constant all_tables.owner%type := 'OWS';
  gc_local_arch_owner         constant all_tables.owner%type := 'RPCHSK';
  gc_local_view_prefix        constant all_tables.table_name%type := 'ARCH_';
  gc_remote_arch_owner        constant all_tables.owner%type := 'ARCH_OWNER';
  gc_link_name                constant all_tables.owner%type := 'ARCH_DB';
  gc_col_arch_source_name     constant all_tab_columns.column_name%type := 'arch_source_name';
  gc_col_arch_process_id      constant all_tab_columns.column_name%type := 'arch_process_id'; 
  gc_col_hsk_add_info      constant all_tab_columns.column_name%type := 'hsk_add_info'; 
  
  type t_all_tab_columns is record(
    owner                     all_tab_columns.owner%type,
    table_name                all_tab_columns.table_name%type,
    column_name               all_tab_columns.column_name%type,
    data_type                 all_tab_columns.data_type%type,
    data_length               all_tab_columns.data_length%type,
    data_precision            all_tab_columns.data_precision%type,
    
    data_scale                all_tab_columns.data_scale%type,
    nullable                  all_tab_columns.nullable%type,
    column_id                 all_tab_columns.column_id%type
  );
  
  TYPE ref_cursor  IS REF CURSOR;
  TYPE tt_all_tab_columns IS TABLE OF t_all_tab_columns;
  
  
  
  function F_GET_ALL_TAB_COLUMNS( 
    ac_owner                  in all_tab_columns.owner%type,
    ac_table_name             in all_tab_columns.table_name%type,
    ac_db_link_name           in all_tab_columns.owner%type  default null
  ) return tt_all_tab_columns pipelined;
  
  function f_get_table_mapping_sql(
    ac_orig_owner               in all_tab_columns.owner%type,
    ac_orig_table_name          in all_tab_columns.table_name%type,
    ac_orig_db_link_name        in all_tab_columns.owner%type,
    ac_src_owner               in all_tab_columns.owner%type,
    ac_src_table_name          in all_tab_columns.table_name%type,
    ac_src_alias               in all_tab_columns.table_name%type,
    ac_src_db_link_name        in all_tab_columns.owner%type,
    ac_src_addtional_sql       in varchar2 default null
  ) return varchar2;

  function F_GET_ALL_TABLES_MAPPING_SQL(
    ac_orig_owner               in all_tab_columns.owner%type,
    ac_orig_table_name          in all_tab_columns.table_name%type,
    ac_plsql_code               in varchar2,
    ac_src_alias                in all_tab_columns.table_name%type,
    ac_include_original_table   in varchar2,
    ac_include_hsk_tables       in varchar2,
    ac_include_arch_db_table    in varchar2,
    ac_src_addtional_sql        in varchar2 default null 
  ) return varchar2;

  procedure p_log( 
    ac_log_type                 in arch_log.log_type%type,
    ac_log_proc                 in arch_log.log_proc%type,
    ac_log_msg                  in arch_log.log_msg%type
  );

  procedure p_recreate_local_views;
END TBX_ARCH_UTILS;

/
