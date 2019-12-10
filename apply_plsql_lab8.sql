/*
||  Name:          apply_plsql_lab8.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 9 lab.
||  Dependencies:  Run the Oracle Database 12c PL/SQL Programming setup programs.
*/

@@/home/student/Data/cit325/lab7/apply_plsql_lab7.sql
-- Open log file.
SPOOL apply_plsql_lab8.txt

-- step 0 
/* Show all 4 DBAs if they have the same name*/
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name = 'DBA';

/* Change all 4 DBAs back to DBA if they are different*/
UPDATE system_user
SET    system_user_name = 'DBA'
WHERE  system_user_name LIKE 'DBA%';

/* Change DBAs to DBA1-4 to be different*/
DECLARE
  /* Create a local counter variable. */
  lv_counter  NUMBER :=2 ;
 
  /* Create a collection of two-character strings. */
  TYPE numbers IS TABLE OF NUMBER;
 
  /* Create a variable of the roman_numbers collection. */
  lv_numbers  NUMBERS := numbers(1,2,3,4);
 
BEGIN
  /* Update the system_user names to make them unique. */
  FOR i IN 1..lv_numbers.COUNT LOOP
    /* Update the system_user table. */
    UPDATE system_user
    SET    system_user_name = system_user_name || ' ' || lv_numbers(i)
    WHERE  system_user_id = lv_counter;
 
    /* Increment the counter. */
    lv_counter := lv_counter + 1;
  END LOOP;
END;
/

/* Show new different DBAs */
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name LIKE 'DBA%';

