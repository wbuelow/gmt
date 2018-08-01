





-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_BP_Rates_stg_to_bp]

AS

BEGIN



SET NOCOUNT ON;



INSERT INTO bp.Rate ([Date],

				[Five_Year],

				[Ten_Year],

				[Twenty_Year]

			  )

SELECT [Date],

		[Five_Year]/100,

		[Ten_Year]/100,

		[Twenty_Year]/100

	FROM [stg].[GBR] AS Stg

	WHERE Stg.Date > ISNULL((SELECT MAX(Date) FROM bp.Rate), '1900-01-01')



;WITH Ordered_by_Date AS (

SELECT *

		,ROW_NUMBER () OVER (ORDER BY DATE) AS ROW_N

	FROM bp.Rate

	WHERE Date BETWEEN DATEADD(M, -1, GETDATE()) AND DATEADD(D, -1, GETDATE()) --cutoff to not interpolate old values

)

, Interp AS

(

SELECT A.Date

		,A.[Five_Year]

		,B.[Five_Year] AS Five_Year_Interpolated

		,A.[Ten_Year]

		,B.[Ten_Year] AS Ten_Year_Interpolated

		,A.[Twenty_Year]

		,B.[Twenty_Year] AS Twenty_Year_Interpolated

	FROM Ordered_by_Date AS A

	JOIN Ordered_by_Date AS B

	ON A.ROW_N = B.ROW_N + 1

)

UPDATE Interp

SET [Five_Year] = ISNULL([Five_Year], Five_Year_Interpolated)

,[Ten_Year] = ISNULL([Ten_Year], Ten_Year_Interpolated)

,[Twenty_Year] = ISNULL([Twenty_Year], Twenty_Year_Interpolated)



END







