set serveroutput on;
show errors;
ALTER SESSION SET nls_date_format='DD/MM/RRRR HH24:MI:SS';
select trigger_name from USER_TRIGGERS;


--qst 1
create or replace trigger affichage_message_employe
after 
insert or delete or update 
on client
FOR EACH ROW
BEGIN
CASE
    WHEN INSERTING THEN DBMS_OUTPUT.PUT_LINE('un nouveau employé est ajouté');
    WHEN DELETING THEN DBMS_OUTPUT.PUT_LINE('un employé est supprimé');
    WHEN UPDATING THEN DBMS_OUTPUT.PUT_LINE('un employé est modifié');
END CASE;
EXCEPTION
    WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/


--qst 2
Create or replace TRIGGER aff_msg_mod_mar
after  insert on modele
For each row
DECLARE marquee Marque.marque%type;
BEGIN
select marque into marquee from marque where NUMMARQUE = :NEW.NUMMARQUE;
dbms_output.put_line(' un nouveau modele est a ajouter a la marque '||marquee);
END;
/

insert into modele (NUMMODELE, NUMMARQUE, MODELE) VALUES (30, 21, 'SUEDE');
--FOR EACH ROW   permet de percourir les enregistrement (plusieur lignes)
raise_application_error(-20000,'le nouveau salaire doit être supérieur à l ancien salaire.');

--qst 3
CREATE OR REPLACE TRIGGER salaire_employe
BEFORE UPDATE OF SALAIRE
ON EMPLOYE
FOR EACH ROW 
DECLARE erreur EXCEPTION;
BEGIN
if (:new.SALAIRE < :old.SALAIRE) THEN
  raise erreur;
end if;  
EXCEPTION
        WHEN erreur THEN raise_application_error(-20000,'le nouveau salaire doit être supérieur à l ancien salaire.');
		WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/


UPDATE employe
SET SALAIRE = 10
WHERE NUMEMPLOYE = 72;


UPDATE employe
SET SALAIRE = 5000000
WHERE NUMEMPLOYE = 72;


--qst 4
CREATE OR REPLACE TRIGGER periode_interv
BEFORE INSERT or update 
ON INTERVENANTS
FOR EACH ROW
DECLARE dated INTERVENTIONS.DATEDEBINTERV%type;
        datef INTERVENTIONS.DATEFININTERV%type;
BEGIN
SELECT DATEDEBINTERV,DATEFININTERV into dated, datef from INTERVENTIONS where NUMINTERVENTION = :NEW.NUMINTERVENTION;
if (:new.DATEDEBUT>dated AND :new.DATEFIN>datef) THEN
    raise_application_error(-20001,'la date n est pas verifie');
	else dbms_output.put_line('la date est verifie');
end if;
END;
/


INSERT INTO INTERVENANTS  VALUES(1,54,To_DATE('2006-02-26 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-02-26 12:00:00','RRRR-MM-DD HH24:MI:SS'));


--qst 5
ALTER TABLE EMPLOYE ADD (TOTAL_INTERVENTIONS INTEGER DEFAULT 0);

CREATE OR REPLACE TRIGGER TOTAL_INTERVENTIONS_TRIGGER
AFTER INSERT ON INTERVENANTS
FOR EACH ROW
BEGIN
	UPDATE EMPLOYE SET TOTAL_INTERVENTIONS = TOTAL_INTERVENTIONS + 1 WHERE EMPLOYE.NUMEMPLOYE = :NEW.NUMEMPLOYE ;
END;
/

select TOTAL_INTERVENTIONS from employe where NUMEMPLOYE=53;
insert into INTERVENANTS(NUMINTERVENTION, NUMEMPLOYE, DATEDEBUT, DATEFIN)


create or replace procedure initialisation is
cursor cr is select count(*) from INTERVENANTS where INTERVENANTS.NUMEMPLOYE = EMPLOYE.NUMEMPLOYE 

-- qst 6
extract pour les date 