/*
||  Name:          apply_plsql_lab10.sql
||  Purpose:       Complete 325 Chapter 11 lab.
||  Dependencies:  Run the Oracle Database 12c PL/SQL Programming setup programs.
*/

SET NULL '<NULL>'
SET PAGESIZE 999
SET SERVEROUTPUT ON

CREATE OR REPLACE
TYPE base_t is OBJECT
    ( oname varchar2(30)
    , name varchar2(30)
    ,constructor function base_t
     return self as result
    , constructor function base_t
     (oname varchar2
     ,name  varchar2)
      RETURN SELF AS RESULT
      ,MEMBER FUNCTION get_name RETURN VARCHAR2
      ,MEMBER FUNCTION get_oname RETURN VARCHAR2
      ,MEMBER PROCEDURE set_oname (oname VARCHAR2)
      ,MEMBER FUNCTION to_string RETURN varchar2)
INSTANTIABLE NOT FINAL;
/

/*
Body
*/

CREATE OR REPLACE TYPE BODY base_t IS 

CONSTRUCTOR FUNCTION base_t RETURN SELF AS RESULT IS 
b BASE_T := base_t (oname => 'BASE_T'
		   ,name  => 'Base_t');
BEGIN 
self := b;
return;
end base_t;

CONSTRUCTOR FUNCTION base_t
(oname   varchar2
,name    varchar2) RETURN SELF AS RESULT IS 
b BASE_T;
   BEGIN
     self.oname := oname;
     self.name := name;
   RETURN;
   END base_t;

   MEMBER FUNCTION get_name return varchar2 is
   BEGIN
        RETURN self.name;
    end get_name;
   
   MEMBER FUNCTION get_oname return varchar2 is
   BEGIN
        RETURN self.oname;
    end get_oname;
    
     MEMBER PROCEDURE set_oname (oname varchar2) is
   BEGIN
        self.oname := oname;
    end set_oname;
   
     MEMBER FUNCTION to_string return varchar2 is
   BEGIN
        RETURN 'Object is ['||self.oname||']';
    end to_string;
    
    end;
   /


drop table logger;

create table logger
(logger_id number
,log_text base_t);

DECLARE
  /* Create a default instance of the object type. */
  lv_instance  BASE_T := base_t();
BEGIN
  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Default  : ['||lv_instance.get_oname()||']');
 
  /* Set the oname value to a new value. */
  lv_instance.set_oname('SUBSTITUTE');
 
  /* Print the default value of the oname attribute. */
  dbms_output.put_line('Override : ['||lv_instance.get_oname()||']');
END;
/

DECLARE
  /* Declare a variable of the UDT type. */
  lv_base  BASE_T;
BEGIN
  /* Assign an instance of the variable. */
  lv_base := base_t(
      oname => 'BASE_T'
    , name => 'NEW' );
 
    /* Insert instance of the base_t object type into table. */
    INSERT INTO logger
    VALUES (logger_s.NEXTVAL, lv_base);
 
    /* Commit the record. */
    COMMIT;
END;
/

INSERT INTO logger
VALUES (logger_s.NEXTVAL, base_t());

COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT t.logger_id
,      t.log.oname AS oname
,      NVL(t.log.get_name(),'Unset') AS get_name
,      t.log.to_string() AS to_string
FROM  (SELECT l.logger_id
       ,      TREAT(l.log_text AS base_t) AS log
       FROM   logger l) t
WHERE  t.log.oname = 'BASE_T';

