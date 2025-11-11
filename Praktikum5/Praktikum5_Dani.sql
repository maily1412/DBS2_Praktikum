-- ==========================================================
-- Praktikum 5
-- ==========================================================

Set SERVEROUTPUT ON;
Set Echo ON;

-- ==========================================================
-- Wenn ich das Skript mehrmals ausführe, lösche ich die Tabelle zuerst
-- ==========================================================

DROP TABLE Staedte CASCADE CONSTRAINTS;

-- ==========================================================
-- Aufgabe 1a
-- Tabelle Stadte erstellen
-- ==========================================================

-- Einheiten: 
-- Stadtname: Text (VARCHAR2)
-- Breitengrad: Dezimalgrad (NUMBER)
-- Längengrad: Dezimalgrad (NUMBER) 

CREATE TABLE Staedte (
    Stadtname VARCHAR(50) PRIMARY KEY,      -- Name der Stadt
    Breitengrad NUMBER(10,2),          -- Breitengrad  in Dezimal
    Laengengrad NUMBER(10,2)      -- Längengrad in Dezimal

);

-- ==========================================================
-- Aufgabe 1b
-- Daten in die Tabelle Städte einfügen
-- ==========================================================

-- View erstellen zur Zeilenaufteilung
CREATE OR REPLACE VIEW staedte_lines 
AS
WITH rws AS(
    SELECT data
    AS str
    FROM user001.webservice_loads
    WHERE id = 2
)    
-- Splitten von Texten
SELECT TRIM(REGEXP_SUBSTR(
         str,
         '[^.]+',         -- alles bis zum nächsten Punkt
         1,
         LEVEL
       )) AS value
FROM rws
CONNECT BY LEVEL <= LENGTH(TRIM(BOTH '.' FROM str)) - LENGTH(REPLACE(str, '.')) + 1;

-- Der CONNECT BY-Teil sorgt dafür, dass jede Zeile bis zum nächsten Punkt extrahiert wird.

-- Schauen ab welcher Position die Werte beginnne
DECLARE
  line VARCHAR2(4000);
BEGIN 
     -- Jede Zeile aus der View durchlaufen
  FOR r IN (SELECT value FROM staedte_lines) LOOP 
   -- Zeilenumbruch entfernen
    line := REPLACE(REPLACE(r.value, CHR(10), ''), CHR(13), '');

 -- Die folgenden Zeilen testen, an welcher Position im String sich die Werte befinden
    DBMS_OUTPUT.PUT_LINE(SUBSTR(line, 1, 2));        -- Grad Nord
    DBMS_OUTPUT.PUT_LINE('m:'||SUBSTR(line, 5, 2));  -- Minuten Nord
    DBMS_OUTPUT.PUT_LINE('g:'||SUBSTR(line, 12, 1)); -- Grad Ost
    DBMS_OUTPUT.PUT_LINE('m:'||SUBSTR(line, 15, 2)); -- Minuten Ost
    DBMS_OUTPUT.PUT_LINE('s:'||SUBSTR(line, 22));    -- Stadtname
  END LOOP;
END;
/

-- Daten in die Tabelle Städte einfügen
DECLARE
    v_line VARCHAR2(1000);
    n_g NUMBER(10,2);
    n_m NUMBER(10,2);
    o_g NUMBER(10,2);
    o_m NUMBER(10,2);
    stadtname VARCHAR2(100);
BEGIN
    FOR r IN (SELECT value FROM staedte_lines) LOOP 
         -- Zeilenumbrüche entfernen
        v_line := REPLACE(REPLACE(r.value, CHR(10), ''), CHR(13), '');

        -- Einzelne Werte aus der Textzeile an den jeweiligen Positionen auslesen
        n_g := TO_NUMBER(SUBSTR(v_line, 1, 2));        -- Grad Nord
        n_m := TO_NUMBER(SUBSTR(v_line, 5, 2));        -- Minuten Nord
        o_g := TO_NUMBER(SUBSTR(v_line, 12, 1));       -- Grad Ost
        o_m := TO_NUMBER(SUBSTR(v_line, 15, 2));       -- Minuten Ost
        stadtname := SUBSTR(v_line, 22);               -- Stadtname

        -- Umrechnung Minuten --> Dezimal 
        INSERT INTO Staedte (Stadtname, Breitengrad, Laengengrad)
        VALUES (
            stadtname,
            n_g + n_m / 60,     -- Nordkoordinate in Dezimal
            o_g + o_m / 60      -- Ostkoordinate in Dezimal
        );
    END LOOP;
