/*
||  Name:          demo_lab8_bank.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 9 lab.
*/

-- Open log file.
SPOOL demo_lab8_bank.txt

/* Drop tables and sequences. */
DROP TABLE bank;
DROP SEQUENCE bank_s;
DROP TABLE dealer;
DROP SEQUENCE dealer_s;
DROP TABLE audit_user;
DROP SEQUENCE audit_user_s;

/* Create bank table and sequence. */
CREATE TABLE bank
( bank_id     NUMBER
, bank_text   VARCHAR2(20)
, t_amount    NUMBER
, created_by  NUMBER );
CREATE SEQUENCE bank_s;

/* Creaet dealer and sequence. */
CREATE TABLE dealer
( dealer_id    NUMBER
, dealer_text  VARCHAR2(20)
, t_amount     NUMBER
, created_by   NUMBER );
CREATE SEQUENCE dealer_s;

/* Create audit_user table to mimic system_user table. */
CREATE TABLE audit_user
( audit_user_id    NUMBER
, audit_user_name  VARCHAR2(20));
CREATE SEQUENCE audit_user_s;

/* Seed audit_user with one row. */
INSERT INTO audit_user
( audit_user_id
, audit_user_name )
VALUES
( audit_user_s.nextval
,'SYSADMIN' );

/* Drop procedure. */
DROP PROCEDURE insert_payment;

/*
   Development strategy:
   ====================
   1. Write a procedure or function shell that defines the list
      of parameters and the transaction control language 
      management.
   2. Write the SQL statements one at a time and test them
      outside of the procedure or function.
   3. Comment out the transaction control language commands
      for committing and rolling back transactions; you do
      that by putting two dashes in-front of the commands, 
      which ensures that you can add the functionality back
      by simply removing the single comment dashes.
   4. Put the working SQL statement into the procedure or
      function, and test it. When you have multiple SQL
      statements do these one at a time, repeating step #2
      and 4 until all SQL statements work in the scope of
      the function or procedure.
   5. Uncomment transaction language commands and test
      the program again.
*/
CREATE OR REPLACE PROCEDURE insert_payment
( pv_bank_text        VARCHAR2
, pv_bank_t_amount    NUMBER
, pv_dealer_text      VARCHAR2
, pv_dealer_t_amount  NUMBER
, pv_user_name        VARCHAR2 ) IS
BEGIN
  /* Set a rollback savepoint. */
  SAVEPOINT start_place;
  /* Put code here. */
  NULL;
  /* Write changes. */
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_place;
END;
/

LIST
SHOW ERRORS

CREATE OR REPLACE PROCEDURE insert_payment
( pv_bank_text        VARCHAR2
, pv_bank_t_amount    NUMBER
, pv_dealer_text      VARCHAR2
, pv_dealer_t_amount  NUMBER
, pv_user_name        VARCHAR2 ) IS

  /* Declare a local variable for the validation query. */
  lv_audit_user_id  NUMBER;
  lv_bank_id        NUMBER;

  /* Create dynamic cursor to translate user name to ID. */
  CURSOR get_user_id 
  ( cv_user_name  VARCHAR2 ) IS
    SELECT audit_user_id
    FROM   audit_user
    WHERE  audit_user_name = cv_user_name;

  /* Create dynamic cursor to check for a pre-existing bank. */
  CURSOR get_bank 
  ( cv_bank_text  VARCHAR2 ) IS
    SELECT bank_id
    FROM   bank
    WHERE  bank_text = cv_bank_text;
   
BEGIN
  /* Set a rollback savepoint. */
  SAVEPOINT start_place;

  /* Translate the pv_user_name to a user_id. */
  FOR i IN get_user_id(pv_user_name) LOOP
    lv_audit_user_id := i.audit_user_id;
  END LOOP;

  /* Open get_bank cursor. */
  OPEN get_bank(pv_bank_text);
  FETCH get_bank INTO lv_bank_id;

  /* Insert a row when one does not exist. */
  IF get_bank%NOTFOUND THEN

    INSERT INTO bank
    ( bank_id
    , bank_text
    , t_amount
    , created_by )
    VALUES
    ( bank_s.nextval
    , pv_bank_text
    , pv_bank_t_amount
    , lv_audit_user_id );

  END IF;

  /* Clode get_bank cursor. */
  CLOSE get_bank;

  INSERT INTO dealer
  ( dealer_id
  , dealer_text
  , t_amount
  , created_by )
  VALUES
  ( dealer_s.nextval
  , pv_dealer_text
  , pv_dealer_t_amount
  , lv_audit_user_id );

  /* Write changes. */
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_place;
END;
/
LIST
SHOW ERRORS

/* Test the insert_payment procedure. */
BEGIN
  insert_payment
  ( pv_bank_text => 'Wells Fargo'
  , pv_bank_t_amount => 500.00
  , pv_dealer_text => 'Honda'
  , pv_dealer_t_amount => 250.00
  , pv_user_name => 'SYSADMIN' );
END;
/

/* Query the results from the tables. */
SELECT * FROM bank;
SELECT * FROM dealer;

/* Test the insert_payment procedure. */
BEGIN
  insert_payment
  ( pv_bank_text => 'Wells Fargo'
  , pv_bank_t_amount => 500.00
  , pv_dealer_text => 'Fait of Northern California'
  , pv_dealer_t_amount => 250.00
  , pv_user_name => 'SYSADMIN' );
END;
/

/* Query the results from the tables. */
SELECT * FROM bank;
SELECT * FROM dealer;

-- Close log file.
SPOOL OFF
