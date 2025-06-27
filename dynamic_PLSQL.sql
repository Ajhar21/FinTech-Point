
--CREATE Table
create or replace procedure cre_tab(p_tab_name varchar2 , p_col_spc varchar2) is
begin
    EXECUTE IMMEDIATE 'CREATE TABLE ' || p_tab_name || ' (' || p_col_spc || ')';
end;


begin
    cre_tab( 'Shakil_p', 's_name varchar2(20), s_id number(4), s_dept varchar2(15)');
end;

select 'CREATE TABLE ' || 'Shakil_p' || ' (' || 's_name varchar2(20), s_id number(4), s_dept varchar2(15)' || ');' from dual;

CREATE TABLE Shakil_p (s_name varchar2(20), s_id number(4), s_dept varchar2(15));

select * from Shakil_p;


--DELETE ROWS
create or replace procedure del_rows_s(p_tab_name varchar2, p_col_name varchar2, p_rec_name varchar2)
is
    v_row_count number := SQL%ROWCOUNT;
begin
    execute immediate ' delete from ' || p_tab_name || ' where ' || p_col_name || ' = ' || chr(39) || p_rec_name || chr(39) ;
    dbms_output.PUT_LINE('Row Deleted: ' || v_row_count );
end;
--drop function del_rows_s;
begin
    del_rows_s('Dynamic_SQL','FIRST_NAME', 'rqqmmss' );
end;

--UPDATE TABLE
create or replace procedure up_tab(
    c_table_name varchar2,
    c_COL_NAME varchar2,
    c_rec_nam varchar2,
    c_cond_col varchar2,
    c_cond_rec varchar2  
)
is
begin
    execute immediate 'update ' || c_table_name || ' set ' || c_COL_NAME || '=' || chr(39) || c_rec_nam 
    ||chr(39) || ' where ' || c_cond_col || '=' || chr(39) || c_cond_rec || chr(39);
end;

begin
    up_tab( 'Dynamic_SQL', 'EMAIL', 'ihshakil088@gmail.com', 'LAST_NAME', 'Shakil' );
end;




--INSERT TABLE
