/* Drop existing objects */
BEGIN
  FOR i IN (SELECT uo.object_type
            ,      uo.object_name
            FROM   user_objects uo
            WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
    EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/


-- Step 1

drop procedure INSERT_CONTACT;

create or replace package contact_package as

PROCEDURE INSERT_CONTACT
(PV_FIRST_NAME           varchar2
,PV_MIDDLE_NAME          varchar2 := ''
,PV_LAST_NAME            varchar2
,PV_CONTACT_TYPE         varchar2
,PV_ACCOUNT_NUMBER       varchar2
,PV_MEMBER_TYPE          varchar2
,PV_CREDIT_CARD_NUMBER   varchar2
,PV_CREDIT_CARD_TYPE     varchar2
,PV_CITY                 varchar2
,PV_STATE_PROVINCE       varchar2    
,PV_POSTAL_CODE          varchar2
,PV_ADDRESS_TYPE         varchar2
,PV_COUNTRY_CODE         varchar2
,PV_AREA_CODE            varchar2
,PV_TELEPHONE_NUMBER     varchar2
,PV_TELEPHONE_TYPE       varchar2
,PV_USER_NAME            varchar2 :='ANONYMOUS');

PROCEDURE INSERT_CONTACT
(PV_FIRST_NAME           varchar2
,PV_MIDDLE_NAME          varchar2 := ''
,PV_LAST_NAME            varchar2
,PV_CONTACT_TYPE         varchar2
,PV_ACCOUNT_NUMBER       varchar2
,PV_MEMBER_TYPE          varchar2
,PV_CREDIT_CARD_NUMBER   varchar2
,PV_CREDIT_CARD_TYPE     varchar2
,PV_CITY                 varchar2
,PV_STATE_PROVINCE       varchar2    
,PV_POSTAL_CODE          varchar2
,PV_ADDRESS_TYPE         varchar2
,PV_COUNTRY_CODE         varchar2
,PV_AREA_CODE            varchar2
,PV_TELEPHONE_NUMBER     varchar2
,PV_TELEPHONE_TYPE       varchar2
,PV_USER_ID              number := -1);


end contact_package;
/

-- Step 1

desc contact_package;

create or replace package body contact_package as

PROCEDURE INSERT_CONTACT
(PV_FIRST_NAME           varchar2
,PV_MIDDLE_NAME          varchar2 := ''
,PV_LAST_NAME            varchar2
,PV_CONTACT_TYPE         varchar2
,PV_ACCOUNT_NUMBER       varchar2
,PV_MEMBER_TYPE          varchar2
,PV_CREDIT_CARD_NUMBER   varchar2
,PV_CREDIT_CARD_TYPE     varchar2
,PV_CITY                 varchar2
,PV_STATE_PROVINCE       varchar2    
,PV_POSTAL_CODE          varchar2
,PV_ADDRESS_TYPE         varchar2
,PV_COUNTRY_CODE         varchar2
,PV_AREA_CODE            varchar2
,PV_TELEPHONE_NUMBER     varchar2
,PV_TELEPHONE_TYPE       varchar2
,PV_USER_NAME            varchar2 := 'ANONYMOUS') is 
LV_ADDRESS_TYPE         varchar2(30);
LV_CONTACT_TYPE         varchar2(30);
LV_CREDIT_CARD_TYPE     varchar2(30);
LV_MEMBER_TYPE          varchar2(30);
LV_TELEPHONE_TYPE       varchar2(30);
LV_MEMBER_ID            number;
LV_SYSTEM_USER_ID       number; 
LV_USER_NAME     VARCHAR2(20); 


CURSOR get_type(cv_table_name  VARCHAR2
               ,cv_column_name VARCHAR2
               ,cv_lookup_type VARCHAR2) IS
               SELECT common_lookup_id
               FROM common_lookup
               WHERE common_lookup_table  = cv_table_name
               AND   common_lookup_column = cv_column_name
               AND   common_lookup_type   = cv_lookup_type;
        
        
        cursor get_member
        (cv_member_account_number VARCHAR2) is 
        select MEMBER_ID
        from   Member
        where account_number = cv_member_account_number;
         
        
        BEGIN
        IF PV_USER_NAME is NULL THEN 
        LV_USER_NAME := 'ANONYMOUS';
        else 
        LV_USER_NAME := PV_USER_NAME;
        end if; 
        
        FOR i IN get_type('MEMBER', 'MEMBER_TYPE', PV_MEMBER_TYPE) LOOP
    lv_member_type := i.common_lookup_id;
    end loop;
    FOR i IN get_type('CONTACT', 'CONTACT_TYPE', PV_CONTACT_TYPE) LOOP
    lv_contact_type := i.common_lookup_id;
    END LOOP;
    FOR i IN get_type('ADDRESS', 'ADDRESS_TYPE', PV_ADDRESS_TYPE) LOOP
    lv_address_type := i.common_lookup_id;
    end loop;
    FOR i IN get_type('TELEPHONE', 'TELEPHONE_TYPE', PV_TELEPHONE_TYPE) LOOP
    lv_telephone_type := i.common_lookup_id;
    END LOOP;
    FOR i IN get_type('MEMBER', 'CREDIT_CARD_TYPE', PV_CREDIT_CARD_TYPE) LOOP
    lv_credit_card_type := i.common_lookup_id;
    END LOOP;


select system_user_id
into LV_USER_NAME
from system_user
where system_user_name = pv_user_name;


SAVEPOINT starting_point;

    OPEN get_member(pv_account_number);
 FETCH get_member into lv_member_id;
 IF get_member%notfound then
lv_member_id := member_s1.NEXTVAL;
    
    
    INSERT INTO member
    VALUES
    ( LV_MEMBER_ID
    , lv_member_type
    , pv_account_number
    , pv_credit_card_number
    , lv_credit_card_type
    ,  LV_USER_NAME
    , SYSDATE
    ,  LV_USER_NAME
    , SYSDATE );
end if;
close get_member;

  INSERT INTO contact
    VALUES
  (contact_s1.NEXTVAL
  , lv_member_id
  , lv_contact_type
  , pv_last_name
  , pv_first_name
  , pv_middle_name
  ,  LV_USER_NAME
  , SYSDATE
  ,  LV_USER_NAME
  , SYSDATE);  

INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  ,lv_address_type
  , pv_city
  , pv_state_province
  , pv_postal_code
  , LV_USER_NAME
  , SYSDATE
  ,  LV_USER_NAME
  , SYSDATE );  

 
  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              -- TELEPHONE_ID
  , contact_s1.CURRVAL                                -- CONTACT_ID
  , address_s1.CURRVAL                                -- ADDRESS_ID
  , lv_telephone_type
  , pv_country_code                                   -- COUNTRY_CODE
  , pv_area_code                                      -- AREA_CODE
  , pv_telephone_number                               -- TELEPHONE_NUMBER
  , LV_USER_NAME                                 -- CREATED_BY
  , SYSDATE                                           -- CREATION_DATE
  , LV_USER_NAME                                 -- LAST_UPDATED_BY
  , SYSDATE);                                         -- LAST_UPDATE_DATE

  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line(SQLERRM);
    RETURN;
    end INSERT_CONTACT;
  
