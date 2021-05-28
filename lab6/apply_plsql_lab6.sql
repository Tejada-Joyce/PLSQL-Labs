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
@/home/student/Data/cit325/lab6/apply_prep_lab6.sql



-- Enter your solution here.
CREATE OR REPLACE PROCEDURE insert_item
( pv_item_barcode        VARCHAR2
, pv_item_type           VARCHAR2
, pv_item_title          VARCHAR2
, pv_item_subtitle       VARCHAR2 := NULL
, pv_item_rating         VARCHAR2
, pv_item_rating_agency  VARCHAR2
, pv_item_release_date   DATE ) IS

  /* Declare local variables. */
  lv_item_type  NUMBER;
  lv_rating_id  NUMBER;
  lv_user_id    NUMBER := 1;
  lv_date       DATE := TRUNC(SYSDATE);
  lv_control    BOOLEAN := FALSE;

  /* Declare error handling variables. */
  lv_local_object  VARCHAR2(30) := 'PROCEDURE';
  lv_local_module  VARCHAR2(30) := 'INSERT_ITEM';

  /* Declare conversion cursor. */
  CURSOR item_type_cur
  ( cv_item_type  VARCHAR2 ) IS
    SELECT common_lookup_id
    FROM   common_lookup
    WHERE  common_lookup_table = 'ITEM'
    AND    common_lookup_column = 'ITEM_TYPE'
    AND    common_lookup_type = cv_item_type;

  /* Declare conversion cursor. */
  CURSOR rating_cur
  ( cv_rating         VARCHAR2
  , cv_rating_agency  VARCHAR2 ) IS
    SELECT rating_agency_id
    FROM   rating_agency
    WHERE  rating = cv_rating
    AND    rating_agency = cv_rating_agency;

  /*
     Enforce logic validation that the rating, rating agency and
     media type match. This is a user-configuration area and they
     may need to add validation code for new materials here.
  */
  CURSOR match_media_to_rating
  ( cv_item_type  NUMBER
  , cv_rating_id  NUMBER ) IS
    SELECT  NULL
    FROM    common_lookup cl CROSS JOIN rating_agency ra
    WHERE   common_lookup_id = cv_item_type
    AND    (common_lookup_type IN ('BLU-RAY','DVD','HD','SD')
    AND     rating_agency_id = cv_rating_id
    AND     rating IN ('G','PG','PG-13','R')
    AND     rating_agency = 'MPAA')
    OR     (common_lookup_type IN ('GAMECUBE','PLAYSTATION','XBOX')
    AND     rating_agency_id = cv_rating_id
    AND     rating IN ('C','E','E10+','T')
    AND     rating_agency = 'ESRB');

  /* Declare an exception. */
  e  EXCEPTION;
  PRAGMA EXCEPTION_INIT(e,-20001);

  /* Designate as an autonomous program. */
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  /* Get the foreign key of an item type. */
  FOR i IN item_type_cur(pv_item_type) LOOP
    lv_item_type := i.common_lookup_id;
  END LOOP;

  /* Get the foreign key of a rating. */
  FOR i IN rating_cur(pv_item_rating, pv_item_rating_agency) LOOP
    lv_rating_id := i.rating_agency_id;
  END LOOP;

  /* Only insert when the two foreign key values are set matches. */
  FOR i IN match_media_to_rating(lv_item_type, lv_rating_id) LOOP

    INSERT
    INTO   item
    ( item_id
    , item_barcode
    , item_type
    , item_title
    , item_subtitle
    , item_desc
    , item_release_date
    , rating_agency_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date )
    VALUES
    ( item_s1.NEXTVAL
    , pv_item_barcode
    , lv_item_type
    , pv_item_title
    , pv_item_subtitle
    , EMPTY_CLOB()
    , pv_item_release_date
    , lv_rating_id
    , lv_user_id
    , lv_date
    , lv_user_id
    , lv_date );

    /* Set control to true. */
    lv_control := TRUE;

    /* Commmit the record. */
    COMMIT;

  END LOOP;

  /* Raise an exception when required. */
  IF NOT lv_control THEN
    RAISE e;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    record_errors( object_name => lv_local_object
                 , module_name => lv_local_module
                 , sqlerror_code => 'ORA'||SQLCODE
                 , sqlerror_message => SQLERRM
                 , user_error_message => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
    RAISE;
END;
/

-- Open log file.
SPOOL apply_plsql_lab6.txt

-- Test a call to the insert_item procedure
DECLARE

  /* Declare the local error handling variables. */
  lv_local_object  VARCHAR2(30) := 'ANONYMOUS';
  lv_local_module  VARCHAR2(30) := 'LOCAL';

BEGIN
  insert_item( pv_item_barcode => 'B01LTHWTHO'
             , pv_item_type => 'DVD'
             , pv_item_title => 'Inferno'
             , pv_item_rating => 'PG-13'
             , pv_item_rating_agency => 'MPAA'
             , pv_item_release_date => '24-JAN-2017');
EXCEPTION
  WHEN OTHERS THEN
    record_errors( object_name => lv_local_object
                 , module_name => lv_local_module
                 , sqlerror_code => 'ORA'||SQLCODE
                 , sqlerror_message => SQLERRM
                 , user_error_message => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    RAISE;
END;
/

COL item_barcode FORMAT A10 HEADING "Item|Barcode"
COL item_title   FORMAT A48 HEADING "Item Title"
COL release_date FORMAT A12 HEADING "Item|Release|Date"
SELECT   i.item_barcode
,        i.item_title
,        i.item_release_date AS release_date
FROM   item i
WHERE  REGEXP_LIKE(i.item_title,'^.*bourne.*$','i')
OR     REGEXP_LIKE(i.item_title,'^.*inferno.*$','i');

CREATE PROCEDURE insert_items
( pv_items  ITEM_TAB ) IS

 /* Declare error handling variables. */
  lv_local_object  VARCHAR2(30) := 'PROCEDURE';
  lv_local_module  VARCHAR2(30) := 'INSERT_ITEMS';
  
  /* Designate as an autonomous program. */
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
  /* Read the list of items and call the insert_item procedure. */
  FOR i IN 1..pv_items.COUNT LOOP
    insert_item( pv_item_barcode => pv_items(i).item_barcode
               , pv_item_type => pv_items(i).item_type
               , pv_item_title => pv_items(i).item_title
               , pv_item_subtitle => pv_items(i).item_subtitle
               , pv_item_rating => pv_items(i).item_rating
               , pv_item_rating_agency => pv_items(i).item_rating_agency
               , pv_item_release_date => pv_items(i).item_release_date );
  END LOOP;
  
  EXCEPTION
  WHEN OTHERS THEN
    record_errors( object_name => lv_local_object
                 , module_name => lv_local_module
                 , sqlerror_code => 'ORA'||SQLCODE
                 , sqlerror_message => SQLERRM
                 , user_error_message => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
    RAISE;
END;
/

-- Test a call to the insert_items procedure for a set of entries 
DECLARE

  /* Declare the local error handling variables. */
  lv_local_object  VARCHAR2(30) := 'ANONYMOUS';
  lv_local_module  VARCHAR2(30) := 'LOCAL';

  /* Create a collection. */
  lv_items  ITEM_TAB :=
    item_tab(
        item_obj( item_barcode => 'B0084IG7KC'
                , item_type => 'BLU-RAY'
                , item_title => 'The Hunger Games'
                , item_subtitle => NULL
                , item_rating => 'PG-13'
                , item_rating_agency => 'MPAA'
                , item_release_date => '18-AUG-2012')
      , item_obj( item_barcode => 'B008JFUS8M'
                , item_type => 'BLU-RAY'
                , item_title => 'The Hunger Games: Catching Fire'
                , item_subtitle => NULL
                , item_rating => 'PG-13'
                , item_rating_agency => 'MPAA'
                , item_release_date => '07-MAR-2014'));
BEGIN
  /* Call a element processing procedure. */
  insert_items(lv_items);

EXCEPTION
  WHEN OTHERS THEN
    record_errors( object_name => lv_local_object
                 , module_name => lv_local_module
                 , sqlerror_code => 'ORA'||SQLCODE
                 , sqlerror_message => SQLERRM
                 , user_error_message => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    RAISE;
END;
/

COL item_barcode FORMAT A10 HEADING "Item|Barcode"
COL item_title   FORMAT A36 HEADING "Item Title"
COL release_date FORMAT A12 HEADING "Item|Release|Date"
SELECT   i.item_barcode
,        i.item_title
,        i.item_release_date AS release_date
FROM     item i
WHERE    REGEXP_LIKE(i.item_title,'^.*bourne.*$','i')
OR       REGEXP_LIKE(i.item_title,'^.*inferno.*$','i')
OR       REGEXP_LIKE(i.item_title,'^.*hunger.*$','i')
ORDER BY CASE
           WHEN REGEXP_LIKE(i.item_title,'^.*bourne.*$','i')  THEN 1
           WHEN REGEXP_LIKE(i.item_title,'^.*hunger.*$','i')  THEN 2
           WHEN REGEXP_LIKE(i.item_title,'^.*inferno.*$','i') THEN 3
         END
,        i.item_release_date;

-- test a second call to the insert_items procedure for a set of entries.
DECLARE

  /* Declare the local error handling variables. */
  lv_local_object  VARCHAR2(30) := 'ANONYMOUS';
  lv_local_module  VARCHAR2(30) := 'LOCAL';

  /* Create a collection. */
  lv_items  ITEM_TAB :=
    item_tab(
        item_obj( item_barcode => 'B00PYLT4YI'
                , item_type => 'BLU-RAY'
                , item_title => 'The Hunger Games: Mockingjay Part 1'
                , item_subtitle => NULL
                , item_rating => 'PG-13'
                , item_rating_agency => 'MPAA'
                , item_release_date => '06-MAR-2015')
      , item_obj( item_barcode => 'B0189HKE5Q'
                , item_type => 'XBOX'
                , item_title => 'The Hunger Games: Mockingjay Part 2'
                , item_subtitle => NULL
                , item_rating => 'PG-13'
                , item_rating_agency => 'MPAA'
                , item_release_date => '22-MAR-2016'));
BEGIN
  /* Call a element processing procedure. */
  insert_items(lv_items);

EXCEPTION
  WHEN OTHERS THEN
    record_errors(object_name => lv_local_object
                 ,module_name => lv_local_module
                 , sqlerror_code => 'ORA'||SQLCODE
                 ,sqlerror_message => SQLERRM
                 ,user_error_message => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    RAISE;
END;
/

COL item_barcode FORMAT A10 HEADING "Item|Barcode"
COL item_title   FORMAT A36 HEADING "Item Title"
COL release_date FORMAT A12 HEADING "Item|Release|Date"
SELECT   i.item_barcode
,        i.item_title
,        i.item_release_date AS release_date
FROM     item i
WHERE    REGEXP_LIKE(i.item_title,'^.*bourne.*$','i')
OR       REGEXP_LIKE(i.item_title,'^.*inferno.*$','i')
OR       REGEXP_LIKE(i.item_title,'^.*hunger.*$','i')
ORDER BY CASE
           WHEN REGEXP_LIKE(i.item_title,'^.*bourne.*$','i')  THEN 1
           WHEN REGEXP_LIKE(i.item_title,'^.*hunger.*$','i')  THEN 2
           WHEN REGEXP_LIKE(i.item_title,'^.*inferno.*$','i') THEN 3
         END
,        i.item_release_date;

-- Check is what has been written to the nc_error table
COL error_id     FORMAT 999999  HEADING "Error|ID #"
COL object_name  FORMAT A20     HEADING "Object Name"
COL module_name  FORMAT A20     HEADING "Module Name"
COL sqlerror_code  FORMAT A10   HEADING "Error|ID #"
SELECT   ne.error_id
,        ne.object_name
,        ne.module_name
,        ne.sqlerror_code
FROM     nc_error ne
ORDER BY 1 DESC;

-- Close log file.
SPOOL OFF
