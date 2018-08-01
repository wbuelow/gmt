

-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_US_Monthly]

AS

BEGIN



SET NOCOUNT ON;



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [us].[Monthly])



SELECT M.BOM AS DATE

		,CAST(un.Value/100     AS [decimal](5, 4)) AS Un_Rate

		,CAST(CPI.Value/100    AS [decimal](5, 4)) AS CPI_Core_Rate

		,CAST(PMI.Value        AS [decimal](5, 3)) AS Man_PMI_Comp

		,CAST(Hous.Value       AS [int]          ) AS Hous_Starts

		,CAST(P.Fed_Funds_Date AS [date]         ) AS Fed_Funds_Date

		,CAST(P.Fed_Funds_Rate AS [decimal](5, 4)) AS Fed_Funds_Rate

		,CAST(Budget.Budget	   AS [int]          ) AS Budget

		,CAST(PPI.Value        AS [decimal](7, 4)) AS PPI

		,CAST(SPMI.Value       AS [decimal](4, 2)) AS SPMI

		,CAST(MPMI.Value       AS [decimal](4, 2)) AS MPMI

		,CAST(CPI_ix.Value     AS [decimal](7, 4)) AS CPI

	INTO #Staged

	FROM [x].[Mnth] AS M

	LEFT JOIN stg.USAUNR AS UN

	ON UN.DATE = M.EOM

	LEFT JOIN stg.USAHSTT AS Hous

	ON Hous.Date = M.EOM

	LEFT JOIN stg.USACINF AS CPI

	ON CPI.Date = M.EOM

	LEFT JOIN stg.MAN_PMI AS PMI

	ON PMI.Date = M.BOM

	OUTER APPLY(

		SELECT TOP 1 Fed.Date AS Fed_Funds_Date

				,Fed.Value/100 AS Fed_Funds_Rate

			FROM stg.USAIR AS Fed

			WHERE Fed.Date >= M.BOM

			ORDER BY Fed.Date 

	) AS P

	LEFT JOIN (

		SELECT DATE

				,Budget

			FROM (

				SELECT DATE

						,AVG([Value]) OVER ( ORDER BY Date ROWS 11 PRECEDING )*12/1000 AS Budget--SAAR 

						,ROW_NUMBER() OVER ( ORDER BY DATE) AS ROW_N

					FROM stg.USAGBVL

			) AS Ordered

			WHERE ROW_N >= 12

	) AS Budget

	ON Budget.Date = M.EOM

	LEFT JOIN (

		SELECT DATE

				,Value

			FROM stg.USAPPI AS PPI

		UNION ALL

		SELECT DATE	

				,PPI

			FROM [gmt].[stg].[static_USAPPIACO]

			WHERE Date < '2009-11-30'

	) AS PPI

	ON PPI.Date = M.EOM

	LEFT JOIN stg.USAMPMI AS MPMI

	ON M.EOM = MPMI.DATE

	LEFT JOIN stg.USASPMI AS SPMI

	ON M.EOM = SPMI.DATE

	LEFT JOIN stg.USACPI AS CPI_ix

	ON M.EOM = CPI_ix.Date

	WHERE COALESCE(un.Value

		,Hous.Value

		,CPI.Value

		,PMI.Value

		,P.Fed_Funds_Rate

		,Budget.Budget

		,PPI.Value

		,MPMI.Value

		,SPMI.Value

		,CPI_ix.Value) IS NOT NULL



UPDATE [us].[Monthly]

SET Un_Rate     = CASE WHEN #Staged.Un_Rate        <> Monthly.Un_Rate        OR Monthly.Un_Rate        IS NULL THEN #Staged.Un_Rate        ELSE Monthly.Un_Rate             END

,Hous_Starts    = CASE WHEN #Staged.Hous_Starts    <> Monthly.Hous_Starts    OR Monthly.Hous_Starts    IS NULL THEN #Staged.Hous_Starts    ELSE Monthly.Hous_Starts         END

,CPI_Core_Rate  = CASE WHEN #Staged.CPI_Core_Rate  <> Monthly.CPI_Core_Rate  OR Monthly.CPI_Core_Rate  IS NULL THEN #Staged.CPI_Core_Rate  ELSE Monthly.CPI_Core_Rate       END 

,Man_PMI_Comp   = CASE WHEN #Staged.Man_PMI_Comp   <> Monthly.Man_PMI_Comp   OR Monthly.Man_PMI_Comp   IS NULL THEN #Staged.Man_PMI_Comp   ELSE Monthly.Man_PMI_Comp        END 

,Fed_Funds_Date = CASE WHEN #Staged.Fed_Funds_Date <> Monthly.Fed_Funds_Date OR Monthly.Fed_Funds_Date IS NULL THEN #Staged.Fed_Funds_Date ELSE Monthly.Fed_Funds_Date      END 

,Fed_Funds_Rate = CASE WHEN #Staged.Fed_Funds_Rate <> Monthly.Fed_Funds_Rate OR Monthly.Fed_Funds_Rate IS NULL THEN #Staged.Fed_Funds_Rate ELSE Monthly.Fed_Funds_Rate      END 

,Budget			= CASE WHEN #Staged.Budget		   <> Monthly.Budget		 OR Monthly.Budget		   IS NULL THEN #Staged.Budget		   ELSE Monthly.Budget		        END 

,PPI			= CASE WHEN #Staged.PPI			   <> Monthly.PPI			 OR Monthly.PPI			   IS NULL THEN #Staged.PPI			   ELSE Monthly.PPI			        END 

,MPMI		    = CASE WHEN #Staged.MPMI		   <> Monthly.MPMI		     OR Monthly.MPMI		   IS NULL THEN #Staged.MPMI		   ELSE Monthly.MPMI		        END   

,SPMI			= CASE WHEN #Staged.SPMI		   <> Monthly.SPMI			 OR Monthly.SPMI		   IS NULL THEN #Staged.SPMI		   ELSE Monthly.SPMI			    END  

,CPI			= CASE WHEN #Staged.CPI			   <> Monthly.CPI			 OR Monthly.CPI			   IS NULL THEN #Staged.CPI			   ELSE Monthly.CPI			        END 

FROM #Staged																						  

WHERE #Staged.DATE = [Monthly].DATE



INSERT INTO [us].[Monthly]

(

[Date]

,Un_Rate

,Hous_Starts

,CPI_Core_Rate

,Man_PMI_Comp

,Fed_Funds_Date

,Fed_Funds_Rate

,Budget

,PPI

,MPMI

,SPMI

,CPI

)

SELECT DATE

		,Un_Rate

		,Hous_Starts

		,CPI_Core_Rate

		,Man_PMI_Comp

		,Fed_Funds_Date

		,Fed_Funds_Rate

		,Budget

		,PPI

		,MPMI

		,SPMI

		,CPI

	FROM #Staged

	WHERE DATE > @MAX_DATE

	ORDER BY DATE



END

