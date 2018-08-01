USE [vol]
GO

/****** Object:  StoredProcedure [owf].[stp_etl_SurfaceMetrics]    Script Date: 8/1/2018 9:34:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [owf].[stp_etl_SurfaceMetrics]
AS
BEGIN

SET NOCOUNT ON;

TRUNCATE TABLE [owf].[SurfaceMetrics]

DROP TABLE IF EXISTS ##OWFTables

SELECT ROW_NUMBER()OVER(ORDER BY OWFTableName) AS ID 
		,OWFTableName
		,TWName AS 'Underlying'
	INTO ##OWFTables
	FROM gmt.futures.dimContract
	WHERE OWFTableName IS NOT NULL
	AND OWFTableName <> 'owfRTYivs' --data beings 7/10/2017. Include when we have at least 252 rows

DECLARE @ID INT = 1
DECLARE @SQL VARCHAR(MAX)

DECLARE @OWFTable VARCHAR(25)
DECLARE @Underlying VARCHAR(10)

WHILE @ID <= (SELECT MAX(ID) FROM ##OWFTables)
BEGIN

SET @OWFTable = (SELECT 'stg.' + OWFTableName FROM ##OWFTables WHERE ID = @ID)
SET @Underlying  = (SELECT Underlying FROM ##OWFTables WHERE ID = @ID)

SET @SQL = 
'INSERT INTO owf.[SurfaceMetrics] (
[Date]
,[DNSvol]
,[saDNSvol]
,[P25dVol]
,[P10dVol]
,[C25dVol]
,[C10dVol]
,[saRR25]
,[saRR10]
,[RR25]
,[RR10]
,[Fly25]
,[Fly10]
,[IVrange]
,[IVOP]
,[RR25OP]
,[RR10OP]
,[FLY25OP]
,[FLY10OP]
)
EXEC owf.stp_R_ProcessSurfaceMetrics ''' + @OWFTable + ''''

EXEC(@SQL)

UPDATE owf.[SurfaceMetrics] 
SET Underlying = @Underlying
WHERE Underlying IS NULL

SET @ID = @ID + 1

END

END



GO


