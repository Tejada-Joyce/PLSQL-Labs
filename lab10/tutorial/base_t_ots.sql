/*
||  Name:          base_t_ots.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 10 lab.
*/

-- Open log file.
SPOOL base_t_ots.txt

SET ECHO OFF
SET FEEDBACK ON
SET NULL '<Null>'
SET PAGESIZE 999
SET SERVEROUTPUT ON

-- Create or replace a generic object type.
CREATE OR REPLACE
  TYPE base_t IS OBJECT
  ( oname  VARCHAR2(30)
  , name   VARCHAR2(30)
  , CONSTRUCTOR FUNCTION base_t
    RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION base_t
    ( oname  VARCHAR2
    , name   VARCHAR2 )
    RETURN SELF AS RESULT
  , MEMBER FUNCTION get_name RETURN VARCHAR2
  , MEMBER FUNCTION get_oname RETURN VARCHAR2
  , MEMBER PROCEDURE set_oname (oname VARCHAR2)
  , MEMBER FUNCTION to_string RETURN VARCHAR2)
INSTANTIABLE NOT FINAL;
/

-- Close log file.
SPOOL OFF
