USE [vol]
GO

/****** Object:  StoredProcedure [owf].[stp_etl_AllSurfaces]    Script Date: 8/1/2018 9:22:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [owf].[stp_etl_AllSurfaces] AS 
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE owf.[AllSurfaces]

DROP TABLE IF EXISTS #T 
CREATE TABLE #T (ID INT IDENTITY(1,1), OWFTableName VARCHAR(25), Underlying VARCHAR(25))
INSERT INTO #T (OWFTableName, Underlying)
SELECT OWFTableName, dC.TWName AS Underlying
	FROM gmt.futures.dimContract dC
	WHERE OWFTableName IS NOT NULL

DECLARE @N INT = 1
DECLARE @M INT = (SELECT MAX(ID) FROM #T)
DECLARE @SQL VARCHAR(MAX)
DECLARE @TableNm VARCHAR(25)
DECLARE @Underlying VARCHAR(25)

WHILE @N <= @M
BEGIN 

SET @TableNm = (SELECT OWFTableName FROM #T WHERE ID = @N)
SET @Underlying = (SELECT Underlying FROM #T WHERE ID = @N)

SET @SQL = '
SELECT date
		,C01dVol
		,C05dVol
		,C10dVol
		,C15dVol
		,C20dVol
		,C25dVol
		,C30dVol
		,C35dVol
		,C40dVol
		,C45dVol
		,DNSvol
		,P45dVol
		,P40dVol
		,P35dVol
		,P30dVol
		,P25dVol
		,P20dVol
		,P15dVol
		,P10dVol
		,P05dVol
		,P01dVol
		,''' + @Underlying + 
	''' FROM stg.' + @TableNm + 
	' ORDER BY DATE'

INSERT INTO owf.[AllSurfaces] (
[Date],
C01dVol,
C05dVol,
C10dVol,
C15dVol,
C20dVol,
C25dVol,
C30dVol,
C35dVol,
C40dVol,
C45dVol,
DNSvol,
P45dVol,
P40dVol,
P35dVol,
P30dVol,
P25dVol,
P20dVol,
P15dVol,
P10dVol,
P05dVol,
P01dVol,
Underlying
)
EXEC(@SQL)

SET @N = @N + 1

END

END
GO


