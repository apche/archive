CREATE OR REPLACE PACKAGE TBX_ARCH_TABLES AS 

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


CREATE OR REPLACE PACKAGE BODY TBX_ARCH_TABLES AS

  
   
  
  function f_ONE_DOC(
    ac_src_owner               in all_tab_columns.owner%type,
    ac_src_table_name          in all_tab_columns.table_name%type,
    ac_src_alias               in all_tab_columns.table_name%type,
    ac_src_db_link_name        in all_tab_columns.owner%type,
    ac_src_addtional_sql       in varchar2 default null  
  ) return tt_DOC pipelined
  is
    lr_ref_cursor ref_cursor ; 
    lr_data ARCH_DOC%ROWTYPE; 
    lc_sql varchar2(32000);
  begin
    lc_sql := TBX_ARCH_UTILS.F_GET_TABLE_MAPPING_SQL( 
      TBX_ARCH_UTILS.gc_orig_owner, 'DOC', NULL, ac_src_owner, 
      ac_src_table_name, ac_src_alias, ac_src_db_link_name, ac_src_addtional_sql);
    begin  
      open lr_ref_cursor for lc_sql;
    exception 
      when others then
         raise_application_error (-20001,sqlerrm||'Error in SQL : '||lc_sql);

    end;
    loop
      fetch lr_ref_cursor into lr_data;
      exit when lr_ref_cursor%NOTFOUND;
      PIPE ROW(lr_data);
    end loop;
    close lr_ref_cursor;
  end f_ONE_DOC;

  function f_ALL_DOC(
    ac_src_alias                in all_tab_columns.table_name%type,
    ac_include_original_table   in varchar2,
    ac_include_hsk_tables       in varchar2,
    ac_include_arch_db_table    in varchar2,
    ac_src_addtional_sql        in varchar2 default null 
  ) return tt_DOC pipelined
  is
    lr_ref_cursor ref_cursor;
    lr_data ARCH_DOC%ROWTYPE;
    lc_sql varchar2(32000);
  begin
    if ac_include_original_table = 'N' and ac_include_hsk_tables = 'N' and ac_include_arch_db_table = 'N' then 
      return;
    end if;
    lc_sql := TBX_ARCH_UTILS.F_GET_ALL_TABLES_MAPPING_SQL('OWS', 'DOC', 
      'TBX_ARCH_TABLES.f_ONE_DOC', ac_src_alias, ac_include_original_table, 
      ac_include_hsk_tables, ac_include_arch_db_table, ac_src_addtional_sql);
    begin  
      open lr_ref_cursor for lc_sql;
    exception 
      when others then
         raise_application_error (-20001,sqlerrm||'Error in SQL : '||lc_sql);

    end;
    loop
      fetch lr_ref_cursor into lr_data;
      exit when lr_ref_cursor%NOTFOUND;
      PIPE ROW(lr_data);
    end loop;
    close lr_ref_cursor;      
  end f_ALL_DOC; 
END TBX_ARCH_TABLES;
/
