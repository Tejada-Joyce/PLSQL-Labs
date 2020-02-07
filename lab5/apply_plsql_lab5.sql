/*
||  Name:          apply_plsql_lab4.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 5 lab.
*/

-- Call seeding libraries.
@/home/student/Data/cit325/lib/cleanup_oracle.sql
@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab5.txt

-- Enter your solution here.
SET SERVEROUTPUT ON
SET VERIFY OFF


--  Create sequence
CREATE SEQUENCE rating_agency_s START WITH 1001;

-- Create rating_agency table
CREATE TABLE rating_agency AS
SELECT rating_agency_s.NEXTVAL AS rating_agency_id
,      il.item_rating AS rating
,      il.item_rating_agency AS rating_agency
FROM  (SELECT DISTINCT
              i.item_rating
       ,      i.item_rating_agency
       FROM   item i) il;
       

--  Verify rating_agency table
SELECT * FROM rating_agency;

-- Add the RATING_AGENCY_ID column to the ITEM table.
ALTER TABLE item
ADD (rating_agency_id  NUMBER);

-- Verify ITEM table
SET NULL ''
COLUMN table_name   FORMAT A18
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'ITEM'
ORDER BY 2;

-- Drop table collection.
DROP TYPE rating_agency_tab;

-- Drop object type.
DROP TYPE rating_agency_obj;

-- A SQL structure or composite object type
CREATE OR REPLACE
  TYPE rating_agency_obj IS  OBJECT
  ( rating_agency_id       NUMBER
  , rating                 VARCHAR2(8)
  , rating_agency          VARCHAR2(4));
/

-- A SQL collection, as a table of the composite object type.
CREATE OR REPLACE
  TYPE rating_agency_tab IS TABLE OF rating_agency_obj;
/

DECLARE
-- Declare a local cursor to read the contents of the RATING_AGENCY table.  
  CURSOR c IS SELECT * FROM rating_agency;

-- Declare empty collection. 
  lv_rating_agency_tab  RATING_AGENCY_TAB := rating_agency_tab();

BEGIN
-- A cursor for loop that reads the cursor contents and assigns them to a local variable of the SQL collection data type.
  FOR i IN c LOOP
    lv_rating_agency_tab.EXTEND;
    lv_rating_agency_tab(lv_rating_agency_tab.COUNT) :=
       rating_agency_obj( rating_agency_id => i.rating_agency_id
                        , rating  => i.rating
                        , rating_agency => i.rating_agency );
    INSERT INTO rating_agency
        ( rating_agency_id
        , rating
        , rating_agency )
        VALUES
        ( i.rating_agency_id
        , i.rating
        , i.rating_agency );
  END LOOP;

--   A range for loop that reads the collection contents and updates the RATING_AGENCY_ID column 
  FOR i IN 1..lv_rating_agency_tab.COUNT LOOP
    UPDATE item SET rating_agency_id = lv_rating_agency_tab(i).rating_agency_id
    WHERE item_rating = lv_rating_agency_tab(i).rating
    AND item_rating_agency = lv_rating_agency_tab(i).rating_agency;
  END LOOP;

END;
/

-- Verify the results
SELECT   rating_agency_id
,        COUNT(*)
FROM     item
WHERE    rating_agency_id IS NOT NULL
GROUP BY rating_agency_id
ORDER BY 1;

-- Close log file.
SPOOL OFF

