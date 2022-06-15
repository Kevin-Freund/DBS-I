
--Aufgabe 1.1 Tabellenerstellung
CREATE TABLE Mitarbeiter (
	MitID char(3) PRIMARY KEY Not Null,
	MitName varchar(20) Not Null,
	MitVorname varchar(20) Null,
	MitGebDat Date Not Null,
	MitJob varchar(20) Not Null,
	MitStundensatz smallmoney Null,
	MitEinsatzort varchar(20) Null
)

Create Table Kunde (
	KunNr Int PRIMARY KEY Not Null,
	KunName varchar(20) Not Null,
	KunOrt varchar(20) Not Null,
	KunPLZ char(5) Not Null,
	KunStrasse varchar(20) Not Null
)

Create Table Ersatzteil (
	EtID char(5) Primary Key Not Null,
	EtBezeichnung varchar(100) Not Null,
	EtPreis smallmoney Not Null,
	EtAnzLager Int Not Null,
	EtHersteller varchar(30) Not Null
)

--Aufgabe 1.2 Import der Daten
INSERT INTO Mitarbeiter SELECT * FROM trommelhelden..quelleMitarbeiter
INSERT INTO Kunde SELECT * FROM trommelhelden..quelleKunde
INSERT INTO Ersatzteil SELECT * FROM trommelhelden..quelleErsatzteil

--Aufgabe 1.3 Kopie von Tabellen
SELECT * INTO Auftrag FROM trommelhelden..quelleAuftrag
SELECT * INTO Montage FROM trommelhelden..quelleMontage

--Aufgabe 1.4 Ändern von Schlüsseln
Alter Table Auftrag Add Primary Key (AufNr);
Alter Table Auftrag Add Foreign Key (MitID) References Mitarbeiter(MitID);
Alter Table Auftrag Add Foreign Key (KunNr) References Kunde(KunNr);

Alter Table Montage Add Primary Key (EtID, AufNr);
Alter Table Montage Add Foreign Key (EtID) References Ersatzteil(EtID);
Alter Table Montage Add Foreign Key (AufNr) References Auftrag(AufNr);


Select * From Auftrag

--Aufgabe 1.5 
--Rechtsklick, Design

--Aufgabe 1.6 Datensätze zählen
Select Count(*) From Auftrag;


--Aufgabe 2.1
--a)
SELECT Count(*) FROM Kunde WHERE KunOrt = 'Radebeul'
SELECT * FROM Kunde WHERE KunOrt = 'Radebeul'

--b)
SELECT * FROM Kunde WHERE KunOrt NOT LIKE 'Chemnitz' 

--c)
Select * From Ersatzteil Where EtBezeichnung Like 'S%'

--d)
Select * From Auftrag Where Anfahrt > 80 Or (1.9 < Dauer And Dauer < 3.1)

--e)
Select MitName, MitVorname, MitJob from Mitarbeiter Where MitEinsatzort = 'Radebeul' Order by MitName 

--f)
Select Count(*) from Auftrag Where Dauer is Null

--g)
Select *, Anfahrt*2.50 as Anfahrtskosten from Auftrag Where Anfahrt is not null

--h)
SELECT EtPreis*EtAnzLager AS Warenbestand_in_Euro FROM Ersatzteil


--Aufgabe 2.2 
--a)
Select MitName, MitVorname, MitGebDat, Case when DateAdd(year, DateDiff(year, MitGebDat, GetDate()), MitGebDat) > GetDate() then DateDiff(Year, MitGebDat, GetDate()) - 1 else DateDiff(Year, MitGebDat, Getdate()) end as MitAlter from Mitarbeiter
--b)
Select avg(DateDiff(day, AufDat, ErlDat)) as durchschnittliche_Frist from Auftrag where month(ErlDat) = month(GetDate())
--c)
Select Aufnr, Case when Dauer is Null then 0 else Dauer end as Auftragsdauer from Auftrag



