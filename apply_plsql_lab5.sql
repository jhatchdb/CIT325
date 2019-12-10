/*
||  Name:          apply_plsql_lab5.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 6 lab.
||  Dependencies:  Run the Oracle Database 12c PL/SQL Programming setup programs.
*/

@@/home/student/Data/cit325/lib/cleanup_oracle.sql
@@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab5.log

-- Create the table --
CREATE SEQUENCE rating_agency_s6 start with 1001; 

CREATE TABLE rating_agency AS
  SELECT rating_agency_s6.NEXTVAL AS rating_agency_id
  ,      il.item_rating AS rating
  ,      il.item_rating_agency AS rating_agency
  FROM  (SELECT DISTINCT
                i.item_rating
         ,      i.item_rating_agency
         FROM   item i) il;

-- Add column --
ALTER TABLE item ADD rating_agency_id NUMBER;

-- Drop in case -- 
DROP TYPE ra;
 
-- create the object --
create or replace 
type ra is OBJECT
(rating_agency_id   number 
,rating             VARCHAR2(8)
,rating_agency      VARCHAR2(4));
/

create or replace type rating_agencies is table of ra;
/ 

-- Anon Block--
DECLARE 
 CURSOR c IS SELECT * FROM rating_agency;
lv_ra rating_agencies := rating_agencies();

BEGIN  
  FOR i IN c  LOOP 
    lv_ra.extend;
    lv_ra(lv_ra.last) := ra(i.rating_agency_id, i.rating, i.rating_agency);
    END LOOP;
    
    for i in 1..lv_ra.LAST LOOP
        UPDATE item SET rating_agency_id = lv_ra(i).rating_agency_id
        WHERE item_rating = lv_ra(i).rating
        and item_rating_agency = lv_ra(i).rating_agency;
        end loop;

   end;
   /
        
        
-- Validation Query --        
        SET NULL ''
COLUMN table_name   FORMAT A18
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'ITEM'
ORDER BY 2;

-- Validation Query --

SELECT   rating_agency_id
,        COUNT(*)
FROM     item
WHERE    rating_agency_id IS NOT NULL
GROUP BY rating_agency_id
ORDER BY 1;
        
        
-- Close log file.
SPOOL OFF
quit;
