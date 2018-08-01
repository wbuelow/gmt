-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_NZ_Rates_stg_to_nz]

AS

BEGIN



SET NOCOUNT ON;



INSERT INTO nz.Rate ([Date]

			  ,[One_Month]

			  ,[Three_Month]

			  ,[Six_Month]

			  ,[One_Year]

			  ,[Two_Year]

			  ,[Five_Year]

			  ,[Ten_Year]

			  )

SELECT [Date]

      ,[One_Month]/100 

      ,[Three_Month]/100

      ,[Six_Month]/100

      ,[One_Year]/100

      ,[Two_Year]/100

      ,[Five_Year]/100

      ,[Ten_Year]/100

	FROM [stg].[NZL] AS Stg

	WHERE Stg.Date > (SELECT ISNULL(MAX(Date), '1900-01-01') FROM nz.Rate)



;WITH Ordered_by_Date AS (

SELECT *

		,ROW_NUMBER () OVER (ORDER BY DATE) AS ROW_N

	FROM nz.Rate

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

		,A.[One_Year]

		,B.[One_Year] AS One_Year_Interpolated

		,A.[Two_Year]

		,B.[Two_Year] AS Two_Year_Interpolated

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

,[One_Year] = ISNULL([One_Year], One_Year_Interpolated)

,[Two_Year] = ISNULL([Two_Year], Two_Year_Interpolated)

,[Five_Year] = ISNULL([Five_Year], Five_Year_Interpolated)

,[Ten_Year] = ISNULL([Ten_Year], Ten_Year_Interpolated)



END