--Aufgabe 2.3
--a)
Select count(*) from Kunde
--b)
Select Count(*), KunOrt from Kunde group by KunOrt
--c)
Select avg(Dauer) as Durchschnitt, MitID from Auftrag where Dauer is not null group by MitID 
--d) 
Select (Min(Dauer)+Max(Dauer)/2) as Durchschnitt_Min_Max, MitID from Auftrag where Dauer is not null group by MitID 
--e)
Select avg(Dauer) as Durchschnitt, MItID, ErlDat, (count(AufNr)) as Auftraege from Auftrag Where MitID is not Null and Dauer is not Null Group By MitID, ErlDat;
--f)
Select Min(ErlDat) as geplante_Erledigung from Auftrag where Dauer is null 


--Aufgabe 2.4
--a)
SELECT MitJob, avg(datediff(year,MitGebDat, getdate())) AS Durchschnittsalter FROM Mitarbeiter GROUP BY MitJob; 
--b) 
Select MitID, avg(Dauer) as durchschnittliche_Dauer, (datename(weekday,ErlDat)) as Wochentag from Auftrag where MitID is not NULL group by MitId, (datename(weekday,ErlDat));


--Aufgabe 2.5
--a)
SELECT AufNr, EtBezeichnung, Anzahl, EtPreis, Anzahl*EtPreis as Ersatzteilkosten FROM Montage m, Ersatzteil e WHERE m.EtID = e.EtID ORDER BY AufNr;    
SELECT AufNr, EtBezeichnung, Anzahl, EtPreis, Anzahl*EtPreis as Ersatzteilkosten FROM Montage m Join Ersatzteil e on m.EtID = e.EtID ORDER BY AufNr;  
--b)
Select AufNr, m.MitID, m.MitStundensatz, a.Dauer, m.MitStundensatz * Cast(a.Dauer as smallmoney) as Lohnkosten from Auftrag a Join Mitarbeiter m on a.MitID = m.MitID Where Dauer is not Null
--c)
Select KunName, KunOrt, Anfahrt from Kunde k Join Auftrag a on k.KunNr = a.KunNr Where Anfahrt > 50 Order by Anfahrt
--d)
Select KunName, a.AufNr, ErlDat, e.EtID from Kunde k Join Auftrag a on k.KunNr = a.KunNr Join Montage m on a.AufNr = m.AufNr Join Ersatzteil e on e.EtID = m.EtID Where  e.EtID = 'H0230' And DateDiff(month, ErlDat, GetDate()) < 3 And Dauer is not Null 
--e)
Select a.AufNr, Anzahl*EtPreis as Materialkosten, MitStundensatz* Cast(a.Dauer as smallmoney) as Lohnkosten, a.Anfahrt*2.50 as Anfahrtskosten from Auftrag a Join Mitarbeiter m on m.MitID = a.MitID Join Montage mt on a.AufNr = mt.AufNr Join Ersatzteil e on e.EtID = mt.EtID Where Anfahrt is not null
--f)
Select AufNr, Case when a.MitID is Null then 'nicht festgelegt' else m.MitName end as Mitarbeiter, AufDat from Auftrag a left Join Mitarbeiter m on a.MitID = m.MitID Where month(AufDat) = month(GetDate())
Select * from Auftrag Where month(AufDat) = month(GetDate())
--g)
Select EtBezeichnung, m.EtID, Sum(Anzahl) as Gebrauch from Ersatzteil e Join Montage m on e.EtID = m.EtID Join Auftrag a on a.AufNr = m.AufNr Where month(AufDat) = month(GetDate()) group by EtBezeichnung, m.EtID

--Aufgabe 2.6
--a)
Select m.MitID, m.MitName from Mitarbeiter m Where Not Exists (Select a.MitID from Auftrag a Where month(GetDate()) = month(GetDate()) And a.MitID = m.MitID)
--b)
Select a.AufNr from Auftrag a Where Not Exists (Select m.AufNr from Montage m Where a.AufNr = m.AufNr)
--Gegensumme
Select Count(AufNr) as Summe from Montage Group by AufNr
--c)
Select AufNr, AufDat from Auftrag Where AufDat = (Select Min(AufDat) from Auftrag Where Dauer is Null)
