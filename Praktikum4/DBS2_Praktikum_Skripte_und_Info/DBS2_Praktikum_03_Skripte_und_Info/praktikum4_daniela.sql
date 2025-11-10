-- ==========================================================
-- Praktikum 4
-- ==========================================================

Set SERVEROUTPUT ON;
Set Echo ON;
SPOOl Praktikum4.txt;
-- ==========================================================
-- Aufgabe 1
-- Höchste Abteilungsnummer ermitteln
-- ==========================================================


DECLARE
    v_max_deptno NUMBER;            -- Höchste vorhandene department_id
BEGIN
    -- MAX-Funktion holt sich die größte department_id aus der Tabelle departments
    SELECT MAX(department_id)
    INTO v_max_deptno
    FROM departments;
    DBMS_OUTPUT.PUT_LINE('Höchste Abteilungsnummer: ' || v_max_deptno);
END;
/

-- ==========================================================
-- Aufgabe 2
-- PL/SQL Block die Informationen über ein bestimmtes Land ausgibt
-- ==========================================================

DECLARE
    v_country_id VARCHAR2(20):='CA';        -- Ländercode für Kanada
    
    v_country_record countries%ROWTYPE; -- Speichert komplette Zeile aus countries
BEGIN
    -- alle Spalten für das Land mit der ID 'CA' holen
    SELECT *
        INTO v_country_record
        FROM countries
        WHERE country_id = UPPER(v_country_id);
    DBMS_OUTPUT.PUT_LINE('Land ID:' || v_country_record.country_id 
        || ' Name: ' || v_country_record.country_name 
        || ' Region ID: ' || v_country_record.region_id);
END;
/

CREATE OR REPLACE PROCEDURE SHOW_COUNTRY(p_country_id countries.country_id%type)
AS v_country_record countries%ROWTYPE;
BEGIN
    SELECT *
        INTO v_country_record
        FROM countries
        WHERE country_id = UPPER(p_country_id);
    DBMS_OUTPUT.PUT_LINE('Land ID:' || v_country_record.country_id 
        || ' Name: ' || v_country_record.country_name 
        || ' Region ID: ' || v_country_record.region_id);
END;
/

-- Test für Deutschland
BEGIN
    SHOW_COUNTRY('DE');
END;
/

-- Test für Großbritannien
BEGIN
    SHOW_COUNTRY('UK');
END;
/

-- Test für USA
BEGIN
    SHOW_COUNTRY('US');
END;
/

-- ==========================================================
-- Aufgabe 3
-- Funktion zur Überprüfung  IBAN
-- ==========================================================

-- Funktion liefert 'OK' bei gültiger IBAN, sonst 'INVALID'

CREATE OR REPLACE FUNCTION pruefe_iban(p_iban IN VARCHAR2)
RETURN VARCHAR2
AS
    nummer NUMBER(24);       -- Umgestellte IBAN als Zahl
    pruefnummer NUMBER(2);      -- Prüfziffer der IBAN
BEGIN
    -- IBAN nach Standard umstellen (Länderkennung + Prüfziffer ans Ende)
    nummer :=SUBSTR(p_iban, 5 || '131400');

    -- Prüfziffer aus Position 3–4 ermitteln
    pruefnummer :=SUBSTR(p_iban, 3, 2);
    
    -- Vergleich nach Modulo-97-Verfahren
    IF pruefnummer = 98 - MOD(nummer, 97) THEN
        RETURN 'OK';
    ELSE
        RETURN 'INVALID';
    END IF;
END;
/

-- Mitarbeiterliste inkl. IBAN und Prüfergebnis ausgeben
SELECT
    s.employee_id,
    e.first_name,
    e.last_name,
    s.iban,
    e.salary,
    pruefe_iban(s.iban) AS is_valid
FROM 
    emp_account s 
    JOIN employees e ON s.employee_id = e.employee_id
ORDER BY
    s.employee_id;

-- ==========================================================
-- Aufgabe 4
-- Kontrollstrukturen - Sternchen basierend auf Gehalt
-- ==========================================================

-- Prozedur setzen Sternchen basierend auf Gehalt
CREATE OR REPLACE PROCEDURE set_employee_stars(v_empno emp.employee_id%TYPE)
AS
    v_asterisk emp.stars%TYPE := NULL;  -- hier werden die Sterne gespeichert
    v_sal emp.salary%TYPE;              -- Gehalt des Mitarbeiters
