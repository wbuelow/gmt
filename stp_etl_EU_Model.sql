

-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================



CREATE PROCEDURE [dbo].[stp_etl_EU_Model]

AS

BEGIN



SET NOCOUNT ON;



DELETE FROM [trade].[FX]

WHERE Pair = 'EURUSD'



IF OBJECT_ID('tempdb..#FX') IS NOT NULL

DROP TABLE #FX

IF OBJECT_ID('tempdb..#CA') IS NOT NULL

DROP TABLE #CA

IF OBJECT_ID('tempdb..#Budget') IS NOT NULL

DROP TABLE #Budget

IF OBJECT_ID('tempdb..#Equities') IS NOT NULL

DROP TABLE #Equities

IF OBJECT_ID('tempdb..#PPI') IS NOT NULL

DROP TABLE #PPI



/* Gather Rate differential data, join to currency for the "left" side of the model */



;WITH Rate AS (

SELECT de.Date

		,de.Two_Year AS F_Rate

		,US.Two_Year AS H_Rate

	FROM de.Rate AS de

	JOIN US.Rate AS US

	ON de.Date = US.Date

)

SELECT FX_BackRatio.Date

		,FX_BackRatio.Settle AS FX_BackRatio

		,FX_CalWeight.Settle AS FX_CalWeight

		,F_Rate

		,H_Rate

	INTO #FX

	FROM stg.CME_EC1_OR AS FX_BackRatio

	JOIN stg.CME_EC1_FW AS FX_CalWeight

	ON FX_BackRatio.Date = FX_CalWeight.Date

	LEFT JOIN Rate AS R

	ON FX_BackRatio.Date = R.Date



/* Current account */



;WITH F AS (

SELECT Date

	,[CA]/P.NGDP AS CA

	FROM EU.[Monthly] AS CA

	OUTER APPLY (

	SELECT TOP 1 NGDP

		FROM [EU].[Quarterly]

		WHERE CA.Date >= [Quarterly].Date

		AND [Quarterly].NGDP IS NOT NULL

		ORDER BY [Quarterly].Date DESC

	) AS P

), H AS (

SELECT Date

	,[CA]/P.NGDP AS CA

	FROM us.[Quarterly] AS CA

	OUTER APPLY (

	SELECT TOP 1 NGDP

		FROM us.[Quarterly]

		WHERE CA.Date >= [Quarterly].Date

		AND [Quarterly].NGDP IS NOT NULL

		ORDER BY [Quarterly].Date DESC

	) AS P

	WHERE CA IS NOT NULL

)

SELECT ISNULL(F.DATE, H.DATE) AS Date

		,F.CA AS F_CA

		,H.CA AS H_CA

	INTO #CA

	FROM F

	FULL JOIN H

	ON F.Date = H.Date

	ORDER BY Date



/* Budget */



;WITH F AS (

SELECT Date

		,Budget_over_GDP AS Budget

	FROM eu.Annual

), H AS (

SELECT Date

		,Budget/NGDP AS Budget

	FROM us.Monthly

	OUTER APPLY (

		SELECT TOP 1 NGDP

			FROM us.[Quarterly]

			WHERE Monthly.Date >= [Quarterly].Date

			AND [Quarterly].NGDP IS NOT NULL

			ORDER BY [Quarterly].Date DESC

	) AS P

	WHERE Budget IS NOT NULL

)

SELECT ISNULL(F.DATE, H.DATE) AS Date

		,F.Budget AS F_Budget

		,H.Budget AS H_Budget

	INTO #Budget

	FROM F

	FULL JOIN H

	ON F.Date = H.Date

	

/* Equities */



SELECT F.Date

		,F.Adjusted_Close AS F_equities

		,S.Adjusted_Close AS H_equities

	INTO #Equities

	FROM eu.stoxx50 AS F

	JOIN us.SP500 AS S

	ON F.Date = S.Date



/* PPI */



SELECT F.Date

		,F.PPI AS F_PPI

		,H.PPI AS H_PPI

	INTO #PPI

	FROM eu.Monthly AS F

	JOIN us.Monthly AS H

	ON F.Date = H.Date



/* PMI */



