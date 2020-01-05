/*
||  Name:          trigger_example.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 10 lab.
*/

/* Set the pagesize. */
SET NULL ''
SET PAGESIZE 99

/* Open log file. */
SPOOL trigger_example.txt

/* Conditionally drop tables. */
SELECT 'Conditional drop ...' AS "Step #1" FROM dual;
BEGIN
  FOR i IN (SELECT uo.object_name
            ,      uo.object_type
            FROM   user_objects uo
            WHERE  uo.object_name IN ('AVENGER','AVENGER_S','LOGGING','LOGGING_S')) LOOP
    EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/

/* Create avenger table. */
SELECT 'Create avenger table and sequence ...' AS "Step #1" FROM dual;
CREATE TABLE avenger
( avenger_id    NUMBER
, avenger_name  VARCHAR2(30));

/* Create avenger_s sequence. */
CREATE SEQUENCE avenger_s;

/* Create logger table. */
SELECT 'Create logging table and sequence ...' AS "Step #2" FROM dual;
CREATE TABLE logging
( logging_id  NUMBER
, old_avenger_id    NUMBER
, old_avenger_name  VARCHAR2(30)
, new_avenger_id    NUMBER
, new_avenger_name  VARCHAR2(30)
, CONSTRAINT logging_pk PRIMARY KEY (logging_id));

/* Create logger_s sequence. */
CREATE SEQUENCE logging_s;

/* Verify item table structure. */
COLUMN table_name   FORMAT A14
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
WHERE    table_name = 'LOGGING'
ORDER BY 2;

/* Verify item table structure. */
COLUMN table_name   FORMAT A14
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
WHERE    table_name = 'AVENGER'
ORDER BY 2;

/* Create package. */
SELECT 'Create log_avenger package ...' AS "Step #3" FROM dual;
CREATE OR REPLACE
  PACKAGE log_avenger IS

  PROCEDURE avenger_insert
  ( pv_new_avenger_id    NUMBER
  , pv_new_avenger_name  VARCHAR2 );

  PROCEDURE avenger_insert
  ( pv_new_avenger_id    NUMBER
  , pv_new_avenger_name  VARCHAR2
  , pv_old_avenger_id    NUMBER
  , pv_old_avenger_name  VARCHAR2 );

  PROCEDURE avenger_insert
  ( pv_old_avenger_id    NUMBER
  , pv_old_avenger_name  VARCHAR2 );

END log_avenger;
/

/* Show errors and description. */
SHOW errors
DESC log_avenger

/* Create package. */
SELECT 'Create log_avenger package body ...' AS "Step #4" FROM dual;
CREATE OR REPLACE
  PACKAGE BODY log_avenger IS

  PROCEDURE avenger_insert
  ( pv_new_avenger_id    NUMBER
  , pv_new_avenger_name  VARCHAR2 ) IS

    /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Insert log entry for an avenger. */
    log_avenger.avenger_insert(
        pv_old_avenger_id => null
      , pv_old_avenger_name => null
      , pv_new_avenger_id => pv_new_avenger_id
      , pv_new_avenger_name => pv_new_avenger_name);
  EXCEPTION
    /* Exception handler. */
    WHEN OTHERS THEN
     RETURN;
  END avenger_insert;

  PROCEDURE avenger_insert
  ( pv_new_avenger_id    NUMBER
  , pv_new_avenger_name  VARCHAR2
  , pv_old_avenger_id    NUMBER
  , pv_old_avenger_name  VARCHAR2 ) IS

    /* Declare local logging value. */
    lv_logging_id  NUMBER;

    /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Get a sequence. */
    lv_logging_id := logging_s.NEXTVAL;

    /* Set a savepoint. */
    SAVEPOINT starting;

    /* Insert log entry for an avenger. */
    INSERT INTO logging
    ( logging_id
    , new_avenger_id
    , new_avenger_name
    , old_avenger_id
    , old_avenger_name )
    VALUES
    ( lv_logging_id
    , pv_new_avenger_id
    , pv_new_avenger_name
    , pv_old_avenger_id
    , pv_old_avenger_name );

    /* Commit the independent write. */
    COMMIT;
  EXCEPTION
    /* Exception handler. */
    WHEN OTHERS THEN
      ROLLBACK TO starting;
      RETURN;
  END avenger_insert;

  PROCEDURE avenger_insert
  ( pv_old_avenger_id    NUMBER
  , pv_old_avenger_name  VARCHAR2 ) IS

    /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Insert log entry for an avenger. */
    log_avenger.avenger_insert(
        pv_old_avenger_id => pv_old_avenger_id
      , pv_old_avenger_name => pv_old_avenger_name
      , pv_new_avenger_id => null
      , pv_new_avenger_name => null);
  EXCEPTION
    /* Exception handler. */
    WHEN OTHERS THEN
     RETURN;
  END avenger_insert;
END log_avenger;
/

SHOW ERRORS

/* Test the log_avenger package. */
SELECT 'Create log_avenger package body ...' AS "Step #5" FROM dual;
DECLARE
  /* Define input values. */
  lv_new_avenger_id    NUMBER        := 1;
  lv_new_avenger_name  VARCHAR2(30) := 'Thor';
