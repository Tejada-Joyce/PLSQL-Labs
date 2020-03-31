-- Create the sindar_t subtype by modeling its columns on the item table
CREATE OR REPLACE
  TYPE sindar_t UNDER elf_t
  ( elfkind                     VARCHAR2(30)
  , CONSTRUCTOR FUNCTION sindar_t
    ( elfkind                   VARCHAR2 ) RETURN SELF AS RESULT  
  , MEMBER FUNCTION get_elfkind RETURN VARCHAR2 
  , MEMBER PROCEDURE set_elfkind (elfkind VARCHAR2)
  , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

DESC sindar_t

-- Implement an sindar_t object body.
CREATE OR REPLACE
  TYPE BODY sindar_t IS

    /* Default constructor, implicitly available, but you should
       include it for those who forget that fact. */
    CONSTRUCTOR FUNCTION sindar_t
    ( elfkind                   VARCHAR2 ) RETURN SELF AS RESULT IS
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
      self.elfkind := elfkind;

      /* Return an instance of self. */
      RETURN;
    END;
    
    /* A getter function to return the elfkind attribute. */
    MEMBER FUNCTION get_elfkind RETURN VARCHAR2 IS
    BEGIN
      RETURN self.elfkind;
    END get_elfkind;

    /* A setter procedure to set the elfkind attribute. */
    MEMBER PROCEDURE set_elfkind
    ( elfkind VARCHAR2 ) IS
    BEGIN
      self.elfkind := elfkind;
    END set_elfkind;

    /* An overriding function for the generalized class. */
    OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
    BEGIN
      RETURN (self AS elf_t).to_string()||'['||self.elfkind||']';
    END to_string;
  END;
/

QUIT;
