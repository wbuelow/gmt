



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_CN_Quarterly]

AS

BEGIN



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [cn].[Quarterly])



	SET NOCOUNT ON;



	;WITH EOQ AS (

	SELECT Q.January

			,CA.VALUE AS CA

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[CANCA] AS CA

		ON Q.March = CA.Date

		LEFT JOIN [stg].[CANGCP] AS RGDP

		ON Q.March = RGDP.Date

		LEFT JOIN [stg].[CANGD] AS DEFL

		ON Q.March = DEFL.Date

	)

	, MOQ AS (

	SELECT Q.January

			,CA.VALUE AS CA

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[CANCA] AS CA

		ON Q.February = CA.Date

		LEFT JOIN [stg].[CANGCP] AS RGDP

		ON Q.February = RGDP.Date

		LEFT JOIN [stg].[CANGD] AS DEFL

		ON Q.February = DEFL.Date

	)

	, Combined AS (

	SELECT ISNULL(EOQ.January, MOQ.January) AS [Date]

			,ISNULL(EOQ.CA, MOQ.CA) AS CA

			,ISNULL(EOQ.RGDP, MOQ.RGDP) AS RGDP

			,ISNULL(EOQ.DEFL, MOQ.DEFL) AS DEFL

		FROM EOQ

		FULL JOIN MOQ

		ON EOQ.January = MOQ.January

		WHERE COALESCE(EOQ.CA, MOQ.CA, EOQ.RGDP, MOQ.RGDP, EOQ.DEFL, MOQ.DEFL) IS NOT NULL

	)

	SELECT DATE

			,AVG([CA]) OVER ( ORDER BY Date ROWS 3 PRECEDING )*4 AS CA--SAAR 

			,RGDP--already annualized

			,DEFL

		INTO #Staged

		FROM Combined



	UPDATE [cn].[Quarterly]

	SET CA = S.CA

	,RGDP = S.RGDP

	,DEFL = S.DEFL

	,NGDP = S.RGDP*S.DEFL/100

	FROM #Staged AS S

	WHERE [Quarterly].DATE = S.DATE



	INSERT INTO [cn].[Quarterly]

	(

	[Date]

	,[CA]

	,[RGDP]

	,[Defl]

	,[NGDP]

	)

	SELECT DATE

			,CA

			,RGDP

			,DEFL

			,RGDP*DEFL/100 AS NGDP --Annualize

		FROM #Staged

		WHERE DATE > @MAX_DATE

		ORDER BY DATE



END





