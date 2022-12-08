
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

select * from OfferMaster.dbo.offer, zorganizowanieWycieczkiTmp where OfferMaster.dbo.offer.offerid = zorganizowanieWycieczkiTmp.IDoferty
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
from OfferMaster.dbo.offer, zorganizowanieWycieczkiTmp where OfferMaster.dbo.offer.offerid =  zorganizowanieWycieczkiTmp.IDoferty group by OfferMaster.dbo.offer.offerid, OfferMaster.dbo.offer.dateofend, OfferMaster.dbo.offer.dateofstart, OfferMaster.dbo.offer.numberofseats, OfferMaster.dbo.offer.costperperson
go 

select * from zorganizowanieWycieczkiTmp2
drop view zorganizowanieWycieczkiTmp2
go

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
drop view zorganizowanieWycieczkiTmp2
go 

select * from zorganizowanieWycieczki
