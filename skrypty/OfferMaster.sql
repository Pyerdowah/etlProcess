drop table if exists OfferMaster.dbo.offer
drop table if exists OfferMaster.dbo.stay
drop table if exists OfferMaster.dbo.hotel
drop table if exists OfferMaster.dbo.employee
drop table if exists OfferMaster.dbo.insurance
drop table if exists OfferMaster.dbo.transport
drop table if exists OfferMaster.dbo.food
drop table if exists OfferMaster.dbo.room



create table OfferMaster.dbo.employee(
	employeeid bigint primary key,
	age int,
	lengthofwork int,
	salary numeric,
	agency int,
	firstname varchar(15),
	lastname varchar(30)
)

create table OfferMaster.dbo.insurance(
	insuranceid bigint primary key,
	kind varchar(30),
	cost numeric,
	dateofcontract date,
	employeeid bigint
)

create table OfferMaster.dbo.transport(
	transportid bigint primary key,
	numberofseats int,
	cityofdeparture varchar(30),
	placeofdestination varchar(50),
	dateofstart datetime,
	dateofend datetime,
	meanoftransport varchar(20),
	cost numeric,
	dateofcontract date,
	employeeid bigint,
	nameofcompany varchar(30)
)

create table OfferMaster.dbo.hotel(
	hotelid bigint primary key,
	numberofstars int,
	nameofhotel varchar(30),
	addressofhotel varchar(100),
	country varchar(50),
	facilities varchar(1000)
)

create table OfferMaster.dbo.food(
	hotelid bigint references hotel,
	foodid bigint,
	kind char(2),
	primary key(hotelid, foodid) 
)

create table OfferMaster.dbo.room(
	hotelid bigint references hotel,
	roomid bigint,
	numberofseatsintheroom int,
	primary key(hotelid, roomid) 
)

create table OfferMaster.dbo.stay(
	stayid bigint primary key,
	dateofstart date,
	dateofend date, 
	numberofseats int,
	hotelid bigint references hotel,
	cost numeric,
	dateofcontract date,
	employeeid bigint
)

create table OfferMaster.dbo.offer(
	offerid bigint primary key,
	stayid bigint references stay,
	transportid bigint references transport,
	employeeid bigint references employee,
	insuranceid bigint references insurance,
	numberofseats int,
	costperperson numeric,
	dateofstart date,
	dateofend date,
	season varchar(10)
)

set dateformat dmy
bulk insert OfferMaster.dbo.employee from 'c:\employee_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert OfferMaster.dbo.insurance from 'c:\insurances_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert OfferMaster.dbo.transport from 'c:\transports_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert OfferMaster.dbo.hotel from 'c:\hotels_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert OfferMaster.dbo.food from 'c:\food_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert OfferMaster.dbo.room from 'c:\rooms_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert OfferMaster.dbo.stay from 'c:\stays_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert OfferMaster.dbo.offer from 'c:\offers_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
