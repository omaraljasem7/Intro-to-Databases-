# This is code for Transforming ERD into Relation with crow's foot notation 
## see  [dbdiagram.io](https://dbdiagram.io/)
### copy & paste the code -> see the Result 
``` sql 
Table Mitarbeiter{
  mitarbeiter_id integer [primary key]
  vorname varchar
  nachname varchar
  anstellungsart varchar
  wochenarbeitsstunden decimal
  position varchar
  strasse varchar 
  hausnummer varchar 
  plz integer
  city VARCHAR
  manager_id integer [ref: > Mitarbeiter.mitarbeiter_id] // refernce to itself as fk  

}

Table Teilprojekt{
  project_id integer [primary key]
  budget decimal 
  arbeitsstundeneinschaetzung decimal
}


// hier gibt es eine tabelle arbeit zwischen mitarbeiter und projekt
TABLE arbeitet_in {
  mitarbeiter_id integer  [ref: > Mitarbeiter.mitarbeiter_id,not null]  // many to many 
  project_id integer [ref: > Teilprojekt.project_id,not null ] // many to many 
  datum date 
  arbeitszeit decimal
  PRIMARY KEY (mitarbeiter_id, project_id, datum)

  
}


// Ref mitarbeiter_projekt : Teilprojekt.project_id <> Mitarbeiter.mitarbeiter_id // many to many 

TABLE Lieferant {
  lieferant_id int [primary key]
  name varchar 
  strasse varchar 
  city varchar 
  hausnummer integer 
}

TABLE Lieferung {
  lieferant_id integer  [ref: > Lieferant.lieferant_id, not null] // one to many 
  lieferung_id integer 
  project_id integer [ref: > Teilprojekt.project_id, not null]
  menge integer
  preis decimal 
  material varchar
  lieferung_datum date
  PRIMARY KEY (lieferung_id)
}


TABLE Unfall {
  unfall_id integer 
  project_id integer  [ref: > Teilprojekt.project_id ,not null] // one to many 
  verletzung varchar
  sachschaden varchar 
  PRIMARY KEY (unfall_id)
}
// unfall kann mehrere mitarbiter haben n:m relationship 

TABLE Unfall_Mitarbeiter {
  unfall_id integer [ ref: > Unfall.unfall_id , not null ]
  mitarbeiter_id integer [ref : > Mitarbeiter.mitarbeiter_id , not null]
  PRIMARY KEY (unfall_id , mitarbeiter_id)
}
/*
// relationship gehört zu 
// many to many relationship betewenn projekt and lieferung 
TABLE lieferrung_in_projekt{
  lieferent_id integer  [ref: > Teilprojekt.project_id ,not null] // one to many from projekt to gehört zu 
  lieferung_id integer [ref: > Lieferung.lieferung_id ,not null]
  project_id integer [ref: > Lieferant.lieferant_id, not null]
  primary key (lieferent_id,lieferung_id,project_id)

}

*/

```