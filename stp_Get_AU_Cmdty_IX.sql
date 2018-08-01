-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_Get_AU_Cmdty_IX]

AS

BEGIN



;WITH Iron AS (

SELECT Date

		,Value AS Settle

	FROM X.Date

	OUTER APPLY (

		SELECT TOP 1 Value

			FROM stg.static_PIORECR_USD

			WHERE Date.Date >= static_PIORECR_USD.Date

			ORDER BY static_PIORECR_USD.Date DESC

	) AS P

	WHERE Is_Workday = 1

	AND Value IS NOT NULL

	AND Date < (SELECT MIN(DATE)

					FROM [UAOIfutures].SGX_FEF)

UNION

SELECT DATE

		,Settle

	FROM [UAOIfutures].SGX_FEF

)

, Aluminum AS (

SELECT Date

		,Value AS Settle

	FROM X.Date

	OUTER APPLY (

		SELECT TOP 1 Value

			FROM stg.static_WorldBankAL

			WHERE Date.Date >= static_WorldBankAL.Date

			ORDER BY static_WorldBankAL.Date DESC

	) AS P

	WHERE Is_Workday = 1

	AND Value IS NOT NULL

	AND Date < (SELECT MIN(DATE)

					FROM [UAOIfutures].SHFE_AL)

UNION

SELECT DATE

		,Settle

	FROM [UAOIfutures].SHFE_AL

)

, FUTS AS (

SELECT FW.Date

		,CMELC1 AS LC

		,CMEW1 AS W

		,al.Settle AS AL

		,CMEHG1 AS HG

		,fe.Settle AS FE

		,alw.Settle AS ALW

		,ATW.Settle AS CF

		,CMENG1 AS NG

		,CMECL1 AS CL

		,CMEGC1 AS GC

	FROM futures.FW 

	JOIN Aluminum AS AL

	ON FW.Date = AL.Date

	JOIN Iron AS FE

	ON FW.Date = FE.Date

	LEFT JOIN au.ALW

	ON FW.Date = alw.Date

	LEFT JOIN [UAOIfutures].ICE_ATW AS ATW

	ON FW.Date = ATW.Date

	--order by date

)

, Weighted AS (

SELECT Date

		,LC/ (SELECT LC  FROM futs WHERE DATE = '4/3/1990')*5.1  AS LC

		,W/  (SELECT W   FROM futs WHERE DATE = '4/3/1990')*3.1  AS W

		,AL/ (SELECT AL  FROM futs WHERE DATE = '4/3/1990')*2.2  AS AL

		,HG/ (SELECT HG  FROM futs WHERE DATE = '4/3/1990')*2.0  AS HG

		,FE/ (SELECT FE  FROM futs WHERE DATE = '4/3/1990')*29.5 AS FE

		,ALW/(SELECT ALW FROM futs WHERE DATE = '2016-01-11')*12.1 AS ALW

		,CF/ (SELECT CF  FROM futs WHERE DATE = '2006-09-05')*8.9  AS CF

		,NG/ (SELECT NG  FROM futs WHERE DATE = '4/3/1990')*9.7  AS NG

		,CL/ (SELECT CL  FROM futs WHERE DATE = '4/3/1990')*3.9  AS CL

		,GC/ (SELECT GC  FROM futs WHERE DATE = '4/3/1990')*8.7  AS GC

	FROM futs

)

, T AS (

SELECT Weighted.Date

		,CAST(

		 (LC + W + AL + HG + FE + ISNULL(ALW,0) + ISNULL(CF,0) + ISNULL(NG,0) +  ISNULL(CL, 0) + GC)/

		 (CASE WHEN Weighted.[DATE] < '1983-03-30' THEN 85.2-12.1-8.9-9.7-3.9

			   WHEN Weighted.[DATE] < '1990-04-03' THEN 85.2-12.1-8.9-9.7 

			   WHEN Weighted.[DATE] < '2006-09-05' THEN 85.2-12.1-8.9

			   WHEN Weighted.[DATE] < '2016-01-11' THEN 85.2-12.1

			   ELSE 85.2--sum of the weights

		  END)

		  AS DECIMAL(38,19))*100000 AS AU_Index

	FROM Weighted

)

SELECT Date

		,AU_Index/NGDP AS CmdtyIX

	FROM T

	OUTER APPLY (

		SELECT TOP 1 NGDP

			FROM [AU].[Quarterly]

			WHERE T.Date >= [Quarterly].Date

			AND [Quarterly].NGDP IS NOT NULL

			ORDER BY [Quarterly].Date DESC

	) AS P

	ORDER BY DATE

END

