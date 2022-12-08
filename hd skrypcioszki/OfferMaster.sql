drop table employee
drop table insurance
drop table transport
drop table food
drop table room
drop table hotel
drop table stay
drop table offer

create table employee(
	employeeid bigint primary key,
	age int,
	lengthofwork int,
	salary numeric,
	agency int,
	firstname varchar(15),
	lastname varchar(30)
)

create table insurance(
	insuranceid bigint primary key,
	kind varchar(30),
	cost numeric,
	dateofcontract date,
	employeeid bigint
)

create table transport(
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

create table hotel(
	hotelid bigint primary key,
	numberofstars int,
	nameofhotel varchar(30),
	addressofhotel varchar(100),
	country varchar(50),
	facilities varchar(1000)
)

create table food(
	hotelid bigint references hotel,
	foodid bigint,
	kind char(2),
	primary key(hotelid, foodid) 
)

create table room(
	hotelid bigint references hotel,
	roomid bigint,
	numberofseatsintheroom int,
	primary key(hotelid, roomid) 
)

create table stay(
	stayid bigint primary key,
	dateofstart date,
	dateofend date, 
	numberofseats int,
	hotelid bigint references hotel,
	cost numeric,
	dateofcontract date,
	employeeid bigint
)

create table offer(
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
bulk insert dbo.employee from 'c:\users\paulina\documents\github\datagenerator\employee_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert dbo.insurance from 'c:\users\paulina\documents\github\datagenerator\insurances_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert dbo.transport from 'c:\users\paulina\documents\github\datagenerator\transports_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert dbo.hotel from 'c:\users\paulina\documents\github\datagenerator\hotels_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert dbo.food from 'c:\users\paulina\documents\github\datagenerator\food_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert dbo.room from 'c:\users\paulina\documents\github\datagenerator\rooms_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert dbo.stay from 'c:\users\paulina\documents\github\datagenerator\stays_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')
bulk insert dbo.offer from 'c:\users\paulina\documents\github\datagenerator\offers_t2.bulk' with (datafiletype = 'widechar', fieldterminator='|')

select * from employee
