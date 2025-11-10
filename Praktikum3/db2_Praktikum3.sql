DROP TABLE Katalog_Artikel ;
DROP TABLE Haushaltsware ;
DROP TABLE Lebensmittel ;
DROP TABLE Bild ;
DROP TABLE Artikel ;
DROP TABLE Katalog ;
DROP TABLE Lieferservice ;

-- Tabellen neu anlegen

CREATE TABLE Lieferservice (
    service_id     NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY, -- automatisch fortlaufend
    service_name   VARCHAR2(100) NOT NULL, -- Pflichtfeld
    adresse        VARCHAR2(255)
);

CREATE TABLE Katalog (
    katalog_id          NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY, -- automatisch fortlaufend
    katalog_name        VARCHAR2(100) NOT NULL, -- Pflichtfeld
    katalog_service_id  NUMBER,
    CONSTRAINT fk_katalog_lieferservice FOREIGN KEY (katalog_service_id) REFERENCES Lieferservice(service_id) -- FK verknüpft Katalog mit Lieferservice
);

CREATE TABLE Artikel (
    artikelnummer  NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    bezeichnung    VARCHAR2(100) NOT NULL,
    preis          NUMBER(10,2) NOT NULL,
    beschreibung   CLOB
);

CREATE TABLE Lebensmittel (
    artikelnummer   NUMBER PRIMARY KEY,
    gewicht         NUMBER(10,2),
    zusammensetzung CLOB,
    CONSTRAINT fk_lebensmittel_artikel FOREIGN KEY (artikelnummer) REFERENCES Artikel(artikelnummer) ON DELETE CASCADE
);


CREATE TABLE Haushaltsware (
    artikelnummer  NUMBER PRIMARY KEY,
    farbe          VARCHAR2(50),
    garantie_bis   DATE,
    CONSTRAINT fk_haushaltsware_artikel FOREIGN KEY (artikelnummer) REFERENCES Artikel(artikelnummer) ON DELETE CASCADE
);

CREATE TABLE Bild (
    bild_id        NUMBER GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1) PRIMARY KEY,
    dateipfad      VARCHAR2(255) NOT NULL,
    titel          VARCHAR2(100),
    artikelnummer  NUMBER,
    CONSTRAINT fk_bild_artikel FOREIGN KEY (artikelnummer) REFERENCES Artikel(artikelnummer)
);

CREATE TABLE Katalog_Artikel (
    katalog_id     NUMBER,
    artikelnummer  NUMBER,
    CONSTRAINT pk_katalog_artikel PRIMARY KEY (katalog_id, artikelnummer),
    CONSTRAINT fk_ka_katalog FOREIGN KEY (katalog_id) REFERENCES Katalog(katalog_id) ON DELETE CASCADE,
    CONSTRAINT fk_ka_artikel FOREIGN KEY (artikelnummer) REFERENCES Artikel(artikelnummer) ON DELETE CASCADE
);

-- Beispieldaten einfügen Aufgabe 2. a)

-- (Optionaler Lieferservice-Eintrag, falls nötig)
INSERT INTO Lieferservice (service_name, adresse)
VALUES ('MediFood Lieferservice', 'Hochschulstraße 1, Düsseldorf');

-- Kataloge
INSERT INTO Katalog (katalog_name, katalog_service_id) VALUES
('Alltagsprodukte', 1);
INSERT INTO Katalog (katalog_name, katalog_service_id) VALUES
('Sonderangebote', 1);
INSERT INTO Katalog (katalog_name, katalog_service_id) VALUES
('Küchenausstattung', 1);

-- Artikel (Oberklasse)
INSERT INTO Artikel (bezeichnung, preis, beschreibung) VALUES
('Brot', 2.99, 'Gesundes Brot');
INSERT INTO Artikel (bezeichnung, preis, beschreibung) VALUES
('Butter', 0.99, 'Natürlich hergestellt');
INSERT INTO Artikel (bezeichnung, preis, beschreibung) VALUES
('Messer', 4.99, 'Aus Edelstahl');
INSERT INTO Artikel (bezeichnung, preis, beschreibung) VALUES
('Brettchen', 3.99, 'Aus Holz');
INSERT INTO Artikel (bezeichnung, preis, beschreibung) VALUES
('Teller', 7.99, 'Aus Keramik');

-- Unterklassen: Lebensmittel
INSERT INTO Lebensmittel (artikelnummer, gewicht, zusammensetzung) VALUES
(1, 1000, 'Vollkorn');
INSERT INTO Lebensmittel (artikelnummer, gewicht, zusammensetzung) VALUES
(2, 250, 'Milch');

-- Unterklassen: Haushaltswaren
INSERT INTO Haushaltsware (artikelnummer, farbe, garantie_bis) VALUES
(3, 'Silber', DATE '2030-12-31');
INSERT INTO Haushaltsware (artikelnummer, farbe, garantie_bis) VALUES
(4, 'Braun', DATE '2027-12-31');
INSERT INTO Haushaltsware (artikelnummer, farbe, garantie_bis) VALUES
(5, 'Blau',  NULL);

-- Beziehungen Artikel ↔ Katalog
INSERT INTO Katalog_Artikel (katalog_id, artikelnummer) VALUES
(1, 1);              -- Brot → Alltagsprodukte
INSERT INTO Katalog_Artikel (katalog_id, artikelnummer) VALUES
(1, 2);
INSERT INTO Katalog_Artikel (katalog_id, artikelnummer) VALUES
(2, 2);      -- Butter → Alltagsprodukte, Sonderangebote
INSERT INTO Katalog_Artikel (katalog_id, artikelnummer) VALUES
(3, 3);              -- Messer → Küchenausstattung
INSERT INTO Katalog_Artikel (katalog_id, artikelnummer) VALUES
(3, 4);              -- Brettchen → Küchenausstattung
INSERT INTO Katalog_Artikel (katalog_id, artikelnummer) VALUES
(3, 5);
INSERT INTO Katalog_Artikel (katalog_id, artikelnummer) VALUES
(2, 5);      -- Teller → Küchenausstattung, Sonderangebote

-- Aufgabe 2. b) : Alle Relationen ausgeben

SELECT * FROM Lieferservice;
SELECT * FROM Katalog;
SELECT * FROM Artikel;
SELECT * FROM Lebensmittel;
SELECT * FROM Haushaltsware;
SELECT * FROM Bild;
SELECT * FROM Katalog_Artikel;

-- Formatierung für 0.99 Euro
CREATE OR REPLACE VIEW Artikel_View AS
SELECT 
    artikelnummer,
    bezeichnung,
    TO_CHAR(preis, 'FM9990.00') AS preis,
    beschreibung
FROM Artikel;

SELECT * FROM Artikel_View;

