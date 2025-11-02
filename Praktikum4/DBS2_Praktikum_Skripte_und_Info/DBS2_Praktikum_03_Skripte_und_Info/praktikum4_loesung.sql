
-- Aufgabe 1 Grundlagen
-- Höchste Abteilungsnummer ermitteln
DECLARE
  v_max_deptno NUMBER;
BEGIN 
  SELECT MAX(department_id)
  INTO v_max_deptno
  FROM departments;

  DBMS_OUTPUT.PUT_LINE('Die höchste Abteilungsnummer ist: ' || v_max_deptno);
END;
/

-- Aufgabe 2 Komplexe Datentypen
-- Ausgabe über bestimmtes Land 
DECLARE
  -- Erstelle eine Variable namens v_countryid, die den gleichen Datentyp hat
  -- wie die Spalte country_id aus der Tabelle countries
  -- und weise ihr den Wert 'CA' zu
  v_countryid countries.country_id%TYPE := 'CA';

  -- Record, der die Struktur der Tabelle countries übernimmt
  -- %ROWTYPE ist ein Platzhalter für „eine ganze Tabellenzeile“
  v_country_record countries%ROWTYPE; 

BEGIN 
  SELECT * 
  INTO v_country_record
  FROM countries
  WHERE country_id = UPPER(v_countryid);

  DBMS_OUTPUT.PUT_LINE('Country Id:        ' || v_country_record.country_id);
  DBMS_OUTPUT.PUT_LINE('Country Name:      ' || v_country_record.country_name);
  DBMS_OUTPUT.PUT_LINE('Region:            ' || v_country_record.region_id);
END;
/

-- Prozedur 
CREATE OR REPLACE PROCEDURE SHOW_COUNTRY(p_country_id countries.country_id%type) 
AS v_country_record countries%ROWTYPE;
BEGIN
  SELECT *
  INTO v_country_record
  FROM countries
  WHERE country_id = UPPER(p_country_id);
  
  DBMS_OUTPUT.PUT_LINE('Country Id:        ' || v_country_record.country_id);
  DBMS_OUTPUT.PUT_LINE('Country Name:      ' || v_country_record.country_name);
  DBMS_OUTPUT.PUT_LINE('Region:            ' || v_country_record.region_id);
END;
/
begin
  SHOW_COUNTRY('DE');
  DBMS_OUTPUT.PUT_LINE(' ');
  SHOW_COUNTRY('UK');
  DBMS_OUTPUT.PUT_LINE(' ');
  SHOW_COUNTRY('US');
end;
/