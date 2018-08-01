



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================



CREATE PROCEDURE [dbo].[stp_etl_NZ_Model]

AS

BEGIN



SET NOCOUNT ON;



DELETE FROM [trade].[FX]

WHERE Pair = 'NZLUSD'



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

IF OBJECT_ID('tempdb..#PMI') IS NOT NULL

DROP TABLE #PMI

IF OBJECT_ID('tempdb..#Cmdty') IS NOT NULL

DROP TABLE #Cmdty



/* Gather Rate differential data, join to currency for the "left" side of the model */



;WITH Rate AS (

SELECT nz.Date

		,CASE WHEN nz.Date < '2013-10-16' OR nz.Date > '2014-12-14'

			  THEN nz.Two_Year

			  ELSE nz.Five_Year

		 END AS F_Rate

		,CASE WHEN nz.Date < '2013-10-16' OR nz.Date > '2014-12-14'

			  THEN US.Two_Year

			  ELSE US.Five_Year

		 END AS H_Rate

	FROM nz.Rate AS nz

	JOIN US.Rate AS US

	ON nz.Date = US.Date

	AND nz.Date >= '1985-03-19'

)

SELECT FX_BackRatio.Date

		,FX_BackRatio.Settle AS FX_BackRatio

		,FX_CalWeight.Settle AS FX_CalWeight

		,R.F_Rate

		,R.H_Rate

	INTO #FX

	FROM stg.CME_NE1_OR AS FX_BackRatio

	JOIN stg.CME_NE1_FW AS FX_CalWeight

	ON FX_BackRatio.Date = FX_CalWeight.Date

	LEFT JOIN Rate AS R

	ON FX_BackRatio.Date = R.Date



/* Current account */



;WITH F AS (

SELECT Date

	,[CA]/P.NGDP AS CA

	FROM nz.[Quarterly] AS CA

	OUTER APPLY (

	SELECT TOP 1 NGDP

		FROM nz.[Quarterly]

		WHERE CA.Date >= [Quarterly].Date

		AND [Quarterly].NGDP IS NOT NULL

		ORDER BY [Quarterly].Date DESC

	) AS P

	WHERE CA IS NOT NULL

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

SELECT F.DATE

		,F.CA AS F_CA

		,H.CA AS H_CA

	INTO #CA

	FROM F

	JOIN H

	ON F.Date = H.Date

	WHERE F.CA IS NOT NULL

	AND H.CA IS NOT NULL

	ORDER BY Date



/* Budget */



;WITH F AS (

SELECT Date

		,Value/NGDP AS Budget

	FROM STG.NZLGBVL

	OUTER APPLY (

		SELECT TOP 1 NGDP

			FROM [au].[Quarterly]

			WHERE NZLGBVL.Date >= [Quarterly].Date

			AND [Quarterly].NGDP IS NOT NULL

			ORDER BY [Quarterly].Date DESC

	) AS P

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

	FROM nz.NZX50 AS F

	JOIN us.SP500 AS S

	ON F.Date = S.Date



/* PPI */



SELECT Date

		,Quarterly.PPI AS F_PPI

		,P.PPI AS H_PPI

	INTO #PPI

	FROM nz.Quarterly

	OUTER APPLY (

		SELECT TOP 1 PPI

			FROM us.Monthly

			WHERE Quarterly.Date >= Monthly.Date

			AND Monthly.PPI IS NOT NULL

			ORDER BY Monthly.Date DESC

	) AS P

	WHERE Quarterly.PPI IS NOT NULL



/* PMI */



SELECT NZ.DATE,

			/*Have both SPMI and MPMI from both F and H */

	   CASE WHEN NZ.MPMI IS NOT NULL AND NZ.SPMI IS NOT NULL 

				AND 

				(

				(US.MPMI IS NOT NULL AND US.SPMI IS NOT NULL)

				OR

				US.Man_PMI_Comp IS NOT NULL

				)

			THEN NZ.MPMI*.25 + NZ.SPMI*.75

			WHEN NZ.MPMI IS NOT NULL AND US.MPMI IS NOT NULL AND NZ.SPMI IS NULL AND US.SPMI IS NULL

			THEN NZ.MPMI

			WHEN NZ.SPMI IS NOT NULL AND US.SPMI IS NOT NULL AND NZ.MPMI IS NULL AND US.MPMI IS NULL

			THEN NZ.SPMI

			WHEN NZ.MPMI IS NOT NULL AND US.MPMI IS NOT NULL

			THEN NZ.MPMI

			WHEN NZ.MPMI IS NOT NULL AND US.Man_PMI_Comp IS NOT NULL

			THEN NZ.MPMI

			WHEN NZ.SPMI IS NOT NULL AND US.SPMI IS NOT NULL

			THEN NZ.SPMI

			WHEN NZ.SPMI IS NOT NULL AND US.Man_PMI_Comp IS NOT NULL

			THEN NZ.SPMI

	   END AS F_PMI

	   ,CASE WHEN NZ.MPMI IS NOT NULL AND NZ.SPMI IS NOT NULL 

				AND 

				(

				(US.MPMI IS NOT NULL AND US.SPMI IS NOT NULL)

				OR

				US.Man_PMI_Comp IS NOT NULL

				)

			THEN ISNULL(US.MPMI*.25 + US.SPMI*.75, US.Man_PMI_Comp)

			WHEN NZ.MPMI IS NOT NULL AND US.MPMI IS NOT NULL AND NZ.SPMI IS NULL AND US.SPMI IS NULL

			THEN US.MPMI

			WHEN NZ.SPMI IS NOT NULL AND US.SPMI IS NOT NULL AND NZ.MPMI IS NULL AND US.MPMI IS NULL

			THEN US.SPMI

			WHEN NZ.MPMI IS NOT NULL AND US.MPMI IS NOT NULL

			THEN US.MPMI

			WHEN NZ.MPMI IS NOT NULL AND US.Man_PMI_Comp IS NOT NULL

			THEN US.Man_PMI_Comp

			WHEN NZ.SPMI IS NOT NULL AND US.SPMI IS NOT NULL

			THEN US.SPMI

			WHEN NZ.SPMI IS NOT NULL AND US.Man_PMI_Comp IS NOT NULL

			THEN US.Man_PMI_Comp

	   END AS H_PMI

	INTO #PMI

	FROM NZ.Monthly AS NZ

	JOIN US.Monthly AS US

	ON NZ.Date = US.Date

	ORDER BY NZ.DATE



/* Commodity */



--CREATE TABLE #Cmdty ([Date] DATE, CmdtyIX DECIMAL(7,4))

--INSERT INTO #Cmdty

--EXEC [dbo].[stp_Get_AU_Cmdty_IX]



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

SELECT 'NZLUSD'

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

					FROM [gmt].[stg].[COTNE]

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

	--OUTER APPLY (

	--	SELECT TOP 1 CmdtyIX

	--		FROM #Cmdty

	--		WHERE F.DATE >= #Cmdty.DATE

	--		ORDER BY #Cmdty.DATE DESC

	--) AS P5

	ORDER BY Date



END