PROCEDURE INSERT_CONTACT
(PV_FIRST_NAME           varchar2
,PV_MIDDLE_NAME          varchar2 := ''
,PV_LAST_NAME            varchar2
,PV_CONTACT_TYPE         varchar2
,PV_ACCOUNT_NUMBER       varchar2
,PV_MEMBER_TYPE          varchar2
,PV_CREDIT_CARD_NUMBER   varchar2
,PV_CREDIT_CARD_TYPE     varchar2
,PV_CITY                 varchar2
,PV_STATE_PROVINCE       varchar2    
,PV_POSTAL_CODE          varchar2
,PV_ADDRESS_TYPE         varchar2
,PV_COUNTRY_CODE         varchar2
,PV_AREA_CODE            varchar2
,PV_TELEPHONE_NUMBER     varchar2
,PV_TELEPHONE_TYPE       varchar2
,PV_USER_ID              number := -1) is 
LV_ADDRESS_TYPE         varchar2(30);
LV_CONTACT_TYPE         varchar2(30);
LV_CREDIT_CARD_TYPE     varchar2(30);
LV_MEMBER_TYPE          varchar2(30);
LV_TELEPHONE_TYPE       varchar2(30);
LV_MEMBER_ID            number;
LV_USER_NAME            VARCHAR2(30);
lv_current_date         date := SYSDATE;


CURSOR get_type(cv_table_name  VARCHAR2
               ,cv_column_name VARCHAR2
               ,cv_lookup_type VARCHAR2) IS
               SELECT common_lookup_id
               FROM common_lookup
               WHERE common_lookup_table  = cv_table_name
               AND   common_lookup_column = cv_column_name
               AND   common_lookup_type   = cv_lookup_type;
        
        
        cursor get_member
        (cv_member_account_number VARCHAR2) is 
        select MEMBER_ID
        from   Member
        where account_number = cv_member_account_number;
         
        
        BEGIN
        
        
        FOR i IN get_type('MEMBER', 'MEMBER_TYPE', PV_MEMBER_TYPE) LOOP
    lv_member_type := i.common_lookup_id;
    end loop;
    FOR i IN get_type('CONTACT', 'CONTACT_TYPE', PV_CONTACT_TYPE) LOOP
    lv_contact_type := i.common_lookup_id;
    END LOOP;
    FOR i IN get_type('ADDRESS', 'ADDRESS_TYPE', PV_ADDRESS_TYPE) LOOP
    lv_address_type := i.common_lookup_id;
    end loop;
    FOR i IN get_type('TELEPHONE', 'TELEPHONE_TYPE', PV_TELEPHONE_TYPE) LOOP
    lv_telephone_type := i.common_lookup_id;
    END LOOP;
    FOR i IN get_type('MEMBER', 'CREDIT_CARD_TYPE', PV_CREDIT_CARD_TYPE) LOOP
    lv_credit_card_type := i.common_lookup_id;
    END LOOP;



LV_USER_NAME := PV_USER_ID;


SAVEPOINT starting_point;

  OPEN get_member(pv_account_number);
 FETCH get_member into lv_member_id;
 IF get_member%notfound then
