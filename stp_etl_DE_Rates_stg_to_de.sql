



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_DE_Rates_stg_to_de]

AS

BEGIN



SET NOCOUNT ON;



INSERT INTO de.Rate ([Date],

				[Six_Month],

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

				[Eleven_Year],

				[Twelve_Year],

				[Thirteen_Year],

				[Fourteen_Year],

				[Fifteen_Year],

				[Sixteen_Year],

				[Seventeen_Year],

				[Eighteen_Year],

				[Nineteen_Year],

				[Twenty_Year],

				[Twenty_One_Year],

				[Twenty_Two_Year],

				[Twenty_Three_Year],

				[Twenty_Four_Year],

				[Twenty_Five_Year],

				[Twenty_Six_Year],

				[Twenty_Seven_Year],

				[Twenty_Eight_Year],

				[Twenty_Nine_Year],

				[Thirty_Year] 

			  )

SELECT [Date],

      [Six_Month]/100,

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

		[Eleven_Year]/100,

		[Twelve_Year]/100,

		[Thirteen_Year]/100,

		[Fourteen_Year]/100,

		[Fifteen_Year]/100,

		[Sixteen_Year]/100,

		[Seventeen_Year]/100,

		[Eighteen_Year]/100,

		[Nineteen_Year]/100,

		[Twenty_Year]/100,

		[Twenty_One_Year]/100,

		[Twenty_Two_Year]/100,

		[Twenty_Three_Year]/100,

		[Twenty_Four_Year]/100,

		[Twenty_Five_Year]/100,

		[Twenty_Six_Year]/100,

		[Twenty_Seven_Year]/100,

		[Twenty_Eight_Year]/100,

		[Twenty_Nine_Year]/100,

		[Thirty_Year]/100

	FROM [stg].[DEU] AS Stg

	WHERE Stg.Date > ISNULL((SELECT MAX(Date) FROM de.Rate), '1900-01-01')



;WITH Ordered_by_Date AS (

SELECT *

		,ROW_NUMBER () OVER (ORDER BY DATE) AS ROW_N

	FROM de.Rate

	WHERE Date BETWEEN DATEADD(M, -1, GETDATE()) AND DATEADD(D, -1, GETDATE()) --cutoff to not interpolate old values

)

, Interp AS

(

SELECT A.Date

		,A.[Six_Month]

		,B.[Six_Month] AS Six_Month_Interpolated

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

		,A.[Eleven_Year]

		,B.[Eleven_Year] AS Eleven_Year_Interpolated

		,A.[Twelve_Year]

		,B.[Twelve_Year] AS Twelve_Year_Interpolated

		,A.[Thirteen_Year]

		,B.[Thirteen_Year] AS Thirteen_Year_Interpolated

		,A.[Fourteen_Year]

		,B.[Fourteen_Year] AS Fourteen_Year_Interpolated

		,A.[Fifteen_Year]

		,B.[Fifteen_Year] AS Fifteen_Year_Interpolated

		,A.[Sixteen_Year]

		,B.[Sixteen_Year] AS  Sixteen_Year_Interpolated

		,A.[Seventeen_Year]

		,B.[Seventeen_Year] AS Seventeen_Year_Interpolated

		,A.[Eighteen_Year]

		,B.[Eighteen_Year] AS Eighteen_Year_Interpolated

		,A.[Nineteen_Year]

		,B.[Nineteen_Year] AS Nineteen_Year_Interpolated

		,A.[Twenty_Year]

		,B.[Twenty_Year] AS Twenty_Year_Interpolated

		,A.[Twenty_One_Year]

		,B.[Twenty_One_Year] AS Twenty_One_Year_Interpolated

		,A.[Twenty_Two_Year]

		,B.[Twenty_Two_Year] AS Twenty_Two_Year_Interpolated

		,A.[Twenty_Three_Year]

		,B.[Twenty_Three_Year] AS Twenty_Three_Year_Interpolated

		,A.[Twenty_Four_Year]

		,B.[Twenty_Four_Year] AS Twenty_Four_Year_Interpolated

		,A.[Twenty_Five_Year]

		,B.[Twenty_Five_Year] AS Twenty_Five_Year_Interpolated

		,A.[Twenty_Six_Year]

		,B.[Twenty_Six_Year] AS Twenty_Six_Year_Interpolated

		,A.[Twenty_Seven_Year]

		,B.[Twenty_Seven_Year] AS Twenty_Seven_Year_Interpolated

		,A.[Twenty_Eight_Year]

		,B.[Twenty_Eight_Year] AS Twenty_Eight_Year_Interpolated

		,A.[Twenty_Nine_Year]

		,B.[Twenty_Nine_Year] AS Twenty_Nine_Year_Interpolated

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

,[Eleven_Year] = ISNULL([Eleven_Year], Eleven_Year_Interpolated)

,[Twelve_Year] = ISNULL([Twelve_Year], Twelve_Year_Interpolated)

,[Thirteen_Year] = ISNULL([Thirteen_Year], Thirteen_Year_Interpolated)

,[Fourteen_Year] = ISNULL([Fourteen_Year], Fourteen_Year_Interpolated)

,[Fifteen_Year] = ISNULL([Fifteen_Year], Fifteen_Year_Interpolated)

,[Sixteen_Year] = ISNULL([Sixteen_Year], Sixteen_Year_Interpolated)

,[Seventeen_Year] = ISNULL([Seventeen_Year], Seventeen_Year_Interpolated)

,[Eighteen_Year] = ISNULL([Eighteen_Year], Eighteen_Year_Interpolated)

,[Nineteen_Year] = ISNULL([Nineteen_Year], Nineteen_Year_Interpolated)

,[Twenty_Year] = ISNULL([Twenty_Year], Twenty_Year_Interpolated)

,[Twenty_One_Year] = ISNULL([Twenty_One_Year], Twenty_One_Year_Interpolated)

,[Twenty_Two_Year] = ISNULL([Twenty_Two_Year], Twenty_Two_Year_Interpolated)

,[Twenty_Three_Year] = ISNULL([Twenty_Three_Year], Twenty_Three_Year_Interpolated)

,[Twenty_Four_Year] = ISNULL([Twenty_Four_Year], Twenty_Four_Year_Interpolated)

,[Twenty_Five_Year] = ISNULL([Twenty_Five_Year], Twenty_Five_Year_Interpolated)

,[Twenty_Six_Year] = ISNULL([Twenty_Six_Year], Twenty_Six_Year_Interpolated)

,[Twenty_Seven_Year] = ISNULL([Twenty_Seven_Year], Twenty_Seven_Year_Interpolated)

,[Twenty_Eight_Year] = ISNULL([Twenty_Eight_Year], Twenty_Eight_Year_Interpolated)

,[Twenty_Nine_Year] = ISNULL([Twenty_Nine_Year], Twenty_Nine_Year_Interpolated)

,[Thirty_Year] = ISNULL([Thirty_Year], Thirty_Year_Interpolated)



END





