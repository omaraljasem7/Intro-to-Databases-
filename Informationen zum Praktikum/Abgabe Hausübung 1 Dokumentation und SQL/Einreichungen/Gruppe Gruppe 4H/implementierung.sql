CREATE TABLE Mitarbeiter(
    mitarbeiter_id INT PRIMARY KEY ,
    vorname varchar(50) ,
    nachname varchar(50) , 
    anstellungsart varchar(50) , 
    wochenarbeitsstunden decimal(10,2) , 
    position varchar(50) , 
    strasse varchar (50) , 
    hausnummer varchar (50) , 
    plz integer  , 
    city VARCHAR(50)
);

-- 2nd table 
CREATE TABLE Teilprojekt (
    project_id integer PRIMARY KEY ,
    budget decimal (10,2),
    arbeitsstundeneinschaetzung decimal(10,2)
)
-- unique constraint 
ALTER TABLE Teilprojekt 
add UNIQUE (project_id); 
-- 3rd table 
CREATE TABLE arbeitet_in (
	mitarbeiter_id integer NOT NULL,
	project_id integer  NOT NULL,
	  datum DATE ,
     arbeitszeit decimal(10,2),
	 PRIMARY KEY (mitarbeiter_id, project_id, datum),  
CONSTRAINT mitarbeiter_fk 
FOREIGN KEY (mitarbeiter_id ) REFERENCES Mitarbeiter
(mitarbeiter_id),
 CONSTRAINT project_fk 
FOREIGN KEY (project_id ) REFERENCES Teilprojekt
(project_id )
ON DELETE CASCADE 
ON UPDATE CASCADE 
);

-- 4 th table 

CREATE TABLE Unfall (
    unfall_id INT not null PRIMARY KEY ,
    project_id INT NOT NULL REFERENCES Teilprojekt (project_id) ,
    verletzung VARCHAR(50) ,
    sachschaden VARCHAR(50) 
    ON DELETE CASCADE 
    ON UPDATE CASCADE 
);

ALTER TABLE Unfall 
ADD column unfall_datum  DATE ; 

-- 5th table 
CREATE TABLE Unfall_Mitarbeiter (
unfall_id int not null ,
mitarbeiter_id int not null REFERENCES  Mitarbeiter(mitarbeiter_id),
PRIMARY KEY (unfall_id, mitarbeiter_id)
);

-- fk on unfall 
ALTER TABLE Unfall_Mitarbeiter
ADD CONSTRAINT unfall_mitarbeiter_fk
FOREIGN KEY (unfall_id)
REFERENCES Unfall (unfall_id)

-- 6th table 

CREATE TABLE Lieferant(
  lieferant_id integer PRIMARY KEY,
  name varchar(50) ,
  strasse varchar (50),
  city varchar(50),
  hausnummer integer 
);

-- Lieferung 

CREATE TABLE Lieferung (
    lieferung_id integer PRIMARY KEY  not null,
    lieferant_id integer not null, 
    project_id  integer not null ,
    menge integer , 
    preis decimal(10,2), 
    material varchar (50),
    lieferung_datum DATE,
    FOREIGN KEY (project_id ) REFERENCES Teilprojekt
    (project_id )
    ON DELETE CASCADE 
    ON UPDATE CASCADE 
);

ALTER TABLE Lieferung 
ADD CONSTRAINT lieferung_fk 
FOREIGN KEY (lieferant_id)
REFERENCES Lieferant (lieferant_id);
-- add column 
ALTER TABLE mitarbeiter 
ADD COLUMN manager_id int ;
-- 
ALTER TABLE mitarbeiter 
ADD CONSTRAINT mitarbeiter_fk 
FOREIGN KEY (manager_id) REFERENCES Mitarbeiter(mitarbeiter_id) 

-- testdaten 