lv_member_id := member_s1.NEXTVAL;
    
    INSERT INTO member
    VALUES
    ( LV_MEMBER_ID
    , lv_member_type
    , pv_account_number
    , pv_credit_card_number
    , lv_credit_card_type
    ,  LV_USER_NAME
    , SYSDATE
    ,  LV_USER_NAME
    , SYSDATE );
end if;
close get_member;

    INSERT INTO contact
    VALUES
  (contact_s1.NEXTVAL
  , lv_member_id
  , lv_contact_type
  , pv_last_name
  , pv_first_name
  , pv_middle_name
  ,  LV_USER_NAME
  , SYSDATE
  ,  LV_USER_NAME
  , SYSDATE);  

INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  ,lv_address_type
  , pv_city
  , pv_state_province
  , pv_postal_code
  , LV_USER_NAME
  , SYSDATE
  ,  LV_USER_NAME
  , SYSDATE );  

 
  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              -- TELEPHONE_ID
  , contact_s1.CURRVAL                                -- CONTACT_ID
  , address_s1.CURRVAL                                -- ADDRESS_ID
  , lv_telephone_type
  , pv_country_code                                   -- COUNTRY_CODE
  , pv_area_code                                      -- AREA_CODE
  , pv_telephone_number                               -- TELEPHONE_NUMBER
  , LV_USER_NAME                                 -- CREATED_BY
  , SYSDATE                                           -- CREATION_DATE
  , LV_USER_NAME                                 -- LAST_UPDATED_BY
  , SYSDATE);                            -- LAST_UPDATE_DATE

   COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line(SQLERRM);
    RETURN;
    end INSERT_CONTACT;
    
end contact_package;
/



--step 2



iNSERT INTO system_user
VALUES ( 6,'BONDSB',1,1001,'Bonds','Barry','L',1,SYSDATE,1,SYSDATE);
INSERT INTO system_user
VALUES ( 7,'OWENSR',1,1001,'Curry','Wardell','S',1,SYSDATE,1,SYSDATE);
INSERT INTO system_user 
VALUES ( -1,'ANONYMOUS',1,1001,'','','',1,SYSDATE,1,SYSDATE); 
-- -- Commit inserted records.
COMMIT;


COL system_user_id  FORMAT 9999  HEADING "System|User ID"
COL system_user_name FORMAT A12  HEADING "System|User Name"
COL first_name       FORMAT A10  HEADING "First|Name"
COL middle_initial   FORMAT A2   HEADING "MI"
COL last_name        FORMAT A10  HeADING "Last|Name"
SELECT system_user_id
,   system_user_name
,   first_name
,   middle_initial
,   last_name
FROM   system_user
WHERE  last_name IN ('Bonds','Curry')
OR     system_user_name = 'ANONYMOUS';


BEGIN
contact_package.insert_contact
( pv_first_name => 'Charlie'
, pv_middle_name => ''
, pv_last_name => 'Brown'
, pv_contact_type => 'CUSTOMER'
, pv_account_number => 'SLC-000011'
, pv_member_type => 'GROUP'
, pv_credit_card_number => '8888-6666-8888-4444'
, pv_credit_card_type => 'VISA_CARD'
, pv_city => 'Lehi'
, pv_state_province => 'Utah'
, pv_postal_code => '84043'
, pv_address_type => 'HOME'
, pv_country_code => '001'
, pv_area_code => '207'
, pv_telephone_number => '877-4321'
, pv_telephone_type => 'HOME'
, pv_user_name => 'DBA 3');
dbms_output.put_line('thumbs up');
END;
/

BEGIN
contact_package.insert_contact
( pv_first_name => 'Peppermint'
, pv_middle_name => ''
, pv_last_name => 'Patty'
, pv_contact_type => 'CUSTOMER'
, pv_account_number => 'SLC-000011'
, pv_member_type => 'GROUP'
, pv_credit_card_number => '8888-6666-8888-4444'
, pv_credit_card_type => 'VISA_CARD'
, pv_city => 'Lehi'
, pv_state_province => 'Utah'
, pv_postal_code => '84043'
, pv_address_type => 'HOME'
, pv_country_code => '001'
, pv_area_code => '207'
, pv_telephone_number => '877-4321'
, pv_telephone_type => 'HOME'
, pv_user_id => -1);
dbms_output.put_line('thumbs up');
END;
/

