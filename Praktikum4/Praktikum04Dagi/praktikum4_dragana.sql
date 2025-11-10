-- DBS2 Praktikum 04 – Aufgabe 1
-- Thema: Grundlagen – Variablen und SELECT INTO

set serveroutput on;
set echo on;

DECLARE
  -- Variable für die höchste Abteilungsnummer
  v_max_deptno NUMBER;
BEGIN
  -- höchste Abteilungsnummer aus der Tabelle departments auswählen
  SELECT MAX(department_id)
  INTO v_max_deptno
  FROM departments;

  -- Ausgabe des Ergebnisses
  DBMS_OUTPUT.PUT_LINE('Die höchste Abteilungsnummer ist: ' || v_max_deptno);
END;
/

-- DBS2 Praktikum 04 – Aufgabe 2a–c
-- Thema: Komplexe Datentypen – Record mit Tabellenstruktur

set serveroutput on;
set echo on;

DECLARE
  -- Variable für die Country-ID
  v_countryid countries.country_id%TYPE := 'CA';

  -- Record-Variable basierend auf der Struktur der Tabelle COUNTRIES
  v_country_record countries%ROWTYPE;
BEGIN
  -- Daten zu dem Land mit country_id = v_countryid holen
  SELECT *
  INTO v_country_record
  FROM countries
  WHERE country_id = v_countryid;

  -- Ausgabe der Informationen
  DBMS_OUTPUT.PUT_LINE('Country Id:   ' || v_country_record.country_id);
  DBMS_OUTPUT.PUT_LINE('Country Name: ' || v_country_record.country_name);
  DBMS_OUTPUT.PUT_LINE('Region:       ' || v_country_record.region_id);
END;
/

-- DBS2 Praktikum 04 – Aufgabe 2d
-- Thema: Stored Procedure show_country

CREATE OR REPLACE PROCEDURE show_country(
  p_country_id IN countries.country_id%TYPE
) AS
  v_country_record countries%ROWTYPE;
BEGIN
  -- Land zur angegebenen ID abrufen
  SELECT *
  INTO v_country_record
  FROM countries
  WHERE country_id = p_country_id;

  -- Ausgabe der Daten
  DBMS_OUTPUT.PUT_LINE('Country Id:   ' || v_country_record.country_id);
  DBMS_OUTPUT.PUT_LINE('Country Name: ' || v_country_record.country_name);
  DBMS_OUTPUT.PUT_LINE('Region:       ' || v_country_record.region_id);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Kein Land mit ID ' || p_country_id || ' gefunden.');
END;
/
-- Tests der Prozedur
BEGIN
  show_country('DE');
  show_country('UK');
  show_country('US');
END;
/

-- Dieses Skript legt die Tabelle emp_account an
@emp_account.sql

-- DBS2 Praktikum 04 – Aufgabe 3
-- Thema: Integration ins SELECT – IBAN-Prüfung (nur deutsche IBANs)

CREATE OR REPLACE FUNCTION is_valid_iban(p_iban IN VARCHAR2)
RETURN VARCHAR2
AS
  v_iban   VARCHAR2(34);
  v_check  NUMBER;
  v_body   VARCHAR2(100);
  v_mod    NUMBER := 0;
BEGIN
  v_iban := REPLACE(UPPER(p_iban), ' ', '');

  -- Nur deutsche IBANs prüfen
  IF SUBSTR(v_iban, 1, 2) != 'DE' THEN
    RETURN 'IGNORED';
  END IF;

  -- Prüfziffer herausnehmen, IBAN umstellen: Zahlenteil + "DE00" (DE → 1314)
  v_check := TO_NUMBER(SUBSTR(v_iban, 3, 2));
  v_body  := SUBSTR(v_iban, 5) || '131400';

  -- Modulo-97 schrittweise berechnen (Zahl ist zu groß für NUMBER)
  FOR i IN 1 .. LENGTH(v_body) LOOP
    v_mod := MOD(TO_NUMBER(TO_CHAR(v_mod) || SUBSTR(v_body, i, 1)), 97);
  END LOOP;

  RETURN CASE WHEN 98 - v_mod = v_check THEN 'OK' ELSE 'INVALID' END;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'ERROR';
END;
/

-- SQL-Abfrage zur Anzeige der Mitarbeiter mit IBAN-Status

SELECT
  e.employee_id,
  e.first_name,
  e.last_name,
  a.iban,
  e.salary,
  is_valid_iban(a.iban) AS is_valid
