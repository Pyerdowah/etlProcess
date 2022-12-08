
-- usuwanie widoku
If (object_id('zorganizowanieWycieczkiView') is not null) 
	Drop View zorganizowanieWycieczkiView;

go

create table zorganizowanieWycieczkiTmp (
	nazwisko varchar(30),
	IDoferty bigint,
	liczbaWykupionychMiejsc int,
	rodzajUbezpieczenia varchar(15),
	rodzajWyzywienia varchar(2),
	kwotaZap³acona numeric
)
go 
bulk insert zorganizowanieWycieczkiTmp from 'C:\Users\Paulina\source\repos\etlProcess\hd skrypcioszki\fake_data_t2.csv' with ( fieldterminator=',', rowterminator='\n')
go

CREATE VIEW zorganizowanieWycieczkiView
AS
SELECT DISTINCT
	(select min(IDoferty) from wycieczka.dbo.oferta where wycieczka.dbo.oferta.sezon = OfferMaster.dbo.offer.season) as [IDoferty],
	(select min(IDpracownika) from wycieczka.dbo.pracownik where wycieczka.dbo.pracownik.IDpracownika = OfferMaster.dbo.offer.employeeid and wycieczka.dbo.pracownik.aktualnoscrekordu = 1) as [IDpracownika],
	(select min(IDdaty) from wycieczka.dbo.tabelaData where wycieczka.dbo.tabelaData.dataa = OfferMaster.dbo.offer.dateofstart  and zorganizowanieWycieczkiTmp.IDoferty = OfferMaster.dbo.offer.offerid) as [IDdatyRozpoczeciaWycieczki],
	(select min(IDtransportu) from wycieczka.dbo.transport where wycieczka.dbo.transport.miejsceWyjazdu = OfferMaster.dbo.transport.cityofdeparture and wycieczka.dbo.transport.srodekLokomocji = OfferMaster.dbo.transport.meanoftransport and wycieczka.dbo.transport.nazwaFirmy = OfferMaster.dbo.transport.nameofcompany) as [IDtransportu],
	(select min(IDubezpieczenia) from wycieczka.dbo.ubezpieczenie where wycieczka.dbo.ubezpieczenie.rodzajUbezpieczenia = OfferMaster.dbo.insurance.kind) as [IDubezpieczenia],
	(select min(IDhotelu) from wycieczka.dbo.hotel where wycieczka.dbo.hotel.nazwa = OfferMaster.dbo.hotel.nameofhotel and wycieczka.dbo.hotel.kraj = OfferMaster.dbo.hotel.country) as [IDhotelu],
	1 as [IDpobytu],
	(select min(IDdaty) from wycieczka.dbo.tabelaData where wycieczka.dbo.tabelaData.dataa = OfferMaster.dbo.transport.dateofcontract) as [IDdatyZawarciaUmowyZFirmaTransportowa],
	(select min(SUM(Cast(liczbaWykupionychMiejsc as numeric(10,2)))) from zorganizowanieWycieczkiTmp where zorganizowanieWycieczkiTmp.IDoferty = OfferMaster.dbo.offer.offerid) as [liczbaMiejscWykupionychPrzezKlientow],
	(select min(SUM(Cast(kwotaZap³acona as numeric(10,2)))) from zorganizowanieWycieczkiTmp where zorganizowanieWycieczkiTmp.IDoferty = OfferMaster.dbo.offer.offerid) as [dochodZKupnaWycieczek],
	(select min(numberofseats) from OfferMaster.dbo.offer where zorganizowanieWycieczkiTmp.IDoferty = OfferMaster.dbo.offer.offerid) as [liczbaWszystkichDostepnychMiejscWTejOfercie],
	(select min(numberofseats * costperperson) from OfferMaster.dbo.offer where zorganizowanieWycieczkiTmp.IDoferty = OfferMaster.dbo.offer.offerid) as [kosztZorganizowaniaWycieczki],
	(select min(numberofseats * costperperson - SUM(Cast(kwotaZap³acona as numeric(10,2)))) from OfferMaster.dbo.offer, zorganizowanieWycieczkiTmp where zorganizowanieWycieczkiTmp.IDoferty = OfferMaster.dbo.offer.offerid) as [zysk]	
