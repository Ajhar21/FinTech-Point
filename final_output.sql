/* Formatted on 5/19/2023 2:41:55 PM (QP5 v5.276) */
SET SERVEROUTPUT ON;
--changed by ajhar

DECLARE
    autho_activity_row   autho_activity_adm%ROWTYPE;
    flag                 NUMBER (1, 0) := 0;

    CURSOR base_2_genarator
    IS
        SELECT * FROM autho_activity_adm;                  -- WHERE ROWNUM = 1
BEGIN
    OPEN base_2_genarator;

    LOOP
        FETCH base_2_genarator   INTO autho_activity_row;

        EXIT WHEN base_2_genarator%NOTFOUND;

        DECLARE
            header_string        VARCHAR2 (168);
            tc_05_tcr_0_string   VARCHAR2 (168);
            tc_05_tcr_1_string   VARCHAR2 (168);
            tc05_tcr5_l3_dclr    VARCHAR2 (168);
            tc05_tcr07_l3_dclr   VARCHAR2 (168);
        BEGIN
            IF flag = 0
            THEN
                header_string :=
                    visa_base2_generator.header_line_print (
                        autho_activity_row);
                DBMS_OUTPUT.put_line (header_string);
                flag := flag + 1;
            END IF;

            tc_05_tcr_0_string :=
                visa_base2_generator.tc_05_tcr_0_line_1 (autho_activity_row);
            DBMS_OUTPUT.put_line (tc_05_tcr_0_string);
            tc_05_tcr_1_string :=
                visa_base2_generator.tc05_tcr01 (autho_activity_row);
            DBMS_OUTPUT.put_line (tc_05_tcr_1_string);
            tc05_tcr5_l3_dclr :=
                visa_base2_generator.tc05_tcr05_l3_rowtype (
                    autho_activity_row);
            DBMS_OUTPUT.put_line (tc05_tcr5_l3_dclr);
            tc05_tcr07_l3_dclr :=
                visa_base2_generator.tc05_tcr07_l3_rowtype (
                    autho_activity_row);

            IF autho_activity_row.chip_application_cryptogram IS NOT NULL
            THEN
                DBMS_OUTPUT.put_line (tc05_tcr07_l3_dclr);
            END IF;
        END;
    END LOOP;

    visa_base2_generator.visa_b2_trailer_gen (
        bin_number                  => '223344',
        processing_date             => SYSDATE - 1,
        batch_money_trans_counter   => 20,
        file_money_trans_counter    => 18,
        batch_number                => 6,
        file_number                 => 1,
        batch_tcr_count             => 60,
        file_tcr_count              => 7,
        center_batch_id             => '123',
        batch_trans_counter         => 30,
        file_trans_counter          => 3,
        batch_trans_amount_sum      => 400000,
        file_trans_amount_sum       => 30000);

    CLOSE base_2_genarator;
END;


