CREATE REPLACE PROCEDURE insert_items
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
