/*
||  Name:          apply_plsql_lab3.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 4 lab.
*/

-- Call seeding libraries.
--@/home/student/Data/cit325/lib/cleanup_oracle.sql
--@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
--SPOOL apply_plsql_lab3.txt

SET SERVEROUTPUT ON
SET VERIFY OFF

-- Enter your solution here.

DECLARE
    TYPE three_type IS RECORD 
    ( xnum       NUMBER
    , xdate      DATE
    , xstring    VARCHAR2(30));

    lv_three_type three_type;
    
    lv_input1  VARCHAR2(100);
    lv_input2  VARCHAR2(100);
    lv_input3  VARCHAR2(100);

    TYPE list IS TABLE OF VARCHAR2(100);
    
    lv_input list;

BEGIN
    lv_input1 := '&1';
    lv_input2 := '&2';
    lv_input3 := '&3';

    lv_input := list(lv_input1, lv_input2, lv_input3);

    FOR i IN 1..lv_input.COUNT LOOP
        IF REGEXP_LIKE(lv_input(i),'^[[:digit:]]*$') 
            THEN lv_three_type.xnum := lv_input(i);
        ELSIF REGEXP_LIKE(lv_input(i),'^[[:alnum:]]*$') 
            THEN lv_three_type.xstring := lv_input(i);
        ELSIF verify_date(lv_input(i)) IS NOT NULL 
            THEN lv_three_type.xdate := lv_input(i);
        END IF;
    END LOOP;    
    
    dbms_output.put_line('Record ['||lv_three_type.xnum||'] ['||lv_three_type.xstring||'] ['||lv_three_type.xdate||']');

END;
/

-- Close log file.
--SPOOL OFF

QUIT;
