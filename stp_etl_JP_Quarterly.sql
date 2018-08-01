

-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_JP_Quarterly]

AS

BEGIN



truncate table [jp].[Quarterly]



	SET NOCOUNT ON;



	;WITH EOQ AS (

	SELECT Q.January

			,GBVL.VALUE AS GBVL

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[JPNGBVL] AS GBVL

		ON Q.March = GBVL.Date

		LEFT JOIN [stg].[JPNGCP] AS RGDP

		ON Q.March = RGDP.Date

		LEFT JOIN [stg].[JPNGD] AS DEFL

		ON Q.March = DEFL.Date

	)

	, MOQ AS (

	SELECT Q.January

			,GBVL.VALUE AS GBVL

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[JPNGBVL] AS GBVL

		ON Q.February = GBVL.Date

		LEFT JOIN [stg].[JPNGCP] AS RGDP

		ON Q.February = RGDP.Date

		LEFT JOIN [stg].[JPNGD] AS DEFL

		ON Q.February = DEFL.Date

	)

	, Combined AS (

	SELECT ISNULL(EOQ.January, MOQ.January) AS [Date]

			,ISNULL(EOQ.GBVL, MOQ.GBVL) AS GBVL

			,ISNULL(EOQ.RGDP, MOQ.RGDP) AS RGDP

			,ISNULL(EOQ.DEFL, MOQ.DEFL) AS DEFL

		FROM EOQ

		FULL JOIN MOQ

		ON EOQ.January = MOQ.January

		WHERE COALESCE(EOQ.GBVL, MOQ.GBVL, EOQ.RGDP, MOQ.RGDP, EOQ.DEFL, MOQ.DEFL) IS NOT NULL

	)

	SELECT DATE

			,AVG(GBVL) OVER ( ORDER BY Date ROWS 3 PRECEDING )*4/10 AS [Budget]--SAAR 

			,RGDP*4 AS RGDP--Annualize

			,AVG(DEFL) OVER ( ORDER BY Date ROWS 3 PRECEDING ) AS DEFL--SA

		INTO #Staged

		FROM Combined





	INSERT INTO [jp].[Quarterly]

	(

	[Date]

	,[Budget]

	,[RGDP]

	,[Defl]

	,[NGDP]

	)

	SELECT DATE

			,[Budget]

			,RGDP

			,DEFL

			,RGDP*DEFL/100 AS NGDP

		FROM #Staged

		ORDER BY DATE



END

