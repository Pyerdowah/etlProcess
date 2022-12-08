CREATE FUNCTION getMiejscowosc(
    @quantity varchar(100)
)
RETURNS varchar(30)
AS 
BEGIN
	DECLARE @Names VARCHAR(MAX)  
	SELECT @Names = COALESCE(@Names + ' ', '') + [value] 
	FROM (select value from string_split((SELECT TOP 1 * FROM STRING_SPLIT(@quantity, ',')), ' ') where value not like '%[0-9]%') as value
    RETURN @Names;
END;
go


-- usuwanie widoku
If (object_id('hotelView') is not null) 
	Drop View hotelView;


-- stworzenie widoku
go
delete from hotel
go
CREATE VIEW hotelView
AS
SELECT DISTINCT
	CASE
		WHEN OfferMaster.dbo.hotel.numberofstars = 1 THEN '1 gwiazdka'
		WHEN OfferMaster.dbo.hotel.numberofstars = 2 THEN '2 gwiazdki'
		WHEN OfferMaster.dbo.hotel.numberofstars = 3 THEN '3 gwiazdki'
		WHEN OfferMaster.dbo.hotel.numberofstars = 4 THEN '4 gwiazdki'
		WHEN OfferMaster.dbo.hotel.numberofstars = 5 THEN '5 gwiazdek'
	END AS [liczbaGwiazdek],
	OfferMaster.dbo.hotel.nameofhotel as [nazwa],
	OfferMaster.dbo.hotel.country as [kraj],
	(SELECT TOP 1 T.* FROM 
	(SELECT TOP 2 * FROM STRING_SPLIT(OfferMaster.dbo.hotel.addressofhotel, ',') ORDER BY value ASC) AS T
	ORDER BY value DESC) as [nazwaUlicy],
	(select value from string_split((SELECT TOP 1 * FROM STRING_SPLIT(OfferMaster.dbo.hotel.addressofhotel, ',')), ' ') where value like '%[0-9]%') as [numerLokalu],
	(select dbo.getMiejscowosc(OfferMaster.dbo.hotel.addressofhotel)) as [miejscowosc]
FROM OfferMaster.dbo.hotel;


-- wypelnienie danymi hurtowni
go
MERGE INTO wycieczka.dbo.hotel	USING hotelView
		ON wycieczka.dbo.hotel.liczbaGwiazdek = hotelView.liczbaGwiazdek
		AND wycieczka.dbo.hotel.nazwa = hotelView.nazwa
		AND wycieczka.dbo.hotel.nazwaUlicy = hotelView.nazwaUlicy
		AND wycieczka.dbo.hotel.numerLokalu = hotelView.numerLokalu
		AND wycieczka.dbo.hotel.miejscowosc = hotelView.miejscowosc
		AND wycieczka.dbo.hotel.kraj = hotelView.kraj
		
		WHEN Not Matched
			THEN
				INSERT
				Values (
				hotelView.liczbaGwiazdek,
				hotelView.nazwa,
				hotelView.nazwaUlicy,
				hotelView.numerLokalu,
				hotelView.miejscowosc,
				hotelView.kraj
				);


-- usuwanie widoku
go
Drop View hotelView;
drop function dbo.getMiejscowosc

select * from OfferMaster.dbo.hotel