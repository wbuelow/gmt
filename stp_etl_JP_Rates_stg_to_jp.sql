



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_JP_Rates_stg_to_jp]

AS

BEGIN



SET NOCOUNT ON;



INSERT INTO jp.Rate ([Date],

				[One_Year],

				[Two_Year],

				[Three_Year],

				[Four_Year],

				[Five_Year],

				[Six_Year],

				[Seven_Year],

				[Eight_Year],

				[Nine_Year],

				[Ten_Year],

				[Fifteen_Year],

				[Twenty_Year],

				[Twenty_Five_Year],

				[Thirty_Year] 

			  )

SELECT [Date],

		[One_Year]/100,

		[Two_Year]/100,

		[Three_Year]/100,

		[Four_Year]/100,

		[Five_Year]/100,

		[Six_Year]/100,

		[Seven_Year]/100,

		[Eight_Year]/100,

		[Nine_Year]/100,

		[Ten_Year]/100,

		[Fifteen_Year]/100,

		[Twenty_Year]/100,

		[Twenty_Five_Year]/100,

		[Thirty_Year]/100

	FROM [stg].[JPN] AS Stg

	WHERE Stg.Date > ISNULL((SELECT MAX(Date) FROM jp.Rate), '1900-01-01')



;WITH Ordered_by_Date AS (

SELECT *

		,ROW_NUMBER () OVER (ORDER BY DATE) AS ROW_N

	FROM jp.Rate

	WHERE Date BETWEEN DATEADD(M, -1, GETDATE()) AND DATEADD(D, -1, GETDATE()) --cutoff to not interpolate old values

)

, Interp AS

(

SELECT A.Date

		,A.[One_Year]

		,B.[One_Year] AS One_Year_Interpolated

		,A.[Two_Year]

		,B.[Two_Year] AS Two_Year_Interpolated

		,A.[Three_Year]

		,B.[Three_Year] AS Three_Year_Interpolated

		,A.[Four_Year]

		,B.[Four_Year] AS Four_Year_Interpolated

		,A.[Five_Year]

		,B.[Five_Year] AS Five_Year_Interpolated

		,A.[Six_Year]

		,B.[Six_Year] AS Six_Year_Interpolated

		,A.[Seven_Year]

		,B.[Seven_Year] AS Seven_Year_Interpolated

		,A.[Eight_Year]

		,B.[Eight_Year] AS Eight_Year_Interpolated

	    ,A.[Nine_Year]

	    ,B.[Nine_Year] AS Nine_Year_Interpolated

		,A.[Ten_Year]

		,B.[Ten_Year] AS Ten_Year_Interpolated

		,A.[Fifteen_Year]

		,B.[Fifteen_Year] AS Fifteen_Year_Interpolated

		,A.[Twenty_Year]

		,B.[Twenty_Year] AS Twenty_Year_Interpolated

		,A.[Twenty_Five_Year]

		,B.[Twenty_Five_Year] AS Twenty_Five_Year_Interpolated

		,A.[Thirty_Year]

		,B.[Thirty_Year] AS Thirty_Year_Interpolated

	FROM Ordered_by_Date AS A

	JOIN Ordered_by_Date AS B

	ON A.ROW_N = B.ROW_N + 1

)

UPDATE Interp

SET [One_Year] = ISNULL([One_Year], One_Year_Interpolated)

,[Two_Year] = ISNULL([Two_Year], Two_Year_Interpolated)

,[Three_Year] = ISNULL([Three_Year], Three_Year_Interpolated)

,[Four_Year] = ISNULL([Four_Year], Four_Year_Interpolated)

,[Five_Year] = ISNULL([Five_Year], Five_Year_Interpolated)

,[Six_Year] = ISNULL([Six_Year], Six_Year_Interpolated)

,[Seven_Year] = ISNULL([Seven_Year], Seven_Year_Interpolated)

,[Eight_Year] = ISNULL([Eight_Year], Eight_Year_Interpolated)

,[Nine_Year] = ISNULL([Nine_Year], Nine_Year_Interpolated)

,[Ten_Year] = ISNULL([Ten_Year], Ten_Year_Interpolated)

,[Fifteen_Year] = ISNULL([Fifteen_Year], Fifteen_Year_Interpolated)

,[Twenty_Year] = ISNULL([Twenty_Year], Twenty_Year_Interpolated)

,[Twenty_Five_Year] = ISNULL([Twenty_Five_Year], Twenty_Five_Year_Interpolated)

,[Thirty_Year] = ISNULL([Thirty_Year], Thirty_Year_Interpolated)



END





