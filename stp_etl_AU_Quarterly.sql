



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_AU_Quarterly]

AS

BEGIN



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [au].[Quarterly])



	SET NOCOUNT ON;



	;WITH EOQ AS (

	SELECT Q.January

			,CA.VALUE AS CA

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

			,PPI.Value AS PPI

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[AUSCA] AS CA

		ON Q.March = CA.Date

		LEFT JOIN [stg].[AUSGCP] AS RGDP

		ON Q.March = RGDP.Date

		LEFT JOIN [stg].[AUSGD] AS DEFL

		ON Q.March = DEFL.Date

		LEFT JOIN stg.AUSPPI AS PPI

		ON Q.March = PPI.Date

	)

	, MOQ AS (

	SELECT Q.January

			,CA.VALUE AS CA

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

			,PPI.Value AS PPI

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[AUSCA] AS CA

		ON Q.February = CA.Date

		LEFT JOIN [stg].[AUSGCP] AS RGDP

		ON Q.February = RGDP.Date

		LEFT JOIN [stg].[AUSGD] AS DEFL

		ON Q.February = DEFL.Date

		LEFT JOIN stg.AUSPPI AS PPI

		ON Q.February = PPI.Date

	)

	, Combined AS (

	SELECT ISNULL(EOQ.January, MOQ.January) AS [Date]

			,ISNULL(EOQ.CA, MOQ.CA) AS CA

			,ISNULL(EOQ.RGDP, MOQ.RGDP) AS RGDP

			,ISNULL(EOQ.DEFL, MOQ.DEFL) AS DEFL

			,ISNULL(EOQ.PPI, MOQ.PPI) AS PPI

		FROM EOQ

		FULL JOIN MOQ

		ON EOQ.January = MOQ.January

		WHERE COALESCE(EOQ.CA, MOQ.CA, EOQ.RGDP, MOQ.RGDP, EOQ.DEFL, MOQ.DEFL, EOQ.PPI, MOQ.PPI) IS NOT NULL

	)

	SELECT DATE

			,AVG([CA]) OVER ( ORDER BY Date ROWS 3 PRECEDING )*4 AS CA--SAAR 

			,RGDP*4 AS RGDP--Annualize

			,DEFL

			,PPI

		INTO #Staged

		FROM Combined



	UPDATE [au].[Quarterly]

	SET CA = S.CA

	,RGDP = S.RGDP

	,DEFL = S.DEFL

	,NGDP = S.RGDP*S.DEFL/100

	,PPI = S.PPI

	FROM #Staged AS S

	WHERE [Quarterly].DATE = S.DATE



	INSERT INTO [au].[Quarterly]

	(

	[Date]

	,[CA]

	,[RGDP]

	,[Defl]

	,[NGDP]

	,PPI

	)

	SELECT DATE

			,CA

			,RGDP

			,DEFL

			,RGDP*DEFL/100 AS NGDP --Annualize

			,PPI

		FROM #Staged

		WHERE DATE > @MAX_DATE

		ORDER BY DATE



END





