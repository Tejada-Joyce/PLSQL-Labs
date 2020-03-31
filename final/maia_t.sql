-- Create the maia_t subtype by modeling its columns on the item table
CREATE OR REPLACE
  TYPE maia_t UNDER base_t
  ( name                        VARCHAR2(30)
  , genus                       VARCHAR2(30)
  , CONSTRUCTOR FUNCTION maia_t
    ( name                        VARCHAR2
    , genus                       VARCHAR2 ) RETURN SELF AS RESULT    
  , OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
  , MEMBER PROCEDURE set_name (name VARCHAR2)
  , MEMBER FUNCTION get_genus RETURN VARCHAR2 
  , MEMBER PROCEDURE set_genus (genus VARCHAR2)
  , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

DESC maia_t

-- Implement an maia_t object body.
CREATE OR REPLACE
  TYPE BODY maia_t IS

    /* Default constructor, implicitly available, but you should
       include it for those who forget that fact. */
    CONSTRUCTOR FUNCTION maia_t
    ( name             VARCHAR2
    , genus            VARCHAR2 ) RETURN SELF AS RESULT IS
    BEGIN
      /* Assign inputs to instance variables. */
      self.oid := oid;
      self.oname := oname;

      /* Assign a designated value or assign a null value. */
      IF name IS NOT NULL AND name IN ('NEW','OLD') THEN
        self.name := name;
      END IF;

      /* Assign inputs to instance variables. */
      self.genus := genus;

      /* Return an instance of self. */
      RETURN;
    END;
    
    /* A getter function to return the name attribute. */
    OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2 IS
    BEGIN
      RETURN self.name;
    END get_name;

    /* A setter procedure to set the oname attribute. */
    MEMBER PROCEDURE set_name
    ( name VARCHAR2 ) IS
    BEGIN
      self.name := name;
    END set_name;
    
    /* A getter function to return the genus attribute. */
    MEMBER FUNCTION get_genus RETURN VARCHAR2 IS
    BEGIN
      RETURN self.genus;
    END get_genus;

    /* A setter procedure to set the genus attribute. */
    MEMBER PROCEDURE set_genus
    ( genus VARCHAR2 ) IS
    BEGIN
      self.genus := genus;
    END set_genus;

    /* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS base_t).to_string()||'['||self.name||']'||'['||self.genus||']';
    END to_string;
  END;
/

QUIT;
