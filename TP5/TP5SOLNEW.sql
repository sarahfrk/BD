-----------------------------TP Triggers----------------------------
--- connexion avec l'utilisateur DBACOMPTOIRS  
connect dbaintervention/psw
--activer le serveur d'affichage
set serveroutput on
/*1.	Créez un trigger qui affiche « un nouveau client est ajouté» après chaque insertion d’un client.
 Répétez la même chose pour la modification ou la suppression.*/

create or replace trigger Ins_del_upd_client 
after insert or delete or update 
on client
for each row
BEGIN
CASE
WHEN INSERTING THEN DBMS_OUTPUT.PUT_LINE('un nouveau client est ajouté');
WHEN DELETING THEN DBMS_OUTPUT.PUT_LINE('un client a été supprimé');
WHEN UPDATING THEN DBMS_OUTPUT.PUT_LINE('un client a été mis a jour');
END CASE;
EXCEPTION
WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/
INSERT INTO CLIENT VALUES (24,'M.','Reda','MERABAT','12/07/1975','CITE JEANNE D''ARC ECRAN B2-GAMBETTA – ORAN','0560724538','0561720538','');
update client set NOM='MERABA' where NUMCLIENT=24;
delete from client where NUMCLIENT=24;
/*2.	Créez un trigger qui affiche « un nouveau modèle  est ajouté à la marque [Nom de la marque] » 
après chaque insertion d’un modèle.*/

create or replace trigger affichage_msg_marque_modele after insert on modele
FOR EACH ROW
DECLARE
nommar marque.MARQUE%type;
BEGIN
select MARQUE into nommar from marque where NUMMARQUE=:new.NUMMARQUE;
DBMS_OUTPUT.PUT_LINE('Le modèle '||:new.MODELE||' est ajoué à la marque ' ||nommar);
EXCEPTION
WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/
/*_______________________________*/
create or replace trigger Ins_marque_modele
	after
	insert
	ON modele
	FOR EACH ROW
	DECLARE
	  nommarque marque.MARQUE%type;
	BEGIN
	  select MARQUE into nommarque from marque where NUMMARQUE=:new.NUMMARQUE;
      DBMS_OUTPUT.PUT_LINE('Le modèle '||:new.MODELE||' est ajoué à la marque ' ||nommarque);

    EXCEPTION
       WHEN no_data_found THEN DBMS_OUTPUT.PUT_LINE('Sorry,data not found!');
       WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
	END;
	/
INSERT INTO MODELE VALUES(29,15,'206');
/*3.	Créer un trigger qui vérifie que lors de la modification du salaire d’un employé, 
la nouvelle valeur ne peut jamais être inférieure à la précédente.*/

create or replace trigger Verifier_nouveau_salaire
	before
	update of SALAIRE
	ON employe
	FOR EACH ROW
	DECLARE
	  err EXCEPTION;
	BEGIN
	if(:NEW.SALAIRE<:OLD.SALAIRE) then RAISE err;
    end if;
    EXCEPTION
      WHEN err THEN raise_application_error(-20101,'modification de salaire echoué : le nouveau salaire ne peut pas être inférieure au ancien salaire');
      WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
	END;
	/
update employe set salaire = 10 where NUMEMPLOYE=72;
/*4.	Chaque intervention est prise en charge par un ou plusieurs employés dans des périodes différentes. 
Créer un trigger qui vérifie que la période d’intervention d’un employé est comprise dans la période d’intervention.*/

create or replace trigger verif_date_intervention 
before 
insert or update 
on intervenants
FOR EACH ROW
DECLARE
datedebut interventions.DATEDEBINTERV%type;
datefin interventions.DATEFININTERV%type;
err EXCEPTION;
BEGIN
select DATEDEBINTERV, DATEFININTERV  into datedebut, datefin from INTERVENTIONS where NUMINTERVENTION = :new.NUMINTERVENTION;
if (:new.DATEDEBUT<datedebut or :new.DATEFIN> datefin) then RAISE err;
end if;
EXCEPTION
WHEN err THEN raise_application_error(-20102,'La période d''intervention d''un employé doit être comprise dans la période d''intervention');
WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/
---modifier le format date 
alter session set nls_date_format = 'DD/MM/RRRR HH24:MI:SS';
INSERT INTO INTERVENTIONS  VALUES(18,20,'Réparation',TO_DATE('2006-06-27 09:00:00','RRRR-MM-DD HH24:MI:SS'),TO_DATE('2006-06-30 12:00:00','RRRR-MM-DD HH24:MI:SS'),25000);
--table intervenants
INSERT INTO INTERVENANTS  VALUES(18,54,To_DATE('2006-02-27 09:00:00','RRRR-MM-DD HH24:MI:SS'),
TO_DATE('2006-02-27 12:00:00','RRRR-MM-DD HH24:MI:SS'));
INSERT INTO INTERVENANTS  VALUES(18,54,To_DATE('2006-02-28 09:00:00','RRRR-MM-DD HH24:MI:SS'),
TO_DATE('2006-03-02 12:00:00','RRRR-MM-DD HH24:MI:SS'));


