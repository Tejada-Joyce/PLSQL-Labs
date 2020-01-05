/*
||  Name:          avenger.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 3 lab.
*/

-- Open log file.
SPOOL avenger.txt

CREATE TABLE avenger
( avenger_id      NUMBER
, first_name      VARCHAR2(20)
, last_name       VARCHAR2(20)
, character_name  VARCHAR2(20))
  ORGANIZATION EXTERNAL
  ( TYPE oracle_loader
    DEFAULT DIRECTORY uploadtext
    ACCESS PARAMETERS
    ( RECORDS DELIMITED BY NEWLINE CHARACTERSET US7ASCII
      BADFILE     'UPLOADTEXT':'avenger.bad'
      DISCARDFILE 'UPLOADTEXT':'avenger.dis'
      LOGFILE     'UPLOADTEXT':'avenger.log'
      FIELDS TERMINATED BY ','
      OPTIONALLY ENCLOSED BY "'"
      MISSING FIELD VALUES ARE NULL)
    LOCATION ('avenger.csv'))
REJECT LIMIT UNLIMITED
/

-- Query the rows.
SELECT * FROM avenger;

-- Close log file.
SPOOL OFF
