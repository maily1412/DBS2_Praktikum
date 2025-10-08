SET ECHO ON

/* DBS2: Beispiel Blatt01 mit Fehlern */
/* Autor: Thomas Rakow, HS Düsseldorf */

/* Verwendete Namenskonvention:
 *  Es werden aussagekraeftige und möglichst spezifische Bezeichner gewählt, 
 *  so wird das gebraeuchlicher Kurs statt kurs verwendet um die Lesbarkeit zu erhoehen und 
 *  einen besseren Bezug zur Fachlichkeit herzustellen. 
*/

/* Korrekturen der Fehler wie im folgenden Beispiel direkt unterhalb der 
   geänderten Stelle vermerken: */
-- FEHLER: Integritätsbedingung für den Primärschlüssel wurde verletzt.
-- ABHILFE: Korrekter Wert für Primärschlüssel verwendet.

/* ======================================================== */
/* Schema aufbauen */
/* Voraussetzung: Rechte zum DROP & CREATE sind vorhanden */

  
/* Altes Schema ggf. löschen*/
DROP TABLE Dozent;
DROP TABLE Kurs;
DROP TABLE Student; 

CREATE TABLE Dozent (
       PersId		NUMBER (4), 
       Name 		VARCHAR2 (10) NOT NULL, 
       Fach 		VARCHAR2 (20), 
       Buero 		VARCHAR2 (6),                    
       CONSTRAINT Dozent_PK PRIMARY KEY (PersId)
);

CREATE TABLE Kurs (
       KursNr        NUMBER(3) CONSTRAINT Kurs_PK PRIMARY KEY, -- Fehler: KursNr doppelt angegeben   Abhilfe: (KursNr) welassen
       Name          VARCHAR2(40) NOT NULL, -- Fehler: Komma vor dem NOT NULL      Abhilfe: Komma wegmachen 
       Deputat       NUMBER(2), 
       PersId	       NUMBER(4));

ALTER TABLE Kurs
ADD CONSTRAINT KursPersIDFK
       FOREIGN KEY (PersId) REFERENCES Dozent(PersId) -- Fehler: Spalte PersId      Abhilfe: Komma wegmachen 
;

CREATE TABLE Student (
       MatrNr	       NUMBER (5),
       Name	       VARCHAR2 (20) NOT NULL,
       Semester      NUMBER (2),
       CONSTRAINT StudentPK PRIMARY KEY (MatrNr)
);

COMMIT;

/* ======================================================== */
/* Daten einfügen */
/* Vorhandene Daten werden nicht gelöscht oder überschrieben!*/

--Dozent einfügen

INSERT INTO Dozent 
VALUES (3450, 'Doerries', 'Mathematik', '4.2.38');

-- FEHLER: Name hatte mehr als 10 Zeichen        ABHILFE: Name kürzen oder größeres VARCHAR() für Name benutzen 
ALTER TABLE Dozent MODIFY Name VARCHAR2(20);

INSERT INTO Dozent (PersId, Name, Fach)
VALUES (4001, 'Schwab-Trapp', 'Mediengestaltung');

INSERT INTO Dozent 
VALUES (4711, 'Dahm', 'Informatik', '4.2.10'); -- FEHLER: falsche Anführungszeichen "..."  ABHILFE: richtige Anführungszeichen einsetzen '...'

INSERT INTO Dozent 
VALUES (4712, 'Rakow', 'Informatik', '4.2.39');

INSERT INTO Dozent 
VALUES (4713, 'Geiger', 'Informatik', '4.2.05'); -- FEHLER: Integritätsbedingung für den Primärschlüssel wurde verletzt.      -- ABHILFE: Korrekter Wert für Primärschlüssel verwendet.

INSERT INTO Dozent 
VALUES (4714, 'Asal',  'Audiovisuelle Medien', '4.3.09');

-- Kurs einfügen

INSERT INTO Kurs 
VALUES (100, 'Mathematik 2', 7, 3450);

INSERT INTO Kurs 
VALUES (115, 'Mediengestaltung 2', 6, 4001);

INSERT INTO Kurs 
VALUES (106, 'Objektorientiertes Programmieren 2', 8, 4711); -- FEHLER: PersID hat 5 Ziffern, aber es sind maximal nur 4 erlaubt      ABHILFE: letzte Ziffer weglassen

INSERT INTO Kurs 
VALUES (111, 'Datenbanksysteme 2', 7, 4712);

/**
INSERT INTO Kurs     -- wurde schon hinzugefügt
VALUES (115, 'Mediengestaltung 2', 6, 4001);
**/

INSERT INTO Kurs 
VALUES (104, 'FMA', 5, 4713);

--Student einfügen

INSERT INTO Student (MatrNr, Name, Semester) 
VALUES (24002, 'Xenokrates', 18); 
 
INSERT INTO Student (MatrNr, Name, Semester) 
VALUES (25403, 'Jonas', 12);                         

INSERT INTO Student (MatrNr, Name, Semester) 
VALUES (26830, 'Aristoxenos', 8); 
 
INSERT INTO Student (MatrNr, Name, Semester) 
VALUES (27550, 'Schopenhauer', 6); 

INSERT INTO Student (MatrNr, Name, Semester) 
VALUES (28106, 'Carnap', 3); 
 
INSERT INTO Student (MatrNr, Name, Semester) 
VALUES (29120, 'Theophrastos', 9); -- FEHLER: ein Wert hat gefehlt    ABHILFE: fehlenden Wert einfügen/ergänzen 
 
INSERT INTO Student (MatrNr, Name, Semester) 
VALUES (29555, 'Feuerbach', 2);

-- Daten persistent in die Datenbank einfuegen
-- ROLLBACK;  FEHLER: Macht Änderungen rückgängig, aber wir wollen es speichern 
Commit;

/* ======================================================== */
/* Daten aller Relationen ausgeben*/

SELECT * FROM Dozent ORDER BY PersId;
SELECT * FROM Kurs ORDER BY KursNr;
SELECT * FROM Student ORDER BY MatrNr;


/* ======================================================== */
/* Aufgabe 2 */
/* Welche Regeln für die Namensgebung (Namenskonvention) wurden umge-
setzt, welche nicht? Fügen Sie die Antwort in die SQL-Datei ein. 

1. Tabellen Name im Singular
2. "Name" kommt in allen drei Tabellen vor -> zu unspezifisch, besser wäre DozentName, KursName, StudentName
3. Constraint-Namen uneinheitlich, z.B. in Zeile 50 -> besser wäre Student_PK und in Zeile 42 -> besser wäre Kurs_Dozent_FK
4. Datentyp korrekt verwendet
5. einheitliche Schreibweise ohne Umlaute oder Sonderzeichen
*/

ALTER TABLE Dozent
RENAME COLUMN Name TO DozentName;

ALTER TABLE Kurs
RENAME COLUMN Name TO KursName;

ALTER TABLE Student
RENAME COLUMN Name TO StudentName;

ALTER TABLE Student
RENAME CONSTRAINT StudentPK TO Student_PK;

ALTER TABLE Kurs
RENAME CONSTRAINT KursPersIDFK TO Kurs_Dozent_FK;


/* ======================================================== */
/* Aufgabe 3 */
SELECT MIN(SEMESTER) 
FROM STUDENT;

SELECT *
FROM STUDENT
WHERE SEMESTER = (
       SELECT MIN(Semester)
       FROM STUDENT
);

/* ================================================== */
/* Aufgabe 4 */



/* ================================================== */
/* Aufgabe 5 */

/* ================================================== */
/* Aufgabe 6 */


/* Ende des Skripts */
