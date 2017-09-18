CREATE OR REPLACE PACKAGE TBX_ARCH_UTILS AS 


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


CREATE OR REPLACE PACKAGE BODY TBX_ARCH_UTILS AS

  function f_get_table_name(
    ac_owner                  in all_tab_columns.owner%type,
    ac_table_name             in all_tab_columns.table_name%type,
    ac_alias                  in all_tab_columns.table_name%type default null,
    ac_db_link_name           in all_tab_columns.owner%type default null
  ) return varchar2
  is
    lc_sql varchar2(4000);  
  begin
    if ac_owner is not null then
      lc_sql :=  ac_owner||'.'; 
    end if;
    lc_sql := lc_sql||ac_table_name;
    if ac_db_link_name is not null then
      lc_sql := lc_sql||'@'||ac_db_link_name;
    end if;
    if ac_alias is not null then
      lc_sql := lc_sql||' '||ac_alias;    
    end if;
    return lc_sql;
  end f_get_table_name; 
  function F_GET_ALL_TAB_COLUMNS( 
    ac_owner                  in all_tab_columns.owner%type,
    ac_table_name             in all_tab_columns.table_name%type,
    ac_db_link_name           in all_tab_columns.owner%type  default null
  ) return tt_all_tab_columns pipelined
  
  is 
    lr_ref_cursor ref_cursor;
    lr_data t_all_tab_columns;
    lc_sql varchar2(4000);
  begin
    lc_sql := 'select owner,table_name,column_name,
      data_type,data_length,data_precision, data_scale, nullable, column_id
    from '||f_get_table_name( NULL, 'all_tab_columns');

    lc_sql := lc_sql||' where owner = :owner and table_name = :table_name';
    open lr_ref_cursor for lc_sql using ac_owner, ac_table_name;
    loop
      fetch lr_ref_cursor into lr_data;
      exit when lr_ref_cursor%NOTFOUND;
      PIPE ROW(lr_data);
    end loop;
    close lr_ref_cursor;
  end F_GET_ALL_TAB_COLUMNS;


  function F_GET_TABLE_MAPPING_SQL(
    ac_orig_owner               in all_tab_columns.owner%type,
    ac_orig_table_name          in all_tab_columns.table_name%type,
    ac_orig_db_link_name        in all_tab_columns.owner%type,
    ac_src_owner               in all_tab_columns.owner%type,
    ac_src_table_name          in all_tab_columns.table_name%type,
    ac_src_alias               in all_tab_columns.table_name%type,
    ac_src_db_link_name        in all_tab_columns.owner%type,
    ac_src_addtional_sql       in varchar2 default null
  ) return varchar2
  
  is 
    cursor lcur_data is
      with dst_columns
      as (
        select * from table( tbx_arch_utils.F_GET_ALL_TAB_COLUMNS( ac_orig_owner, ac_orig_table_name, ac_orig_db_link_name))
      ), src_columns
      as (
        select * from table( tbx_arch_utils.F_GET_ALL_TAB_COLUMNS( ac_src_owner, ac_src_table_name,ac_src_db_link_name))
      ), tj as 
      (
        select 
          dst.table_name dst_table_name, dst.column_name dst_column_name, 
          dst.data_type dst_data_type, dst.data_length dst_data_length, 
          dst.data_precision dst_data_precision, dst.nullable dst_nullable, dst.column_id dst_column_id,
        
          src.table_name src_table_name, src.column_name src_column_name, 
          src.data_type src_data_type, src.data_length src_data_length, 
          src.data_precision src_data_precision, src.nullable src_nullable, src.column_id src_column_id
        
        from dst_columns dst left join src_columns src on ( dst.column_name = src.column_name)
      )
      select * from tj
      order by dst_column_id
    ;

    lc_sql varchar2(32000);
    ln_count  number;
  begin
    ln_count := 0;
    for r in lcur_data loop
      if ln_count = 0 then -- Add standard columns
        lc_sql := 'select ';
        lc_sql := lc_sql||''''||f_get_table_name( ac_src_owner, ac_src_table_name, ac_src_alias, ac_src_db_link_name)||
          ''' as '||gc_col_arch_source_name||', ';
        --- Add value of arch_process_id column only for tables in archive database
        if ac_src_db_link_name is not null then
          lc_sql := lc_sql||nvl(ac_src_alias,ac_src_table_name)||'.'||gc_col_arch_process_id||' ';
        else
          lc_sql := lc_sql||'NULL ';
        end if;
        lc_sql := lc_sql||'as '||gc_col_arch_process_id||', ';
        --- Add value of hsk_add_info column only for tables in archive database OR in archive user
        if ac_src_db_link_name is not null OR ac_src_owner = gc_local_arch_owner  then
          lc_sql := lc_sql||nvl(ac_src_alias,ac_src_table_name)||'.'||gc_col_hsk_add_info||' ';
        else
          lc_sql := lc_sql||'NULL ';
        end if;       
        lc_sql := lc_sql||' as '||gc_col_hsk_add_info;
      end if;
      lc_sql := lc_sql||', ';

      if r.src_table_name is null then
        lc_sql := lc_sql||'NULL '||r.dst_column_name;
      else
        lc_sql := lc_sql||nvl(ac_src_alias,ac_src_table_name)||'.'||r.src_column_name;  
      end if;
      ln_count := ln_count + 1;  
    end loop;
    lc_sql := lc_sql||' from '||f_get_table_name( ac_src_owner, ac_src_table_name, ac_src_alias, ac_src_db_link_name);
    lc_sql := lc_sql||' '||ac_src_addtional_sql;
    p_log( 'I', 'TBX_ARCH_UTILS.F_GET_TABLE_MAPPING_SQL', lc_sql);
    return lc_sql;
  end F_GET_TABLE_MAPPING_SQL;

  function F_GET_ALL_TABLES_MAPPING_SQL(
    ac_orig_owner               in all_tab_columns.owner%type,
    ac_orig_table_name          in all_tab_columns.table_name%type,
    ac_plsql_code               in varchar2,
    ac_src_alias                in all_tab_columns.table_name%type,
    ac_include_original_table   in varchar2,
    ac_include_hsk_tables       in varchar2,
    ac_include_arch_db_table    in varchar2,
    ac_src_addtional_sql        in varchar2 default null 
  ) return varchar2
  is
    lr_par par_arch_tables%rowtype;
    lc_sql varchar2(32000);
    ln_number_of_tables number;
  begin
    ln_number_of_tables := 0;
    select * into lr_par -- load parameterization
      from par_arch_tables where amnd_state = 'A' and table_name = ac_orig_table_name;
    for r in ( 
      
      select owner, table_name, to_char(null) db_link_name 
        from all_tables 
          where owner = gc_local_arch_owner
            and regexp_like ( table_name, lr_par.arch_tables_mask)
            and ac_include_hsk_tables = 'Y'
      union all
        select ac_orig_owner, ac_orig_table_name, to_char(null) db_link_name  
          from dual where ac_include_original_table = 'Y'
      union all
        select gc_remote_arch_owner, ac_orig_table_name, gc_link_name db_link_name
          from dual where ac_include_arch_db_table = 'Y'
      ) loop -- find all tables
      if ln_number_of_tables > 0 then
        lc_sql := lc_sql||chr(10)||'union all'||chr(10);  
      end if;
        lc_sql := lc_sql||'select * from TABLE( '||ac_plsql_code||'( '''||r.owner||
        ''', '''||r.table_name||''', '''||ac_src_alias||''', '''||r.db_link_name||''', '''||replace( ac_src_addtional_sql, '''', '''''')||'''))';
      ln_number_of_tables := ln_number_of_tables + 1;
    end loop;
    return lc_sql;
  end F_GET_ALL_TABLES_MAPPING_SQL;

  procedure p_recreate_local_views
  is
    Cursor lcur_views_to_rebuild 
      is
      select * from par_arch_tables p
        where 
          ( select count(*) from all_tab_columns atc where atc.owner = gc_orig_owner and atc.table_name = p.table_name)
          != 
          ( ( select count(*) from all_tab_columns atc where atc.owner = gc_local_arch_owner and atc.table_name = gc_local_view_prefix||p.table_name) 
          -3 -- View contains 3 special columns
          );
  lc_sql varchar2(32000);        
  begin
    for r in lcur_views_to_rebuild loop
      lc_sql := 'create or replace view '||gc_local_view_prefix||r.table_name||
      ' as select 
          cast (NULL as varchar2(100)) as arch_source_name, 
          cast (NULL as number) as arch_process_id,
          cast (NULL as varchar2(100) ) as hsck_add_info,
        r.* from '||f_get_table_name( gc_orig_owner, r.table_name, 'r', null);
      execute immediate lc_sql;
    end loop;
  end p_recreate_local_views; 
  
    procedure p_log( 
    ac_log_type                 in arch_log.log_type%type,
    ac_log_proc                 in arch_log.log_proc%type,
    ac_log_msg                  in arch_log.log_msg%type
  )
  is
    pragma autonomous_transaction;
    ln_id number;
  begin
    select seq_arch_log.nextval into ln_id
    from dual;

    insert INTO ARCH_LOG (ID,LOG_DATETIME,LOG_TYPE,LOG_PROC,LOG_MSG)
      VALUES ( ln_id, sysdate, ac_log_type, ac_log_proc, substr( ac_log_msg, 1, 4000) );
    commit;
  end p_log;
END TBX_ARCH_UTILS;
/
