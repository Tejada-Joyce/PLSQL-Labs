/*
||  Name:          apply_plsql_lab11.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 12 lab.
||  Dependencies:  Run the Oracle Database 12c PL/SQL Programming setup programs.
*/
@/home/student/Data/cit325/lib/cleanup_oracle.sql
@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql
-- Open log file.
SPOOL apply_plsql_lab10.txt

SET SERVEROUTPUT ON
SET VERIFY OFF

-- ... insert your solution here ...

--  Add a text_file_name column to the item table
ALTER TABLE item 
ADD text_file_name VARCHAR2(40);

-- Verification script 
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'ITEM'
ORDER BY 2;

-- ------------------------------------------------------------------------
--  Step #1
--  -------
--  Create a logger table and logger_s sequence. 
-- ------------------------------------------------------------------------
DROP TABLE logger;
DROP SEQUENCE logger_s;

-- Verify the item table
DESC item

-- Create the logger table and logger_s sequence
CREATE TABLE logger
( logger_id                        NUMBER
, old_item_id                       NUMBER
, old_item_barcode                  VARCHAR2(20)
, old_item_type                     NUMBER
, old_item_title                    VARCHAR2(60)
, old_item_subtitle                 VARCHAR2(60) 
, old_item_rating                   VARCHAR2(8)   
, old_item_rating_agency            VARCHAR2(4)   
, old_item_release_date             DATE          
, old_created_by                    NUMBER        
, old_creation_date                 DATE          
, old_last_updated_by               NUMBER        
, old_last_update_date              DATE
, old_text_file_name                VARCHAR2(40)
, new_item_id                       NUMBER
, new_item_barcode                  VARCHAR2(20)
, new_item_type                     NUMBER
, new_item_title                    VARCHAR2(60)
, new_item_subtitle                 VARCHAR2(60) 
, new_item_rating                   VARCHAR2(8)   
, new_item_rating_agency            VARCHAR2(4)   
, new_item_release_date             DATE          
, new_created_by                    NUMBER        
, new_creation_date                 DATE          
, new_last_updated_by               NUMBER        
, new_last_update_date              DATE
, new_text_file_name                VARCHAR2(40)
, CONSTRAINT logger_pk PRIMARY KEY (logger_id));

CREATE SEQUENCE logger_s;

-- Describe the logger table 
DESC logger

-- Test the INSERT statement into the logger table:
DECLARE
  /* Dynamic cursor. */
  CURSOR get_row IS
    SELECT * FROM item WHERE item_title = 'Brave Heart';
BEGIN
  /* Read the dynamic cursor. */
  FOR i IN get_row LOOP
    INSERT INTO logger 
    VALUES
      ( logger_s.NEXTVAL
      , i.item_id                       
      , i.item_barcode               
      , i.item_type                     
      , i.item_title                    
      , i.item_subtitle                  
      , i.item_rating                      
      , i.item_rating_agency             
      , i.item_release_date                     
      , i.created_by                            
      , i.creation_date                           
      , i.last_updated_by                       
      , i.last_update_date              
      , i.text_file_name                
      , i.item_id                       
      , i.item_barcode                  
      , i.item_type                     
      , i.item_title                    
      , i.item_subtitle                 
      , i.item_rating                     
      , i.item_rating_agency            
      , i.item_release_date                       
      , i.created_by                            
      , i.creation_date                           
      , i.last_updated_by                       
      , i.last_update_date
      , i.text_file_name);   
  END LOOP;
END;
/

/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;


