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

If (object_id('pracownikView2') is not null) 
	Drop table pracownikView2;
-- stworzenie widoku
go

CREATE VIEW pracownikView
AS
SELECT DISTINCT
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
	1 AS [aktualnoscRekordu]
FROM OfferMaster.dbo.employee;
go
CREATE VIEW pracownikView2
AS
SELECT DISTINCT
	OfferMaster.dbo.employee.employeeid as [IDpracownika],
	CASE
		WHEN OfferMaster.dbo.employee.lengthofwork between 0 and 4 THEN 'poni¿ej 3 lat'
		WHEN OfferMaster.dbo.employee.lengthofwork between 5 and 11 THEN 'pomiêdy 3-10 lat'
		WHEN OfferMaster.dbo.employee.lengthofwork > 11 THEN 'powy¿ej 10 lat'
	END AS [dlugoscPracyNaStanowisku],
	CASE
		WHEN OfferMaster.dbo.employee.age between 18 and 24 THEN '18-23 lat'
		WHEN OfferMaster.dbo.employee.age between 25 and 31 THEN '24-30 lat'
		WHEN OfferMaster.dbo.employee.age between 32 and 51 THEN '30-50 lat'
		WHEN OfferMaster.dbo.employee.age > 52 THEN 'powy¿ej 50 lat'
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
	0 AS [aktualnoscRekordu]
FROM OfferMaster.dbo.employee where (OfferMaster.dbo.employee.lengthofwork = 4 or OfferMaster.dbo.employee.lengthofwork = 11 or
		 OfferMaster.dbo.employee.age = 24 or OfferMaster.dbo.employee.age = 31 or OfferMaster.dbo.employee.age = 51) 


-- wypelnienie danymi hurtowni
go
MERGE INTO wycieczka.dbo.pracownik	USING pracownikView
		ON wycieczka.dbo.pracownik.IDpracownika = pracownikView.IDpracownika
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

MERGE INTO wycieczka.dbo.pracownik	USING pracownikView2
		ON 0=1
		WHEN not Matched
			THEN
				INSERT
				Values (
					pracownikView2.IDpracownika,
					pracownikView2.dlugoscPracyNaStanowisku,
					pracownikView2.wiek,
					pracownikView2.pensja,
					pracownikView2.filia,
					pracownikView2.imieINazwisko,
					pracownikView2.aktualnoscRekordu
				);


-- usuwanie widoku
go

Drop View pracownikView;
go 
drop view pracownikView2;
drop function dbo.getImie

select * from wycieczka.dbo.pracownik