FROM employees e
JOIN emp_account a
  ON e.employee_id = a.employee_id;
/

-- Erst das bereitgestellte Script ausführen (Kopie von employees-Tabelle):
@lab_04_01.sql

-- DBS2 Praktikum 04 – Aufgabe 4
-- Thema: Kontrollstrukturen – Sterne für Gehalt

CREATE OR REPLACE PROCEDURE set_employee_stars(
  p_emp_id IN emp.employee_id%TYPE
) AS
  v_salary     emp.salary%TYPE;
  v_stars      emp.stars%TYPE := '';
  v_count      NUMBER;
BEGIN
  -- Gehalt des Mitarbeiters abrufen
  SELECT salary
  INTO v_salary
  FROM emp
  WHERE employee_id = p_emp_id;

  -- Anzahl der Sternchen berechnen: 1 Stern pro volle 1000 €
  v_count := ROUND(v_salary / 1000);

  -- String aus Sternchen zusammenbauen
  FOR i IN 1 .. v_count LOOP
    v_stars := v_stars || '*';
  END LOOP;

  -- Update der Tabelle
  UPDATE emp
  SET stars = v_stars
  WHERE employee_id = p_emp_id;

  -- Ausgabe für Kontrolle
  DBMS_OUTPUT.PUT_LINE('Mitarbeiter ' || p_emp_id ||
                       ' hat Gehalt ' || v_salary ||
                       ' → Sterne: ' || v_stars);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Kein Mitarbeiter mit ID ' || p_emp_id || ' gefunden.');
END;
/

-- Test der Prozedur
set serveroutput on;

BEGIN
  set_employee_stars(176);
END;
/

-- Kontrolle der Daten in der emp-Tabelle
SELECT employee_id, first_name, salary, stars
FROM emp
WHERE employee_id = 176;
/

-- DBS2 Praktikum 04 – Aufgabe 5
-- Thema: Trigger – Automatisches Setzen der Sterne

CREATE OR REPLACE TRIGGER emp_set_stars
  BEFORE INSERT OR UPDATE ON emp
  FOR EACH ROW
DECLARE
  v_stars VARCHAR2(50) := '';
  v_count NUMBER;
BEGIN
  -- Berechnung: 1 Stern pro volle 1000 Euro Gehalt
  v_count := ROUND(:NEW.salary / 1000);

  -- Sternchenkette zusammensetzen
  FOR i IN 1 .. v_count LOOP
    v_stars := v_stars || '*';
  END LOOP;

  -- neuen Wert in die Zieltabelle schreiben
  :NEW.stars := v_stars;
END;
/

-- Test 1: Neuen Mitarbeiter einfügen
INSERT INTO emp (
  employee_id, first_name, last_name, email, hire_date, job_id, salary
)
VALUES (
  999, 'Test', 'Trigger', 'TTRIGGER', SYSDATE, 'IT_PROG', 7500
);

-- Test 2: Vorhandenen Mitarbeiter aktualisieren
UPDATE emp
SET salary = 12500
WHERE employee_id = 176;

-- Ergebnisse prüfen
SELECT employee_id, first_name, salary, stars
FROM emp
WHERE employee_id IN (176, 999);
/

-- DBS2 Praktikum 04 – Aufgabe 6 (Teil 1)
-- Thema: Log-Tabelle für Gehaltsänderungen

CREATE TABLE emp_salary_log (
  log_id        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  employee_id   NUMBER,
  old_salary    NUMBER,
  new_salary    NUMBER,
  changed_at    DATE,
  changed_by    VARCHAR2(30)
);

-- DBS2 Praktikum 04 – Aufgabe 6 (Teil 2)
-- Thema: Trigger mit Zeitprüfung

CREATE OR REPLACE TRIGGER emp_salary_protect
  BEFORE UPDATE OF salary ON emp
  FOR EACH ROW
DECLARE
  v_day   VARCHAR2(10);
  v_hour  NUMBER;
BEGIN
  -- Wochentag und Stunde bestimmen
  v_day  := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
  v_hour := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));

  -- Prüfung: Nur Mo–Fr und 08–18 Uhr erlaubt
  IF v_day NOT IN ('MON', 'TUE', 'WED', 'THU', 'FRI')
     OR v_hour < 8 OR v_hour >= 18 THEN
    RAISE_APPLICATION_ERROR(-20001,
      'Gehälter dürfen nur werktags zwischen 8:00 und 18:00 Uhr geändert werden.');
  END IF;

  -- Änderung im Log vermerken
  INSERT INTO emp_salary_log (employee_id, old_salary, new_salary, changed_at, changed_by)
  VALUES (:OLD.employee_id, :OLD.salary, :NEW.salary, SYSDATE, USER);