-- -----------------------------------------------------------------------------------
--  Step #2
--  -------
--  Create overloaded item_insert autonomous procedures inside a manage_item package. 
-- -----------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE manage_item IS
 PROCEDURE item_insert
  ( pv_new_item_id              NUMBER
  , pv_new_item_barcode         VARCHAR2
  , pv_new_item_type            NUMBER
  , pv_new_item_title           VARCHAR2
  , pv_new_item_subtitle        VARCHAR2
  , pv_new_item_rating          VARCHAR2
  , pv_new_item_rating_agency   VARCHAR2 
  , pv_new_item_release_date    DATE
  , pv_new_created_by           NUMBER 
  , pv_new_creation_date        DATE 
  , pv_new_last_updated_by      NUMBER
  , pv_new_last_update_date     DATE
  , pv_new_text_file_name       VARCHAR2 );
  
  PROCEDURE item_insert
  ( pv_old_item_id              NUMBER
  , pv_old_item_barcode         VARCHAR2
  , pv_old_item_type            NUMBER
  , pv_old_item_title           VARCHAR2
  , pv_old_item_subtitle        VARCHAR2
  , pv_old_item_rating          VARCHAR2
  , pv_old_item_rating_agency   VARCHAR2
  , pv_old_item_release_date    DATE
  , pv_old_created_by           NUMBER
  , pv_old_creation_date        DATE
  , pv_old_last_updated_by      NUMBER
  , pv_old_last_update_date     DATE
  , pv_old_text_file_name       VARCHAR2
  , pv_new_item_id              NUMBER
  , pv_new_item_barcode         VARCHAR2
  , pv_new_item_type            NUMBER
  , pv_new_item_title           VARCHAR2
  , pv_new_item_subtitle        VARCHAR2
  , pv_new_item_rating          VARCHAR2
  , pv_new_item_rating_agency   VARCHAR2 
  , pv_new_item_release_date    DATE
  , pv_new_created_by           NUMBER 
  , pv_new_creation_date        DATE 
  , pv_new_last_updated_by      NUMBER
  , pv_new_last_update_date     DATE
  , pv_new_text_file_name       VARCHAR2 );
  
  PROCEDURE item_insert
  ( pv_old_item_id              NUMBER
  , pv_old_item_barcode         VARCHAR2
  , pv_old_item_type            NUMBER
  , pv_old_item_title           VARCHAR2
  , pv_old_item_subtitle        VARCHAR2
  , pv_old_item_rating          VARCHAR2
  , pv_old_item_rating_agency   VARCHAR2
  , pv_old_item_release_date    DATE
  , pv_old_created_by           NUMBER
  , pv_old_creation_date        DATE
  , pv_old_last_updated_by      NUMBER
  , pv_old_last_update_date     DATE
  , pv_old_text_file_name       VARCHAR2 );
  
END manage_item;
/

CREATE OR REPLACE PACKAGE BODY manage_item IS
 PROCEDURE item_insert
  ( pv_new_item_id              NUMBER
  , pv_new_item_barcode         VARCHAR2
  , pv_new_item_type            NUMBER
  , pv_new_item_title           VARCHAR2
  , pv_new_item_subtitle        VARCHAR2
  , pv_new_item_rating          VARCHAR2
  , pv_new_item_rating_agency   VARCHAR2 
  , pv_new_item_release_date    DATE
  , pv_new_created_by           NUMBER 
  , pv_new_creation_date        DATE 
  , pv_new_last_updated_by      NUMBER
  , pv_new_last_update_date     DATE
  , pv_new_text_file_name       VARCHAR2 ) IS
 
 /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
    
 BEGIN
    /* Insert log entry for an item. */
    manage_item.item_insert(
        pv_old_item_id => NULL            
      , pv_old_item_barcode => NULL        
      , pv_old_item_type => NULL           
      , pv_old_item_title => NULL          
      , pv_old_item_subtitle => NULL   
      , pv_old_item_rating => NULL         
      , pv_old_item_rating_agency => NULL  
      , pv_old_item_release_date => NULL   
      , pv_old_created_by => NULL          
      , pv_old_creation_date => NULL       
      , pv_old_last_updated_by => NULL      
      , pv_old_last_update_date => NULL    
      , pv_old_text_file_name => NULL      
      , pv_new_item_id => pv_new_item_id              
      , pv_new_item_barcode => pv_new_item_barcode       
      , pv_new_item_type => pv_new_item_type          
      , pv_new_item_title => pv_new_item_title         
      , pv_new_item_subtitle => pv_new_item_subtitle      
      , pv_new_item_rating => pv_new_item_rating         
      , pv_new_item_rating_agency => pv_new_item_rating_agency  
      , pv_new_item_release_date => pv_new_item_release_date  
      , pv_new_created_by => pv_new_created_by          
      , pv_new_creation_date => pv_new_creation_date       
      , pv_new_last_updated_by => pv_new_last_updated_by     
      , pv_new_last_update_date => pv_new_last_update_date  
      , pv_new_text_file_name => pv_new_text_file_name);
