#!/bin/bash

# Remove file from system.
find . -name apply_plsql_lab3.txt -exec rm -f {} \;

# Create log file with header information.
echo 'Log: apply_plsql_lab3.txt' >> apply_plsql_lab3.txt
echo '==================================================' >> apply_plsql_lab3.txt

# Call script file with a valid number, string, and null value for date.
echo 'Test Case: Valid number, string, null             '  >> apply_plsql_lab3.txt
echo '--------------------------------------------------' >> apply_plsql_lab3.txt
sqlplus -s student/student @apply_plsql_lab3.sql 38 catch22 '' 2>/dev/null |
while IFS='\n' read msg; do
  echo $msg >> apply_plsql_lab3.txt
done

# Call script file with a valid number, string, and date.
echo '==================================================' >> apply_plsql_lab3.txt
echo 'Test Case: Valid number, string, and date         ' >> apply_plsql_lab3.txt
echo '--------------------------------------------------' >> apply_plsql_lab3.txt
sqlplus -s student/student @apply_plsql_lab3.sql 41 aerodromes '13-OCT-1307' 2>/dev/null |
while IFS='\n' read msg; do
  echo $msg >> apply_plsql_lab3.txt
done

# Call script file with a valid number, string, and invalid date.
echo '==================================================' >> apply_plsql_lab3.txt
echo 'Test Case: Valid number, string, and invalid date ' >> apply_plsql_lab3.txt
echo '--------------------------------------------------' >> apply_plsql_lab3.txt
sqlplus -s student/student @apply_plsql_lab3.sql '31-APR-2017' dagger 81 2>/dev/null |
while IFS='\n' read msg; do
  echo $msg >> apply_plsql_lab3.txt
done
echo '==========================================' >> apply_plsql_lab3.txt
