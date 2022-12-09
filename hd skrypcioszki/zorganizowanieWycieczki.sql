
-- usuwanie widoku
If (object_id('zorganizowanieWycieczkiView') is not null) 
	Drop View zorganizowanieWycieczkiView;
go
-- usuwanie widoku
If (object_id('zorganizowanieWycieczkiView2') is not null) 
	Drop View zorganizowanieWycieczkiView2;
go


-- usuwanie widoku
If (object_id('zorganizowanieWycieczkiTmp') is not null) 
	Drop table zorganizowanieWycieczkiTmp;
go

-- usuwanie widoku
If (object_id('zorganizowanieWycieczkiTmp2') is not null) 
	Drop View zorganizowanieWycieczkiTmp2;
go

-- usuwanie widoku
If (object_id('zorganizowanieWycieczkiTmp3') is not null) 
	Drop View zorganizowanieWycieczkiTmp3;
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


create view zorganizowanieWycieczkiTmp2 
as
select 
OfferMaster.dbo.offer.offerid as [IdOferty],
DATEDIFF(day, OfferMaster.dbo.offer.dateOfStart, OfferMaster.dbo.offer.dateOfEnd) as [d³ugoœæPobytu],
sum(liczbaWykupionychMiejsc)  as [sumaWykupionychMiejsc],
sum(kwotaZap³acona) as [sumaZap³acona],
OfferMaster.dbo.offer.numberOfSeats as [liczbaWszystkichMiejsc],
OfferMaster.dbo.offer.numberofseats * OfferMaster.dbo.offer.costperperson as [kosztZorganizowaniaWycieczki],
sum(kwotaZap³acona) - OfferMaster.dbo.offer.numberofseats * OfferMaster.dbo.offer.costperperson as [zysk]
from OfferMaster.dbo.offer, zorganizowanieWycieczkiTmp where OfferMaster.dbo.offer.offerid = zorganizowanieWycieczkiTmp.IDoferty group by OfferMaster.dbo.offer.offerid, OfferMaster.dbo.offer.dateofend, OfferMaster.dbo.offer.dateofstart, OfferMaster.dbo.offer.numberofseats, OfferMaster.dbo.offer.costperperson
go 

create view zorganizowanieWycieczkiTmp3
as
SELECT
OfferMaster.dbo.offer.offerid as [IdOferty],
DATEDIFF(day, OfferMaster.dbo.offer.dateOfStart, OfferMaster.dbo.offer.dateOfEnd) as [d³ugoœæPobytu],
0  as [sumaWykupionychMiejsc],
0 as [sumaZap³acona],
OfferMaster.dbo.offer.numberOfSeats as [liczbaWszystkichMiejsc],
OfferMaster.dbo.offer.numberofseats * OfferMaster.dbo.offer.costperperson as [kosztZorganizowaniaWycieczki],
- OfferMaster.dbo.offer.numberofseats * OfferMaster.dbo.offer.costperperson as [zysk]
FROM OfferMaster.dbo.offer LEFT JOIN zorganizowanieWycieczkiTmp ON OfferMaster.dbo.offer.offerid = zorganizowanieWycieczkiTmp.IDoferty WHERE zorganizowanieWycieczkiTmp.IDoferty IS NULL