SELECT EU.DATE,

			/*Have both SPMI and MPMI from both F and H */

	   CASE WHEN EU.MPMI IS NOT NULL AND EU.SPMI IS NOT NULL 

				AND 

				(

				(US.MPMI IS NOT NULL AND US.SPMI IS NOT NULL)

				OR

				US.Man_PMI_Comp IS NOT NULL

				)

			THEN EU.MPMI*.25 + EU.SPMI*.75

			WHEN EU.MPMI IS NOT NULL AND US.MPMI IS NOT NULL AND EU.SPMI IS NULL AND US.SPMI IS NULL

			THEN EU.MPMI

			WHEN EU.SPMI IS NOT NULL AND US.SPMI IS NOT NULL AND EU.MPMI IS NULL AND US.MPMI IS NULL

			THEN EU.SPMI

			WHEN EU.MPMI IS NOT NULL AND US.MPMI IS NOT NULL

			THEN EU.MPMI

			WHEN EU.MPMI IS NOT NULL AND US.Man_PMI_Comp IS NOT NULL

			THEN EU.MPMI

			WHEN EU.SPMI IS NOT NULL AND US.SPMI IS NOT NULL

			THEN EU.SPMI

			WHEN EU.SPMI IS NOT NULL AND US.Man_PMI_Comp IS NOT NULL

			THEN EU.SPMI

	   END AS F_PMI

	   ,CASE WHEN EU.MPMI IS NOT NULL AND EU.SPMI IS NOT NULL 

				AND 

				(

				(US.MPMI IS NOT NULL AND US.SPMI IS NOT NULL)

				OR

				US.Man_PMI_Comp IS NOT NULL

				)

			THEN ISNULL(US.MPMI*.25 + US.SPMI*.75, US.Man_PMI_Comp)

			WHEN EU.MPMI IS NOT NULL AND US.MPMI IS NOT NULL AND EU.SPMI IS NULL AND US.SPMI IS NULL

			THEN US.MPMI

			WHEN EU.SPMI IS NOT NULL AND US.SPMI IS NOT NULL AND EU.MPMI IS NULL AND US.MPMI IS NULL

			THEN US.SPMI

			WHEN EU.MPMI IS NOT NULL AND US.MPMI IS NOT NULL

			THEN US.MPMI

			WHEN EU.MPMI IS NOT NULL AND US.Man_PMI_Comp IS NOT NULL

			THEN US.Man_PMI_Comp

			WHEN EU.SPMI IS NOT NULL AND US.SPMI IS NOT NULL

			THEN US.SPMI

			WHEN EU.SPMI IS NOT NULL AND US.Man_PMI_Comp IS NOT NULL

			THEN US.Man_PMI_Comp

	   END AS H_PMI

	INTO #PMI

	FROM EU.Monthly AS EU

	JOIN US.Monthly AS US

	ON EU.Date = US.Date

	ORDER BY EU.DATE



INSERT INTO [trade].[FX]

(

[Pair]

,[Date]

,FX_BackRatio

,FX_CalWeight

,[F_Rate]

,[H_Rate]

,[F_CA]

,[H_CA]

,[F_Budget]

,[H_Budget]

,[F_Equities]

,[H_Equities]

,[COT]

,F_PPI

,H_PPI

,F_PMI

,H_PMI

)

SELECT 'EURUSD'

		,F.Date

		,FX_BackRatio

		,FX_CalWeight

		,F.F_Rate

		,F.H_Rate

		,P.F_CA

		,P.H_CA

		,P1.F_Budget

		,P1.H_Budget

		,E.F_Equities

		,E.H_equities

		,P2.Percent_Long AS 'COT'

		,P3.F_PPI

		,P3.H_PPI

		,P4.F_PMI

		,P4.H_PMI

	FROM #FX F

	OUTER APPLY (

		SELECT TOP 1 F_CA

					,H_CA

			FROM #CA

			WHERE F.DATE >= #CA.DATE

			ORDER BY #CA.DATE DESC

	) AS P

	OUTER APPLY (

		SELECT TOP 1 F_Budget

					,H_Budget

			FROM #Budget

			WHERE F.DATE >= #Budget.DATE

			ORDER BY #Budget.DATE DESC

	) AS P1

	LEFT JOIN #Equities AS E

	ON F.Date = E.Date

	OUTER APPLY (

		SELECT TOP 1 Percent_long

			FROM (

				SELECT [Date]

						,CASE WHEN [Asset Manager Longs] + [Leveraged Funds Longs] + [Asset Manager Shorts] + [Leveraged Funds Shorts]= 0

							  THEN 0

							  ELSE CAST(([Asset Manager Longs] + [Leveraged Funds Longs]) - ([Asset Manager Shorts] + [Leveraged Funds Shorts]) AS DECIMAL)/CAST([Asset Manager Longs] + [Leveraged Funds Longs] + [Asset Manager Shorts] + [Leveraged Funds Shorts] AS DECIMAL)

						 END AS Percent_Long

					FROM [gmt].[stg].[COTEC]

			) AS ComT

			WHERE F.Date >= ComT.Date

			ORDER BY ComT.Date DESC

	) AS P2

	OUTER APPLY (

		SELECT TOP 1 F_PPI

					,H_PPI

			FROM #PPI

			WHERE F.DATE >= #PPI.DATE

			ORDER BY #PPI.DATE DESC

	) AS P3

	OUTER APPLY (

		SELECT TOP 1 F_PMI

					,H_PMI

			FROM #PMI

			WHERE F.DATE >= #PMI.DATE

			ORDER BY #PMI.DATE DESC

	) AS P4

	ORDER BY Date



END

