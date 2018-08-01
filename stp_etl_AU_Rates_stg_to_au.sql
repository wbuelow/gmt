

-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_AU_Rates_stg_to_au]

AS

BEGIN



SET NOCOUNT ON;



INSERT INTO au.Rate ([Date]

			  ,[One_Month]

			  ,[Three_Month]

			  ,[Six_Month]

			  ,[Two_Year]

			  ,[Three_Year]

			  ,[Five_Year]

			  ,[Ten_Year]

			  )

SELECT [Date]

      ,[One_Month]/100 

      ,[Three_Month]/100

      ,[Six_Month]/100

      ,[Two_Year]/100

      ,[Three_Year]/100

      ,[Five_Year]/100

      ,[Ten_Year]/100

	FROM [stg].[AUS] AS Stg

	WHERE Stg.Date > (SELECT MAX(Date) FROM au.Rate)



;WITH Ordered_by_Date AS (

SELECT *

		,ROW_NUMBER () OVER (ORDER BY DATE) AS ROW_N

	FROM au.Rate

	WHERE DATE BETWEEN DATEADD(M, -1, GETDATE()) AND DATEADD(D, -1, GETDATE())

)

, Interp AS

(

SELECT A.Date

		,A.[One_Month]

		,B.[One_Month] AS One_Month_Interpolated

		,A.Three_Month

		,B.Three_Month AS Three_Month_Interpolated

		,A.[Six_Month]

		,B.[Six_Month] AS Six_Month_Interpolated

		,A.[Two_Year]

		,B.[Two_Year] AS Two_Year_Interpolated

		,A.[Three_Year]

		,B.[Three_Year] AS Three_Year_Interpolated

		,A.[Five_Year]

		,B.[Five_Year] AS Five_Year_Interpolated

		,A.[Ten_Year]

		,B.[Ten_Year] AS Ten_Year_Interpolated

	FROM Ordered_by_Date AS A

	JOIN Ordered_by_Date AS B

	ON A.ROW_N = B.ROW_N + 1

)

UPDATE Interp

SET [One_Month] = ISNULL([One_Month], One_Month_Interpolated)

,Three_Month = ISNULL(Three_Month, Three_Month_Interpolated)

,[Six_Month] = ISNULL([Six_Month], Six_Month_Interpolated)

,[Two_Year] = ISNULL([Two_Year], Two_Year_Interpolated)

,[Three_Year] = ISNULL([Three_Year], Three_Year_Interpolated)

,[Five_Year] = ISNULL([Five_Year], Five_Year_Interpolated)

,[Ten_Year] = ISNULL([Ten_Year], Ten_Year_Interpolated)



END



