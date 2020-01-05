declare
  one varchar2(1);
begin
  one := &1;
  dbms_output.put_line('Hello '||one||'!');
exception
  when others then
    dbms_output.put_line('Caught an error.'||SQLERRM);
end;
/
