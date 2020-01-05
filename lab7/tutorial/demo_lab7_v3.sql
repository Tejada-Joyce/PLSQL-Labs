/*
||  Name:          demo_lab7_v3.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 8 lab.
*/

/* Drop and recreate the message table. */
DROP TABLE message;
CREATE TABLE message
( message_id     NUMBER
, message_text   VARCHAR2(20));
DROP SEQUENCE message_s;
CREATE SEQUENCE message_s;

/* Create or replace a procedure that was a procedure. */
DROP PROCEDURE write_string;
CREATE OR REPLACE
  FUNCTION write_string
  ( pv_message  VARCHAR2 ) RETURN NUMBER IS
    -- Declare a default return value.
    lv_retval  NUMBER := 0; -- Zero is a placeholder for false.
    -- Precompiler instructions.
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO message
    ( message_id, message_text)
    VALUES
    ( message_s.nextval, pv_message );
    -- Counts the inserted rows.
    lv_retval := SQL%ROWCOUNT;

    -- Autonomous transaction must contain a commit to avoid:
    -- ORA-06519: active autonomous transaction detected and rolled back
    COMMIT;
    RETURN lv_retval;
  END;
/

LIST
SHOW ERRORS

/* Testing block for multiple transaction scopes. */
SELECT write_string('SQL Query') AS retval FROM dual;

/* Testing block for a single transaction scope. */
DECLARE
  e EXCEPTION;
BEGIN
  IF NOT write_string('Testing') = 0 THEN
    RAISE e;
  END IF;
END;
/

/* Testing block for multiple transaction scopes. */
DECLARE
  e EXCEPTION;
BEGIN
  IF NOT write_string('Testing') = 0 THEN
    RAISE e;
  END IF;
EXCEPTION
  WHEN others THEN
    RETURN;
END;
/

/* Testing block for multiple transaction scopes. */
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  lv_count NUMBER := 0;
  e EXCEPTION;
BEGIN
  lv_count := write_string('Testing');
  IF NOT lv_count = 0 THEN
    dbms_output.put_line('Inserted ['||lv_count||'] rows into message.');
    RAISE e;
  END IF;
EXCEPTION
  WHEN others THEN
    RETURN;
END;
/

LIST
SHOW ERRORS

/* Query results from all transaction scopes. */
SELECT * FROM message;
