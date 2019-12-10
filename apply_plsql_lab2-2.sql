/*
||  Name:          apply_plsql_lab2-2.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 3 lab.
||  Dependencies:  Run the Oracle Database 12c PL/SQL Programming setup programs.
*/

-- Open log file.
SPOOL apply_plsql_lab2-2.txt

 set echo on
 
 
-- ... insert your solution here ...


DECLARE 
lv_raw_input VARCHAR2(100);
lv_input VARCHAR2(10);

BEGIN
lv_raw_input := '&1';
lv_input := substr(lv_raw_input,1, 10);
dbms_output.put_line('[' || lv_raw_input || ']');

IF LENGTH(lv_raw_input) > 10 THEN 
 dbms_output.put_line('Hello''[' || lv_input || ']');
 ELSIF LENGTH(lv_raw_input) <= 10 THEN
 dbms_output.put_line('Hello' || lv_raw_input);
 ELSE 
dbms_output.put_line('Hello World');
    END IF; 
 END;
 /
 
  quit; 
-- Close log file.
SPOOL OFF
