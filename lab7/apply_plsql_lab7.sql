/*
||  Name:          apply_plsql_lab7.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 8 lab.
*/

-- Call seeding libraries.
@/home/student/Data/cit325/lib/cleanup_oracle.sql
@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab7.txt

-- Enter your solution here.

-- ------------------------------------------------------------------
--  Step #0
-- ------------------------------------------------------------------
UPDATE system_user
SET    system_user_name = 'DBA'
WHERE  system_user_name LIKE 'DBA%';

-- Update system_user_name
DECLARE
  /* Create a local counter variable. */
  lv_counter  NUMBER := 2;

  /* Create a collection of two-character strings. */
  TYPE numbers IS TABLE OF NUMBER;

  /* Create a variable of the roman_numbers collection. */
  lv_numbers  NUMBERS := numbers(1,2,3,4);

BEGIN
  /* Update the system_user names to make them unique. */
  FOR i IN 1..lv_numbers.COUNT LOOP
    /* Update the system_user table. */
    UPDATE system_user
    SET    system_user_name = system_user_name || ' ' || lv_numbers(i)
    WHERE  system_user_id = lv_counter;

    /* Increment the counter. */
    lv_counter := lv_counter + 1;
  END LOOP;
END;
/

-- Verify the update
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name LIKE 'DBA%';

BEGIN
  FOR i IN (SELECT uo.object_type
            ,      uo.object_name
            FROM   user_objects uo
            WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
    EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/

-- ------------------------------------------------------------------
--  Step #1
--  -------
--  Create an insert_contact definer rights procedure and test case.
-- ------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE insert_contact
  (pv_first_name             VARCHAR2
  ,pv_middle_name            VARCHAR2
  ,pv_last_name              VARCHAR2
  ,pv_contact_type           VARCHAR2
  ,pv_account_number         VARCHAR2
  ,pv_member_type            VARCHAR2
  ,pv_credit_card_number     VARCHAR2
  ,pv_credit_card_type       VARCHAR2
  ,pv_city                   VARCHAR2
  ,pv_state_province         VARCHAR2
  ,pv_postal_code            VARCHAR2
  ,pv_address_type           VARCHAR2
  ,pv_country_code           VARCHAR2
  ,pv_area_code              VARCHAR2
  ,pv_telephone_number       VARCHAR2
  ,pv_telephone_type         VARCHAR2
  ,pv_user_name              VARCHAR2 ) IS
  
-- You can declare a local variable as a constant by assigning it the sysdate value.  
  lv_creation_date  DATE := SYSDATE ;
  lv_created_by     NUMBER;
 
 -- Local variables, to leverage subquery assignments in INSERT statements.
  lv_address_type        VARCHAR2(30);
  lv_contact_type        VARCHAR2(30);
  lv_credit_card_type    VARCHAR2(30);
  lv_member_type         VARCHAR2(30);
  lv_telephone_type      VARCHAR2(30);
  
  
  CURSOR get_lookup_type 
  ( cv_table_name  VARCHAR2
  , cv_column_name VARCHAR2
  , cv_type_name   VARCHAR2 ) IS  
   SELECT common_lookup_id
      FROM   common_lookup
      WHERE  common_lookup_table = cv_table_name
      AND    common_lookup_column = cv_column_name 
      AND    common_lookup_type = cv_type_name ;

BEGIN

    /* Assign a value when a row exists. */
    FOR i IN get_lookup_type('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
      lv_member_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
      lv_credit_card_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
      lv_contact_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
      lv_address_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
      lv_telephone_type := i.common_lookup_id;
    END LOOP;

    SELECT system_user_id
    INTO   lv_created_by
    FROM   system_user
    WHERE  system_user_name = pv_user_name;
  
  -- Create a SAVEPOINT as a starting point.
  SAVEPOINT starting_point;
  
  INSERT INTO member
  ( member_id
  , member_type
  , account_number
  , credit_card_number
  , credit_card_type
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date )
  VALUES
  ( member_s1.NEXTVAL
  , lv_member_type
  , pv_account_number
  , pv_credit_card_number
  , lv_credit_card_type
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );

  INSERT INTO contact
  ( contact_id
  , member_id
  , contact_type
  , last_name
  , first_name
  , middle_name
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date)
  VALUES
  ( contact_s1.NEXTVAL
  , member_s1.CURRVAL
  , lv_contact_type
  , pv_last_name
  , pv_first_name
  , pv_middle_name
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date ); 

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  , lv_address_type
  , pv_city
  , pv_state_province
  , pv_postal_code
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );  

  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              
  , contact_s1.CURRVAL                                
  , address_s1.CURRVAL                                
  , lv_telephone_type
  , pv_country_code                                   
  , pv_area_code                        
  , pv_telephone_number                  
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );                          

  COMMIT;
