USE Census;

--Table Updates
EXEC sp_rename 'fy2025_fmr_50', 'Housing';

EXEC sp_rename 'LGBTStateRights', 'StateLaws';


ALTER TABLE dbo.CensusMk4 ALTER COLUMN [Estimate!!Total!!Total population] bigint;  
GO

ALTER TABLE dbo.CensusMk4 ALTER COLUMN [Estimate!!Total!!Total population!!AGE!!20 to 24 years] bigint;  
GO  

ALTER TABLE dbo.CensusMk4 ALTER COLUMN [Estimate!!Percent!!Total population!!AGE!!20 to 24 years] float;  
GO  

ALTER TABLE dbo.CensusMk4 ALTER COLUMN [Estimate!!Percent Female!!Total population!!AGE!!20 to 24 years] float;  
GO

ALTER TABLE dbo.CensusMk4 ALTER COLUMN [Estimate!!Percent Male!!Total population!!AGE!!20 to 24 years] float;  
GO

ALTER TABLE dbo.CensusMk4 ALTER COLUMN [Estimate!!Female!!Total population!!AGE!!20 to 24 years] bigint;  
GO

ALTER TABLE dbo.CensusMk4 ALTER COLUMN [Estimate!!Male!!Total population!!AGE!!20 to 24 years] bigint;  
GO

ALTER TABLE dbo.StateLaws ALTER COLUMN [LGBT Score] float;  
GO

UPDATE StateLaws
SET [Abortion Status] = 'Illegal'
WHERE [Abortion Status] = 'Illegla'

--Initial Table Exploration
SELECT *
FROM CensusMk4;

SELECT *
FROM Housing;

SELECT *
FROM StateLaws;

SELECT *
FROM ElectionResults;

--Totals
SELECT [Geographic Area Name], [Estimate!!Total!!Total population]
FROM CensusMk4
ORDER BY [Estimate!!Total!!Total population] DESC;