go
create view zorganizowanieWycieczkiView
as
select 
	IDoferty = oferta.IDoferty,
	IDpracownika = pracownik.IDrekordu,
	IDdatyRozpoczeciaWycieczki = dataRozp.IDdaty,
	IDtransportu = transportt.IDtransportu,
	IDubezpieczenia = ubezpieczenie.IDubezpieczenia,
	IDhotelu = hotell.IDhotelu,
	CASE
		WHEN v2.d³ugoœæPobytu between 0 and 6 THEN (select wycieczka.dbo.pobyt.IDpobytu from wycieczka.dbo.pobyt where wycieczka.dbo.pobyt.dlugoscPobytu = 'poni¿ej tygodnia' )
		WHEN v2.d³ugoœæPobytu between 7 and 8 THEN (select wycieczka.dbo.pobyt.IDpobytu from wycieczka.dbo.pobyt where wycieczka.dbo.pobyt.dlugoscPobytu = 'tydzieñ' )
		WHEN v2.d³ugoœæPobytu between 9 and 12 THEN (select wycieczka.dbo.pobyt.IDpobytu from wycieczka.dbo.pobyt where wycieczka.dbo.pobyt.dlugoscPobytu = 'nieca³e dwa tygodnie' )
		WHEN v2.d³ugoœæPobytu between 13 and 15 THEN (select wycieczka.dbo.pobyt.IDpobytu from wycieczka.dbo.pobyt where wycieczka.dbo.pobyt.dlugoscPobytu = 'dwa tygodnie' )
	END AS [IDpobytu],
	IDdatyZawarciaUmowyZFirmaTransportowa = dataTransp.IDdaty,
	liczbaMiejscWykupionychPrzezKlientow = v2.sumaWykupionychMiejsc,
	dochodZKupnaWycieczek = v2.sumaZap³acona,
	liczbaWszystkichDostepnychMiejscWTejOfercie = v2.liczbaWszystkichMiejsc,
	zysk = v2.zysk,
	kosztZorganizowaniaWycieczki = v2.kosztZorganizowaniaWycieczki
	from OfferMaster.dbo.offer as offer
	join OfferMaster.dbo.transport on offer.transportid =  OfferMaster.dbo.transport.transportid
	join OfferMaster.dbo.stay on offer.stayid =  OfferMaster.dbo.stay.stayid
	join OfferMaster.dbo.insurance on offer.insuranceid =  OfferMaster.dbo.insurance.insuranceid
	join OfferMaster.dbo.hotel as hotel on OfferMaster.dbo.stay.hotelid = hotel.hotelid
	join wycieczka.dbo.ubezpieczenie as ubezpieczenie on ubezpieczenie.rodzajUbezpieczenia = OfferMaster.dbo.insurance.kind
	join wycieczka.dbo.oferta as oferta on offer.season = oferta.sezon
	join wycieczka.dbo.pracownik as pracownik on offer.employeeid = pracownik.IDpracownika and pracownik.aktualnoscrekordu = 1
	join wycieczka.dbo.tabelaData as dataRozp on offer.dateofstart = dataRozp.dataa
	join wycieczka.dbo.transport as transportt on OfferMaster.dbo.transport.meanoftransport = transportt.srodekLokomocji and OfferMaster.dbo.transport.cityofdeparture = transportt.miejsceWyjazdu and OfferMaster.dbo.transport.nameofcompany = transportt.nazwaFirmy
	join wycieczka.dbo.hotel as hotell on hotel.nameofhotel = hotell.nazwa and hotel.country = hotell.kraj
	join zorganizowanieWycieczkiTmp2 as v2 on offer.offerid = v2.IdOferty
	join wycieczka.dbo.tabelaData as dataTransp on OfferMaster.dbo.transport.dateofcontract = dataTransp.dataa


-- wypelnienie danymi hurtowni
go

create view zorganizowanieWycieczkiView2
as
select 
	IDoferty = oferta.IDoferty,
	IDpracownika = pracownik.IDrekordu,
	IDdatyRozpoczeciaWycieczki = dataRozp.IDdaty,
	IDtransportu = transportt.IDtransportu,
	IDubezpieczenia = ubezpieczenie.IDubezpieczenia,
	IDhotelu = hotell.IDhotelu,
	CASE
		WHEN v2.d³ugoœæPobytu between 0 and 6 THEN (select wycieczka.dbo.pobyt.IDpobytu from wycieczka.dbo.pobyt where wycieczka.dbo.pobyt.dlugoscPobytu = 'poni¿ej tygodnia' )
		WHEN v2.d³ugoœæPobytu between 7 and 8 THEN (select wycieczka.dbo.pobyt.IDpobytu from wycieczka.dbo.pobyt where wycieczka.dbo.pobyt.dlugoscPobytu = 'tydzieñ' )
		WHEN v2.d³ugoœæPobytu between 9 and 12 THEN (select wycieczka.dbo.pobyt.IDpobytu from wycieczka.dbo.pobyt where wycieczka.dbo.pobyt.dlugoscPobytu = 'nieca³e dwa tygodnie' )
		WHEN v2.d³ugoœæPobytu between 13 and 15 THEN (select wycieczka.dbo.pobyt.IDpobytu from wycieczka.dbo.pobyt where wycieczka.dbo.pobyt.dlugoscPobytu = 'dwa tygodnie' )
	END AS [IDpobytu],
	IDdatyZawarciaUmowyZFirmaTransportowa = dataTransp.IDdaty,
	liczbaMiejscWykupionychPrzezKlientow = v2.sumaWykupionychMiejsc,
	dochodZKupnaWycieczek = v2.sumaZap³acona,
	liczbaWszystkichDostepnychMiejscWTejOfercie = v2.liczbaWszystkichMiejsc,
	zysk = v2.zysk,
	kosztZorganizowaniaWycieczki = v2.kosztZorganizowaniaWycieczki
	from OfferMaster.dbo.offer as offer
	join OfferMaster.dbo.transport on offer.transportid =  OfferMaster.dbo.transport.transportid
	join OfferMaster.dbo.stay on offer.stayid =  OfferMaster.dbo.stay.stayid
	join OfferMaster.dbo.insurance on offer.insuranceid =  OfferMaster.dbo.insurance.insuranceid
	join OfferMaster.dbo.hotel as hotel on OfferMaster.dbo.stay.hotelid = hotel.hotelid
	join wycieczka.dbo.ubezpieczenie as ubezpieczenie on ubezpieczenie.rodzajUbezpieczenia = OfferMaster.dbo.insurance.kind
	join wycieczka.dbo.oferta as oferta on offer.season = oferta.sezon
	join wycieczka.dbo.pracownik as pracownik on offer.employeeid = pracownik.IDpracownika and pracownik.aktualnoscrekordu = 1
	join wycieczka.dbo.tabelaData as dataRozp on offer.dateofstart = dataRozp.dataa
	join wycieczka.dbo.transport as transportt on OfferMaster.dbo.transport.meanoftransport = transportt.srodekLokomocji and OfferMaster.dbo.transport.cityofdeparture = transportt.miejsceWyjazdu and OfferMaster.dbo.transport.nameofcompany = transportt.nazwaFirmy
	join wycieczka.dbo.hotel as hotell on hotel.nameofhotel = hotell.nazwa and hotel.country = hotell.kraj
	join zorganizowanieWycieczkiTmp3 as v2 on offer.offerid = v2.IdOferty
	join wycieczka.dbo.tabelaData as dataTransp on OfferMaster.dbo.transport.dateofcontract = dataTransp.dataa


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
					zorganizowanieWycieczkiView.zysk,
					zorganizowanieWycieczkiView.liczbaWszystkichDostepnychMiejscWTejOfercie,
					zorganizowanieWycieczkiView.kosztZorganizowaniaWycieczki
				);


