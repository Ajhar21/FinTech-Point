/* Formatted on 25-May-2023 16:56:45 (QP5 v5.276) */
DECLARE
    v_table_name   VARCHAR2 (30) := 'SABAB01';
    v_sql          VARCHAR2 (200);
    v_result       SYS_REFCURSOR;
    v_id           NUMBER := 1;
    v_name         VARCHAR2 (50) := 'John Doe';
BEGIN
    -- Create Operation
    v_sql := 'INSERT INTO ' || v_table_name || ' (id, name) VALUES (:1, :2)';

    EXECUTE IMMEDIATE v_sql USING v_id, v_name;

    DBMS_OUTPUT.put_line ('Record created successfully.');

    -- Read Operation
    v_sql := 'SELECT * FROM ' || v_table_name;

    OPEN v_result FOR v_sql;

    DBMS_OUTPUT.put_line ('Read Operation Output:');

    LOOP
        FETCH v_result   INTO v_id, v_name;

        EXIT WHEN v_result%NOTFOUND;
        DBMS_OUTPUT.put_line ('ID: ' || v_id || ', Name: ' || v_name);
    END LOOP;

    CLOSE v_result;

    -- Update Operation
    v_sql := 'UPDATE ' || v_table_name || ' SET name = :1 WHERE id = :2';

    EXECUTE IMMEDIATE v_sql USING 'Jane Smith', v_id;

    DBMS_OUTPUT.put_line ('Record updated successfully.');

    -- Delete Operation
    v_sql := 'DELETE FROM ' || v_table_name || ' WHERE id = :1';

    EXECUTE IMMEDIATE v_sql USING v_id;

    DBMS_OUTPUT.put_line ('Record deleted successfully.');
END;