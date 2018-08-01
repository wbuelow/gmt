





-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_MP_Quarterly]

AS

BEGIN



TRUNCATE TABLE [mp].[Quarterly]



	SET NOCOUNT ON;



	;WITH EOQ AS (

	SELECT Q.January

			,CA.VALUE AS CA

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[MEXCA] AS CA

		ON Q.March = CA.Date

		LEFT JOIN [stg].[MEXGCP] AS RGDP

		ON Q.March = RGDP.Date

		LEFT JOIN [stg].[MEXGD] AS DEFL

		ON Q.March = DEFL.Date

	)

	, MOQ AS (

	SELECT Q.January

			,CA.VALUE AS CA

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[MEXCA] AS CA

		ON Q.February = CA.Date

		LEFT JOIN [stg].[MEXGCP] AS RGDP

		ON Q.February = RGDP.Date

		LEFT JOIN [stg].[MEXGD] AS DEFL

		ON Q.February = DEFL.Date

	)

	, Combined AS (

	SELECT ISNULL(EOQ.January, MOQ.January) AS [Date]

			,AVG(ISNULL(EOQ.CA, MOQ.CA)) OVER ( ORDER BY ISNULL(EOQ.January, MOQ.January) ROWS 3 PRECEDING ) AS CA

			,ISNULL(EOQ.RGDP, MOQ.RGDP) AS RGDP

			,ISNULL(EOQ.DEFL, MOQ.DEFL) AS DEFL

		FROM EOQ

		FULL JOIN MOQ

		ON EOQ.January = MOQ.January

		WHERE COALESCE(EOQ.RGDP, MOQ.RGDP, EOQ.DEFL, MOQ.DEFL) IS NOT NULL

		--ORDER BY DATE

	)

	INSERT INTO [mp].[Quarterly]

	(

	[Date]

	,[CA]

	,[RGDP]

	,[Defl]

	,[NGDP]

	)

	SELECT DATE

			,AVG([CA]) OVER ( ORDER BY Date ROWS 3 PRECEDING )*4/P.CMEMP1 AS CA--SAAR 

			,RGDP

			,DEFL

			,RGDP*DEFL/100 AS NGDP

		FROM Combined

		OUTER APPLY (

			SELECT TOP 1 CMEMP1/1000000 CMEMP1

				FROM futures.FW AS F

				WHERE F.Date <= Combined.Date

				ORDER BY F.Date DESC

		) AS P

		ORDER BY DATE 



	



END







