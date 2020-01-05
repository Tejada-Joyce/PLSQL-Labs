/*
||  Name:          demo_lab8_v1.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 3 lab.
*/

-- Open log file.
SPOOL demo_lab8_v1.txt

/* Create a simple overloaded set of procedures. */
CREATE OR REPLACE
  PACKAGE sample IS

  /* An overload procedure. */
  PROCEDURE do_something
  ( pv_thing1   VARCHAR2 
  , pv_thing2   VARCHAR2 );

  /* An overload procedure. */
  PROCEDURE do_something
  ( pv_cat      VARCHAR2
  , pv_thing1   VARCHAR2
  , pv_thing2   VARCHAR2 );

END sample;
/

/* Create a simple overloaded set of procedures. */
CREATE OR REPLACE
  PACKAGE BODY sample IS
  
  /* An overload procedure. */
  PROCEDURE do_something
  ( pv_thing1   VARCHAR2 
  , pv_thing2   VARCHAR2 ) IS
  
  BEGIN
    NULL;
  END;

  /* An overload procedure. */
  PROCEDURE do_something
  ( pv_cat      VARCHAR2 := 'Cat in the hat.'
  , pv_thing1   VARCHAR2
  , pv_thing2   VARCHAR2 ) IS
  
  BEGIN
    NULL;
  END;

END sample;
/
  
-- Close log file.
SPOOL OFF
