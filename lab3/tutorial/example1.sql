DECLARE
  /* Declare a collection of strings. */
  TYPE list IS TABLE OF VARCHAR2(10);

  /* Declare a variable of the string collection. */
  lv_strings  LIST := list();
BEGIN
  /* Assign values. */
  lv_strings.EXTEND;
  lv_strings(lv_strings.COUNT) := NVL('&1','');
  /* Loop through list of values to find only the numbers. */
  FOR i IN 1..lv_strings.COUNT LOOP
    dbms_output.put_line('Debug 1 ['||i||']');
    IF REGEXP_LIKE(lv_strings(i),'^[[:digit:]]*$') THEN
      dbms_output.put_line('Debug 2 ['||i||']');
      dbms_output.put_line('Print number ['||lv_strings(i)||']');
    ELSE
      dbms_output.put_line('Debug 3 ['||i||']');
    END IF;
  END LOOP;
END;
/

-- Exit sqlplus.
QUIT;
