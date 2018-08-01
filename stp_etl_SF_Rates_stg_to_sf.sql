-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_SF_Rates_stg_to_sf]

AS

BEGIN



SET NOCOUNT ON;



INSERT INTO sf.Rate ([Date]

			  ,[O-N]

			  ,[One_Month]

			  ,[Three_Month]

			  ,[Six_Month]

			  ,[Twelve_Month]

			  ,[Two_Year]

			  ,[Three_Year]

			  ,Four_Year

			  ,[Five_Year]

			  ,[Seven_Year]

			  ,[Ten_Year]

			  ,[Twenty_Year]

			  ,[Thirty_Year]

			  )

SELECT [Date]

	  ,[O-N]/100 

      ,[One_Month]/100 

      ,[Three_Month]/100

      ,[Six_Month]/100

      ,[Twelve_Month]/100

      ,[Two_Year]/100

      ,[Three_Year]/100

	  ,Four_Year/100

      ,[Five_Year]/100

      ,[Seven_Year]/100

      ,[Ten_Year]/100

      ,[Twenty_Year]/100

      ,[Thirty_Year]/100

	FROM [stg].[CHE] AS Stg

	WHERE Stg.Date > (SELECT ISNULL(MAX(Date), '1900-01-01') FROM sf.Rate)



;WITH Ordered_by_Date AS (

SELECT *

		,ROW_NUMBER () OVER (ORDER BY DATE) AS ROW_N

	FROM sf.Rate

	WHERE DATE BETWEEN DATEADD(M, -1, GETDATE()) AND DATEADD(D, -1, GETDATE())

)

, Interp AS

(

SELECT A.Date

		,A.[O-N]

		,B.[O-N] AS Overnight_Interpolated

		,A.[One_Month]

		,B.[One_Month] AS One_Month_Interpolated

		,A.Three_Month

		,B.Three_Month AS Three_Month_Interpolated

		,A.[Six_Month]

		,B.[Six_Month] AS Six_Month_Interpolated

		,A.[Twelve_Month]

		,B.[Twelve_Month] AS Twelve_Month_Interpolated

		,A.[Two_Year]

		,B.[Two_Year] AS Two_Year_Interpolated

		,A.[Three_Year]

		,B.[Three_Year] AS Three_Year_Interpolated

		,A.[Four_Year]

		,B.[Four_Year] AS Four_Year_Interpolated

		,A.[Five_Year]

		,B.[Five_Year] AS Five_Year_Interpolated

		,A.[Seven_Year]

		,B.[Seven_Year] AS Seven_Year_Interpolated

		,A.[Ten_Year]

		,B.[Ten_Year] AS Ten_Year_Interpolated

		,A.[Twenty_Year]

		,B.[Twenty_Year] AS Twenty_Year_Interpolated

		,A.[Thirty_Year]

		,B.[Thirty_Year] AS Thirty_Year_Interpolated

	FROM Ordered_by_Date AS A

	JOIN Ordered_by_Date AS B

	ON A.ROW_N = B.ROW_N + 1

)

UPDATE Interp

SET [O-N] = ISNULL([O-N], Overnight_Interpolated)

,[One_Month] = ISNULL([One_Month], One_Month_Interpolated)

,Three_Month = ISNULL(Three_Month, Three_Month_Interpolated)

,[Six_Month] = ISNULL([Six_Month], Six_Month_Interpolated)

,Twelve_Month = ISNULL(Twelve_Month, Twelve_Month_Interpolated)

,[Two_Year] = ISNULL([Two_Year], Two_Year_Interpolated)

,[Three_Year] = ISNULL([Three_Year], Three_Year_Interpolated)

,Four_Year = ISNULL([Four_Year], Four_Year_Interpolated)

,[Five_Year] = ISNULL([Five_Year], Five_Year_Interpolated)

,[Seven_Year] = ISNULL([Seven_Year], Seven_Year_Interpolated)

,[Ten_Year] = ISNULL([Ten_Year], Ten_Year_Interpolated)

,[Twenty_Year] = ISNULL([Twenty_Year], Twenty_Year_Interpolated)

,[Thirty_Year] = ISNULL([Thirty_Year], Thirty_Year_Interpolated)



END