--   EXCEPTION
--     /* Exception handler. */
--     WHEN OTHERS THEN
--      RETURN;
  END item_insert;   

  PROCEDURE item_insert
  ( pv_old_item_id              NUMBER
  , pv_old_item_barcode         VARCHAR2
  , pv_old_item_type            NUMBER
  , pv_old_item_title           VARCHAR2
  , pv_old_item_subtitle        VARCHAR2
  , pv_old_item_rating          VARCHAR2
  , pv_old_item_rating_agency   VARCHAR2
  , pv_old_item_release_date    DATE
  , pv_old_created_by           NUMBER
  , pv_old_creation_date        DATE
  , pv_old_last_updated_by      NUMBER
  , pv_old_last_update_date     DATE
  , pv_old_text_file_name       VARCHAR2
  , pv_new_item_id              NUMBER
  , pv_new_item_barcode         VARCHAR2
  , pv_new_item_type            NUMBER
  , pv_new_item_title           VARCHAR2
  , pv_new_item_subtitle        VARCHAR2
  , pv_new_item_rating          VARCHAR2
  , pv_new_item_rating_agency   VARCHAR2 
  , pv_new_item_release_date    DATE
  , pv_new_created_by           NUMBER 
  , pv_new_creation_date        DATE 
  , pv_new_last_updated_by      NUMBER
  , pv_new_last_update_date     DATE
  , pv_new_text_file_name       VARCHAR2 ) IS
  
  /* Declare local logger value. */
    lv_logger_id  NUMBER;

    /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Get a sequence. */
    lv_logger_id := logger_s.NEXTVAL;

    /* Set a savepoint. */
    SAVEPOINT starting;

    /* Insert log entry for an item. */
    INSERT INTO logger
    VALUES
    ( lv_logger_id
    , pv_old_item_id              
    , pv_old_item_barcode         
    , pv_old_item_type            
    , pv_old_item_title           
    , pv_old_item_subtitle        
    , pv_old_item_rating          
    , pv_old_item_rating_agency   
    , pv_old_item_release_date    
    , pv_old_created_by           
    , pv_old_creation_date        
    , pv_old_last_updated_by      
    , pv_old_last_update_date     
    , pv_old_text_file_name       
    , pv_new_item_id              
    , pv_new_item_barcode         
    , pv_new_item_type            
    , pv_new_item_title           
    , pv_new_item_subtitle        
    , pv_new_item_rating          
    , pv_new_item_rating_agency    
    , pv_new_item_release_date    
    , pv_new_created_by            
    , pv_new_creation_date         
    , pv_new_last_updated_by      
    , pv_new_last_update_date     
    , pv_new_text_file_name );

    /* Commit the independent write. */
    COMMIT;
--   EXCEPTION
--     /* Exception handler. */
--     WHEN OTHERS THEN
--       ROLLBACK TO starting;
--       RETURN;
  END item_insert;
  
  PROCEDURE item_insert
  ( pv_old_item_id              NUMBER
  , pv_old_item_barcode         VARCHAR2
  , pv_old_item_type            NUMBER
  , pv_old_item_title           VARCHAR2
  , pv_old_item_subtitle        VARCHAR2
  , pv_old_item_rating          VARCHAR2
  , pv_old_item_rating_agency   VARCHAR2
  , pv_old_item_release_date    DATE
  , pv_old_created_by           NUMBER
  , pv_old_creation_date        DATE
  , pv_old_last_updated_by      NUMBER
  , pv_old_last_update_date     DATE
  , pv_old_text_file_name       VARCHAR2 ) IS
 
 /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
    
 BEGIN
    /* Insert log entry for an item. */
    manage_item.item_insert(
        pv_old_item_id => pv_old_item_id            
      , pv_old_item_barcode => pv_old_item_barcode        
      , pv_old_item_type => pv_old_item_type           
      , pv_old_item_title => pv_old_item_title          
      , pv_old_item_subtitle => pv_old_item_subtitle   
      , pv_old_item_rating => pv_old_item_rating         
      , pv_old_item_rating_agency => pv_old_item_rating_agency  
      , pv_old_item_release_date => pv_old_item_release_date   
      , pv_old_created_by => pv_old_created_by          
      , pv_old_creation_date => pv_old_creation_date       
      , pv_old_last_updated_by => pv_old_last_updated_by      
      , pv_old_last_update_date => pv_old_last_update_date    
      , pv_old_text_file_name => pv_old_text_file_name      
      , pv_new_item_id => NULL              
      , pv_new_item_barcode => NULL       
      , pv_new_item_type => NULL          
      , pv_new_item_title => NULL         
      , pv_new_item_subtitle => NULL      
      , pv_new_item_rating => NULL         
      , pv_new_item_rating_agency => NULL  
      , pv_new_item_release_date => NULL  
      , pv_new_created_by => NULL          
      , pv_new_creation_date => NULL       
      , pv_new_last_updated_by => NULL     
      , pv_new_last_update_date => NULL  
      , pv_new_text_file_name => NULL);
