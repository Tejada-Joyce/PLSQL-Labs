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