BEGIN   
     -- Gehalt des angegebenen Mitarbeiters lesen
    SELECT salary
    INTO v_sal
    FROM emp
    WHERE employee_id = v_empno;

    -- Pro 1000 € Gehalt ein Sternchen hinzufügen
    -- Die Schleife läuft so oft, wie das Gehalt durch 1000 gerundet ergibt
    FOR i IN 1..ROUND(v_sal / 1000) 
    LOOP
        v_asterisk := v_asterisk || '*';    -- in jeder Runde ein * anhängen
    END LOOP;
    
    -- Spalte stars aktualisieren
    UPDATE emp
    SET stars = v_asterisk
    WHERE employee_id = v_empno;
    
    COMMIT;
END;
/

-- Beispielaufruf für Mitarbeiter 176
BEGIN
    set_employee_stars(176);
END;
/

-- Mitarbeiter mit Sternchen anzeigen
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    stars
FROM emp
WHERE employee_id = 176;

--==========================================================
-- Aufgabe 5
-- Trigger zum automatischen Setzen der Sternchen
--==========================================================

CREATE OR REPLACE TRIGGER emp_set_stars
 BEFORE INSERT OR UPDATE ON emp
 FOR EACH ROW
DECLARE
    v_asterisk emp.stars%TYPE := NULL;  -- Zwischenpuffer für Sternchen
    v_sal emp.salary%TYPE;              -- Rundungsbasis
BEGIN
     -- Anzahl Sterne aus dem Gehalt ableiten
    v_sal := ROUND(:NEW.salary / 1000);
    
    -- Sternchen-Schleife, hängt pro 1000 € ein Stern an 
    FOR i IN 1..v_sal 
    LOOP
        v_asterisk := v_asterisk || '*';
    END LOOP;
    
    -- fertige Sternchen-Zeichenkette wird in  den neuen Datensatz geschrieben
    :NEW.stars := v_asterisk;
END;
/

--==========================================================
-- Aufgabe 6
-- Protokoll-Tabelle für Gehaltsänderungen
--==========================================================


CREATE OR REPLACE TRIGGER ueberpruefe_gehaltsaenderung
BEFORE INSERT OR UPDATE OF salary ON emp  -- wird ausgelöst bei INSERT oder wenn salary geändert wird
FOR EACH ROW
DECLARE
    v_hour NUMBER;                      -- aktuelle Stunde (0–23)
    v_day VARCHAR2(10);                 -- aktueller Wochentag
BEGIN
    -- aktuelle Uhrzeit und Wochentag abfragen
    v_hour := TO_NUMBER(TO_CHAR(SYSDATE, 'HH24'));
    v_day := TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH');
    
    IF 
        v_hour < 8 OR v_hour >= 18 OR v_day IN ('SAT', 'SUN') THEN
        -- falls ja: Änderung verbieten
        RAISE_APPLICATION_ERROR(-20001, 
            'Gehaltsänderungen nur werktags zwischen 8 und 18 Uhr!');
    END IF;
     -- Wenn sich das Gehalt tatsächlich ändert oder beim Einfügen ein neues Gehalt gesetzt wird
    IF :NEW.salary != :OLD.salary THEN
    -- Änderung in die Protokoll-Tabelle eintragen
        INSERT INTO salary_log (employee_id, old_salary, new_salary)
        VALUES (:NEW.employee_id, :OLD.salary, :NEW.salary);
    END IF;
END;
/    

-- Test: Gehalt des Mitarbeiters 176 um 1000 € erhöhen
UPDATE emp
SET salary = salary + 1000
WHERE employee_id = 176;

SELECT * FROM salary_log ORDER BY changed_at DESC;


-- ==========================================================
-- Aufgabe 7a
-- Prozedur zur Ausgabe eines Mitarbeiters
-- ==========================================================

CREATE OR REPLACE PROCEDURE output_employee(p_emp employees%ROWTYPE)
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('____________________________________________________');
    DBMS_OUTPUT.PUT_LINE('Mitarbeiter Nr.: ' || p_emp.employee_id);
    DBMS_OUTPUT.PUT_LINE('Name:            ' || p_emp.first_name || ' ' || p_emp.last_name);
    DBMS_OUTPUT.PUT_LINE('E-Mail:          ' || LOWER(p_emp.email) || '@oracle.com');
    DBMS_OUTPUT.PUT_LINE('Telefon Nr.:     ' || p_emp.phone_number);
    DBMS_OUTPUT.PUT_LINE('Eingestellt am:  ' || TO_CHAR(p_emp.hire_date, 'DD.MM.YY'));
    DBMS_OUTPUT.PUT_LINE('Gehalt:          ' || p_emp.salary || ' $');
    DBMS_OUTPUT.PUT_LINE('Beruf ID:        ' || p_emp.job_id);
    DBMS_OUTPUT.PUT_LINE('Abteilung Nr.:   ' || p_emp.department_id);
    DBMS_OUTPUT.PUT_LINE('Vorgesetzter Nr.:' || p_emp.manager_id);
    DBMS_OUTPUT.PUT_LINE('____________________________________________________');
