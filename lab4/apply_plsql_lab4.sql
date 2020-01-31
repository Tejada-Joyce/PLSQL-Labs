/*
||  Name:          apply_plsql_lab4.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 5 lab.
*/

-- Call seeding libraries.
--@/home/student/Data/cit325/lib/cleanup_oracle.sql
--@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab4.txt

SET SERVEROUTPUT ON
SET VERIFY OFF

-- Enter your solution here.
-- CREATE OR REPLACE
--     TYPE lyric IS OBJECT
--     ( day_name     VARCHAR2(8)
--     , gift_name    VARCHAR2(24));
-- /

DECLARE
    TYPE days IS TABLE OF VARCHAR2(8);
    lv_days days := days('first','second','third','fourth','fifth','sixth','seventh','eighth','ninth','tenth','eleventh','twelfth');
    TYPE gifts IS TABLE OF lyric;
    lv_gifts gifts := gifts( lyric('and a','Partridge in a pear tree')
                            , lyric('Two','Turtle doves')
                            , lyric('Three','French hens')
                            , lyric('Four','Calling birds')
                            , lyric('Five','Golden rings')
                            , lyric('Six','Geese a laying')
                            , lyric('Seven','Swans a swimming')
                            , lyric('Eight','Maids a milking')
                            , lyric('Nine','Ladies dancing')
                            , lyric('Ten','Lords a leaping')
                            , lyric('Eleven','Pipers piping')
                            , lyric('Twelve','Drummers drumming'));
                            
BEGIN                        
    FOR i IN 1..lv_days.COUNT LOOP
        dbms_output.put_line('On the '||lv_days(i)||' day of Christmas');
        dbms_output.put_line('my true love sent to me:');
        
        FOR j IN REVERSE 1..i LOOP
            IF i = 1 THEN
                dbms_output.put_line('-A Partridge in a pear tree');
            ELSE
                dbms_output.put_line('-'||lv_gifts(j).day_name||' '||lv_gifts(j).gift_name||'');
            END IF;            
        END LOOP;
        dbms_output.put_line(CHR(13));
    END LOOP;
    
END;
/

-- Close log file.
SPOOL OFF