-- EXCEPTION 
--   WHEN OTHERS THEN
--     ROLLBACK TO starting_point;
--     RETURN;
END insert_contact;
/

-- execute insert_contact('Charles','Francis','Xavier','CUSTOMER', 'SLC-000008', 'INDIVIDUAL','7777-6666-5555-4444','DISCOVER_CARD','Milbridge','Maine','04658','HOME','001','207','111-1234', 'HOME','DBA 2');

--You write an anonymous block PL/SQL program to test the insert_contact procedure.
BEGIN
  insert_contact
    ( 'Charles'
    , 'Francis'
    , 'Xavier'
    , 'CUSTOMER'
    , 'SLC-000008'
    , 'INDIVIDUAL'
    , '7777-6666-5555-4444'
    , 'DISCOVER_CARD'
    , 'Milbridge'
    , 'Maine'
    , '04658'
    , 'HOME'
    , '001'
    , '207'
    , '111-1234'
    , 'HOME'
    , 'DBA 2');
END;
/

-- Display any compilation errors.
SHOW ERRORS  

--Verify step #1
COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14

SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Xavier';


-- ---------------------------------------------------------------------------------------
--  Step #2
--  -------
--  Modify the definer rights insert_contact procedure to be invoker rights procedure. 
-- ---------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE insert_contact
  (pv_first_name             VARCHAR2
  ,pv_middle_name            VARCHAR2
  ,pv_last_name              VARCHAR2
  ,pv_contact_type           VARCHAR2
  ,pv_account_number         VARCHAR2
  ,pv_member_type            VARCHAR2
  ,pv_credit_card_number     VARCHAR2
  ,pv_credit_card_type       VARCHAR2
  ,pv_city                   VARCHAR2
  ,pv_state_province         VARCHAR2
  ,pv_postal_code            VARCHAR2
  ,pv_address_type           VARCHAR2
  ,pv_country_code           VARCHAR2
  ,pv_area_code              VARCHAR2
  ,pv_telephone_number       VARCHAR2
  ,pv_telephone_type         VARCHAR2
  ,pv_user_name              VARCHAR2 ) 
  AUTHID current_user IS
  
  PRAGMA autonomous_transaction;
  
-- You can declare a local variable as a constant by assigning it the sysdate value.  
  lv_creation_date  DATE := SYSDATE ;
  lv_created_by     NUMBER;
 
 -- Local variables, to leverage subquery assignments in INSERT statements.
  lv_address_type        VARCHAR2(30);
  lv_contact_type        VARCHAR2(30);
  lv_credit_card_type    VARCHAR2(30);
  lv_member_type         VARCHAR2(30);
  lv_telephone_type      VARCHAR2(30);
  
  
  CURSOR get_lookup_type 
  ( cv_table_name  VARCHAR2
  , cv_column_name VARCHAR2
  , cv_type_name   VARCHAR2 ) IS  
   SELECT common_lookup_id
      FROM   common_lookup
      WHERE  common_lookup_table = cv_table_name
      AND    common_lookup_column = cv_column_name 
      AND    common_lookup_type = cv_type_name ;

