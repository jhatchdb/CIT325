/*
||  Name:          apply_plsql_lab12.sql
||  Purpose:       Complete 325 Chapter 13 lab.
||  Dependencies:  Run the Oracle Database 12c PL/SQL Programming setup programs.
*/


@@/home/student/Data/cit325/lib/cleanup_oracle.sql
@@/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab12.txt

DROP TYPE contact_obj FORCE;
DROP TYPE contact_tab FORCE;
DROP TYPE item_obj FORCE;
DROP TYPE item_tab FORCE;

CREATE OR REPLACE
  TYPE item_obj IS OBJECT
  ( title     VARCHAR2(60)
  , subtitle  VARCHAR2(60)
  , rating    VARCHAR2(8)
  , release_date DATE);
/

desc item_obj

CREATE OR REPLACE
  TYPE item_tab IS TABLE of item_obj;
/

CREATE OR REPLACE
  FUNCTION item_list
  ( pv_start_date varchar2 
   ,pv_end_date  date := (trunc(sysdate) + 1)) RETURN item_tab IS
 
    /* Declare a record type. */
    TYPE ITEM_rec IS RECORD
    ( TITLE VARCHAR2(60)
    ,SUBTITLE VARCHAR2(60)
    ,RATING VARCHAR2(8)
    ,RELEASE_DATE Date);
 
    /* Declare reference cursor for an NDS cursor. */
    item_cur   SYS_REFCURSOR;
 
    /* Declare a customer row for output from an NDS cursor. */
    item_row   ITEM_REC;
    item_set   ITEM_TAB := item_tab();
 
    /* Declare dynamic statement. */
    stmt  VARCHAR2(2000);
  BEGIN
    /* Create a dynamic statement. */
    stmt := 'SELECT item_title, item_subtitle, item_rating, item_release_date as release_date '
         || 'FROM   item '
         || 'WHERE  item_rating_agency = ''MPAA'' and item_release_date between :pv_start_date and :pv_end_date';
 
    /* Open and read dynamic cursor. */
    OPEN item_cur FOR stmt USING pv_start_date ,pv_end_date;
    LOOP
      /* Fetch the cursror into a customer row. */
      FETCH item_cur INTO item_row;
      EXIT WHEN item_cur%NOTFOUND;
 
      /* Extend space and assign a value collection. */      
      item_set.EXTEND;
      item_set(item_set.COUNT) :=
        item_obj( title  => item_row.title
                   , subtitle => item_row.subtitle
                   , rating   => item_row.rating
                   , release_date => item_row.release_date);
    END LOOP;
 
    /* Return customer set. */
    RETURN item_set;
  END item_list;
 /
L

 select il.title, il.rating 
 from TABLE(item_list('01-JAN-00')) il;
 L
 show errors

-- Close log file.
SPOOL OFF