INSERT INTO Mitarbeiter VALUES
(1, 'Anna', 'Müller', 'Vollzeit', 40, 'Ingenieurin', 'Hauptstr', '1', 35000, 'Gießen', NULL),
(2, 'Ben', 'Schmidt', 'Vollzeit', 40, 'Techniker', 'Nebenstr', '5', 35000, 'Gießen', 1),
(3, 'Clara', 'Weber', 'Teilzeit', 20, 'Technikerin', 'Ringstr', '12', 35000, 'Gießen', 1),
(4, 'David', 'Klein', 'Vollzeit', 40, 'Bauleiter', 'Marktstr', '7', 35000, 'Gießen', NULL);


INSERT INTO Teilprojekt VALUES
(100, 100000, 500),
(101, 80000, 200),
(102, 60000, 0);


INSERT INTO arbeitet_in VALUES
(2, 100, '2024-01-10', 8),
(2, 100, '2024-01-11', 8),
(3, 100, '2024-01-10', 4),
(3, 101, '2024-01-12', 4),
(1, 101, '2024-01-10', 8),
(4, 102, '2024-01-08', 8);


INSERT INTO Lieferant VALUES
(10, 'SteelCorp', 'Industriestr', 'Frankfurt', 20),
(11, 'BuildMat', 'Werkstr', 'Kassel', 3);

INSERT INTO Lieferung VALUES
(1000, 10, 100, 50, 20000, 'Stahl', '2024-01-05'),
(1001, 10, 100, 30, 15000, 'Stahl', '2024-01-15'),
(1002, 11, 101, 40, 10000, 'Beton', '2024-01-07'),
(1003, 11, 101, 20, 7000, 'Stahl', '2024-01-18'),
(1004, 10, 102, 10, 3000, 'Aluminium', '2023-06-10');


INSERT INTO Unfall VALUES
(500, 100, 'Schnittverletzung', 'Werkzeug beschädigt', '2024-02-01'),
(501, 100, 'Prellung', 'Kein Schaden', '2024-03-10'),
(502, 101, 'Sturz', 'Gerüst beschädigt', '2023-11-20');

INSERT INTO Unfall_Mitarbeiter VALUES
(500, 2),
(500, 3),
(501, 2),
(502, 3);


ALTER TABLE teilprojekt
ADD COLUMN projekt_name VARCHAR(50) 

UPDATE teilprojekt 
set projekt_name = 'Energieversorgung' where project_id=100 

UPDATE teilprojekt
set projekt_name = 'Lebenserhaltung' where   project_id=101


UPDATE teilprojekt
set projekt_name = 'Kommunikationssystem' where project_id=102 

-- Lösung zu den Aufgaben 
-- mit zwischenschritten und finale lösung 

/* Wann wird die Raumstation voraussichtlich fertiggestellt sein? (Errechenbar über bisherige
Arbeitszeit pro Woche und Restzeit der Projekte) 
*/
-- das oberprojekt aller teilprojekte 
INSERT INTO teilprojekt (project_id,budget,arbeitsstundeneinschaetzung,projekt_name,status)
VALUES(1,500000.00,900,'Raumstation','offen') 

-- restdauer in wochen 
WITH rest AS (
  SELECT SUM(arbeitsstundeneinschaetzung) AS reststunden
  FROM Teilprojekt
),
speed AS (
  SELECT AVG(stunden_pro_woche) AS std_pro_woche
  FROM (
    SELECT DATE_TRUNC('week', datum) AS woche,
           SUM(arbeitszeit) AS stunden_pro_woche
    FROM arbeitet_in
    GROUP BY DATE_TRUNC('week', datum)
  ) w
)
SELECT
  rest.reststunden / speed.std_pro_woche AS restdauer_wochen
FROM rest, speed;
-- date  

WITH restdauer AS (
  SELECT
    (SUM(tp.arbeitsstundeneinschaetzung) /
     AVG(w.stunden_pro_woche)) AS wochen
  FROM Teilprojekt tp,
       (SELECT DATE_TRUNC('week', datum) AS woche,
               SUM(arbeitszeit) AS stunden_pro_woche
        FROM arbeitet_in
        GROUP BY DATE_TRUNC('week', datum)) w
),
letztes_datum AS (
  SELECT MAX(datum) AS letztes_arbeitsdatum
  FROM arbeitet_in
)
SELECT
  letztes_datum.letztes_arbeitsdatum
  + (restdauer.wochen * INTERVAL '1 week') AS voraussichtliches_fertigstellungsdatum
