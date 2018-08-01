-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================



CREATE PROCEDURE [dbo].[stp_etl_Backwards_Ratio_Adjust] --'CME_SI'

						@Contract_Nm VARCHAR(25)

AS

BEGIN



SET NOCOUNT ON;



--DECLARE @Contract_Nm VARCHAR(25) = 'CME_SI'

DECLARE @DropTempTableSQL AS NVARCHAR(MAX)

DECLARE @CreateTableSQL AS NVARCHAR(MAX)

DECLARE @TempTableInsertSQL AS NVARCHAR(MAX)

DECLARE @CalcActiveContractSQL AS NVARCHAR(MAX)

DECLARE @CalcCumDiffSQL AS NVARCHAR(MAX)

DECLARE @TableInsertSQL AS NVARCHAR(MAX)



SET @DropTempTableSQL = 'IF OBJECT_ID(''tempdb..##' + @Contract_Nm + ''') IS NOT NULL

							DROP TABLE ##' + @Contract_Nm

EXECUTE(@DropTempTableSQL)



SET @CreateTableSQL = 

' if not exists (select * from INFORMATION_SCHEMA.TABLES where TABLE_NAME = ''' + @Contract_Nm + ''' AND TABLE_SCHEMA = ''BackwardsRatio'')

begin 

	create table BackwardsRatio.' + @Contract_Nm  + ' (Seq_ID INT IDENTITY(1,1)

	,Created_Dt Datetime default getdate()

	,[Date] Date

	,Price Decimal(38, 19)

	)

end

else truncate table BackwardsRatio.' + @Contract_Nm



EXECUTE(@CreateTableSQL)



SET @TempTableInsertSQL = 



';WITH BaseTbl AS (

SELECT Front.Date

		,Front.Settle AS FrontSettle

		,Back.Settle AS BackSettle

		,CASE WHEN Back.Open_Interest > Front.Open_Interest

				THEN ''Back''

				ELSE ''Front''

				END AS ContractWithGreaterOI

		,ROW_NUMBER()OVER(ORDER BY Front.Date DESC) AS RowN

	FROM stg.' + @Contract_Nm + '1 AS Front

	LEFT JOIN stg.' + @Contract_Nm + '2 AS Back

	ON Front.Date = Back.Date

)

, Roll_Dates AS (

SELECT A.Date

	FROM BaseTbl AS A

	JOIN BaseTbl AS B

	ON A.RowN = B.RowN - 1

	WHERE a.ContractWithGreaterOI <> b.ContractWithGreaterOI 

	AND A.BackSettle IS NOT NULL

)

SELECT BaseTbl.*

		,CAST(1 AS decimal(6,4)) AS Cum_Diff

		,Roll_Dates.Date AS RollDate

		,CAST(NULL AS DECIMAL(6,4)) AS Roll_Diff

		,CAST(NULL AS decimal(38,19)) AS Unadjusted

	INTO ##' + @Contract_Nm + 

	' FROM BaseTbl

	LEFT JOIN Roll_Dates

	ON BaseTbl.Date = Roll_Dates.Date



CREATE INDEX IX ON ##' + @Contract_Nm + '(RowN) '



EXECUTE(@TempTableInsertSQL)



SET @CalcActiveContractSQL =



--' DECLARE @ActiveContract VARCHAR(5) = (SELECT TOP 1 ContractWithGreaterOI FROM ##' + @Contract_Nm + ' ORDER BY ROWN)

--DECLARE @AlternativeContract VARCHAR(5) = (CASE WHEN @ActiveContract = ''Back'' THEN ''Front'' ELSE ''Back'' END)

--DECLARE @N INT = 2

--DECLARE @M INT = (SELECT MAX(RowN) FROM ##' + @Contract_Nm + ')



--WHILE @N <= @M

--	BEGIN 

--		UPDATE ##' + @Contract_Nm + '

--		SET ContractWithGreaterOI = CASE WHEN RollDate IS NULL THEN @ActiveContract ELSE @AlternativeContract END

--		, @ActiveContract = CASE WHEN RollDate IS NULL THEN @ActiveContract ELSE @AlternativeContract END

--		, @AlternativeContract = CASE WHEN @ActiveContract = ''Back'' THEN ''Front'' ELSE ''Back'' END

--		WHERE RowN = @N



--	SET @N = @N + 1



--	END



'UPDATE ##' + @Contract_Nm + '

SET Unadjusted = CASE WHEN ContractWithGreaterOI = ''Back'' AND BackSettle IS NOT NULL

						THEN BackSettle

						ELSE FrontSettle

						END

,Roll_Diff = CASE WHEN RollDate IS NOT NULL 

				  THEN CASE WHEN ContractWithGreaterOI = ''Back''

							THEN BackSettle/FrontSettle

							ELSE FrontSettle/BackSettle

					   END

			      ELSE 1 END'



EXECUTE(@CalcActiveContractSQL)



SET @CalcCumDiffSQL = 

'DECLARE @N INT = 1

DECLARE @M INT = (SELECT MAX(RowN) FROM ##' + @Contract_Nm + ')

DECLARE @Cum_Diff Decimal(6,4)



WHILE @N <= @M

	BEGIN



	SET @Cum_Diff = CAST((SELECT Cum_Diff*Roll_Diff FROM ##' + @Contract_Nm + ' WHERE RowN = @N) AS decimal(6,4)) 

	UPDATE ##' + @Contract_Nm + '

	SET Cum_Diff = @Cum_Diff

	WHERE RowN = @N + 1



	SET @N = @N + 1



	END'



EXECUTE(@CalcCumDiffSQL)



SET @TableInsertSQL = 

'INSERT INTO BackwardsRatio.' + @Contract_Nm + '([Date], Price) 

SELECT Date	

		,Cum_Diff*Unadjusted AS Settle

	FROM ##' + @Contract_Nm + '

	ORDER BY Date'



EXECUTE(@TableInsertSQL)



EXECUTE(@DropTempTableSQL)



END

