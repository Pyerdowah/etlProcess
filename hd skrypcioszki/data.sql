Declare @StartDate date; 
Declare @EndDate date;
SELECT @StartDate = '2021-01-01', @EndDate = '2022-12-31';
Declare @DateInProcess datetime = @StartDate;

-- wypelnienie tabeli
While @DateInProcess <= @EndDate
	Begin
		INSERT INTO tabelaData VALUES( 
			@DateInProcess,
			Cast(Year(@DateInProcess) as int),
			Cast(DATENAME(month, @DateInProcess) as varchar(11)),
			Cast(Day(@DateInProcess) as int)
		);  
		Set @DateInProcess = DateAdd(d, 1, @DateInProcess);
	End
GO


select * from tabelaData
select * from pobyt
select * from ubezpieczenie
select * from oferta
