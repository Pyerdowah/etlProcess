drop table zorganizowanieWycieczki
drop table pracownik
drop table ubezpieczenie
drop table transport
drop table pobyt
drop table hotel
drop table oferta
drop table tabelaData


create table pracownik (
	IDrekordu bigint identity(1,1) primary key,
	IDpracownika bigint,
	dlugoscpracynastanowisku varchar(50),
	wiek varchar(50),
	pensja varchar(50),
	filia varchar(7),
	imieINazwisko varchar(100),
	aktualnoscrekordu bit not null
)

create table ubezpieczenie (
	IDubezpieczenia bigint identity(1,1) primary key,
	rodzajUbezpieczenia varchar(12)
)

create table transport (
	IDtransportu bigint identity(1,1) primary key,
	srodekLokomocji char(7),
	miejsceWyjazdu varchar(30),
	nazwaFirmy varchar(50)
)

create table pobyt (
	IDpobytu bigint identity(1,1) primary key,
	dlugoscPobytu int
)

create table hotel (
	IDhotelu bigint identity(1,1) primary key,
	liczbaGwiazdek varchar(10),
	nazwa varchar(30),
	nazwaUlicy varchar(30),
	numerLokalu varchar(10),
	miejscowosc varchar(30),
	kraj varchar(50)
)

create table oferta (
	IDoferty bigint identity(1,1) primary key,
	sezon varchar(6)
)

create table tabelaData (
	IDdaty bigint identity(1,1) primary key,
	dataa date,
	rok int,
	miesiac varchar(11),
	dzien int
)

create table zorganizowanieWycieczki (
	IDoferty bigint foreign key references oferta,
	IDpracownika bigint foreign key references pracownik,
	IDdatyRozpoczeciaWycieczki bigint foreign key references tabelaData,
	IDtransportu bigint foreign key references transport,
	IDubezpieczenia bigint foreign key references ubezpieczenie,
	IDhotelu bigint foreign key references hotel,
	IDpobytu bigint foreign key references pobyt,
	IDdatyZawarciaUmowyZFirmaTransportowa bigint foreign key references tabelaData,
	liczbaMiejscWykupionychPrzezKlientow int,
	dochodZKupnaWycieczek numeric,
	zysk numeric,
	liczbaWszystkichDostepnychMiejscWTejOfercie int,
	kosztZorganizowaniaWycieczki numeric
)
