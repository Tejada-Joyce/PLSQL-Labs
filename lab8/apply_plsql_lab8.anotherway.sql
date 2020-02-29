/*
||  Name:          apply_plsql_lab8.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 9 lab.
*/
-- Call seeding libraries.
-- @/home/student/Data/cit325/lib/cleanup_oracle.sql
-- @/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

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


-- Open log file.
SPOOL apply_plsql_lab8.txt

-- Enter your solution here.

-- ------------------------------------------------------------------------
--  Step #1
--  -------
--  Create a contact_package package specification that holds overloaded 
--  insert_contact procedures.
-- ------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE contact_package IS
 PROCEDURE insert_contact
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
  ,pv_user_name              VARCHAR2 );
  
  PROCEDURE insert_contact
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
  ,pv_user_id                NUMBER := -1 );
END contact_package;
/

-- Display any compilation errors.
SHOW ERRORS  
-- ------------------------------------------------------------------------
--  Step #2
--  -------
--   Create a contact_package package body that implements two 
--   insert_contact procedures.
-- ------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY contact_package IS
 PROCEDURE insert_contact
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
  
  --  Create an lv_member_id variable with a NUMBER data type.
  lv_member_id      NUMBER := NULL;
 
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
      
 -- Create a get_member dynamic cursor against the member table that looks for a row by 
 -- checking whether the member.account_number equals pv_account_number parameter value.
  CURSOR get_member 
   ( cv_account_number  VARCHAR2 ) IS  
    SELECT m.member_id
       FROM   member m
       WHERE  m.account_number = cv_account_number ;

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

    FOR i IN get_member(pv_account_number) LOOP
      lv_member_id := i.member_id;
    END LOOP;
    
    SELECT system_user_id
    INTO   lv_created_by
    FROM   system_user
    WHERE  system_user_name = pv_user_name;
    
  
  -- Create a SAVEPOINT as a starting point.
  SAVEPOINT starting_point;
    -- Write a simple loop when determining whether the row exists in the member table; 
    -- and the simple loop should only insert a row into the member table when the %NOTFOUND condition is true
--     OPEN get_member(pv_account_number);
--     LOOP
--      FETCH get_member INTO lv_member_id;
--      IF  get_member%NOTFOUND THEN
     IF lv_member_id = NULL THEN  
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
     END IF;
--     END LOOP;
--     CLOSE get_member;
    
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
--     EXCEPTION 
--       WHEN OTHERS THEN
--         ROLLBACK TO starting_point;
--         RETURN;
 END insert_contact;

  -- Display any compilation errors.
  --SHOW ERRORS 

 PROCEDURE insert_contact
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
  ,pv_user_id                NUMBER := -1 ) IS
  
  -- You can declare a local variable as a constant by assigning it the sysdate value.  
  lv_creation_date  DATE := SYSDATE ;
  --  You should insert a -1 value for the created_by when a null value is passed to the pv_user_id parameter. 
  lv_created_by     NUMBER := NVL(pv_user_id,-1) ;
  
  --  Create an lv_member_id variable with a NUMBER data type.
  lv_member_id      NUMBER := NULL ;
 
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
      
 -- Create a get_member dynamic cursor against the member table that looks for a row by 
 -- checking whether the member.account_number equals pv_account_number parameter value.
  CURSOR get_member 
   ( cv_account_number  VARCHAR2 ) IS  
    SELECT m.member_id
       FROM   member m
       WHERE  m.account_number = cv_account_number ;

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
  
    FOR i IN get_member(pv_account_number) LOOP
      lv_member_id := i.member_id;
    END LOOP;  
  
  -- Create a SAVEPOINT as a starting point.
  SAVEPOINT starting_point;
    -- Write a simple loop when determining whether the row exists in the member table; 
    -- and the simple loop should only insert a row into the member table when the %NOTFOUND condition is true