BEGIN
contact_package.insert_contact
( pv_first_name => 'Sally'
, pv_middle_name => ''
, pv_last_name => 'Brown'
, pv_contact_type => 'CUSTOMER'
, pv_account_number => 'SLC-000011'
, pv_member_type => 'GROUP'
, pv_credit_card_number => '8888-6666-8888-4444'
, pv_credit_card_type => 'VISA_CARD'
, pv_city => 'Lehi'
, pv_state_province => 'Utah'
, pv_postal_code => '84043'
, pv_address_type => 'HOME'
, pv_country_code => '001'
, pv_area_code => '207'
, pv_telephone_number => '877-4321'
, pv_telephone_type => 'HOME'
, pv_user_id => 6);
dbms_output.put_line('thumbs up'); 
END;
/


COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14

SELECT c.first_name
||     CASE
WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
      END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name IN ('Brown','Patty');




--step 3
drop package contact_package;

create or replace package contact_package as

function INSERT_CONTACT
(PV_FIRST_NAME           varchar2
,PV_MIDDLE_NAME          varchar2 := ''
,PV_LAST_NAME            varchar2
,PV_CONTACT_TYPE         varchar2
,PV_ACCOUNT_NUMBER       varchar2
,PV_MEMBER_TYPE          varchar2
,PV_CREDIT_CARD_NUMBER   varchar2
,PV_CREDIT_CARD_TYPE     varchar2
,PV_CITY                 varchar2
,PV_STATE_PROVINCE       varchar2    
,PV_POSTAL_CODE          varchar2
,PV_ADDRESS_TYPE         varchar2
,PV_COUNTRY_CODE         varchar2
,PV_AREA_CODE            varchar2
,PV_TELEPHONE_NUMBER     varchar2
,PV_TELEPHONE_TYPE       varchar2
,PV_USER_NAME            varchar2 :='') return number;

function INSERT_CONTACT
(PV_FIRST_NAME           varchar2
,PV_MIDDLE_NAME          varchar2 := ''
,PV_LAST_NAME            varchar2
,PV_CONTACT_TYPE         varchar2
,PV_ACCOUNT_NUMBER       varchar2
,PV_MEMBER_TYPE          varchar2
,PV_CREDIT_CARD_NUMBER   varchar2
,PV_CREDIT_CARD_TYPE     varchar2
,PV_CITY                 varchar2
,PV_STATE_PROVINCE       varchar2    
,PV_POSTAL_CODE          varchar2
,PV_ADDRESS_TYPE         varchar2
,PV_COUNTRY_CODE         varchar2
,PV_AREA_CODE            varchar2
,PV_TELEPHONE_NUMBER     varchar2
,PV_TELEPHONE_TYPE       varchar2
,PV_USER_ID              number := -1) return number;


end contact_package;
/


create or replace package body contact_package as

function INSERT_CONTACT
(PV_FIRST_NAME           varchar2
,PV_MIDDLE_NAME          varchar2 := ''
,PV_LAST_NAME            varchar2
,PV_CONTACT_TYPE         varchar2
,PV_ACCOUNT_NUMBER       varchar2
,PV_MEMBER_TYPE          varchar2
,PV_CREDIT_CARD_NUMBER   varchar2
,PV_CREDIT_CARD_TYPE     varchar2
,PV_CITY                 varchar2
,PV_STATE_PROVINCE       varchar2    
,PV_POSTAL_CODE          varchar2
,PV_ADDRESS_TYPE         varchar2
,PV_COUNTRY_CODE         varchar2
,PV_AREA_CODE            varchar2
,PV_TELEPHONE_NUMBER     varchar2
,PV_TELEPHONE_TYPE       varchar2
,PV_USER_NAME            varchar2 := '') return number is
LV_ADDRESS_TYPE         varchar2(30);
LV_CONTACT_TYPE         varchar2(30);
LV_CREDIT_CARD_TYPE     varchar2(30);
LV_MEMBER_TYPE          varchar2(30);
LV_TELEPHONE_TYPE       varchar2(30);
LV_MEMBER_ID            number;
LV_SYSTEM_USER_ID       number; 
LV_USER_NAME     VARCHAR2(20); 


