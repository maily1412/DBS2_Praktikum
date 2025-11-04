Set SERVEROUTPUT ON;
Set Echo ON;
SPOOl Praktikum4_Maily.txt;

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



-- Aufgabe 3 Integration ins SELECT
-- Gültigkeit der IBAN prüfen 
CREATE OR REPLACE FUNCTION ist_iban_gueltig(p_iban IN VARCHAR2) 
 return VARCHAR2
AS
  zahl number(24); -- umgebaute Zahl, die man für Modulo-Test braucht
  pruefziffer number(2); -- Prüfziffer aus der IBAN
BEGIN
  zahl := substr(p_iban || '131400', 5); -- Ländercode DE und 00 an IBAN anhängen und ab dem 5. Zeichen die Zahlen übernehemen
  pruefziffer := substr(p_iban, 3, 2); -- Holt die 2 Prüfziffer aus der IBAN an der 3. Stelle 

  -- Ergebnis der Modulo Rechnung soll von 98 abgezogen werden und wenn es gleich der Prüfziffer ist, ist es gültig
  IF pruefziffer =  98 - MOD(zahl, 97) then 
  return 'OK';
  ELSE 
  return 'Invalid';
  END IF;
END;
/
SELECT s.employee_id, e.FIRST_NAME, e.LAST_NAME, s.iban, e.salary, ist_iban_gueltig(s.iban) AS is_valid
FROM emp_account s 
JOIN employees e 
ON s.employee_id = e.employee_id;
/



-- Aufgabe 4 Kontrollstrukturen
CREATE OR REPLACE PROCEDURE set_employee_stars(v_empno emp.employee_id%TYPE) 
IS
  v_asterisk  emp.stars%TYPE := NULL; -- Sterne werden hier gesammelt 
  v_sal       emp.salary%TYPE;        -- Gehalt 
BEGIN
  -- Gehalt aus der Tabelle lesen
  -- NVL(salary, 0) falls Mitarbeiter kein Gehalt hat, dann soll 0 ausgegeben werden. 
  SELECT salary 
  INTO v_sal 
  FROM emp 
  WHERE employee_id = v_empno;

  -- Anzahl Sterne berechnen
  -- 1 Stern pro 1000 €
  -- LPAD(starttext, länge, füllzeichen) -> Mach den Text so lang, indem man von links mit dem Zeichen auffüllst
  v_asterisk := LPAD('*', ROUND(v_sal / 1000), '*');  -- Alternativ mit einer FOR-Schleife?

  -- Tabelle updaten
  UPDATE emp
  SET stars = v_asterisk
  WHERE employee_id = v_empno;
END;
/
-- Aufruf der Funktion
BEGIN 
   set_employee_stars(176);
END;
/
-- Tabelle emp anzeigen
SELECT employee_id, salary, stars 
 FROM emp
 WHERE employee_id=176; 
/



-- Aufgabe 5 Trigger
-- beim Ändern oder Hinzufügen eines Angestellten soll automatisch die Spalte stars mit dem entsprechenden Wert gefüllt werden 
CREATE OR REPLACE TRIGGER emp_set_stars 
  BEFORE INSERT OR UPDATE ON emp 
  FOR EACH ROW 
DECLARE 
  v_asterisk  emp.stars%TYPE := NULL; -- Sterne werden hier gesammelt 
  v_sal       emp.salary%TYPE;        -- Gehalt  
BEGIN
  -- Korrelationsvariablen :OLD und :NEW kann auf jeweils aktuellen Daten zugreifen (Beide gleichzeitig sind nur für UPDATE definiert)
  -- Warum kann man nicht in einem Trigger die Funktion set_employee_stars() aufrufen?
  -- Warum werden hier nicht die SQL Befehle gebraucht? 
  :NEW.stars := LPAD('*', ROUND(v_sal / 1000), '*');  
END;


-- Aufgabe 6 Trigger 
-- Änderungen an der Spalte Gehalt soll protokolliert werden und nur zwischen 8 bis 18 Uhr an Werktagen erlaubt sein
CREATE OR REPLACE TRIGGER emp_set_sal 
  BEFORE INSERT OR UPDATE ON emp 
  FOR EACH ROW  
BEGIN
  -- SYSDATE ist aktuelle Zeitpunkt (Datum + Uhrzeit)
  -- HH24 gibt die Stunde (im 24-Stunden-Format) als Text zurück
  -- TO_NUMBER wandelt aktuelle Stunde in eine Zahl um
  IF -- Wenn die Stunde zwischen 8 und 18 liegt und der Wochentag nicht Samstag oder Sonntag ist -> dann darf das Gehalt geändert werden.
    TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) BETWEEN 8 AND 18 AND TO_CHAR(SYSDATE, 'DY') NOT IN ('SAT', 'SUN')
  THEN
    DBMS_OUTPUT.PUT_LINE('Gehalt wurde geändert');
  ELSE -- ansonsten Error
  -- Fehlernummer muss zwischen –20000 und –20999 liegen
  RAISE_APPLICATION_ERROR (-20444,  'Gehalt kann nicht geändert werden. Nur zwischen 8 bis 18 Uhr an Werktagen möglich');
  END IF;
END;
/
-- Test:
UPDATE emp
SET salary = salary + 100
WHERE employee_id = 116;
-- Anzeigen:
SELECT *
FROM emp
WHERE employee_id = 116;
