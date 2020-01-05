/*
||  Name:          demo_lab7_v2.sql
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
CREATE OR REPLACE
  PROCEDURE write_string
  ( pv_message  VARCHAR2 ) IS
    -- Precompiler instructions.
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO message
    ( message_id, message_text)
    VALUES
    ( message_s.nextval, pv_message );
    -- Autonomous transaction must contain a commit to avoid:
    -- ORA-06519: active autonomous transaction detected and rolled back
    COMMIT;
  END;
/

/* Testing block for a single transaction scope. */
DECLARE
  e EXCEPTION;
BEGIN
  write_string('Testing');
  RAISE e;
END;
/

/* Query results from a single transaction scope. */
SELECT * FROM message;

/* Testing block for multiple transaction scopes. */
BEGIN
  write_string('Testing');
END;
/

/* Query results from multiple transaction scopes. */
SELECT * FROM message;