BEGIN

    /* Assign a value when a row exists. */
    FOR i IN get_lookup_type('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
      lv_member_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
      lv_credit_card_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
      lv_contact_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
      lv_address_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
      lv_telephone_type := i.common_lookup_id;
    END LOOP;

    SELECT system_user_id
    INTO   lv_created_by
    FROM   system_user
    WHERE  system_user_name = pv_user_name;
  
  -- Create a SAVEPOINT as a starting point.
  SAVEPOINT starting_point;
  
  INSERT INTO member
  ( member_id
  , member_type
  , account_number
  , credit_card_number
  , credit_card_type
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date )
  VALUES
  ( member_s1.NEXTVAL
  , lv_member_type
  , pv_account_number
  , pv_credit_card_number
  , lv_credit_card_type
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );

  INSERT INTO contact
  ( contact_id
  , member_id
  , contact_type
  , last_name
  , first_name
  , middle_name
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date)
  VALUES
  ( contact_s1.NEXTVAL
  , member_s1.CURRVAL
  , lv_contact_type
  , pv_last_name
  , pv_first_name
  , pv_middle_name
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date ); 

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  , lv_address_type
  , pv_city
  , pv_state_province
  , pv_postal_code
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );  

  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              
  , contact_s1.CURRVAL                                
  , address_s1.CURRVAL                                
  , lv_telephone_type
  , pv_country_code                                   
  , pv_area_code                        
  , pv_telephone_number                  
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );                          

  COMMIT;
-- EXCEPTION 
--   WHEN OTHERS THEN
--     ROLLBACK TO starting_point;
--     RETURN;
END insert_contact;
/

--You write an anonymous block PL/SQL program to test the insert_contact procedure.
BEGIN
  insert_contact
    ( 'Maura'
    , 'Jane'
    , 'Haggerty'
    , 'CUSTOMER'
    , 'SLC-000009'
    , 'INDIVIDUAL'
    , '8888-7777-6666-5555'
    , 'MASTER_CARD'
    , 'Bangor'
    , 'Maine'
    , '04401'
    , 'HOME'
    , '001'
    , '207'
    , '111-1234'
    , 'HOME'
    , 'DBA 2');
END;
/

-- Display any compilation errors.
SHOW ERRORS  

--Verify step #2

COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14

SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Haggerty';


-- -------------------------------------------------------------------------------------------------------
--  Step #3
--  -------
--  Create an autonomous definer rights insert_contact function by modifying the insert_contact procedure.
-- -------------------------------------------------------------------------------------------------------
DROP PROCEDURE insert_contact; 