END;
/

-- ==========================================================
-- Anonymer Block: Mitarbeiter holen und ausgeben
-- ==========================================================

DECLARE
    p_emp employees%ROWTYPE;   -- Variable, die die ganze Zeile speichern kann
BEGIN
    -- Mitarbeiter mit ID 101 aus der Tabelle holen
    SELECT * INTO p_emp
    FROM employees
    WHERE employee_id = 101;
    
    -- Prozedur zur Ausgabe aufrufen
    output_employee(p_emp);
END;
/

-- ==========================================================
-- Aufgabe 7b
-- Erweiterte Ausgabe eines Mitarbeiters mit Texten
-- ==========================================================

CREATE OR REPLACE PROCEDURE output_employee_b(p_emp employees%ROWTYPE)
AS
    v_job_title jobs.job_title%TYPE;                -- Jobtitel Mitarbeiters
    v_department_name departments.department_name%TYPE; -- Abteilungsname
    v_manager_name VARCHAR2(100);                   -- Name des Vorgesetzten
BEGIN
   -- Abteilungsname nur ermitteln, falls vorhanden
    IF p_emp.department_id IS NOT NULL THEN
        SELECT department_name
        INTO v_department_name
        FROM departments
        WHERE department_id = p_emp.department_id;
    END IF;

      -- Jobtitel zur Job-ID ermitteln
    SELECT job_title
    INTO v_job_title
    FROM jobs
    WHERE job_id = p_emp.job_id;

    -- Managername nur ermitteln, falls vorhanden
    IF p_emp.manager_id IS NOT NULL THEN
        SELECT first_name || ' ' || last_name
        INTO v_manager_name
        FROM employees
        WHERE employee_id = p_emp.manager_id;
    END IF;

    -- Ausgabe des formatierten Mitarbeiterprofils
    DBMS_OUTPUT.PUT_LINE('____________________________________________________');
    DBMS_OUTPUT.PUT_LINE('Mitarbeiter Nr.: ' || p_emp.employee_id);
    DBMS_OUTPUT.PUT_LINE('Name:            ' || p_emp.first_name || ' ' || p_emp.last_name);
    DBMS_OUTPUT.PUT_LINE('E-Mail:          ' || LOWER(p_emp.email) || '@oracle.com');
    DBMS_OUTPUT.PUT_LINE('Telefon Nr.:     ' || p_emp.phone_number);
    DBMS_OUTPUT.PUT_LINE('Eingestellt am:  ' || TO_CHAR(p_emp.hire_date, 'DD.MM.YY'));
    DBMS_OUTPUT.PUT_LINE('Gehalt:          ' || p_emp.salary || ' $');
    DBMS_OUTPUT.PUT_LINE('Beruf:           ' || v_job_title);
    DBMS_OUTPUT.PUT_LINE('Abteilung:       ' || v_department_name);
    DBMS_OUTPUT.PUT_LINE('Vorgesetzter:    ' || v_manager_name);
    DBMS_OUTPUT.PUT_LINE('____________________________________________________');
END;
/

--Test erweiterten Prozedur
DECLARE
    p_emp employees%ROWTYPE;
BEGIN
    SELECT * INTO p_emp
    FROM employees
    WHERE employee_id = 101;

    output_employee_b(p_emp);
END;
/

-- ==========================================================
-- Aufgabe 7c
-- Alle Mitarbeiter mit Cursor ausgeben
-- ==========================================================

CREATE OR REPLACE PROCEDURE output_employees
AS
    p_emp employees%ROWTYPE;   -- Variable für die Mitarbeiterdaten
   
    CURSOR emp_cursor        -- Cursor für alle Mitarbeiter der Tabelle
    IS
        SELECT * FROM employees;
    BEGIN
    -- Cursor öffnen und sequenziell verarbeiten
    OPEN emp_cursor;

    LOOP
        FETCH emp_cursor INTO p_emp;          -- nächsten Datensatz holen
        EXIT WHEN emp_cursor%NOTFOUND;        -- Schleife beenden, wenn keine Daten mehr da

        
        output_employee_b(p_emp);
    END LOOP;

    -- Cursor schließen
    CLOSE emp_cursor;
END;
/

--- Test der Prozedur zur Ausgabe aller Mitarbeiter
EXECUTE output_employees;

-- ==========================================================
-- Aufgabe 7d
-- Ausgabe von Mitarbeitern in einem bestimmten Bereich
-- (von-bis und wahlweise auf- oder absteigend)
-- ==========================================================