INSERT INTO INTERVENANTS  VALUES(18,54,To_DATE('2006-06-28 09:00:00','RRRR-MM-DD HH24:MI:SS'),
TO_DATE('2006-06-29 12:00:00','RRRR-MM-DD HH24:MI:SS'));

/*5.	L’administrateur veut, pour un besoin interne, avoir le nombre total des interventions pour chaque employé. 
Pour cela, il ajoute un attribut : TOTAL_INTERVENTIONS dans la table employé. 
a.	Ajoutez  l’attribut.
b.	Créez un trigger TOTAL_INTERVENTIONS_TRIGGER qui met à jour l’attribut TOTAL_ INTERVENTIONS.*/

alter table employe add TOTAL_INTERVENTIONS NUMBER;
desc employe
/*initialiser l'attribut TOTAL_INTERVENTIONS par les valeurs qui existes 
dans la BD en créant une procédure qui permet de calculer le nombre d'intérventions d'un employé donné*/

create or replace procedure initialiser is
cursor cr is select numemploye from employe;
NBINTERVENTIONS number;
begin
for item in cr 
loop
select count(*) into NBINTERVENTIONS from intervenants where NUMEMPLOYE=item.numemploye;
update employe set TOTAL_INTERVENTIONS=NBINTERVENTIONS where NUMEMPLOYE=item.numemploye;
end loop;
end initialiser;
/
select numemploye, TOTAL_INTERVENTIONS from employe;
execute initialiser;
select numemploye, TOTAL_INTERVENTIONS from employe;
/*____________________*/
create or replace trigger TOTAL_INTERV_Insert_Delete 
after 
insert or delete  
on intervenants
for each ROW
BEGIN
CASE
WHEN INSERTING THEN update employe set TOTAL_INTERVENTIONS= TOTAL_INTERVENTIONS+1 where numemploye= :new.numemploye;
WHEN DELETING THEN  update employe set TOTAL_INTERVENTIONS= TOTAL_INTERVENTIONS-1 where numemploye= :old.numemploye;
END CASE;
EXCEPTION
WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/

/*6.	L’administrateur veut sauvegarder pour chaque mois de l’année le total de gains de toutes ses interventions. 
A chaque fois une intervention est ajouté dans un mois soit c’est la première intervention dans ce mois 
donc on ajoute une ligne dans la table CHIFFRE_AFFAIRE (MOIS, ANNEE, TOTAL_GAINS) 
ou bien on met à jour l’attribut TOTAL_GAINS.*/


-------------------------------------------
create table CHIFFRE_AFFAIRE (mois varchar2(2), ANNEE varchar2(4), TOTAL_GAINS number, constraint pk_chiffre primary key(mois, ANNEE));

create or replace trigger total_CA_trigger
after insert or delete ON 
interventions
FOR EACH ROW
declare 
mois_annee integer;
vmois varchar(2);
vannee varchar(4);
BEGIN
CASE
WHEN DELETING THEN  
   BEGIN
   SELECT EXTRACT(YEAR FROM :old.DATEDEBINTERV),EXTRACT(MONTH FROM :old.DATEDEBINTERV) into vannee, vmois 
   FROM DUAL;
   update CHIFFRE_AFFAIRE set TOTAL_GAINS=TOTAL_GAINS-:old.COUTINTERV where annee=vannee and mois=vmois  ;
   end;   
WHEN INSERTING THEN 
begin
SELECT EXTRACT(YEAR FROM :new.DATEDEBINTERV),EXTRACT(MONTH FROM :new.DATEDEBINTERV) into vannee, vmois FROM DUAL;
select count(mois)into mois_annee  from CHIFFRE_AFFAIRE where annee=vannee and mois=vmois  ;
if (mois_annee=0) then insert into CHIFFRE_AFFAIRE values(vannee,vmois, :new.COUTINTERV);
else 
update CHIFFRE_AFFAIRE set TOTAL_GAINS=TOTAL_GAINS+:new.COUTINTERV where annee=vannee and mois=vmois  ;
end if;
end;
END CASE;
EXCEPTION
WHEN OTHERS then  DBMS_OUTPUT.PUT_LINE('error : '||sqlcode||' '||sqlerrm);
END;
/


The DUAL table is a one row, one column, dummy table used by Oracle.
SELECT statements need a table, and if you don’t need one for your query, you can use the DUAL table
Don’t modify or delete the DUAL table
