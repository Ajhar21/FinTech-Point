/* Formatted on 22-May-2023 20:31:48 (QP5 v5.276) */
-- SET SERVEROUTPUT ON;

/*START FP_TEAM 20230519 */
CREATE OR REPLACE PACKAGE visa_base2_generator
IS
    PROCEDURE generating_base2;

    FUNCTION header_line_print (
        p_autho_activity_row    autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2;

    FUNCTION tc_05_tcr_0 (p_autho_activity_row autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2;

    FUNCTION tc05_tcr01 (rowtype_variable2 autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2;

    FUNCTION tc05_tcr05 (rowtype_variable autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2;

    FUNCTION tc05_tcr7 (rowtype_variable autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2;

    -- changed the prcedure into function, Jahirul, 22-05-2023
    FUNCTION visa_b2_trailer_gen (
        p_bin_number                   VARCHAR2,
        p_processing_date              DATE,
        p_batch_money_trans_counter    NUMERIC,
        p_file_money_trans_counter     NUMERIC,
        p_batch_number                 NUMERIC,
        p_file_number                  NUMERIC,
        --trx_counter                  NUMERIC,
        p_batch_tcr_count              NUMERIC,
        p_file_tcr_count               NUMERIC,
        p_center_batch_id              VARCHAR2,
        p_batch_trans_counter          NUMERIC,
        p_file_trans_counter           NUMERIC,
        p_batch_trans_amount_sum       autho_activity_adm.transaction_amount%TYPE,
        p_file_trans_amount_sum        autho_activity_adm.transaction_amount%TYPE)
        RETURN VARCHAR2;
END visa_base2_generator;
/*END FP_TEAM 20230519 */

/*START FP_TEAM 20230519 */

CREATE OR REPLACE PACKAGE BODY visa_base2_generator
IS
    PROCEDURE generating_base2
    IS
    BEGIN
        DECLARE
            autho_activity_row        autho_activity_adm%ROWTYPE;
            flag                      NUMBER (1, 0) := 0;
            file_tcr_count_flag       NUMBER := 0;
            trx_counter_m             NUMBER := 0;
            -- file_trans_amount_sum_m number := 0;
            file_trans_amount_sum_m   autho_activity_adm.transaction_amount%TYPE
                := 0; --changed type to sustain the precision of the value. - Jahirul
            tc_05_91_and_92_string    VARCHAR2 (338);

            CURSOR base_2_genarator
            IS
                SELECT * FROM autho_activity_adm;
        BEGIN
            OPEN base_2_genarator;

            LOOP
                FETCH base_2_genarator   INTO autho_activity_row;

                EXIT WHEN base_2_genarator%NOTFOUND;

                DECLARE
                    header_string        VARCHAR2 (168);
                    tc_05_tcr_0_string   VARCHAR2 (168);
                    tc_05_tcr_1_string   VARCHAR2 (168);
                    tc05_tcr5_string     VARCHAR2 (168);
                    tc05_tcr7_string     VARCHAR2 (168);
                BEGIN
                    IF autho_activity_row.action_code = '000'
                    THEN
                        -- Start FP_Shakil 20230519
                        trx_counter_m := trx_counter_m + 1;

                        IF autho_activity_row.chip_application_cryptogram
                               IS NOT NULL
                        THEN
                            file_tcr_count_flag := file_tcr_count_flag + 4;
                        ELSE
                            file_tcr_count_flag := file_tcr_count_flag + 3;
                        END IF;

                        file_trans_amount_sum_m :=
                              (file_trans_amount_sum_m)
                            + ( (autho_activity_row.transaction_amount));

                        -- END FP_Shakil 20230519
                        IF flag = 0
                        THEN
                            header_string :=
                                visa_base2_generator.header_line_print (
                                    autho_activity_row);
                            DBMS_OUTPUT.put_line (header_string);
                            flag := flag + 1;
                        END IF;


                        tc_05_tcr_0_string :=
                            visa_base2_generator.tc_05_tcr_0 (
                                autho_activity_row);
                        DBMS_OUTPUT.put_line (tc_05_tcr_0_string);
                        tc_05_tcr_1_string :=
                            visa_base2_generator.tc05_tcr01 (
                                autho_activity_row);
                        DBMS_OUTPUT.put_line (tc_05_tcr_1_string);
                        tc05_tcr5_string :=
                            visa_base2_generator.tc05_tcr05 (
                                autho_activity_row);
                        DBMS_OUTPUT.put_line (tc05_tcr5_string);
                        tc05_tcr7_string :=
                            visa_base2_generator.tc05_tcr7 (
                                autho_activity_row);

                        IF autho_activity_row.chip_application_cryptogram
                               IS NOT NULL
                        THEN
                            DBMS_OUTPUT.put_line (tc05_tcr7_string);
                        END IF;
                    END IF;
                END;
            END LOOP;

            tc_05_91_and_92_string :=
                visa_base2_generator.visa_b2_trailer_gen (
                    p_bin_number                  => '432326',
                    p_processing_date             => SYSDATE - 1,
                    p_batch_money_trans_counter   => 20,
                    p_file_money_trans_counter    => 18,
                    p_batch_number                => 6,
                    p_file_number                 => 1,
                    p_batch_tcr_count             => 60,
                    p_file_tcr_count              => file_tcr_count_flag,
                    p_center_batch_id             => ' ',
                    p_batch_trans_counter         => 30,
                    p_file_trans_counter          => trx_counter_m,
                    p_batch_trans_amount_sum      => 400000,
                    p_file_trans_amount_sum       => file_trans_amount_sum_m);
            DBMS_OUTPUT.put_line (tc_05_91_and_92_string);

            CLOSE base_2_genarator;
        END;
    END generating_base2;

    /*START FP_AJHAR 20230519 */
    FUNCTION header_line_print (
        p_autho_activity_row    autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2
    IS
        reserved_4      VARCHAR2 (89);
        header_string   VARCHAR2 (168);
    BEGIN
        reserved_4 := LPAD (reserved_4, 89, ' ');
        header_string :=
               '90'
            || '432326'
            || TO_CHAR (SYSDATE - 1, 'YYDDD')                --processing_date
            || '      2304000400'
            || 'TEST'
            || ' 0000      000000000000000000'
            || 'INMACR  '
            || '      '
            || '001'
            || reserved_4;
        RETURN header_string;
    END header_line_print;

    /*END FP_AJHAR 20230519 */

    /*START FP_AJHAR 20230519 */
    FUNCTION tc_05_tcr_0 (p_autho_activity_row autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2
    IS
        acq_ref_num          VARCHAR2 (23);

        tc_05_tcr_0_string   VARCHAR2 (168);
    BEGIN
        acq_ref_num :=
               LPAD (p_autho_activity_row.reference_number, 12, ' ')
            || SUBSTR (p_autho_activity_row.external_stan, 1, 6)
            || TO_CHAR (p_autho_activity_row.transaction_local_date, 'YYDDD');



        tc_05_tcr_0_string :=
               '05'                                         --Transaction_Code
            || '0'                                --Transaction_Code_Qualifier
            || '0'                     --Transaction_Component_Sequence_Number
            || RPAD (p_autho_activity_row.card_number, 19, '0') --card_number+account_num_extension
            || 'Z'                                     --Floor_Limit_Indicator
            || ' '                              --CRB/Exception_File_Indicator
            || 'N' --Positive_Cardholder_Authorization_Service_(PCAS)_Indicator
            || LPAD (acq_ref_num, 23, ' ')         --Acquirer_Reference_Number
            || '00000000'                             --Acquirer�s_Business_ID
            || TO_CHAR (p_autho_activity_row.transaction_local_date, 'MMDD') --Purchase_Date_(MMDD)
            || LPAD (p_autho_activity_row.billing_amount * 100, 12, '0') --Destination_Amount
            || LPAD (p_autho_activity_row.billing_currency, 3, ' ') --Destination_Currency_Code
            || LPAD (p_autho_activity_row.transaction_amount * 100, 12, '0') --Source_Amount
            || LPAD (p_autho_activity_row.transaction_currency, 3) --Source_Currency_Code
            || RPAD (
                   SUBSTR (
                       p_autho_activity_row.card_acc_name_address,
                       1,
                         INSTR (p_autho_activity_row.card_acc_name_address,
                                '\')
                       - 1),
                   25,
                   ' ')                                        --Merchant_Name
            || RPAD (
                   REPLACE (
                       SUBSTR (
                           p_autho_activity_row.card_acc_name_address,
                             INSTR (
                                 p_autho_activity_row.card_acc_name_address,
                                 '\',
                                 2)
                           + 1,
                             INSTR (
                                 p_autho_activity_row.card_acc_name_address,
                                 '\',
                                 2,
                                 3)
                           - 2),
                       '\',
                       ' '),
                   13,
                   ' ')                                        --Merchant_City
            || RPAD (
                   TRIM (
                       SUBSTR (p_autho_activity_row.card_acc_name_address,
                               -3)),
                   3,
                   ' ')                                --Merchant_Country_Code
            || LPAD (p_autho_activity_row.card_acceptor_activity, 4, ' ') --Merchant_Category_Code
            || '00000'                                     --Merchant_ZIP_Code
            || '   '                            --Merchant_State/Province_Code
            || ' '                                 --Requested_Payment_Service
            || ' '                                                  --Reserved
            || '1'                                                --Usage_Code
            || LPAD (NVL (p_autho_activity_row.reason_code, '00'), 2, ' ') --reason_code
            || '8'                                           --Settlement_Flag
            || 'N'                   --Authorization_Characteristics_Indicator
            || LPAD (p_autho_activity_row.authorization_code, 6, ' ')
            || SUBSTR (p_autho_activity_row.pos_data, 1, 1) --POS_Terminal_Capability
            || ' '                               --International_Fee_Indicator
            || '1'                                      --Cardholder_ID_Method
            || ' '                                      --Collection-Only_Flag
            || LPAD (SUBSTR (p_autho_activity_row.pos_entry_mode, 1, 2),
                     2,
                     ' ')
            || TO_CHAR (p_autho_activity_row.business_date, 'YDDD')
            || '0';

        RETURN tc_05_tcr_0_string;
    END tc_05_tcr_0;

    /*END FP_AJHAR 20230519 */

    /*START FP_ANOY 20230519 */
    FUNCTION tc05_tcr01 (rowtype_variable2 autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2
    IS
        tc05_tcr01_print   VARCHAR2 (168);
    BEGIN
        tc05_tcr01_print :=
            (   '05'
             || '0'
             || '1'
             || '      '
             || '      '
             || '000000'
             || ' '
             || '                                                  '
             || '  '
             || '   '
             || ' '
             || ' '
             || RPAD (rowtype_variable2.card_acceptor_id, 15, ' ')
             || LPAD (rowtype_variable2.private_data_1, 8, ' ')
             || '000000000000'
             || ' '
             || ' '
             || RPAD (TO_CHAR (rowtype_variable2.business_date, 'YDDD'),
                      6,
                      '0')             --CENTRAL PROCESSING DATE/BUSINESS_DATE
             || ' '
             || ' '
             || '0'
             || ' '
             || ' '
             || ' '
             || '0'
             || '  '
             || '                         '
             || '000000000'
             || ' '
             || ' ');
        RETURN tc05_tcr01_print;
    END tc05_tcr01;

    /*END FP_ANOY 20230519 */

    /*START FP_SHAKIL 20230519 */
    FUNCTION tc05_tcr05 (rowtype_variable autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2
    IS
        tc05_tcr05_l3_print   VARCHAR2 (168);
        eci_07                VARCHAR2 (2);
    /*ACTION_CODE=000 approved , else declined; /// processing code=90 e_com Transaction*/
    BEGIN
        IF     rowtype_variable.action_code = '000'
           AND rowtype_variable.processing_code = '90'
        THEN
            eci_07 := '07';         --Transaction approved & E_COM Transaction
        ELSE
            eci_07 := '  ';
        END IF;

        tc05_tcr05_l3_print :=
            (   '0505'
             || '586213531861029'
             || LPAD (TRUNC (100 * (rowtype_variable.transaction_amount)),
                      12,
                      '0')
             || LPAD (rowtype_variable.transaction_currency, 3, ' ')
             || '          0000 '
             || '000000000000'
             || 'N'
             || '                 '
             || LPAD (eci_07, 2, ' ')
             || '          '
             || '000000000000000'
             || ' '
             || '00000000'
             || '00000000'
             || '000000000000'
             || 'N       '
             || '      0000000000000000  '
             || ' ');
        RETURN tc05_tcr05_l3_print;
    END tc05_tcr05;

    /*END FP_SHAKIL 20230519 */

    /*START FP_SHAKIL 20230519 */
    FUNCTION tc05_tcr7 (rowtype_variable autho_activity_adm%ROWTYPE)
        RETURN VARCHAR2
    IS
        tc05_tcr07_l3_print   VARCHAR2 (168);
    BEGIN
        tc05_tcr07_l3_print :=
            (   '05'
             || '07'
             || LPAD (NVL (rowtype_variable.processing_code, '0'), 2, '0')
             || LPAD (NVL (rowtype_variable.card_sequence_number, '0'),
                      3,
                      '0')
             || LPAD (NVL (rowtype_variable.chip_transaction_date, '0'),
                      6,
                      '0')
             || LPAD (NVL (rowtype_variable.chip_terminal_capability, '0'),
                      6,
                      '0')
             || LPAD (
                    NVL (
                        TRIM (
                            LEADING '0' FROM rowtype_variable.chip_terminal_country_code),
                        '0'),
                    3,
                    '0')
             || '        '
             || LPAD (NVL (rowtype_variable.chip_unpredictable_number, '0'),
                      8,
                      '0')
             || '0005'
             || '7C00'
             || LPAD (
                    NVL (rowtype_variable.chip_application_cryptogram, '0'),
                    16,
                    '0')
             || '01'
             || '0A'
             || '0000248000'
             || '03606002'
             || '000000050000'
             || '  '
             || '                '
             || '06'
             || '  '
             || '                              '
             || '        '
             || '          ');
        RETURN tc05_tcr07_l3_print;
    END tc05_tcr7;                                 /*END FP_SHAKIL 20230519 */

    /*START FP_JAHIR 20230519 - 2205203: changed into function*/

    FUNCTION visa_b2_trailer_gen (
        p_bin_number                   VARCHAR2,
        p_processing_date              DATE,
        p_batch_money_trans_counter    NUMERIC,
        p_file_money_trans_counter     NUMERIC,
        p_batch_number                 NUMERIC,
        p_file_number                  NUMERIC,
        --trx_counter                  NUMERIC,
        p_batch_tcr_count              NUMERIC,
        p_file_tcr_count               NUMERIC,
        p_center_batch_id              VARCHAR2,
        p_batch_trans_counter          NUMERIC,
        p_file_trans_counter           NUMERIC,
        p_batch_trans_amount_sum       autho_activity_adm.transaction_amount%TYPE,
        p_file_trans_amount_sum        autho_activity_adm.transaction_amount%TYPE)
        RETURN VARCHAR2
    IS
        v_tcr91_trans_code              VARCHAR2 (2) := '91';
        v_tcr92_trans_code              VARCHAR2 (2) := '92';
        v_trans_code_qualifier          VARCHAR2 (1) := '0';
        v_trans_comp_seq_number         VARCHAR2 (1) := '0';
        v_bin_number                  VARCHAR2 (6) := LPAD (p_bin_number, 6);
        v_processing_date             VARCHAR2 (5)
            := LPAD (TO_CHAR (p_processing_date, 'YYDDD'), 5);
        v_tcr91_data                    VARCHAR2 (168);
        v_tcr92_data                    VARCHAR2 (168);
        v_dest_amount                   VARCHAR2 (15) := LPAD (0, 15, '0');
        v_batch_money_trans_counter   VARCHAR2 (12)
            := LPAD (TO_CHAR (NVL (p_batch_money_trans_counter, 0)), 12, '0');
        v_file_money_trans_counter    VARCHAR2 (12)
            := LPAD (TO_CHAR (NVL (p_file_money_trans_counter, 0)), 12, '0');
        v_batch_number                VARCHAR2 (6)
            := LPAD (TO_CHAR (p_batch_number), 6, '0');
        v_file_number                 VARCHAR2 (6)
            := LPAD (TO_CHAR (p_file_number), 6, '0');
        v_batch_tcr_counter           VARCHAR2 (12)
            := LPAD (TO_CHAR (p_batch_tcr_count), 12, '0');
        v_file_tcr_counter            VARCHAR2 (12)
            := LPAD (TO_CHAR (p_file_tcr_count), 12, '0');
        v_reserved_se1                  VARCHAR2 (6) := '      ';
        v_center_batch_id             VARCHAR2 (8) := '        ';
        v_batch_trans_counter         VARCHAR2 (9)
            := LPAD (NVL (p_batch_trans_counter, 0), 9, 0);
        v_file_trans_counter          VARCHAR2 (9)
            := LPAD (NVL (p_file_trans_counter, 0), 9, 0);
        v_reserved_se2                  VARCHAR2 (18) := '                  ';
        v_batch_trans_amount_sum      VARCHAR2 (15)
            := LPAD (NVL (p_batch_trans_amount_sum * 100, 0), 15, 0);
        v_file_trans_amount_sum       VARCHAR2 (15)
            := LPAD (NVL (p_file_trans_amount_sum * 100, 0), 15, 0);
        v_reserved_se3                  VARCHAR2 (15) := '               ';
       v_reserved_se4                  VARCHAR2 (15) := '               ';
        v_reserved_se5                  VARCHAR2 (15) := '               ';
        v_reserved_se6                  VARCHAR2 (7) := '       ';
    BEGIN
        v_tcr91_data :=
               v_tcr91_trans_code
            || v_trans_code_qualifier
            || v_trans_comp_seq_number
            || v_bin_number
            || v_processing_date                                          -- V
            || v_dest_amount                                                -- V
            || v_batch_money_trans_counter                                -- V
            || v_batch_number
            || v_batch_tcr_counter
            || v_reserved_se1
            || v_center_batch_id
            || v_batch_trans_counter
            || v_reserved_se2
            || v_batch_trans_amount_sum
            || v_reserved_se3
            || v_reserved_se4
            || v_reserved_se5
            || v_reserved_se6;

        v_tcr92_data :=
               v_tcr92_trans_code
            || v_trans_code_qualifier
            || v_trans_comp_seq_number
            || v_bin_number
            || v_processing_date
            || v_dest_amount
            || v_file_money_trans_counter
            || v_file_number
            || v_file_tcr_counter
            || v_reserved_se1
            || v_center_batch_id
            || v_file_trans_counter
            || v_reserved_se2
            || v_file_trans_amount_sum
            || v_reserved_se3
            || v_reserved_se4
            || v_reserved_se5
            || v_reserved_se6;

        RETURN v_tcr91_data || CHR (10) || v_tcr92_data;
    END visa_b2_trailer_gen;
/*END FP_JAHIR 20230519 */
END visa_base2_generator;

/*END FP_TEAM 20230519 */