/* ********tp3******************** */
/*1*/ 
SELECT * FROM DICT;
DESC DICT;
SELECT COUNT(*) FROM DICT;
/*2*/
DESC ALL_TAB_COLUMNS;
DESC USER_USERS;
DESC ALL_CONSTRAINTS;
DESC USER_TAB_PRIVS;
/*3*/
SELECT USER FROM USER_USERS;
/*4*/
DESC ALL_TAB_COLUMNS; 
DESC USER_TAB_COLUMNS;
/*CONNECTE WITH TP1'S USER */
/*5*/
SELECT DISTINCT TABLE_NAME FROM ALL_TABLES;
SELECT * FROM USER_TABLES ;
SELECT TABLE_NAME, TABLESPACE_NAME CLUSTER_NAME FROM USER_TABLES ;
/*6*/
SELECT DISTINCT TABLE_NAME FROM ALL_TABLES WHERE OWNER='SYSTEM';
SELECT DISTINCT TABLE_NAME FROM ALL_TABLES WHERE OWNER='ADMINHOTEL';
/*7*/
SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH FROM USER_TAB_COLUMNS WHERE TABLE_NAME='RESERVATION';
SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME='CLIENT';
/*8*/
SELECT CONSTRAINT_NAME FROM USER_CONSTRAINTS WHERE TABLE_NAME='RESERVATION';
/*9*/
SELECT * FROM USER_CONSTRAINTS ;
SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE FROM USER_CONSTRAINTS;
/*10*/
/* LES ATTRIBUTS*/
SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH 
FROM USER_TAB_COLUMNS 
WHERE TABLE_NAME='RESERVATION';
/*LES CONTRAINTES*/
SELECT U.CONSTRAINT_NAME, U.CONSTRAINT_TYPE, A.COLUMN_NAME 
FROM USER_CONSTRAINTS U, ALL_CONS_COLUMNS A 
WHERE A.TABLE_NAME='RESERVATION' 
AND U.CONSTRAINT_NAME=A.CONSTRAINT_NAME;
/*11*/
SELECT PRIVILEGE, TABLE_NAME FROM USER_TAB_PRIVS WHERE GRANTEE='ADMINHOTEL';
/*12*/
/*CONNECTER AUTANT QUE ADMINHOTEL*/
SELECT GRANTED_ROLE FROM USER_ROLE_PRIVS;
/*13*/
SELECT * FROM USER_OBJECTS;
SELECT OBJECT_NAME FROM USER_OBJECTS;
SELECT OBJECT_NAME FROM ALL_OBJECTS WHERE OWNER='ADMINHOTEL'; /* SI CONNECTE AVEC UN AUTRE USER*/
/*14*/
SELECT OWNER FROM ALL_TABLES WHERE TABLE_NAME='RESERVATION';
/*15*/
SELECT BYTES/1024 AS SIZE_TABLE_KO FROM USER_SEGMENTS WHERE SEGMENT_NAME='RESERVATION';