-- usuwanie widoku
go

MERGE INTO wycieczka.dbo.zorganizowanieWycieczki USING zorganizowanieWycieczkiView2
		ON wycieczka.dbo.zorganizowanieWycieczki.IDoferty = zorganizowanieWycieczkiView2.IDoferty
		AND wycieczka.dbo.zorganizowanieWycieczki.IDpracownika = zorganizowanieWycieczkiView2.IDpracownika
		AND wycieczka.dbo.zorganizowanieWycieczki.IDdatyRozpoczeciaWycieczki = zorganizowanieWycieczkiView2.IDdatyRozpoczeciaWycieczki
		AND wycieczka.dbo.zorganizowanieWycieczki.IDtransportu = zorganizowanieWycieczkiView2.IDtransportu
		AND wycieczka.dbo.zorganizowanieWycieczki.IDubezpieczenia = zorganizowanieWycieczkiView2.IDubezpieczenia
		AND wycieczka.dbo.zorganizowanieWycieczki.IDhotelu = zorganizowanieWycieczkiView2.IDhotelu
		AND wycieczka.dbo.zorganizowanieWycieczki.IDpobytu = zorganizowanieWycieczkiView2.IDpobytu
		AND wycieczka.dbo.zorganizowanieWycieczki.IDdatyZawarciaUmowyZFirmaTransportowa = zorganizowanieWycieczkiView2.IDdatyZawarciaUmowyZFirmaTransportowa
		AND wycieczka.dbo.zorganizowanieWycieczki.liczbaMiejscWykupionychPrzezKlientow = zorganizowanieWycieczkiView2.liczbaMiejscWykupionychPrzezKlientow
		AND wycieczka.dbo.zorganizowanieWycieczki.dochodZKupnaWycieczek = zorganizowanieWycieczkiView2.dochodZKupnaWycieczek
		AND wycieczka.dbo.zorganizowanieWycieczki.liczbaWszystkichDostepnychMiejscWTejOfercie = zorganizowanieWycieczkiView2.liczbaWszystkichDostepnychMiejscWTejOfercie
		AND wycieczka.dbo.zorganizowanieWycieczki.zysk = zorganizowanieWycieczkiView2.zysk
				AND wycieczka.dbo.zorganizowanieWycieczki.kosztZorganizowaniaWycieczki = zorganizowanieWycieczkiView2.kosztZorganizowaniaWycieczki
		WHEN Not Matched
			THEN
				INSERT
				Values (
					zorganizowanieWycieczkiView2.IDoferty,
					zorganizowanieWycieczkiView2.IDpracownika,
					zorganizowanieWycieczkiView2.IDdatyRozpoczeciaWycieczki,
					zorganizowanieWycieczkiView2.IDtransportu,
					zorganizowanieWycieczkiView2.IDubezpieczenia,
					zorganizowanieWycieczkiView2.IDhotelu,
					zorganizowanieWycieczkiView2.IDpobytu,
					zorganizowanieWycieczkiView2.IDdatyZawarciaUmowyZFirmaTransportowa,
					zorganizowanieWycieczkiView2.liczbaMiejscWykupionychPrzezKlientow,
					zorganizowanieWycieczkiView2.dochodZKupnaWycieczek,
					zorganizowanieWycieczkiView2.zysk,
					zorganizowanieWycieczkiView2.liczbaWszystkichDostepnychMiejscWTejOfercie,
					zorganizowanieWycieczkiView2.kosztZorganizowaniaWycieczki
				);


-- usuwanie widoku
go

Drop View zorganizowanieWycieczkiView;
drop table zorganizowanieWycieczkiTmp
drop view zorganizowanieWycieczkiTmp2
drop view zorganizowanieWycieczkiTmp3
drop view zorganizowanieWycieczkiView2
go 