END;
/

-- Test: gültige Änderung (innerhalb der erlaubten Zeit)
UPDATE emp
SET salary = salary + 500
WHERE employee_id = 100;

-- Test: Änderung außerhalb der Zeit (manuell simuliert)
-- (Kann getestet werden, indem man den Trigger kurz modifiziert oder SYSDATE ersetzt)

-- Logeinträge prüfen
SELECT * FROM emp_salary_log;

-- DBS2 Praktikum 04 – Aufgabe 7a
-- Thema: Einzelne Mitarbeiterausgabe (formatiert)

CREATE OR REPLACE PROCEDURE output_employee(
  p_employee_id IN employees.employee_id%TYPE
) AS
  v_emp employees%ROWTYPE;
BEGIN
  SELECT *
  INTO v_emp
  FROM employees
  WHERE employee_id = p_employee_id;

  DBMS_OUTPUT.PUT_LINE('____________________________________________________');
  DBMS_OUTPUT.PUT_LINE('Mitarbeiter Nr.: ' || v_emp.employee_id);
  DBMS_OUTPUT.PUT_LINE('Name:            ' || v_emp.first_name || ' ' || v_emp.last_name);
  DBMS_OUTPUT.PUT_LINE('E-Mail:          ' || v_emp.email || '@oracle.com');
  DBMS_OUTPUT.PUT_LINE('Telefon Nr.:     ' || v_emp.phone_number);
  DBMS_OUTPUT.PUT_LINE('Eingestellt am:  ' || TO_CHAR(v_emp.hire_date, 'DD.MM.YY'));
  DBMS_OUTPUT.PUT_LINE('Gehalt:          ' || v_emp.salary || ' $');
  DBMS_OUTPUT.PUT_LINE('Beruf ID:        ' || v_emp.job_id);
  DBMS_OUTPUT.PUT_LINE('Abteilung Nr.:   ' || v_emp.department_id);
  DBMS_OUTPUT.PUT_LINE('Vorgesetzter Nr.:' || v_emp.manager_id);
  DBMS_OUTPUT.PUT_LINE('____________________________________________________');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Kein Mitarbeiter mit ID ' || p_employee_id || ' gefunden.');
END;
/

BEGIN
  output_employee(101);
END;
/

-- DBS2 Praktikum 04 – Aufgabe 7b
-- Thema: Ausgabe mit Text für Job, Abteilung, Vorgesetzten

CREATE OR REPLACE PROCEDURE output_employee_b(
  p_employee_id IN employees.employee_id%TYPE
) AS
  v_emp employees%ROWTYPE;
  v_job_title jobs.job_title%TYPE;
  v_dept_name departments.department_name%TYPE;
  v_mgr_name VARCHAR2(100);
BEGIN
  SELECT * INTO v_emp FROM employees WHERE employee_id = p_employee_id;

  SELECT job_title INTO v_job_title FROM jobs WHERE job_id = v_emp.job_id;
  SELECT department_name INTO v_dept_name FROM departments WHERE department_id = v_emp.department_id;
  SELECT first_name || ' ' || last_name INTO v_mgr_name FROM employees WHERE employee_id = v_emp.manager_id;

  DBMS_OUTPUT.PUT_LINE('____________________________________________________');
  DBMS_OUTPUT.PUT_LINE('Mitarbeiter Nr.: ' || v_emp.employee_id);
  DBMS_OUTPUT.PUT_LINE('Name:            ' || v_emp.first_name || ' ' || v_emp.last_name);
  DBMS_OUTPUT.PUT_LINE('E-Mail:          ' || v_emp.email || '@oracle.com');
  DBMS_OUTPUT.PUT_LINE('Telefon Nr.:     ' || v_emp.phone_number);
  DBMS_OUTPUT.PUT_LINE('Eingestellt am:  ' || TO_CHAR(v_emp.hire_date, 'DD.MM.YY'));
  DBMS_OUTPUT.PUT_LINE('Gehalt:          ' || v_emp.salary || ' $');
  DBMS_OUTPUT.PUT_LINE('Beruf:           ' || v_job_title);
  DBMS_OUTPUT.PUT_LINE('Abteilung:       ' || v_dept_name);
  DBMS_OUTPUT.PUT_LINE('Vorgesetzter:    ' || v_mgr_name);
  DBMS_OUTPUT.PUT_LINE('____________________________________________________');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Kein Mitarbeiter mit ID ' || p_employee_id || ' gefunden.');
