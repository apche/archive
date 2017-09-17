begin
  pck_arch.p_process;
end;
/

begin
  tbx_arch_utils.p_recreate_local_views;
end;
/

select count(*) 
  from user_tab_columns where table_name = 'ARCH_DOC';

select * from table( TBX_ARCH_TABLES.F_ALL_DOC( '', 'Y', 'Y', 'Y', ''));

select * from arch_log order by 1 desc;
select * from all_tab_columns where table_name = 'ARCH_DOC';
  
select TBX_ARCH_UTILS.F_GET_ALL_TABLES_MAPPING_SQL('OWS', 'DOC', 'TBX_ARCH_TABLES.f_GET_DOC', 'DAT', 'Y', 'Y', 'where 1=1 OR AMND_DATE = trunc(sysdate, ''YEAR'')')
;
select 'RPCHSK.DOC_20130101 DAT' as arch_source_name, NULL as arch_process_id, DAT.hsk_add_info  as hsk_add_info, DAT.ID, DAT.AMND_DATE, NULL AMND_STAE, NULL SOURCE_CONTRACT, NULL TARGET_CONTRACT from RPCHSK.DOC_20130101 DAT where 1=1 OR AMND_DATE = trunc(sysdate, 'YEAR')

;

select * from ARCH_PROCESS order by id desc;
select * from ARCH_PROCESS_TABLE order by id desc;
select * from ARCH_TABLE_OPERATION order by id desc;

select * from table( TBX_ARCH_TABLES.F_GET_DOC( 'RPCHSK', 'DOC_20120101', 'DAT',NULL, ' WHERE 1=1'));


select tbx_arch_utils.F_GET_TABLE_MAPPING_SQL( 'OWS', 'DOC', NULL, 'RPCHSK', 'DOC_20120101', 'DAT',NULL, ' WHERE 1=0') from dual;

select t.table_name, count(*) XCOUNT, LISTAGG(p.table_name, ';') WITHIN GROUP (ORDER BY p.table_name) ORIG_TABLE_LIST  from all_tables t 
    join PAR_ARCH_TABLES p on ( 1=1  )
  where t.owner = 'RPCHSK' 
    and p.AMND_STATE = 'A'
    and regexp_like ( t.table_name, p.ARCH_TABLES_MASK)
  group by t.table_name
  having count(*) > 1
  ;
  select * from all_tables t where t.owner = 'RPCHSK'   ;
  
  
  select p.id, p.TABLE_NAME ORIG_TABLE_NAME , p.transformation_type, p.priority, t.table_name,
    lead( p.TABLE_NAME, 1, NULL) over ( order by p.priority desc, t.table_name) next_tab
    from all_tables t 
    join PAR_ARCH_TABLES p on ( 1=1  )
  where t.owner = 'RPCHSK' 
    and p.AMND_STATE = 'A'
    and regexp_like ( t.table_name, p.ARCH_TABLES_MASK)
    order by p.priority desc, t.table_name;
    
  with source_columns as
  ( select table_name, column_name, data_type, data_length, data_precision, data_scale, nullable 
    from all_tab_columns where owner = 'RPCHSK' and table_name = 'DOC_20130101'
  ), dest_columns as
  (
   select table_name, column_name, data_type, data_length, data_precision, data_scale, nullable 
    from user_tab_columns@ARCH_DB where  table_name = 'DOC'
  ), joined as
  (
    select 
      sc.table_name sc_table_name ,      sc.column_name sc_column_name ,
      sc.data_type sc_data_type ,      sc.data_length sc_data_length ,
      sc.data_precision sc_data_precision ,      sc.data_scale sc_data_scale ,
      sc.nullable sc_nullable ,
      dc.table_name dc_table_name ,      dc.column_name dc_column_name ,
      dc.data_type dc_data_type ,      dc.data_length dc_data_length ,
      dc.data_precision dc_data_precision ,      dc.data_scale dc_data_scale ,
      dc.nullable dc_nullable
  
    from source_columns sc 
      full join dest_columns dc on ( sc.column_name = dc.column_name)
  )
  select 'NONE' OPERATION, j.* 
    from joined j
  ;
  
  select table_name, column_name, data_type, data_length, data_precision, data_scale, nullable 
    from all_tab_columns where owner = 'RPCHSK' and table_name = 'DOC_20130101';
    
    
select * from par_arch_tables where amnd_state = 'A';
    