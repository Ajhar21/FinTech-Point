create table BASE2_OUT
(
    SEQ_NUM number GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    RRN_OUT char(12),
    TRx_LOCAL_DATE DATE,        --TRANSACTION_LOCAL_DATE
    CARD_NUMB  VARCHAR2(22 BYTE),     --CARD_NUMBER" VARCHAR2(22 BYTE)
    TCR_90 varchar2(168),
    TCR_0 varchar2(168),
    TCR_1 varchar2(168),
    TCR_5 varchar2(168),
    TCR_7 varchar2(168),
    TCR_91 varchar2(168),
    TCR_92 varchar2(168)

    --CONSTRAINT RRN_out_PK primary key(RRN_OUT)
);

-- drop table BASE2_OUT;
--insert into BASE2_OUT(RRN_OUT,