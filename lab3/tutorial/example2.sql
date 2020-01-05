SET VERIFY OFF
DECLARE
  /* Declare a collection of strings. */
  TYPE list IS TABLE OF VARCHAR2(10);

  argc     NUMBER := 3;
  counter  NUMBER := 1;

  /* Declare a variable of the string collection. */
  lv_strings  LIST := list();
BEGIN
  /* Assign values. */
  lv_strings.EXTEND(argc);
  FOR i IN 1..lv_strings.COUNT LOOP
    IF i = 1 THEN
      lv_strings(counter) := NVL('&1','');
    ELSIF i = 2 THEN
      lv_strings(counter) := NVL('&2','');
    ELSIF i = 3 THEN
      lv_strings(counter) := NVL('&3','');
    END IF;
    counter := counter + 1;
  END LOOP;

  FOR i IN 1..lv_strings.COUNT LOOP
    dbms_output.put_line('Debug ['||i||']['||lv_strings(i)||']');
  END LOOP;

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
