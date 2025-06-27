create or replace package dynamic_CRUD 
IS
    procedure cre_tab(p_tab_name varchar2 , p_col_spc varchar2);
    
    procedure insert_tab(p_tab_nam varchar2, p_rec varchar2);

    procedure up_tab(
    c_table_name varchar2,
    c_COL_NAME varchar2,
    c_rec_nam varchar2,
    c_cond_col varchar2,
    c_cond_rec varchar2  );

    procedure del_rows_s(p_tab_name varchar2, p_col_name varchar2, p_rec_name varchar2);

end dynamic_CRUD;

create or replace package body dynamic_CRUD
is
    procedure cre_tab(p_tab_name varchar2 , p_col_spc varchar2) is
    begin
        EXECUTE IMMEDIATE 'CREATE TABLE ' || p_tab_name || ' (' || p_col_spc || ')';
    end;
     
    procedure insert_tab(p_tab_nam varchar2, p_rec varchar2)
    is
    begin
        execute immediate 'insert into ' || p_tab_nam || ' values(' || p_rec || ')';
    end;


    procedure up_tab(
        c_table_name varchar2,
        c_COL_NAME varchar2,
        c_rec_nam varchar2,
        c_cond_col varchar2,
        c_cond_rec varchar2  )
    is
    begin
        execute immediate 'update ' || c_table_name || ' set ' || c_COL_NAME || '=' || chr(39) || c_rec_nam 
        ||chr(39) || ' where ' || c_cond_col || '=' || chr(39) || c_cond_rec || chr(39);
    end;

    procedure del_rows_s(p_tab_name varchar2, p_col_name varchar2, p_rec_name varchar2)
    is
        v_row_count number := SQL%ROWCOUNT;
    begin
        execute immediate ' delete from ' || p_tab_name || ' where ' || p_col_name || ' = ' || chr(39) || p_rec_name || chr(39) ;
        dbms_output.PUT_LINE('Row Deleted: ' || v_row_count );
    end;

END dynamic_CRUD;



begin
    dynamic_CRUD.insert_tab( 'Shakil_p', chr(39)|| 'SIDDIK' ||chr(39) || ',' ||1099 || ','|| chr(39) || 'DEAN' || chr(39)  );
end;



select * from Shakil_p;