CURSOR get_type(cv_table_name  VARCHAR2
               ,cv_column_name VARCHAR2
               ,cv_lookup_type VARCHAR2) IS
               SELECT common_lookup_id
               FROM common_lookup
               WHERE common_lookup_table  = cv_table_name
               AND   common_lookup_column = cv_column_name
               AND   common_lookup_type   = cv_lookup_type;
        
        
        cursor get_member
        (cv_member_account_number VARCHAR2) is 
        select MEMBER_ID
        from   Member
        where account_number = cv_member_account_number;
         
        
        BEGIN
        IF PV_USER_NAME is NULL THEN 
        LV_USER_NAME := 'ANONYMOUS';
        else 
        LV_USER_NAME := PV_USER_NAME;
        end if; 
        
        FOR i IN get_type('MEMBER', 'MEMBER_TYPE', PV_MEMBER_TYPE) LOOP
    lv_member_type := i.common_lookup_id;
    end loop;
    FOR i IN get_type('CONTACT', 'CONTACT_TYPE', PV_CONTACT_TYPE) LOOP
    lv_contact_type := i.common_lookup_id;
    END LOOP;
    FOR i IN get_type('ADDRESS', 'ADDRESS_TYPE', PV_ADDRESS_TYPE) LOOP
    lv_address_type := i.common_lookup_id;
    end loop;
    FOR i IN get_type('TELEPHONE', 'TELEPHONE_TYPE', PV_TELEPHONE_TYPE) LOOP
    lv_telephone_type := i.common_lookup_id;
    END LOOP;
    FOR i IN get_type('MEMBER', 'CREDIT_CARD_TYPE', PV_CREDIT_CARD_TYPE) LOOP
    lv_credit_card_type := i.common_lookup_id;
    END LOOP;


select system_user_id
into LV_USER_NAME
from system_user
where system_user_name = pv_user_name;


SAVEPOINT starting_point;

    OPEN get_member(pv_account_number);
 FETCH get_member into lv_member_id;
 IF get_member%notfound then
lv_member_id := member_s1.NEXTVAL;
    
    
    INSERT INTO member
    VALUES
    ( LV_MEMBER_ID
    , lv_member_type
    , pv_account_number
    , pv_credit_card_number
    , lv_credit_card_type
    ,  LV_USER_NAME
    , SYSDATE
    ,  LV_USER_NAME
    , SYSDATE );
end if;
close get_member;

  INSERT INTO contact
    VALUES
  (contact_s1.NEXTVAL
  , lv_member_id
  , lv_contact_type
  , pv_last_name
  , pv_first_name
  , pv_middle_name
  ,  LV_USER_NAME
  , SYSDATE
  ,  LV_USER_NAME
  , SYSDATE);  

INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  ,lv_address_type
  , pv_city
  , pv_state_province
  , pv_postal_code
  , LV_USER_NAME
  , SYSDATE
  ,  LV_USER_NAME
  , SYSDATE );  

 
  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              -- TELEPHONE_ID
  , contact_s1.CURRVAL                                -- CONTACT_ID
  , address_s1.CURRVAL                                -- ADDRESS_ID
  , lv_telephone_type
  , pv_country_code                                   -- COUNTRY_CODE
  , pv_area_code                                      -- AREA_CODE
  , pv_telephone_number                               -- TELEPHONE_NUMBER
  , LV_USER_NAME                                 -- CREATED_BY
  , SYSDATE                                           -- CREATION_DATE
  , LV_USER_NAME                                 -- LAST_UPDATED_BY
  , SYSDATE);    -- LAST_UPDATE_DATE
  
  return 0;
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line(SQLERRM);
    RETURN 1;
    end INSERT_CONTACT;
  