--   EXCEPTION
--     /* Exception handler. */
--     WHEN OTHERS THEN
--      RETURN;
  END item_insert;   

END manage_item;
/
-- Display any compilation errors.
SHOW ERRORS  

DESC manage_item

-- Test that the overloaded insert_item procedures write the correct data to the logger table.
DECLARE
  /* Dynamic cursor. */
  CURSOR get_row IS
    SELECT * FROM item WHERE item_title = 'King Arthur';
BEGIN
  /* Read the dynamic cursor. */
  FOR i IN get_row LOOP
  
    manage_item.item_insert(
      pv_new_item_id => i.item_id              
      , pv_new_item_barcode => i.item_barcode       
      , pv_new_item_type => i.item_type          
      , pv_new_item_title => i.item_title || '-Inserted'        
      , pv_new_item_subtitle => i.item_subtitle      
      , pv_new_item_rating => i.item_rating         
      , pv_new_item_rating_agency => i.item_rating_agency  
      , pv_new_item_release_date => i.item_release_date  
      , pv_new_created_by => i.created_by          
      , pv_new_creation_date => i.creation_date       
      , pv_new_last_updated_by => i.last_updated_by     
      , pv_new_last_update_date => i.last_update_date  
      , pv_new_text_file_name => i.text_file_name);

  END LOOP;
END;
/

DECLARE
  /* Dynamic cursor. */
  CURSOR get_row IS
    SELECT * FROM item WHERE item_title = 'King Arthur';
BEGIN
  /* Read the dynamic cursor. */
  FOR i IN get_row LOOP
  
    manage_item.item_insert(
      pv_old_item_id => i.item_id            
      , pv_old_item_barcode => i.item_barcode        
      , pv_old_item_type => i.item_type           
      , pv_old_item_title => i.item_title          
      , pv_old_item_subtitle => i.item_subtitle   
      , pv_old_item_rating => i.item_rating         
      , pv_old_item_rating_agency => i.item_rating_agency  
      , pv_old_item_release_date => i.item_release_date   
      , pv_old_created_by => i.created_by          
      , pv_old_creation_date => i.creation_date       
      , pv_old_last_updated_by => i.last_updated_by      
      , pv_old_last_update_date => i.last_update_date    
      , pv_old_text_file_name => i.text_file_name      
      , pv_new_item_id => i.item_id              
      , pv_new_item_barcode => i.item_barcode       
      , pv_new_item_type => i.item_type          
      , pv_new_item_title => i.item_title || '-Changed'        
      , pv_new_item_subtitle => i.item_subtitle      
      , pv_new_item_rating => i.item_rating         
      , pv_new_item_rating_agency => i.item_rating_agency  
      , pv_new_item_release_date => i.item_release_date  
      , pv_new_created_by => i.created_by          
      , pv_new_creation_date => i.creation_date       
      , pv_new_last_updated_by => i.last_updated_by     
      , pv_new_last_update_date => i.last_update_date  
      , pv_new_text_file_name => i.text_file_name);

  END LOOP;
END;
/

DECLARE
  /* Dynamic cursor. */
  CURSOR get_row IS
    SELECT * FROM item WHERE item_title = 'King Arthur';
BEGIN
  /* Read the dynamic cursor. */
  FOR i IN get_row LOOP
  
    manage_item.item_insert(
      pv_old_item_id => i.item_id            
      , pv_old_item_barcode => i.item_barcode        
      , pv_old_item_type => i.item_type           
      , pv_old_item_title => i.item_title || '-Deleted'         
      , pv_old_item_subtitle => i.item_subtitle   
      , pv_old_item_rating => i.item_rating         
      , pv_old_item_rating_agency => i.item_rating_agency  
      , pv_old_item_release_date => i.item_release_date   
      , pv_old_created_by => i.created_by          
      , pv_old_creation_date => i.creation_date       
      , pv_old_last_updated_by => i.last_updated_by      
      , pv_old_last_update_date => i.last_update_date    
      , pv_old_text_file_name => i.text_file_name);

  END LOOP;
END;
/

/* Query the logger table. */
/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

-- Close log file.
SPOOL OFF