FROM restdauer, letztes_datum;


-- • Welche Teilprojekte haben ihr Budget überschritten?

SELECT t.project_id , t.budget, t.projekt_name,
sum(l.preis*l.menge)
from lieferung l 
JOIN teilprojekt t 
on l.project_id = t.project_id
group by (t.project_id)
HAVING sum(l.preis*l.menge) > t.budget
ORDER BY t.project_id;
-- • Welches Baumaterial wird besonders oft benötigt?

SELECT material, 
sum(menge)
from lieferung l 
group by material 
ORDER BY sum(menge) DESC
LIMIT 1

-- • Wie viele Teilprojekte sind abgeschlossen?

SELECT * from teilprojekt 
where status ='abgeschlossen' OR arbeitsstundeneinschaetzung = 0 ; 

-- • Unter welchem Supervisor sind im letzten Jahr die meisten Unfälle passiert?
-- solution step by step 
-- hier sieht man welche mitarbeiter haben welche unfälle bei welchem manager 

SELECT m.mitarbeiter_id, concat(m.vorname , ' ' , m.nachname ) as full_name,
m.manager_id,count(*) 
from mitarbeiter m 
JOIN unfall_mitarbeiter u 
ON m.mitarbeiter_id = u.mitarbeiter_id
group by m.mitarbeiter_id , full_name , manager_id

-- dann subquery für die manger 
-- wer ist der manager 

SELECT * from mitarbeiter where manager_id IS NOT NULL ; 

-- gib mir das jahr vom datum 
SELECT EXTRACT(YEAR FROM current_date );
-- add 1 year to current_date 

SELECT current_date + interval '1 year'; 
-- sub
SELECT EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '1 year');
-- alle informationen zu den unfällen die passiert sind im letzen jahr 
SELECT m.mitarbeiter_id,m.manager_id, concat(m.vorname , ' ' , m.nachname ) as full_name,
m.manager_id,um.unfall_id ,u.verletzung,u.sachschaden, u. unfall_datum , 
EXTRACT(YEAR FROM unfall_datum ), 
concat(mgr.vorname,' ',mgr.nachname) as manager_name
from mitarbeiter m 
JOIN unfall_mitarbeiter um
ON m.mitarbeiter_id = um.mitarbeiter_id
JOIN unfall u 
ON um. unfall_id = u.unfall_id
JOIN mitarbeiter mgr
    ON m.manager_id = mgr.mitarbeiter_id
WHERE EXTRACT(YEAR FROM unfall_datum )=EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '1 year'); 
-- richtige lösung

-- finale lösung 

SELECT  concat(mgr.vorname,' ',mgr.nachname) as manager_name, 
count (*) as number_of_accedients 
from mitarbeiter m 
JOIN unfall_mitarbeiter um
ON m.mitarbeiter_id = um.mitarbeiter_id
JOIN unfall u 
ON um. unfall_id = u.unfall_id
JOIN mitarbeiter mgr
    ON m.manager_id = mgr.mitarbeiter_id
WHERE EXTRACT(YEAR FROM unfall_datum )=EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '1 year')
group by mgr.manager_id ,manager_name 
-- update dates for last year 
UPDATE unfall 
set unfall_datum ='2025-02-01' where unfall_id = 500;

UPDATE unfall 
set unfall_datum ='2025-03-10' where unfall_id = 501;

-- add column for status of a project 

ALTER TABLE teilprojekt
ADD COLUMN status VARCHAR (50) ;
UPDATE teilprojekt 
SET status = 'offen' where project_id = 100 ;

UPDATE teilprojekt 
SET status = 'offen' where project_id = 101 ;

UPDATE teilprojekt 
SET status = 'abgeschlossen' where project_id = 102;