function INSERT_CONTACT
(PV_FIRST_NAME           varchar2
,PV_MIDDLE_NAME          varchar2 := ''
,PV_LAST_NAME            varchar2
,PV_CONTACT_TYPE         varchar2
,PV_ACCOUNT_NUMBER       varchar2
,PV_MEMBER_TYPE          varchar2
,PV_CREDIT_CARD_NUMBER   varchar2
,PV_CREDIT_CARD_TYPE     varchar2
,PV_CITY                 varchar2
,PV_STATE_PROVINCE       varchar2    
,PV_POSTAL_CODE          varchar2
,PV_ADDRESS_TYPE         varchar2
,PV_COUNTRY_CODE         varchar2
,PV_AREA_CODE            varchar2
,PV_TELEPHONE_NUMBER     varchar2
,PV_TELEPHONE_TYPE       varchar2
,PV_USER_ID              number := -1)return number is
LV_ADDRESS_TYPE         varchar2(30);
LV_CONTACT_TYPE         varchar2(30);
LV_CREDIT_CARD_TYPE     varchar2(30);
LV_MEMBER_TYPE          varchar2(30);
LV_TELEPHONE_TYPE       varchar2(30);
LV_MEMBER_ID            number;
LV_USER_NAME            VARCHAR2(30);
lv_current_date         date := SYSDATE;


CURSOR get_type(cv_table_name  VARCHAR2
               ,cv_column_name VARCHAR2
               ,cv_lookup_type VARCHAR2) IS
               SELECT common_lookup_id
               FROM common_lookup
               WHERE common_lookup_table  = cv_table_name
               AND   common_lookup_column = cv_column_name
               AND   common_lookup_type   = cv_lookup_type;
        
        
        cursor get_member
        (cv_member_account_number VARCHAR2) is 
        select MEMBER_ID
        from   Member
        where account_number = cv_member_account_number;
         
        
        BEGIN
        
        
        FOR i IN get_type('MEMBER', 'MEMBER_TYPE', PV_MEMBER_TYPE) LOOP
    lv_member_type := i.common_lookup_id;
    end loop;
    FOR i IN get_type('CONTACT', 'CONTACT_TYPE', PV_CONTACT_TYPE) LOOP
    lv_contact_type := i.common_lookup_id;
    END LOOP;
    FOR i IN get_type('ADDRESS', 'ADDRESS_TYPE', PV_ADDRESS_TYPE) LOOP
    lv_address_type := i.common_lookup_id;
    end loop;
    FOR i IN get_type('TELEPHONE', 'TELEPHONE_TYPE', PV_TELEPHONE_TYPE) LOOP
    lv_telephone_type := i.common_lookup_id;
    END LOOP;
    FOR i IN get_type('MEMBER', 'CREDIT_CARD_TYPE', PV_CREDIT_CARD_TYPE) LOOP
    lv_credit_card_type := i.common_lookup_id;
    END LOOP;



LV_USER_NAME := PV_USER_ID;


SAVEPOINT starting_point;

  OPEN get_member(pv_account_number);
 FETCH get_member into lv_member_id;
 IF get_member%notfound then
lv_member_id := member_s1.NEXTVAL;
    
    INSERT INTO member
    VALUES
    ( LV_MEMBER_ID
    , lv_member_type
    , pv_account_number
    , pv_credit_card_number
    , lv_credit_card_type
    ,  LV_USER_NAME
    , SYSDATE
    ,  LV_USER_NAME
    , SYSDATE );
end if;
close get_member;

    INSERT INTO contact
    VALUES
  (contact_s1.NEXTVAL
  , lv_member_id
  , lv_contact_type
  , pv_last_name
  , pv_first_name
  , pv_middle_name
  ,  LV_USER_NAME
  , SYSDATE
  ,  LV_USER_NAME
  , SYSDATE);  