BEGIN
  FOR i IN (SELECT uo.object_type
            ,      uo.object_name
            FROM   user_objects uo
            WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
    EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/


CREATE OR REPLACE FUNCTION insert_contact
  (pv_first_name         IN    VARCHAR2
  ,pv_middle_name        IN    VARCHAR2
  ,pv_last_name          IN    VARCHAR2
  ,pv_contact_type       IN    VARCHAR2
  ,pv_account_number     IN    VARCHAR2
  ,pv_member_type        IN    VARCHAR2
  ,pv_credit_card_number IN    VARCHAR2
  ,pv_credit_card_type   IN    VARCHAR2
  ,pv_city               IN    VARCHAR2
  ,pv_state_province     IN    VARCHAR2
  ,pv_postal_code        IN    VARCHAR2
  ,pv_address_type       IN    VARCHAR2
  ,pv_country_code       IN    VARCHAR2
  ,pv_area_code          IN    VARCHAR2
  ,pv_telephone_number   IN    VARCHAR2
  ,pv_telephone_type     IN    VARCHAR2
  ,pv_user_name          IN    VARCHAR2 ) 
  RETURN NUMBER IS
  
  lv_validation NUMBER;
  
-- You can declare a local variable as a constant by assigning it the sysdate value.  
  lv_creation_date  DATE := SYSDATE ;
  lv_created_by     NUMBER;
 
 -- Local variables, to leverage subquery assignments in INSERT statements.
  lv_address_type        VARCHAR2(30);
  lv_contact_type        VARCHAR2(30);
  lv_credit_card_type    VARCHAR2(30);
  lv_member_type         VARCHAR2(30);
  lv_telephone_type      VARCHAR2(30);
  
  
  CURSOR get_lookup_type 
  ( cv_table_name  VARCHAR2
  , cv_column_name VARCHAR2
  , cv_type_name   VARCHAR2 ) IS  
   SELECT common_lookup_id
      FROM   common_lookup
      WHERE  common_lookup_table = cv_table_name
      AND    common_lookup_column = cv_column_name 
      AND    common_lookup_type = cv_type_name ;

BEGIN

    /* Assign a value when a row exists. */
    FOR i IN get_lookup_type('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
      lv_member_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
      lv_credit_card_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
      lv_contact_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
      lv_address_type := i.common_lookup_id;
    END LOOP;
    
    FOR i IN get_lookup_type('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
      lv_telephone_type := i.common_lookup_id;
    END LOOP;

    SELECT system_user_id
    INTO   lv_created_by
    FROM   system_user
    WHERE  system_user_name = pv_user_name;
  
  -- Create a SAVEPOINT as a starting point.
  SAVEPOINT starting_point;
  
  INSERT INTO member
  ( member_id
  , member_type
  , account_number
  , credit_card_number
  , credit_card_type
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date )
  VALUES
  ( member_s1.NEXTVAL
  , lv_member_type
  , pv_account_number
  , pv_credit_card_number
  , lv_credit_card_type
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );

  INSERT INTO contact
  ( contact_id
  , member_id
  , contact_type
  , last_name
  , first_name
  , middle_name
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date)
  VALUES
  ( contact_s1.NEXTVAL
  , member_s1.CURRVAL
  , lv_contact_type
  , pv_last_name
  , pv_first_name
  , pv_middle_name
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date ); 

  INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  , lv_address_type
  , pv_city
  , pv_state_province
  , pv_postal_code
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );  

  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              
  , contact_s1.CURRVAL                                
  , address_s1.CURRVAL                                
  , lv_telephone_type
  , pv_country_code                                   
  , pv_area_code                        
  , pv_telephone_number                  
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date );          
  
  lv_validation := 0;
 
  COMMIT;
  
   RETURN lv_validation;
   
  EXCEPTION 
    WHEN OTHERS THEN
    ROLLBACK TO starting_point;
    lv_validation := 1;
    RETURN lv_validation;
    
END insert_contact;
/

-- Display any compilation errors.
SHOW ERRORS  

--Test function

DECLARE 
   lv_validation  NUMBER; 
BEGIN 
   lv_validation := insert_contact('Harriet','Mary','McDonnell','CUSTOMER','SLC-000010','INDIVIDUAL','9999-8888-7777-6666','VISA_CARD','Orono','Maine','04469','HOME','001','207','111-1234','HOME','DBA 2');
   
   IF lv_validation = 0 THEN
      dbms_output.put_line('Success!'); 
   ELSE
      dbms_output.put_line('Failure!');
   END IF;
END; 
/

--Verify Step #3
COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14

SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'McDonnell';
-- ----------------------------------------------------------------------------------------------------------------------
--  Step #4
--  -------
--  Create a contact_obj SQL data type, a contact_tab SQL collection data type, and a get_contact object table function.
-- ----------------------------------------------------------------------------------------------------------------------

--  Create a contact_obj SQL object type
CREATE OR REPLACE TYPE contact_obj IS OBJECT
( first_name     varchar2(20)
, middle_name    varchar2(20)
, last_name      varchar2(20));
/

-- Create a contact_tab SQL collection type
CREATE OR REPLACE TYPE contact_tab IS TABLE OF contact_obj;
/

--Create a get_contact object table function
CREATE OR REPLACE FUNCTION get_contact RETURN CONTACT_TAB IS

   -- Declare a counter variable
   lv_counter PLS_INTEGER := 1;
   -- Declare a collection variable (of the contact_tab list)
   lv_contact_tab CONTACT_TAB := contact_tab();
   -- Declare a non-parameterized cursor against the contact table
   CURSOR c IS
      SELECT first_name, middle_name, last_name
      FROM contact;
      
BEGIN
 
  FOR i IN c LOOP
    lv_contact_tab.EXTEND;
 
    lv_contact_tab(lv_counter) := contact_obj( i.first_name
                                             , i.middle_name
                                             , i.last_name );
 
    lv_counter := lv_counter + 1;
  END LOOP;
  
  RETURN lv_contact_tab;
END;
/

--Test function
SET PAGESIZE 999
COL full_name FORMAT A24
SELECT first_name || CASE
                       WHEN middle_name IS NOT NULL
                       THEN ' ' || middle_name || ' '
                       ELSE ' '
                     END || last_name AS full_name
FROM   TABLE(get_contact);

-- Close log file.
SPOOL OFF
