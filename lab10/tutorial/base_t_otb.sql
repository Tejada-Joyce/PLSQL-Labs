/*
||  Name:          base_t_otb.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 10 lab.
*/

-- Open log file.
SPOOL base_t_otb.txt

SET ECHO OFF
SET FEEDBACK ON
SET NULL '<Null>'
SET PAGESIZE 999
SET SERVEROUTPUT ON

-- Create or replace a generic object type.
CREATE OR REPLACE
  TYPE BODY base_t IS

  CONSTRUCTOR FUNCTION base_t RETURN SELF AS RESULT IS
    b BASE_T := base_t(oname => 'BASE_T'
                      ,name => 'Base_t');
  BEGIN
    self := b;
    RETURN;
  END base_t;
  
  CONSTRUCTOR FUNCTION base_t
  ( oname  VARCHAR2
  , name   VARCHAR2 ) RETURN SELF AS RESULT IS
    b BASE_T;
  BEGIN
    self.oname := oname;
    self.name := name;
    RETURN;
  END base_t;
  
  MEMBER FUNCTION get_name RETURN VARCHAR2 IS
  BEGIN
    RETURN self.name;
  END get_name;
  
  MEMBER FUNCTION get_oname RETURN VARCHAR2 IS
  BEGIN
    RETURN self.oname;
  END get_oname;
  
  MEMBER PROCEDURE set_oname (oname VARCHAR2) IS
  BEGIN
    self.oname := oname;
  END set_oname;
  
  MEMBER FUNCTION to_string RETURN VARCHAR2 IS
  BEGIN
    RETURN 'Object is ['||self.oname||']';
  END to_string;
END;
/

-- Close log file.
SPOOL OFF
