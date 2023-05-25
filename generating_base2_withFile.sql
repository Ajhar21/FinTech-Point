/* Formatted on 24-May-2023 17:30:20 (QP5 v5.276) */
CREATE OR REPLACE PROCEDURE executing_base2_file
IS
    base2_file_genaration   UTL_FILE.file_type;
BEGIN
    base2_file_genaration := UTL_FILE.fopen ('MY_DIR', 'Base2_file'||to_char(sysdate, 'YYDDD HH24MMSS') || '.txt', 'W');

    DECLARE
        p_autho_activity_row        autho_activity_adm%ROWTYPE;
        v_flag                      NUMBER (1, 0) := 0;
        v_file_tcr_count_flag       NUMBER := 0;
        v_trx_counter_m             NUMBER := 0;
        -- v_file_trans_amount_sum_m number := 0;
        v_file_trans_amount_sum_m   autho_activity_adm.transaction_amount%TYPE
            := 0; --changed type to sustain the precision of the value. - Jahirul
        v_tc_05_91_and_92_string    VARCHAR2 (338);

        CURSOR cur_base_2_genarator
        IS
            SELECT * FROM autho_activity_adm;
    BEGIN
        OPEN cur_base_2_genarator;

        LOOP
            FETCH cur_base_2_genarator   INTO p_autho_activity_row;

            EXIT WHEN cur_base_2_genarator%NOTFOUND;

            DECLARE
                v_header_string        VARCHAR2 (168);
                v_tc_05_tcr_0_string   VARCHAR2 (168);
                v_tc_05_tcr_1_string   VARCHAR2 (168);
                v_tc05_tcr5_string     VARCHAR2 (168);
                v_tc05_tcr7_string     VARCHAR2 (168);
            BEGIN
                IF p_autho_activity_row.action_code = '000'
                THEN
                    -- Start FP_Shakil 20230519
                    v_trx_counter_m := v_trx_counter_m + 1;

                    IF p_autho_activity_row.chip_application_cryptogram
                           IS NOT NULL
                    THEN
                        v_file_tcr_count_flag := v_file_tcr_count_flag + 4;
                    ELSE
                        v_file_tcr_count_flag := v_file_tcr_count_flag + 3;
                    END IF;

                    v_file_trans_amount_sum_m :=
                          (v_file_trans_amount_sum_m)
                        + ( (p_autho_activity_row.transaction_amount));

                    -- END FP_Shakil 20230519
                    IF v_flag = 0
                    THEN
                        v_header_string :=
                            visa_base2_generator2.header_line_print (
                                p_autho_activity_row);
                        --DBMS_OUTPUT.put_line (v_header_string);
                        UTL_FILE.put_line (base2_file_genaration,
                                           v_header_string);
                        v_flag := v_flag + 1;
                    END IF;


                    v_tc_05_tcr_0_string :=
                        visa_base2_generator2.tc_05_tcr_0 (
                            p_autho_activity_row);
                    --DBMS_OUTPUT.put_line (v_tc_05_tcr_0_string);
                    UTL_FILE.put_line (base2_file_genaration,
                                       v_tc_05_tcr_0_string);
                    v_tc_05_tcr_1_string :=
                        visa_base2_generator2.tc05_tcr01 (
                            p_autho_activity_row);
                    --DBMS_OUTPUT.put_line (v_tc_05_tcr_1_string);
                    UTL_FILE.put_line (base2_file_genaration,
                                       v_tc_05_tcr_1_string);
                    v_tc05_tcr5_string :=
                        visa_base2_generator2.tc05_tcr05 (
                            p_autho_activity_row);
                    --DBMS_OUTPUT.put_line (v_tc05_tcr5_string);
                    UTL_FILE.put_line (base2_file_genaration,
                                       v_tc05_tcr5_string);
                    v_tc05_tcr7_string :=
                        visa_base2_generator2.tc05_tcr7 (p_autho_activity_row);

                    IF p_autho_activity_row.chip_application_cryptogram
                           IS NOT NULL
                    THEN
                        --DBMS_OUTPUT.put_line (v_tc05_tcr7_string);
                        UTL_FILE.put_line (base2_file_genaration,
                                           v_tc05_tcr7_string);
                    END IF;
                END IF;
            END;
        END LOOP;

        v_tc_05_91_and_92_string :=
            visa_base2_generator2.visa_b2_trailer_gen (
                p_bin_number                  => '432326',
                p_processing_date             => SYSDATE - 1,
                p_batch_money_trans_counter   => 20,
                p_file_money_trans_counter    => 18,
                p_batch_number                => 6,
                p_file_number                 => 1,
                p_batch_tcr_count             => 60,
                p_file_tcr_count              => v_file_tcr_count_flag,
                p_center_batch_id             => ' ',
                p_batch_trans_counter         => 30,
                p_file_trans_counter          => v_trx_counter_m,
                p_batch_trans_amount_sum      => 400000,
                p_file_trans_amount_sum       => v_file_trans_amount_sum_m);
        --DBMS_OUTPUT.put_line (v_tc_05_91_and_92_string);
        UTL_FILE.put_line (base2_file_genaration, v_tc_05_91_and_92_string);

        CLOSE cur_base_2_genarator;
    END;

    UTL_FILE.fclose (base2_file_genaration);
END;
/




