/*
||  Name:          apply_plsql_lab6.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 7 lab.
*/

/* Set environment variables. */
SET ECHO ON
SET FEEDBACK ON
SET PAGESIZE 49999
SET SERVEROUTPUT ON SIZE UNLIMITED

/* Run the library files. */
@$CIT325/lab6/apply_prep_lab6.sql

-- Open log file.
SPOOL apply_plsql_lab6.txt

-- Enter your solution here.

-- Close log file.
SPOOL OFF