CREATE OR REPLACE PROCEDURE output_employee_set(
    from_employee   IN NUMBER,    -- Start-ID
    to_employee     IN NUMBER,    -- End-ID
    ascending_order IN BOOLEAN    -- TRUE = aufsteigend, FALSE = absteigend
)
AS

    p_emp employees%ROWTYPE;     -- Variable für Mitarbeiterdaten
CURSOR c_employees
IS
    -- Cursor für aufsteigende Reihenfolge
    SELECT *
    FROM employees
    WHERE employee_id BETWEEN from_employee AND to_employee
    ORDER BY employee_id ASC;

-- Cursor für absteigende Reihenfolge
CURSOR c_employees_desc
IS
    SELECT *
    FROM employees
    WHERE employee_id BETWEEN from_employee AND to_employee
    ORDER BY employee_id DESC;


BEGIN
    IF ascending_order THEN
    -- Aufsteigende Ausgabe
    FOR emp_record IN c_employees 
    LOOP
        output_employee_b(emp_record);
    END LOOP;
    ELSE
    -- Absteigende Ausgabe
    FOR emp_record IN c_employees_desc 
    LOOP
        output_employee_b(emp_record);
    END LOOP;
    END IF;
END;
/

-- Aufsteigend
BEGIN
    output_employee_set(100, 105, TRUE);
END;
/

-- Absteigend
BEGIN
    output_employee_set(100, 105, FALSE);
END;
/
-- ==========================================================
-- Aufgabe 8
-- Ausgabe eines Mitarbeiters nach Nachnamen + Exception Handling
-- ==========================================================
CREATE OR REPLACE PROCEDURE output_employee_by_name(p_last_name IN employees.last_name%TYPE)
AS
p_emp employees%ROWTYPE;
    v_job_title jobs.job_title%TYPE;
    v_department_name departments.department_name%TYPE;
    v_manager_name VARCHAR2(100);
BEGIN
    -- Mitarbeiter-Daten anhand Nachname holen
    SELECT *
    INTO p_emp
    FROM employees
    WHERE UPPER(last_name) = UPPER(p_last_name);

    
    IF p_emp.department_id IS NOT NULL THEN
        SELECT department_name
        INTO v_department_name
        FROM departments
        WHERE department_id = p_emp.department_id;
    END IF;

    
    SELECT job_title
    INTO v_job_title
    FROM jobs
    WHERE job_id = p_emp.job_id;


    IF p_emp.manager_id IS NOT NULL THEN
        SELECT first_name || ' ' || last_name
        INTO v_manager_name
        FROM employees
        WHERE employee_id = p_emp.manager_id;
    END IF;

    -- Ausgabe des formatierten Mitarbeiterprofils
    DBMS_OUTPUT.PUT_LINE('____________________________________________________');
    DBMS_OUTPUT.PUT_LINE('Mitarbeiter Nr.: ' || p_emp.employee_id);
    DBMS_OUTPUT.PUT_LINE('Name:            ' || p_emp.first_name || ' ' || p_emp.last_name);
    DBMS_OUTPUT.PUT_LINE('E-Mail:          ' || LOWER(p_emp.email) || '@oracle.com');
    DBMS_OUTPUT.PUT_LINE('Telefon Nr.:     ' || p_emp.phone_number);
    DBMS_OUTPUT.PUT_LINE('Eingestellt am:  ' || TO_CHAR(p_emp.hire_date, 'DD.MM.YY'));
    DBMS_OUTPUT.PUT_LINE('Gehalt:          ' || p_emp.salary || ' $');
    DBMS_OUTPUT.PUT_LINE('Beruf:           ' || v_job_title);
    DBMS_OUTPUT.PUT_LINE('Abteilung:       ' || v_department_name);
    DBMS_OUTPUT.PUT_LINE('Vorgesetzter:    ' || v_manager_name);
    DBMS_OUTPUT.PUT_LINE('____________________________________________________');

-- ==========================================================
-- Exception Handling
-- ==========================================================
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Kein Mitarbeiter mit Nachnamen "' || p_last_name || '" gefunden.');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Mehrere Mitarbeiter mit Nachnamen "' || p_last_name || '" gefunden.');
        DBMS_OUTPUT.PUT_LINE('Bitte spezifischeren Namen angeben.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Fehler');
END;
/

-- 1. Eindeutiger Name (funktioniert)
BEGIN
    output_employee_by_name('Kochhar');
END;
/

-- 2. Kein Treffer (NO_DATA_FOUND)
BEGIN
    output_employee_by_name('Unbekannt');
END;
/

-- 3. Mehrere Treffer (TOO_MANY_ROWS)
BEGIN
    output_employee_by_name('Smith');  -- falls mehrfach vorhanden
END;
/
SPOOl OFF;