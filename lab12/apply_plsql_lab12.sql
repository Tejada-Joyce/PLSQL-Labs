/*
||  Name:          apply_plsql_lab12.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 13 lab.
*/

-- Call seeding libraries.
@/home/student/Data/cit325/lib/cleanup_oracle.sql
@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab12.txt

-- Enter your solution here.

-- Create the item_obj object type
CREATE OR REPLACE
  TYPE item_obj IS OBJECT
  ( title            VARCHAR2(60)
  , subtitle         VARCHAR2(60)
  , rating           VARCHAR2(8)
  , release_date     DATE);
/

DESC item_obj

-- Create the item_tab collection object type
CREATE OR REPLACE
  TYPE item_tab IS TABLE of item_obj;
/

DESC item_tab

-- Create a item_list function
CREATE OR REPLACE
  FUNCTION item_list
  ( pv_start_date  DATE 
  , pv_end_date    DATE := TRUNC(SYSDATE) + 1) RETURN item_tab IS
     
    /* Create an item_rec record type that mirrors the item_obj object type. */
    /* Declare a record type. */
    TYPE item_rec IS RECORD
    ( title            VARCHAR2(60)
    , subtitle         VARCHAR2(60)
    , rating           VARCHAR2(8)
    , release_date     DATE);
    
    /* Create an item_cur system reference cursor that is weakly typed cursor. */
    /* Declare reference cursor for an NDS cursor. */
    item_cur   SYS_REFCURSOR;
    
    /* Declare a customer row for output from an NDS cursor. */
    /* Create an item_row variable of the item_rec data type.*/
    item_row   ITEM_REC;
    /* Create an item_set variable of the item_tab collection type, and create an empty instance of the item_tab collection.*/
    item_set   ITEM_TAB := item_tab();

    /* Declare dynamic statement. */
    /* Create a stmt string variable to hold a Native Dynamic SQL (NDS) variable.*/
    stmt  VARCHAR2(2000);
  BEGIN
    /* Create a dynamic statement. */
    stmt := 'SELECT item_title AS title, item_subtitle AS subtitle, item_rating AS rating, item_release_date AS release_date '
         || 'FROM   item '
         || 'WHERE  item_rating_agency = ''MPAA'''
         || 'AND    item_release_date BETWEEN :start_date AND :end_date' ;
    dbms_output.put_line(stmt);
    
    /* Open the item_cur system reference cursor with the stmt dynamic statement, 
       and assign the pv_start_date and pv_end_date variables inside the USING clause. */
    /* Open and read dynamic cursor. */
    OPEN item_cur FOR stmt USING pv_start_date, pv_end_date ;
    LOOP
      /* Fetch the item_cur system reference cursor into the item_row variable of the item_rec data type. */
      FETCH item_cur INTO item_row;
      EXIT WHEN item_cur%NOTFOUND;

      /* Extend space in the item_set variable of the item_tab collection. */
      item_set.EXTEND;
      item_set(item_set.COUNT) :=
        item_obj( title  => item_row.title
                , subtitle => item_row.subtitle
                , rating   => item_row.rating
                , release_date  => item_row.release_date);
    END LOOP;

    /* Return item set. */
    RETURN item_set;
  END item_list;
/

DESC item_list

-- Test Case
COL title   FORMAT A60 HEADING "TITLE"
COL rating  FORMAT A12 HEADING "RATING"
SELECT   il.title
,        il.rating
FROM     TABLE(item_list('01-JAN-2000')) il;

-- Close log file.
SPOOL OFF
