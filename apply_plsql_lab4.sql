/*
||  Name:          apply_plsql_lab4.sql
||  Purpose:       Complete 325 Chapter 5 lab.
||  Dependencies:  Run the Oracle Database 12c PL/SQL Programming setup programs.
*/
@@/home/student/Data/cit325/lib/cleanup_oracle.sql
-- Open log file.
SPOOL apply_plsql_lab4.log

-- ... insert your solution here ...
DECLARE 
TYPE DAY_NUM is ta                                                                                                                                                                                    ble of varchar2(8);
TYPE GIFT is table of varchar(24);
  days DAY_NUM := DAY_NUM('first', 'second', 'third', 'fourth', 'fifth','sixth','seventh','eigth','ninth','tenth','eleventh','twelth');
  gifts GIFT := GIFT('Partridge in a pear tree', 'Two Turtle doves', 'Three French hens', 'Four Calling birds', 'Five Golden rings', 'Six Geese a laying', 'Seven Swans a swimming', 'Eight Maids a milking', 'Nine Ladies dancing', 'Ten Lords a leaping', 'Eleven Pipers piping', 'Twelve Drummers drumming');
  append varchar2(8) := '';
BEGIN 
    For i in 1..days.last LOOP
        dbms_output.put_line('On the ' || days(i) || ' day of christmas');
        dbms_output.put_line('my true love sent to me:');
     for j in reverse 1..i loop
     if j = 1 then
        if i = 1 then 
           append := 'A ';
        else
          append:= 'and a ';
        end if; 
       else 
       append:= '';
        end if; 
     dbms_output.put_line('-'||append||gifts(j));
     end loop;
     dbms_output.put_line(CHR(13));
     end loop;
     end;
     /
-- Close log file.
SPOOL OFF

quit; 
