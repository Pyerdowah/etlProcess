CREATE FUNCTION getImie(
    @imie varchar(15),
	@nazwisko varchar(30)
)
RETURNS varchar(100)
AS 
BEGIN
    RETURN COALESCE(@imie + ' ' + @nazwisko, '');
END;
go
delete from pracownik
-- usuwanie widoku
If (object_id('pracownikView') is not null) 
	Drop View pracownikView;

If (object_id('pracownikTmp') is not null) 
	Drop table pracownikTmp;
-- stworzenie widoku
go

create table employeeTmp(
	employeeid bigint primary key,
	age int,
	lengthofwork int,
	salary numeric,
	agency int,
	firstname varchar(15),
	lastname varchar(30)
)
go

bulk insert employeeTmp from 'c:\users\paulina\documents\github\datagenerator\employee_t1.bulk' with (datafiletype = 'widechar', fieldterminator='|')
go

CREATE VIEW pracownikView
AS
SELECT DISTINCT
		when OfferMaster.dbo.employee.lengthofwork = 4 or OfferMaster.dbo.employee.lengthofwork = 11 or  OfferMaster.dbo.employee.age = 24 or OfferMaster.dbo.employee.age = 31 or OfferMaster.dbo.employee.age = 51 then
	OfferMaster.dbo.employee.employeeid as [IDpracownika],
	CASE
		WHEN OfferMaster.dbo.employee.lengthofwork between 0 and 3 THEN 'poni¿ej 3 lat'
		WHEN OfferMaster.dbo.employee.lengthofwork between 4 and 10 THEN 'pomiêdy 3-10 lat'
		WHEN OfferMaster.dbo.employee.lengthofwork > 10 THEN 'powy¿ej 10 lat'
	END AS [dlugoscPracyNaStanowisku],
	CASE
		WHEN OfferMaster.dbo.employee.age between 18 and 23 THEN '18-23 lat'
		WHEN OfferMaster.dbo.employee.age between 24 and 30 THEN '24-30 lat'
		WHEN OfferMaster.dbo.employee.age between 31 and 50 THEN '30-50 lat'
		WHEN OfferMaster.dbo.employee.age > 50 THEN 'powy¿ej 50 lat'
	END AS [wiek],
	CASE
		WHEN OfferMaster.dbo.employee.salary between 0.0 and 5000.0 THEN 'poni¿ej 5 tys z³'
		WHEN OfferMaster.dbo.employee.salary between 5000.1 and 7000.0 THEN 'pomiêdzy 5-7 tys z³'
		WHEN OfferMaster.dbo.employee.salary between 7000.1 and 10000.0 THEN 'pomiêdzy 7-10 tys z³'
		WHEN OfferMaster.dbo.employee.salary > 10000.0 THEN 'powy¿ej 10 tys z³'
	END AS [pensja],
		CASE
		WHEN OfferMaster.dbo.employee.agency = 1 THEN 'Filia 1'
		WHEN OfferMaster.dbo.employee.agency = 2 THEN 'Filia 2'
		WHEN OfferMaster.dbo.employee.agency = 3 THEN 'Filia 3'
		WHEN OfferMaster.dbo.employee.agency = 4 THEN 'Filia 4'
		WHEN OfferMaster.dbo.employee.agency = 5 THEN 'Filia 5'
	END AS [filia],
	(select dbo.getImie(OfferMaster.dbo.employee.firstname, OfferMaster.dbo.employee.lastname)) as [imieINazwisko],
	case 
		when OfferMaster.dbo.employee.lengthofwork = 4 or OfferMaster.dbo.employee.lengthofwork = 11 then 1
		WHEN OfferMaster.dbo.employee.age = 24 or OfferMaster.dbo.employee.age = 31 or OfferMaster.dbo.employee.age = 51 then 1
	end AS [aktualnoscRekordu]
FROM OfferMaster.dbo.employee;


-- wypelnienie danymi hurtowni
go
MERGE INTO wycieczka.dbo.pracownik	USING pracownikView
		ON wycieczka.dbo.pracownik.IDpracownika = pracownikView.IDpracownika
		AND wycieczka.dbo.pracownik.dlugoscPracyNaStanowisku = pracownikView.dlugoscPracyNaStanowisku
		AND wycieczka.dbo.pracownik.wiek = pracownikView.wiek
		AND wycieczka.dbo.pracownik.pensja = pracownikView.pensja
		AND wycieczka.dbo.pracownik.filia = pracownikView.filia
		AND wycieczka.dbo.pracownik.imieINazwisko = pracownikView.imieINazwisko
		AND wycieczka.dbo.pracownik.aktualnoscRekordu = pracownikView.aktualnoscRekordu
		WHEN Not Matched
			THEN
				INSERT
				Values (
					pracownikView.IDpracownika,
					pracownikView.dlugoscPracyNaStanowisku,
					pracownikView.wiek,
					pracownikView.pensja,
					pracownikView.filia,
					pracownikView.imieINazwisko,
					pracownikView.aktualnoscRekordu
				);


-- usuwanie widoku
go
select * from pracownikView
select * from OfferMaster.dbo.employee
Drop View pracownikView;
go 
drop table employeeTmp;
drop function dbo.getImie



