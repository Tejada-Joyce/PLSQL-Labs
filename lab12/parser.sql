/*
||  Name:          parser.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 10 lab.
*/

-- Open log file.
SPOOL parser.txt

CREATE OR REPLACE PROCEDURE parse_rows
( pv_text  VARCHAR2 ) IS
 
  /* Declare parsing indexes. */
  lv_start     NUMBER := 1;
  lv_end       NUMBER := 1;
  lv_length    NUMBER;
 
BEGIN
 
  /* Assign an end value based on parsing line return or length. */
  IF INSTR(pv_text,CHR(10),lv_start) = 0 THEN
    lv_end := LENGTH(pv_text) + 1;
  ELSE
    lv_end := INSTR(pv_text,CHR(10),lv_start);
  END IF;
 
  /* Assign a length value to the parsed string. */
  lv_length := lv_end - lv_start;
 
  /* Print first line. */
  DBMS_OUTPUT.put_line(SUBSTR(pv_text,lv_start,lv_length));
 
  /* Print the rows of a multiple line string. */
  WHILE (lv_end < LENGTH(pv_text)) LOOP
 
    /* Assign a new start value. */
    lv_start := lv_end + 1;
 
    /* Assign a new end value. */
    IF INSTR(pv_text,CHR(10),lv_start + 1) = 0 THEN
      lv_end := LENGTH(pv_text) + 1;
    ELSE
      lv_end := INSTR(pv_text,CHR(10),lv_start + 1);
    END IF;
 
    /* Assign a new length. */
    lv_length := lv_end - lv_start;
 
    /* Print the individual rows. */
    DBMS_OUTPUT.put_line(SUBSTR(pv_text,lv_start,lv_length));
 
  END LOOP;
END;
/


-- Close log file.
SPOOL OFF