BEGIN
  log_avenger.avenger_insert(
      pv_new_avenger_id => lv_new_avenger_id
    , pv_new_avenger_name => lv_new_avenger_name );
END;
/

DECLARE
  /* Define input values. */
  lv_new_avenger_id    NUMBER        := 2;
  lv_new_avenger_name  VARCHAR2(30) := 'Hulk';
BEGIN
  log_avenger.avenger_insert(
      pv_new_avenger_id => lv_new_avenger_id
    , pv_new_avenger_name => lv_new_avenger_name );
END;
/

DECLARE
  /* Define input values. */
  lv_avenger_id        NUMBER       := 3;
  lv_old_avenger_name  VARCHAR2(30) := 'Thor';
  lv_new_avenger_name  VARCHAR2(30) := 'King Thor';
BEGIN
  log_avenger.avenger_insert(
      pv_old_avenger_id => lv_avenger_id
    , pv_old_avenger_name => lv_old_avenger_name
    , pv_new_avenger_id => lv_avenger_id
    , pv_new_avenger_name => lv_new_avenger_name );
END;
/

DECLARE
  /* Define input values. */
  lv_old_avenger_id    NUMBER        := 4;
  lv_old_avenger_name  VARCHAR2(30) := 'King Thor';
BEGIN
  log_avenger.avenger_insert(
      pv_old_avenger_id => lv_old_avenger_id
    , pv_old_avenger_name => lv_old_avenger_name );
END;
/

/* Query the logger table. */
COL logger_id         FORMAT 999999  HEADING "Logging|ID #"
COL old_avenger_id    FORMAT 999999  HEADING "Old|Avenger|ID #"
COL old_avenger_name  FORMAT A20     HEADING "Old Avenger Name"
COL new_avenger_id    FORMAT 999999  HEADING "New|Avenger|ID #"
COL new_avenger_name  FORMAT A30     HEADING "New Avenger Name"
SELECT * FROM logging;

/* Test the log_avenger package. */
SELECT 'Create avenger_trig trigger ...' AS "Step #6" FROM dual;

/* Create a database trigger. */
CREATE OR REPLACE
  TRIGGER avenger_trig
  BEFORE INSERT OR UPDATE OF avenger_name ON avenger
  FOR EACH ROW
  DECLARE
    /* Declare exception. */
    e EXCEPTION;
    PRAGMA EXCEPTION_INIT(e,-20001);
  BEGIN
    /* Check for an event and log accordingly. */
    IF INSERTING THEN
      /* Log the insert change to the item table in the logger table. */
      log_avenger.avenger_insert(
          pv_new_avenger_id => :new.avenger_id
        , pv_new_avenger_name => :new.avenger_name );

      /* Check for an empty item_id primary key column value,
         and assign the next sequence value when it is missing. */
      IF :new.avenger_id IS NULL THEN
        SELECT avenger_s.NEXTVAL
        INTO   :new.avenger_id
        FROM   dual;
      END IF;
    ELSIF UPDATING THEN
      /* Log the update change to the item table in the logging table. */
      log_avenger.avenger_insert(
          pv_new_avenger_id => :new.avenger_id
        , pv_new_avenger_name => :new.avenger_name
        , pv_old_avenger_id => :old.avenger_id
        , pv_old_avenger_name => :old.avenger_name );
    END IF;
  END item_trig;
/

/* Show errors and description. */
SHOW errors

/* Test the log_avenger package. */
SELECT 'Create avenger_delete_trig trigger ...' AS "Step #7" FROM dual;

CREATE OR REPLACE
  TRIGGER avenger_delete_trig
  BEFORE DELETE ON avenger
  FOR EACH ROW
  DECLARE
    /* Declare exception. */
    e EXCEPTION;
    PRAGMA EXCEPTION_INIT(e,-20001);
  BEGIN
    IF DELETING THEN
      /* Log the delete change to the item table in the logging table. */
      log_avenger.avenger_insert(
          pv_old_avenger_id => :old.avenger_id
        , pv_old_avenger_name => :old.avenger_name );
    END IF;
  END item_trig;
/

/* Show errors and description. */
SHOW errors

/* Test the log_avenger package. */
SELECT 'Create avenger_delete_trig trigger ...' AS "Step #7" FROM dual;

/* Insert into the avenber table. */
INSERT INTO avenger
( avenger_id
, avenger_name )
VALUES
( avenger_s.NEXTVAL
,'Captain America');

/* Update values in the avenger table. */
UPDATE avenger
SET    avenger_name = 'Captain America "Wanted"'
WHERE  avenger_name = 'Captain America';

/* Delete value from the avenger table. */
DELETE
FROM   avenger
WHERE  avenger_name LIKE 'Captain America%';

/* Query the avenger table. */
SELECT * FROM avenger;

/* Query the logger table. */
COL logger_id         FORMAT 999999  HEADING "Logging|ID #"
COL old_avenger_id    FORMAT 999999  HEADING "Old|Avenger|ID #"
COL old_avenger_name  FORMAT A25     HEADING "Old Avenger Name"
COL new_avenger_id    FORMAT 999999  HEADING "New|Avenger|ID #"
COL new_avenger_name  FORMAT A25     HEADING "New Avenger Name"
SELECT * FROM logging;

/* Close log file. */
SPOOL OFF
