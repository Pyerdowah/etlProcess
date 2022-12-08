-- usuwanie widoku
If (object_id('transportView') is not null) 
	Drop View transportView;


-- stworzenie widoku
go

delete from transport
go
CREATE VIEW transportView
AS
SELECT DISTINCT
	OfferMaster.dbo.transport.meanoftransport as [srodekLokomocji],
	OfferMaster.dbo.transport.cityofdeparture as [miejsceWyjazdu],
	OfferMaster.dbo.transport.nameofcompany as [nazwaFirmy]
FROM OfferMaster.dbo.transport;


-- wypelnienie danymi hurtowni
go
MERGE INTO wycieczka.dbo.transport	USING transportView
		ON wycieczka.dbo.transport.srodekLokomocji = transportView.srodekLokomocji
		AND wycieczka.dbo.transport.miejsceWyjazdu = transportView.miejsceWyjazdu
		AND wycieczka.dbo.transport.nazwaFirmy = transportView.nazwaFirmy
		
		WHEN Not Matched
			THEN
				INSERT
				Values (
				transportView.srodekLokomocji,
				transportView.miejsceWyjazdu,
				transportView.nazwaFirmy
				);


-- usuwanie widoku
go
Drop View transportView;