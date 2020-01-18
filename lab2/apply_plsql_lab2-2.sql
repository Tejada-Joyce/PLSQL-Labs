/*
||  Name:          apply_plsql_lab2-2.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 3 lab.
*/

-- Call seeding libraries.
--@/home/student/Data/cit325/lib/cleanup_oracle.sql
--@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
--SPOOL apply_plsql_lab2-2.txt

SET SERVEROUTPUT ON
SET VERIFY OFF

-- Enter your solution here.
DECLARE
    lv_input        VARCHAR2(10);
    lv_raw_input    VARCHAR2(20);
BEGIN
    lv_raw_input := NVL('&1', NULL);
    
    IF LENGTH(lv_raw_input) <= 10 THEN
        dbms_output.put_line('Hello '||lv_raw_input||'!');
    ELSIF LENGTH(lv_raw_input) > 10 THEN
        lv_input := SUBSTR(lv_raw_input, 1, 10);
        dbms_output.put_line('Hello '||lv_input||'!');
    ELSE
        dbms_output.put_line('Hello World!');
    END IF;
END;
/


-- Close log file.
--SPOOL OFF

QUIT;