INSERT INTO address
  VALUES
  ( address_s1.NEXTVAL
  , contact_s1.CURRVAL
  ,lv_address_type
  , pv_city
  , pv_state_province
  , pv_postal_code
  , LV_USER_NAME
  , SYSDATE
  ,  LV_USER_NAME
  , SYSDATE );  

 
  INSERT INTO telephone
  VALUES
  ( telephone_s1.NEXTVAL                              -- TELEPHONE_ID
  , contact_s1.CURRVAL                                -- CONTACT_ID
  , address_s1.CURRVAL                                -- ADDRESS_ID
  , lv_telephone_type
  , pv_country_code                                   -- COUNTRY_CODE
  , pv_area_code                                      -- AREA_CODE
  , pv_telephone_number                               -- TELEPHONE_NUMBER
  , LV_USER_NAME                                 -- CREATED_BY
  , SYSDATE                                           -- CREATION_DATE
  , LV_USER_NAME                                 -- LAST_UPDATED_BY
  , SYSDATE);                            -- LAST_UPDATE_DATE

  return 0;
   COMMIT;
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK;
    dbms_output.put_line(SQLERRM);
    RETURN 1;
    end INSERT_CONTACT;
    
end contact_package;
/

DECLARE 
success number;

BEGIN
success := contact_package.insert_contact
( pv_first_name => 'Shirley'
, pv_middle_name => ''
, pv_last_name => 'Partridge'
, pv_contact_type => 'CUSTOMER'
, pv_account_number => 'SLC-000012'
, pv_member_type => 'GROUP'
, pv_credit_card_number => '8888-6666-8888-4444'
, pv_credit_card_type => 'VISA_CARD'
, pv_city => 'Lehi'
, pv_state_province => 'Utah'
, pv_postal_code => '84043'
, pv_address_type => 'HOME'
, pv_country_code => '001'
, pv_area_code => '207'
, pv_telephone_number => '877-4321'
, pv_telephone_type => 'HOME'
, pv_user_name => 'DBA 3');
dbms_output.put_line('thumbs up');
END;
/

DECLARE 
success number;


BEGIN
success := contact_package.insert_contact
( pv_first_name => 'Keith'
, pv_middle_name => ''
, pv_last_name => 'Partridge'
, pv_contact_type => 'CUSTOMER'
, pv_account_number => 'SLC-000012'
, pv_member_type => 'GROUP'
, pv_credit_card_number => '8888-6666-8888-4444'
, pv_credit_card_type => 'VISA_CARD'
, pv_city => 'Lehi'
, pv_state_province => 'Utah'
, pv_postal_code => '84043'
, pv_address_type => 'HOME'
, pv_country_code => '001'
, pv_area_code => '207'
, pv_telephone_number => '877-4321'
, pv_telephone_type => 'HOME'
, pv_user_id => 6);
dbms_output.put_line('thumbs up');
end;
/

DECLARE 
success number;


BEGIN
success := contact_package.insert_contact
( pv_first_name => 'Shirley'
, pv_middle_name => ''
, pv_last_name => 'Partridge'
, pv_contact_type => 'CUSTOMER'
, pv_account_number => 'SLC-000012'
, pv_member_type => 'GROUP'
, pv_credit_card_number => '8888-6666-8888-4444'
, pv_credit_card_type => 'VISA_CARD'
, pv_city => 'Lehi'
, pv_state_province => 'Utah'
, pv_postal_code => '84043'
, pv_address_type => 'HOME'
, pv_country_code => '001'
, pv_area_code => '207'
, pv_telephone_number => '877-4321'
, pv_telephone_type => 'HOME'
, pv_user_id => -1);
dbms_output.put_line('thumbs up');
end;
/

COL full_name      FORMAT A18   HEADING "Full Name"
COL created_by     FORMAT 9999  HEADING "System|User ID"
COL account_number FORMAT A12   HEADING "Account|Number"
COL address        FORMAT A16   HEADING "Address"
COL telephone      FORMAT A16   HEADING "Telephone"
SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      c.created_by 
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Partridge';

L
show errors
-- Close log file.
SPOOL OFF
