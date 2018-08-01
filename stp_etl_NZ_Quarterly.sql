



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_NZ_Quarterly]

AS

BEGIN



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [nz].[Quarterly])



	SET NOCOUNT ON;



	;WITH EOQ AS (

	SELECT Q.January

			,RGDP.VALUE AS RGDP

			,DEFL.Value AS DEFL

			,CA.Value AS CA

			,PPI.Value AS PPI

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[NZLGCP] AS RGDP

		ON Q.March = RGDP.Date

		LEFT JOIN [stg].[NZLGD] AS DEFL

		ON Q.March = DEFL.Date

		LEFT JOIN [stg].[NZLCA] AS CA

		ON Q.March = CA.Date

		LEFT JOIN [stg].[NZLPPI] AS PPI

		ON Q.March = PPI.Date

	)

	, MOQ AS (

	SELECT Q.January

			,RGDP.VALUE AS RGDP

			,DEFL.Value AS DEFL

			,CA.Value AS CA

			,PPI.Value AS PPI

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[NZLGCP] AS RGDP

		ON Q.February = RGDP.Date

		LEFT JOIN [stg].[NZLGD] AS DEFL

		ON Q.February = DEFL.Date

		LEFT JOIN [stg].[NZLCA] AS CA

		ON Q.March = CA.Date

		LEFT JOIN [stg].[NZLPPI] AS PPI

		ON Q.March = PPI.Date

	)

	, Combined AS (

	SELECT ISNULL(EOQ.January, MOQ.January) AS [Date]

			,ISNULL(EOQ.RGDP, MOQ.RGDP) AS RGDP

			,ISNULL(EOQ.DEFL, MOQ.DEFL) AS DEFL

			,ISNULL(EOQ.CA, MOQ.CA) AS CA

			,ISNULL(EOQ.PPI, MOQ.PPI) AS PPI

		FROM EOQ

		FULL JOIN MOQ

		ON EOQ.January = MOQ.January

		WHERE COALESCE(EOQ.CA, MOQ.CA, EOQ.RGDP, MOQ.RGDP, EOQ.DEFL, MOQ.DEFL, EOQ.PPI, MOQ.PPI) IS NOT NULL

	)

	SELECT DATE

			,RGDP*4 AS RGDP--Annualize

			,DEFL

			,AVG(CA) OVER ( ORDER BY Date ROWS 3 PRECEDING )*4 AS CA--SAAR 

			,PPI

		INTO #Staged

		FROM Combined



	UPDATE nz.[Quarterly]

	SET CA = S.CA

	,RGDP = S.RGDP

	,DEFL = S.DEFL

	,NGDP = S.RGDP*S.DEFL/1000

	,PPI = S.PPI

	FROM #Staged AS S

	WHERE [Quarterly].DATE = S.DATE



	INSERT INTO nz.[Quarterly]

	(

	[Date]

	,CA

	,[RGDP]

	,[Defl]

	,[NGDP]

	,PPI

	)

	SELECT DATE

			,CA

			,RGDP

			,DEFL

			,RGDP*DEFL/1000 AS NGDP

			,PPI

		FROM #Staged

		WHERE DATE > @MAX_DATE

		ORDER BY DATE



END