END;
/

-- Test: Alle Daten aus der Tabelle Städte anzeigen
Select * From Staedte;

-- ==========================================================
-- Aufgabe 1c
-- Funktion: Abstand zwischen zwei Städten (km, mit Erdkrümmung)
-- ==========================================================

CREATE OR REPLACE FUNCTION abstand (a staedte%ROWTYPE, b staedte%ROWTYPE)
RETURN NUMBER
AS
    dist_y NUMBER(10,5);        -- Nord-Süd-Distanz
    dist_x NUMBER(10,5);        -- Ost-West-Distanz
    rad CONSTANT NUMBER := ACOS(-1) / 180; -- Grad --> Radiant-Umrechnungsfaktor
    erdradius CONSTANT NUMBER := 6378.137; -- Erdradius in km
    distanz NUMBER(10,2);
BEGIN
 -- Längengrad-Differenz, korrigiert um den Cosinus des mittleren Breitengrads zu ermitteln
    dist_x := (b.Laengengrad - a.Laengengrad) * COS((a.Breitengrad + b.Breitengrad) / 2 * rad);
    
    -- Differenz der Breitengrade (Nord-Süd)
    dist_y := b.Breitengrad - a.Breitengrad;
    
    -- Pythagoras auf der Kugeloberfläche, dann in km umrechnen
    distanz := erdradius * rad * SQRT(dist_x * dist_x + dist_y * dist_y);
    
    RETURN ROUND(distanz, 2);
END abstand;
/

-- Test: Entfernung zwischen Düsseldorf und Köln
DECLARE
    stadt_a staedte%ROWTYPE;
    stadt_b staedte%ROWTYPE;
    entfernung NUMBER;
BEGIN
  -- Daten für Düsseldorf und Köln aus Tabelle holen
    SELECT * INTO stadt_a FROM Staedte WHERE Stadtname = 'Düsseldorf';
    SELECT * INTO stadt_b FROM Staedte WHERE Stadtname = 'Köln';
    
    -- Abstand berechnen
    entfernung := abstand(stadt_a, stadt_b);
    
    DBMS_OUTPUT.PUT_LINE('Entfernung zwischen Düsseldorf und Köln: ' ||  entfernung || ' km');
END;
/

-- ==========================================================
-- Aufgabe 1d
-- Prozedur: Entfernungstabelle (nutzt meine ROWTYPE-Funktion abstand)
-- ==========================================================
CREATE OR REPLACE PROCEDURE entfernungs_tabelle AS
BEGIN
  -- Überschrift: 2-Buchstaben-Kürzel je Stadt
  DBMS_OUTPUT.PUT('-                  ');
  FOR stadt IN (SELECT * FROM Staedte ORDER BY Stadtname) LOOP
    DBMS_OUTPUT.PUT(LPAD(SUBSTR(stadt.Stadtname, 1, 2), 10));
  END LOOP;
  DBMS_OUTPUT.NEW_LINE;

  -- Matrix: Zeile = Ausgangsstadt, Spalte = Zielstadt
  FOR stadt IN (SELECT * FROM Staedte ORDER BY Stadtname) LOOP
    DBMS_OUTPUT.PUT(RPAD(stadt.Stadtname, 20));
    FOR ziel IN (SELECT * FROM Staedte ORDER BY Stadtname) LOOP
      -- wichtig: TO_CHAR mit Format-Model, nicht „10”
      DBMS_OUTPUT.PUT(LPAD(TO_CHAR(abstand(stadt, ziel), 'FM9990.00'), 10));
    END LOOP;
    DBMS_OUTPUT.NEW_LINE;
  END LOOP;
END;
/

-- Test: Entfernungstabelle ausgeben
EXECUTE entfernungs_tabelle();
