-- Drop table collection.
DROP TYPE test_tab;
 
-- Drop object type.
DROP TYPE test_obj;

DROP TABLE test;
DROP TABLE test2;

CREATE TABLE test
( id     NUMBER
, text   VARCHAR2(10));

INSERT INTO test VALUES (1,'One');
INSERT INTO test VALUES (2,'Two');
INSERT INTO test VALUES (3,'Three');

CREATE TABLE test2
( id     NUMBER
, text   VARCHAR2(10));


-- Create object type.
CREATE OR REPLACE 
  TYPE test_obj IS OBJECT
  ( id    NUMBER
  , text  VARCHAR2(10));
/
 
-- Create collection of object type.
CREATE OR REPLACE
  TYPE test_tab IS TABLE OF test_obj;
/
 
-- Declare anonymous block to write to and use a collection.
DECLARE
  /* Declare empty collection. */
  lv_test_tab  TEST_TAB := test_tab();
BEGIN
  /* Implement assignment of variables inside a loop, which mimics
     how you would handle them if they were read from a cursor loop. */
  FOR i IN (SELECT * FROM test) LOOP
    lv_test_tab.EXTEND;
    lv_test_tab(lv_test_tab.COUNT) := 
       test_obj( i.id
               , i.text );
  END LOOP;
 
  /* Insert the values from the collection into a table. */
  FOR i IN 1..lv_test_tab.COUNT LOOP
    INSERT INTO test2
    VALUES
    ( lv_test_tab(i).id
    , lv_test_tab(i).text );
  END LOOP;
  /* Make insert permanent. */
  COMMIT;
END;
/

list
show errors