SELECT [Geographic Area Name], 
	(CAST([Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS float) / CAST([Estimate!!Total!!Total population] AS float) * 100) AS PctF,
	(CAST([Estimate!!Male!!Total population!!AGE!!20 to 24 years] AS float) / CAST([Estimate!!Total!!Total population] AS float) * 100) AS PctM,
	[Estimate!!Total!!Total population] AS Total_population
FROM CensusMk4
WHERE (CAST([Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS float) / CAST([Estimate!!Total!!Total population] AS float) * 100) > (CAST([Estimate!!Male!!Total population!!AGE!!20 to 24 years] AS float) / CAST([Estimate!!Total!!Total population] AS float) * 100)
ORDER BY PctF DESC;

SELECT [Geographic Area Name], (CAST([Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS float)/CAST([Estimate!!Total!!Total population] AS float) * 100) as PctTotal
FROM CensusMk4
ORDER BY PctTotal DESC;


--Percent
SELECT [Geographic Area Name], [Estimate!!Percent!!Total population!!AGE!!20 to 24 years]
FROM CensusMk4
ORDER BY [Estimate!!Percent!!Total population!!AGE!!20 to 24 years] DESC;

SELECT [Geographic Area Name], [Estimate!!Percent Female!!Total population!!AGE!!20 to 24 years], [Estimate!!Percent Male!!Total population!!AGE!!20 to 24 years], [Estimate!!Total!!Total population!!AGE!!20 to 24 years]
FROM CensusMk4
WHERE [Estimate!!Percent Female!!Total population!!AGE!!20 to 24 years] > [Estimate!!Percent Male!!Total population!!AGE!!20 to 24 years]
ORDER BY [Estimate!!Percent Female!!Total population!!AGE!!20 to 24 years] DESC;

SELECT [Geographic Area Name], [Estimate!!Percent Male!!Total population!!AGE!!20 to 24 years]
FROM CensusMk4
ORDER BY [Estimate!!Percent Male!!Total population!!AGE!!20 to 24 years] DESC;


--Aggregates
SELECT AVG([Estimate!!Percent!!Total population!!AGE!!20 to 24 years])
FROM CensusMk4;

SELECT AVG([Estimate!!Percent!!Total population!!AGE!!20 to 24 years]), 
	   AVG([Estimate!!Percent Male!!Total population!!AGE!!20 to 24 years]), 
	   AVG([Estimate!!Percent Female!!Total population!!AGE!!20 to 24 years])
FROM CensusMk4;

SELECT TOP 10 PERCENT [Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS Fpop, [Geographic Area Name]
FROM CensusMk4
ORDER BY Fpop DESC;
--323 counties

--Table Level Queries
SELECT State, CAST([LGBT Score] AS float), [Abortion Status], [State Abbr]
FROM StateLaws;

SELECT state_name, county_name, votes_dem, per_dem
FROM ElectionResults;

SELECT LEFT([Geographic Area Name], CHARINDEX(',',[Geographic Area Name]) - 1) AS County,
	RIGHT([Geographic Area Name], LEN([Geographic Area Name]) - CHARINDEX(',',[Geographic Area Name]) - 1) AS State,
	(CAST(C1.[Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS float) / CAST(C1.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS float) * 100) AS PctFtoAge,
	(CAST(C1.[Estimate!!Male!!Total population!!AGE!!20 to 24 years] AS float) / CAST(C1.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS float) * 100) AS PctMtoAge,
	C1.[Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS AgeFpop,
	C1.[Estimate!!Male!!Total population!!AGE!!20 to 24 years] AS AgeMpop,
	C1.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS Agepop,
	(CAST(C1.[Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS float) / CAST(C1.[Estimate!!Total!!Total population] AS float) * 100) AS PctF,
	(CAST(C1.[Estimate!!Male!!Total population!!AGE!!20 to 24 years] AS float) / CAST(C1.[Estimate!!Total!!Total population] AS float) * 100) AS PctM,
	C1.[Estimate!!Total!!Total population] AS Tpop
FROM CensusMk4 AS C1
WHERE C1.[Estimate!!Female!!Total population!!AGE!!20 to 24 years] 
		>= C1.[Estimate!!Male!!Total population!!AGE!!20 to 24 years]
	AND C1.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] IN (SELECT TOP 10 PERCENT C2.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS Agepop2
		FROM CensusMk4 AS C2
		ORDER BY Agepop2 DESC)
--	AND RIGHT([Geographic Area Name], LEN([Geographic Area Name]) - CHARINDEX(',',[Geographic Area Name]) - 1) = 'Indiana'
ORDER BY PctFtoAge DESC;

SELECT LEFT([Geographic Area Name], CHARINDEX(',',[Geographic Area Name]) - 1) AS County
FROM CensusMk4;

--Final Joined Query
SELECT DISTINCT SL.State, H.cntyname, H.rent_50_1 AS OneBed, H.rent_50_2/2 AS TwoBedPerPerson, 
	SL.[LGBT Score], SL.[Abortion Status], ER.votes_dem, ER.per_dem,
	CD.PctFtoAge, CD.PctMtoAge, CD.AgeFpop, CD.AgeMpop, CD.PctF, CD.PctM, CD.Tpop
FROM Housing AS H
	JOIN StateLaws AS SL
		ON H.state_alpha = SL.[State Abbr]
	JOIN ElectionResults AS ER
		ON ER.state_name = SL.State AND ER.county_name = H.cntyname
	JOIN (SELECT LEFT([Geographic Area Name], CHARINDEX(',',[Geographic Area Name]) - 1) AS County,
			RIGHT([Geographic Area Name], LEN([Geographic Area Name]) - CHARINDEX(',',[Geographic Area Name]) - 1) AS State,
			(CAST(C1.[Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS float) / CAST(C1.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS float) * 100) AS PctFtoAge,
			(CAST(C1.[Estimate!!Male!!Total population!!AGE!!20 to 24 years] AS float) / CAST(C1.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS float) * 100) AS PctMtoAge,
			C1.[Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS AgeFpop,
			C1.[Estimate!!Male!!Total population!!AGE!!20 to 24 years] AS AgeMpop,
			C1.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS Agepop,
			(CAST(C1.[Estimate!!Female!!Total population!!AGE!!20 to 24 years] AS float) / CAST(C1.[Estimate!!Total!!Total population] AS float) * 100) AS PctF,
			(CAST(C1.[Estimate!!Male!!Total population!!AGE!!20 to 24 years] AS float) / CAST(C1.[Estimate!!Total!!Total population] AS float) * 100) AS PctM,
			C1.[Estimate!!Total!!Total population] AS Tpop
		FROM CensusMk4 AS C1
		WHERE C1.[Estimate!!Female!!Total population!!AGE!!20 to 24 years] 
				>= C1.[Estimate!!Male!!Total population!!AGE!!20 to 24 years]
			AND C1.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] IN (SELECT TOP 10 PERCENT C2.[Estimate!!Total!!Total population!!AGE!!20 to 24 years] AS Agepop2
				FROM CensusMk4 AS C2
				ORDER BY Agepop2 DESC)) AS CD
				ON CD.County = H.cntyname AND CD.State = SL.State
WHERE (H.rent_50_1 <= 1250 OR (H.rent_50_2/2) <= 1250)
	AND SL.[Abortion Status] IN ('Protected', 'Expanded Access', 'Not Protected')
	AND SL.[LGBT Score] >= 0
	AND ER.per_dem >= .500
ORDER BY CD.Tpop DESC;