--     OPEN get_member(pv_account_number);
--     LOOP
--      FETCH get_member INTO lv_member_id;
--      IF  get_member%NOTFOUND THEN
     IF lv_member_id = NULL THEN  
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
     END IF;
--     END LOOP;
--     CLOSE get_member;
    
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
--     EXCEPTION 
--       WHEN OTHERS THEN
--         ROLLBACK TO starting_point;
--         RETURN;
 END insert_contact;
 -- Display any compilation errors.
 --SHOW ERRORS 

END contact_package;
/
-- Display any compilation errors.
SHOW ERRORS  

--Insert new users
INSERT INTO system_user
  VALUES
  ( 6                              
  , 'BONDSB'                                
  , 1        
  , 1                       
  , 'Bonds'
  , 'Barry'                                 
  , 'L'                        
  , 1
  , SYSDATE
  , 1
  , SYSDATE );  
  
INSERT INTO system_user
  VALUES
  ( 7                              
  , 'CURRYW'                                
  , 1        
  , 1                        
  , 'Curry'
  , 'Wardell'                                 
  , 'S'                        
  , 1
  , SYSDATE
  , 1
  , SYSDATE );  
  
  INSERT INTO system_user
  VALUES
  ( -1                              
  , 'ANONYMOUS'                                
  , 1        
  , 1                        
  , NULL
  , NULL                                 
  , NULL                       
  , 1
  , SYSDATE
  , 1
  , SYSDATE );

-- Test the overloaded insert_contact procedures

BEGIN
  contact_package.insert_contact(
      pv_first_name => 'Charlie'
    , pv_middle_name => NULL
    , pv_last_name => 'Brown'
    , pv_contact_type => 'CUSTOMER'
    , pv_account_number => 'SLC-000011'
    , pv_member_type => 'GROUP'
    , pv_credit_card_number => '8888-6666-8888-4444'
    , pv_credit_card_type => 'VISA_CARD'
    , pv_city => 'Lehi'
    , pv_state_province => 'Utah'
    , pv_postal_code => '84043'
    , pv_address_type => 'HOME'
    , pv_country_code => '001'
    , pv_area_code => '207'
    , pv_telephone_number => '877-4321'
    , pv_telephone_type => 'HOME'
    , pv_user_name => 'DBA 3'
    );
END;
/

BEGIN
  contact_package.insert_contact(
      pv_first_name => 'Peppermint'
    , pv_middle_name => NULL
    , pv_last_name => 'Patty'
    , pv_contact_type => 'CUSTOMER'
    , pv_account_number => 'SLC-000011'
    , pv_member_type => 'GROUP'
    , pv_credit_card_number => '8888-6666-8888-4444'
    , pv_credit_card_type => 'VISA_CARD'
    , pv_city => 'Lehi'
    , pv_state_province => 'Utah'
    , pv_postal_code => '84043'
    , pv_address_type => 'HOME'
    , pv_country_code => '001'
    , pv_area_code => '207'
    , pv_telephone_number => '877-4321'
    , pv_telephone_type => 'HOME'
    );
END;
/

BEGIN
  contact_package.insert_contact(
      pv_first_name => 'Sally'
    , pv_middle_name => NULL
    , pv_last_name => 'Brown'
    , pv_contact_type => 'CUSTOMER'
    , pv_account_number => 'SLC-000011'
    , pv_member_type => 'GROUP'
    , pv_credit_card_number => '8888-6666-8888-4444'
    , pv_credit_card_type => 'VISA_CARD'
    , pv_city => 'Lehi'
    , pv_state_province => 'Utah'
    , pv_postal_code => '84043'
    , pv_address_type => 'HOME'
    , pv_country_code => '001'
    , pv_area_code => '207'
    , pv_telephone_number => '877-4321'
    , pv_telephone_type => 'HOME'
    , pv_user_id => '6'
    );
END;
/

--Verify inserts
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
WHERE  c.last_name IN ('Brown','Patty');

-- Close log file.
SPOOL OFF
