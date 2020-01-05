/*
||  Name:          example.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 10 lab.
*/

-- Open log file.
SPOOL example.txt

/* Unconditional drops of objects. */
DROP TABLE cart;
DROP SEQUENCE cart_s;
DROP TYPE pear_t FORCE;
DROP TYPE apple_t FORCE;
DROP TYPE fruit_t FORCE;

/* Create  base_t object type. */
CREATE OR REPLACE
  TYPE fruit_t IS OBJECT
  ( oname VARCHAR2(30)
  , name  VARCHAR2(30)
  , CONSTRUCTOR FUNCTION fruit_t RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION fruit_t
    ( oname  VARCHAR2
    , name   VARCHAR2 ) RETURN SELF AS RESULT
  , MEMBER FUNCTION get_name RETURN VARCHAR2
  , MEMBER FUNCTION get_oname RETURN VARCHAR2
  , MEMBER PROCEDURE set_oname (oname VARCHAR2)
  , MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

SHOW errors
DESC fruit_t

/* Create logger table. */
CREATE TABLE cart
( cart_id  NUMBER
, item     FRUIT_T );

/* Create logger_s sequence. */
CREATE SEQUENCE cart_s;

/* Describe logger table. */
DESC cart

/* Create base_t object body. */
CREATE OR REPLACE
  TYPE BODY fruit_t IS

    /* Override constructor. */
    CONSTRUCTOR FUNCTION fruit_t RETURN SELF AS RESULT IS
    BEGIN
      self.oname := 'FRUIT_T';
      RETURN;
    END;

    /* Formalized default constructor. */
    CONSTRUCTOR FUNCTION fruit_t
    ( oname  VARCHAR2
    , name   VARCHAR2 ) RETURN SELF AS RESULT IS
    BEGIN
      /* Assign an oname value. */
      self.oname := oname;

      RETURN;
    END;

    /* A getter function to return the name attribute. */
    MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN self.name;
    END get_name;

    /* A getter function to return the name attribute. */
    MEMBER FUNCTION get_oname RETURN VARCHAR2 IS
    BEGIN
      RETURN self.oname;
    END get_oname;

    /* A setter procedure to set the oname attribute. */
    MEMBER PROCEDURE set_oname
    ( oname VARCHAR2 ) IS
    BEGIN
      self.oname := oname;
    END set_oname;

    /* A to_string function. */
    MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN '['||self.oname||']';
    END to_string;
  END;
/

SET SERVEROUTPUT ON SIZE UNLIMITED

/* Anonymous block tests object type. */
DECLARE
  /* Create a default instance of the object type. */
  lv_instance  FRUIT_T := fruit_t();
BEGIN
  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Default  : ['||lv_instance.get_oname()||']');

  /* Set the oname value to a new value. */
  lv_instance.set_oname('SUBSTITUTE');

  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Override : ['||lv_instance.get_oname()||']');
END;
/

/* Insert an row into the table with a default base_t type. */
INSERT INTO cart
VALUES (cart_s.NEXTVAL, fruit_t());

INSERT INTO cart
VALUES
( cart_s.NEXTVAL
, fruit_t(
    oname => 'FRUIT_T'
  , name => 'NEW' ));

/* Test case - Insert and test a base_t type with two parameters. */
DECLARE
  /* Declare a variable of the UDT type. */
  lv_fruit  FRUIT_T;
BEGIN
  /* Assign an instance of the variable. */
  lv_fruit := fruit_t(
      oname => 'FRUIT_T'
    , name => 'OLD' );

    /* Insert instance of the base_t object type into table. */
    INSERT INTO cart
    VALUES (cart_s.NEXTVAL, lv_fruit);

    /* Commit the record. */
    COMMIT;
END;
/

/* Test the two rows inserted into the logger table. */
COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT g.cart_id
,      g.item.oname AS oname
,      NVL(g.item.get_name(),'Unset') AS get_name
,      g.item.to_string() AS to_string
FROM  (SELECT c.cart_id
       ,      TREAT(c.item AS fruit_t) AS item
       FROM   cart c) g
WHERE  g.item.oname = 'FRUIT_T';

/* Create or replace the item_t type. */
CREATE OR REPLACE
  TYPE apple_t UNDER fruit_t
  ( variety     VARCHAR2(20)
  , class_size  VARCHAR2(20)
  , CONSTRUCTOR FUNCTION apple_t
    ( oname       VARCHAR2
    , name        VARCHAR2
    , variety     VARCHAR2
    , class_size  VARCHAR2 ) RETURN SELF AS RESULT
  , OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
  , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

SHOW errors
DESC apple_t

/* Create or replace the item_t object body. */
CREATE OR REPLACE
  TYPE BODY apple_t IS

    /* Default constructor, implicitly available, but you should
       include it for those who forget that fact. */
    CONSTRUCTOR FUNCTION apple_t
    ( oname       VARCHAR2
    , name        VARCHAR2
    , variety     VARCHAR2
    , class_size  VARCHAR2 ) RETURN SELF AS RESULT IS
    BEGIN
      /* Assign inputs to instance variables. */    
      self.oname := oname;

      /* Assign a designated value or assign a null value. */
      IF name IS NOT NULL AND name IN ('NEW','OLD') THEN
        self.name := name;
      END IF;

      /* Assign inputs to instance variables. */  
      self.variety := variety;
      self.class_size := class_size;

      /* Return an instance of self. */
      RETURN;
    END;

    /* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS fruit_t).get_name();
    END get_name;

    /* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS fruit_t).to_string()||'.['||self.name||']';
    END to_string;
  END;
/

SHOW ERRORS
DESC apple_t

INSERT INTO cart
VALUES
( cart_s.NEXTVAL
, apple_t(
    oname => 'APPLE_T'
  , name => 'NEW' 
  , variety => 'PIPPIN'
  , class_size => 'MEDIUM'));

/* Test the two rows inserted into the logger table. */
COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT g.cart_id
,      g.item.oname AS oname
,      NVL(g.item.get_name(),'Unset') AS get_name
,      g.item.to_string() AS to_string
FROM  (SELECT c.cart_id
       ,      TREAT(c.item AS fruit_t) AS item
       FROM   cart c) g
WHERE  g.item.oname IN ('FRUIT_T','APPLE_T');

-- Close log file.
SPOOL OFF
