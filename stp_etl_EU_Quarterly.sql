-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_EU_Quarterly]

AS

BEGIN



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [eu].[Quarterly])



	SET NOCOUNT ON;



	;WITH EOQ AS (

	SELECT Q.January

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[EURGCP] AS RGDP

		ON Q.March = RGDP.Date

		LEFT JOIN [stg].[EURGD] AS DEFL

		ON Q.March = DEFL.Date

	)

	, MOQ AS (

	SELECT Q.January

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[EURGCP] AS RGDP

		ON Q.February = RGDP.Date

		LEFT JOIN [stg].[EURGD] AS DEFL

		ON Q.February = DEFL.Date

	)

	, Combined AS (

	SELECT ISNULL(EOQ.January, MOQ.January) AS [Date]

			,ISNULL(EOQ.RGDP, MOQ.RGDP) AS RGDP

			,ISNULL(EOQ.DEFL, MOQ.DEFL) AS DEFL

		FROM EOQ

		FULL JOIN MOQ

		ON EOQ.January = MOQ.January

		WHERE COALESCE(EOQ.RGDP, MOQ.RGDP, EOQ.DEFL, MOQ.DEFL) IS NOT NULL

	)

	SELECT DATE

			,RGDP*4 AS RGDP

			,DEFL

		INTO #Staged

		FROM Combined



	UPDATE [eu].[Quarterly]

	SET RGDP = S.RGDP

	,DEFL = S.DEFL

	,NGDP = S.RGDP*S.DEFL/100

	FROM #Staged AS S

	WHERE [Quarterly].DATE = S.DATE



	INSERT INTO [eu].[Quarterly]

	(

	[Date]

	,[RGDP]

	,[Defl]

	,[NGDP]

	)

	SELECT DATE

			,RGDP

			,DEFL

			,RGDP*DEFL/100 AS NGDP

		FROM #Staged

		WHERE DATE > @MAX_DATE

		ORDER BY DATE



END

