/*
||  Name:          demo_lab8.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 3 lab.
*/

-- Open log file.
SPOOL demo_lab8.txt

/* Create or replace demo_overload package. */
CREATE OR REPLACE PACKAGE demo_overload IS

  /* Overloaded function. */
  FUNCTION thing 
  ( pv_name    VARCHAR2
  , pv_number  NUMBER ) RETURN VARCHAR2;

  /* Overloaded function. */
  FUNCTION thing 
  ( pv_name    VARCHAR2
  , pv_number  VARCHAR2 ) RETURN VARCHAR2;

  /* Overloaded function. */
  FUNCTION thing 
  ( name    VARCHAR2
  ,"number" NUMBER ) RETURN VARCHAR2;

END demo_overload;
/

/* Create or replace demo_overload package body. */
CREATE OR REPLACE PACKAGE BODY demo_overload IS

  /* Overloaded function. */
  FUNCTION thing 
  ( pv_name    VARCHAR2
  , pv_number  NUMBER ) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'VARCHAR2 + NUMBER';
  END thing;

  /* Overloaded function. */
  FUNCTION thing 
  ( pv_name    VARCHAR2
  , pv_number  VARCHAR2 ) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'VARCHAR2 + VARCHAR2';
  END thing;

  /* Overloaded function. */
  FUNCTION thing 
  ( name    VARCHAR2
  ,"number" NUMBER ) RETURN VARCHAR2 IS
  BEGIN
    RETURN 'VARCHAR2 + NUMBER';
  END thing;
  
END demo_overload;
/

-- Test the string and number with named notation.
SELECT demo_overload.thing(pv_name =>'Thing1', pv_number => 1) FROM dual;

-- Test the string and string with positional notation.
SELECT demo_overload.thing('Thing2','2') FROM dual;

-- Test the string and number with named notation.
SELECT demo_overload.thing(name =>'Thing3', "number" => 3) FROM dual;

-- Close log file.
SPOOL OFF