END;
/

BEGIN
  output_employee_b(101);
END;
/

-- DBS2 Praktikum 04 – Aufgabe 7c
-- Thema: Cursor zum Durchlaufen aller Mitarbeiter

CREATE OR REPLACE PROCEDURE output_employees AS
  CURSOR c_emp IS
    SELECT employee_id FROM employees ORDER BY employee_id;
  v_id employees.employee_id%TYPE;
BEGIN
  OPEN c_emp;
  LOOP
    FETCH c_emp INTO v_id;
    EXIT WHEN c_emp%NOTFOUND;
    output_employee_b(v_id);
  END LOOP;
  CLOSE c_emp;
END;
/

BEGIN
  output_employees;
END;
/

-- DBS2 Praktikum 04 – Aufgabe 7d
-- Thema: Bereichsweise Ausgabe mit Sortierrichtung

CREATE OR REPLACE PROCEDURE output_employee_set(
  from_employee IN NUMBER,
  to_employee   IN NUMBER,
  ascending_order IN BOOLEAN
) AS
BEGIN
  IF ascending_order THEN
    FOR rec IN (
      SELECT employee_id
      FROM employees
      WHERE employee_id BETWEEN from_employee AND to_employee
      ORDER BY employee_id ASC
    ) LOOP
      output_employee_b(rec.employee_id);
    END LOOP;
  ELSE
    FOR rec IN (
      SELECT employee_id
      FROM employees
      WHERE employee_id BETWEEN from_employee AND to_employee
      ORDER BY employee_id DESC
    ) LOOP
      output_employee_b(rec.employee_id);
    END LOOP;
  END IF;
END;
/


-- Bereich 203–205 aufsteigend
BEGIN
  output_employee_set(203, 205, TRUE);
END;
/

-- Bereich 205–203 absteigend
BEGIN
  output_employee_set(203, 205, FALSE);
END;
/

CREATE OR REPLACE PROCEDURE output_employee_by_name (
    p_last_name IN employees.last_name%TYPE
) IS
    -- Record für die Mitarbeiterdaten
    v_emp employees%ROWTYPE;

    -- Exception-Typen
    e_no_data_found   EXCEPTION;
    e_too_many_rows   EXCEPTION;

BEGIN
    -- Versuche, Mitarbeiter anhand des Nachnamens zu holen
    SELECT * INTO v_emp
    FROM employees
    WHERE UPPER(last_name) = UPPER(p_last_name);

    -- Formatierte Ausgabe
    DBMS_OUTPUT.PUT_LINE('____________________________________________________');
    DBMS_OUTPUT.PUT_LINE('Mitarbeiter Nr.: ' || v_emp.employee_id);
    DBMS_OUTPUT.PUT_LINE('Name:            ' || v_emp.first_name || ' ' || v_emp.last_name);
    DBMS_OUTPUT.PUT_LINE('E-Mail:          ' || v_emp.email || '@oracle.com');
    DBMS_OUTPUT.PUT_LINE('Telefon Nr.:     ' || v_emp.phone_number);
    DBMS_OUTPUT.PUT_LINE('Eingestellt am:  ' || TO_CHAR(v_emp.hire_date, 'DD.MM.YY'));
    DBMS_OUTPUT.PUT_LINE('Gehalt:          ' || v_emp.salary || ' $');
    DBMS_OUTPUT.PUT_LINE('Beruf ID:        ' || v_emp.job_id);
    DBMS_OUTPUT.PUT_LINE('Abteilung Nr.:   ' || v_emp.department_id);
    DBMS_OUTPUT.PUT_LINE('Vorgesetzter Nr.:' || v_emp.manager_id);
    DBMS_OUTPUT.PUT_LINE('____________________________________________________');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Fehler: Kein Mitarbeiter mit Nachnamen "' || p_last_name || '" gefunden!');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Fehler: Mehrere Mitarbeiter mit Nachnamen "' || p_last_name || '" gefunden!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unerwarteter Fehler: ' || SQLERRM);
END;
/


-- 1. Normale Ausgabe (z. B. Kochhar existiert)
EXEC output_employee_by_name('Kochhar');

-- 2. Kein Treffer
EXEC output_employee_by_name('Nichtda');

-- 3. Mehrere Treffer (z. B. King – gibt es im HR-Schema 2x)
EXEC output_employee_by_name('King');