FROM OfferMaster.dbo.offer, wycieczka.dbo.oferta, OfferMaster.dbo.transport, OfferMaster.dbo.insurance, OfferMaster.dbo.hotel, zorganizowanieWycieczkiTmp where  zorganizowanieWycieczkiTmp.IDoferty = OfferMaster.dbo.offer.offerid;


-- wypelnienie danymi hurtowni
go

MERGE INTO wycieczka.dbo.zorganizowanieWycieczki USING zorganizowanieWycieczkiView
		ON wycieczka.dbo.zorganizowanieWycieczki.IDoferty = zorganizowanieWycieczkiView.IDoferty
		AND wycieczka.dbo.zorganizowanieWycieczki.IDpracownika = zorganizowanieWycieczkiView.IDpracownika
		AND wycieczka.dbo.zorganizowanieWycieczki.IDdatyRozpoczeciaWycieczki = zorganizowanieWycieczkiView.IDdatyRozpoczeciaWycieczki
		AND wycieczka.dbo.zorganizowanieWycieczki.IDtransportu = zorganizowanieWycieczkiView.IDtransportu
		AND wycieczka.dbo.zorganizowanieWycieczki.IDubezpieczenia = zorganizowanieWycieczkiView.IDubezpieczenia
		AND wycieczka.dbo.zorganizowanieWycieczki.IDhotelu = zorganizowanieWycieczkiView.IDhotelu
		AND wycieczka.dbo.zorganizowanieWycieczki.IDpobytu = zorganizowanieWycieczkiView.IDpobytu
		AND wycieczka.dbo.zorganizowanieWycieczki.IDdatyZawarciaUmowyZFirmaTransportowa = zorganizowanieWycieczkiView.IDdatyZawarciaUmowyZFirmaTransportowa
		AND wycieczka.dbo.zorganizowanieWycieczki.liczbaMiejscWykupionychPrzezKlientow = zorganizowanieWycieczkiView.liczbaMiejscWykupionychPrzezKlientow
		AND wycieczka.dbo.zorganizowanieWycieczki.dochodZKupnaWycieczek = zorganizowanieWycieczkiView.dochodZKupnaWycieczek
		AND wycieczka.dbo.zorganizowanieWycieczki.liczbaWszystkichDostepnychMiejscWTejOfercie = zorganizowanieWycieczkiView.liczbaWszystkichDostepnychMiejscWTejOfercie
		AND wycieczka.dbo.zorganizowanieWycieczki.zysk = zorganizowanieWycieczkiView.zysk
				AND wycieczka.dbo.zorganizowanieWycieczki.kosztZorganizowaniaWycieczki = zorganizowanieWycieczkiView.kosztZorganizowaniaWycieczki
		WHEN Not Matched
			THEN
				INSERT
				Values (
					zorganizowanieWycieczkiView.IDoferty,
					zorganizowanieWycieczkiView.IDpracownika,
					zorganizowanieWycieczkiView.IDdatyRozpoczeciaWycieczki,
					zorganizowanieWycieczkiView.IDtransportu,
					zorganizowanieWycieczkiView.IDubezpieczenia,
					zorganizowanieWycieczkiView.IDhotelu,
					zorganizowanieWycieczkiView.IDpobytu,
					zorganizowanieWycieczkiView.IDdatyZawarciaUmowyZFirmaTransportowa,
					zorganizowanieWycieczkiView.liczbaMiejscWykupionychPrzezKlientow,
					zorganizowanieWycieczkiView.dochodZKupnaWycieczek,
					zorganizowanieWycieczkiView.liczbaWszystkichDostepnychMiejscWTejOfercie,
					zorganizowanieWycieczkiView.zysk,
					zorganizowanieWycieczkiView.kosztZorganizowaniaWycieczki
				)			
		WHEN Not Matched By Source
			THEN DELETE;


-- usuwanie widoku
go
Drop View zorganizowanieWycieczkiView;
drop table zorganizowanieWycieczkiTmp
go 

select * from zorganizowanieWycieczki