create or replace type item_t UNDER base_t 
( ITEM_ID                NUMBER
, ITEM_BARCODE           VARCHAR2(20)
, ITEM_TYPE              NUMBER
, ITEM_TITLE             VARCHAR2(60)
, ITEM_SUBTITLE          VARCHAR2(60)
, ITEM_RATING            VARCHAR2(8)
, ITEM_RATING_AGENCY     VARCHAR2(4)
, ITEM_RELEASE_DATE      DATE
, CREATED_BY             NUMBER
, CREATION_DATE          DATE
, LAST_UPDATED_BY        NUMBER
, LAST_UPDATE_DATE       DATE
,CONSTRUCTOR FUNCTION item_t
( oname  varchar2
, name varchar2
, item_id number
, ITEM_BARCODE VARCHAR2
, ITEM_TYPE number
, ITEM_TITLE VARCHAR2
, ITEM_SUBTITLE VARCHAR2
, ITEM_RATING VARCHAR2
, ITEM_RATING_AGENCY VARCHAR2
, ITEM_RELEASE_DATE DATE
, CREATED_BY NUMBER
, CREATION_DATE DATE
, LAST_UPDATED_BY NUMBER
, LAST_UPDATE_DATE DATE) RETURN SELF AS RESULT
, OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
, OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
  INSTANTIABLE NOT FINAL;
/

desc item_t
CREATE OR REPLACE TYPE BODY item_t IS 

-- CONSTRUCTOR FUNCTION base_t RETURN SELF AS RESULT IS 
-- b BASE_T := base_t (oname => 'BASE_T'
-- 		   ,name  => 'Base_t');
-- BEGIN 
-- self := b;
-- return;
-- end base_t;

CONSTRUCTOR FUNCTION item_t
( oname  varchar2
, name varchar2
, item_id number
, ITEM_BARCODE VARCHAR2
, ITEM_TYPE number
, ITEM_TITLE VARCHAR2
, ITEM_SUBTITLE VARCHAR2
, ITEM_RATING VARCHAR2
, ITEM_RATING_AGENCY VARCHAR2
, ITEM_RELEASE_DATE DATE
, CREATED_BY NUMBER
, CREATION_DATE DATE
, LAST_UPDATED_BY NUMBER
, LAST_UPDATE_DATE DATE) RETURN SELF AS RESULT IS 
   BEGIN
     self.oname := oname;
     self.name := name;
     self.item_id := item_id;
     self.ITEM_BARCODE := ITEM_BARCODE;
     self.ITEM_TYPE := ITEM_TYPE;
     self.ITEM_TITLE := ITEM_TITLE; 
     self.ITEM_SUBTITLE := ITEM_SUBTITLE;
     self.ITEM_RATING := item_rating;
     self.ITEM_RATING_AGENCY := ITEM_RATING_AGENCY;
     self.ITEM_RELEASE_DATE := ITEM_RELEASE_DATE;
     self.CREATED_BY := CREATED_BY;
     self.CREATION_DATE := CREATION_DATE;
     self.LAST_UPDATED_BY := LAST_UPDATED_BY;
     self.LAST_UPDATE_DATE := LAST_UPDATE_DATE;
   RETURN;
   END;

   OVERRIDING MEMBER FUNCTION get_name return varchar2 is
   BEGIN
        RETURN (self as base_t).get_name();
    end get_name;
   
    OVERRIDING MEMBER FUNCTION to_string return varchar2 is
   BEGIN
        RETURN (SELF AS base_t).to_string() || '['||self.name||']';
    end to_string;
    
    end;
   /
   
   
   insert into logger
   values
   (logger_s.NEXTVAL
   , item_t(oname =>'ITEM_T'
           ,name => 'new'
           ,item_id => 1004
           ,ITEM_BARCODE => 'ASIN: B0002S64TQ'
           , ITEM_TYPE => 1013
           , ITEM_TITLE => 'Casino Royale'
           , ITEM_SUBTITLE => ''
           , ITEM_RATING => 'PG-13'
           , ITEM_RATING_AGENCY => 'MPAA'
           , ITEM_RELEASE_DATE => sysdate
           , CREATED_BY => 3
           , CREATION_DATE => sysdate
           , LAST_UPDATED_BY => 3
           , LAST_UPDATE_DATE => sysdate));

   
   create or replace type contact_t UNDER base_t 
( CONTACT_ID          NUMBER
 ,MEMBER_ID           NUMBER
 ,CONTACT_TYPE        NUMBER
 ,FIRST_NAME          VARCHAR2(60)
 ,MIDDLE_NAME         VARCHAR2(60)
 ,LAST_NAME           VARCHAR2(8)
 ,CREATED_BY          NUMBER
 ,CREATION_DATE       DATE
 ,LAST_UPDATED_by     NUMBER
 ,LAST_UPDATE_DATE    DATE
,CONSTRUCTOR FUNCTION contact_t
(oname varchar2, name varchar2 ,CONTACT_ID NUMBER ,MEMBER_ID NUMBER, CONTACT_TYPE NUMBER,FIRST_NAME VARCHAR2 ,MIDDLE_NAME VARCHAR2,LAST_NAME VARCHAR2 ,CREATED_BY NUMBER, CREATION_DATE DATE,LAST_UPDATED_by NUMBER,LAST_UPDATE_DATE DATE)
RETURN SELF AS RESULT
,OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
,OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2)
 INSTANTIABLE FINAL;
/

CREATE OR REPLACE TYPE BODY contact_t IS 

-- CONSTRUCTOR FUNCTION base_t RETURN SELF AS RESULT IS 
-- b BASE_T := base_t (oname => 'BASE_T'
-- 		   ,name  => 'Base_t');
-- BEGIN 
-- self := b;
-- return;
-- end base_t;

CONSTRUCTOR FUNCTION contact_t
(oname  varchar2, name varchar2, CONTACT_ID NUMBER ,MEMBER_ID NUMBER, CONTACT_TYPE NUMBER,FIRST_NAME VARCHAR2 ,MIDDLE_NAME VARCHAR2,LAST_NAME VARCHAR2 ,CREATED_BY NUMBER, CREATION_DATE DATE,LAST_UPDATED_by NUMBER,LAST_UPDATE_DATE DATE) RETURN SELF AS RESULT IS 
   BEGIN
     self.oname := oname;
     self.name := name;
     self.CONTACT_ID := CONTACT_ID;
     self.MEMBER_ID :=  MEMBER_ID;
     self.CONTACT_TYPE := CONTACT_TYPE;
     self.FIRST_NAME := FIRST_NAME; 
     self.MIDDLE_NAME := MIDDLE_NAME;
     self.LAST_NAME := LAST_NAME;
     self.CREATED_BY := CREATED_BY;
     self.CREATION_DATE := CREATION_DATE;
     self.LAST_UPDATED_BY := LAST_UPDATED_BY;
     self.LAST_UPDATE_DATE := LAST_UPDATE_DATE;
   RETURN;
   END contact_t;

   OVERRIDING MEMBER FUNCTION get_name return varchar2 is
   BEGIN
        RETURN (self as base_t).get_name();
    end get_name;
   
   
    OVERRIDING MEMBER FUNCTION to_string return varchar2 is
   BEGIN
        RETURN (SELF AS base_t).to_string || '['||self.name||']';
    end to_string;
    
    end;
   /


 insert into logger
   values
   (logger_s.NEXTVAL
   , contact_t(oname => 'CONTACT_T' , name => 'new', CONTACT_ID => 1001 ,MEMBER_ID => 1001, CONTACT_TYPE => 1003,FIRST_NAME => 'Randi' ,MIDDLE_NAME => '',LAST_NAME => 'Winn' ,CREATED_BY => 2, CREATION_DATE => sysdate,LAST_UPDATED_by => 2,LAST_UPDATE_DATE => sysdate));
   
   
   COLUMN oname     FORMAT A20
COLUMN get_name  FORMAT A20
COLUMN to_string FORMAT A20
SELECT t.logger_id
,      t.log.oname AS oname
,      t.log.get_name() AS get_name
,      t.log.to_string() AS to_string
FROM  (SELECT l.logger_id
       ,      TREAT(l.log_text AS base_t) AS log
       FROM   logger l) t
WHERE  t.log.oname IN ('CONTACT_T','ITEM_T');
   
-- Close log file.
SPOOL OFF
L 
show errors
