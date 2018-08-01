





-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_BP_Monthly]

AS

BEGIN



	SET NOCOUNT ON;



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [bp].[Monthly])



SELECT BOM AS DATE

		,CAST(AVG(Budget.Value) OVER ( ORDER BY Budget.Date ROWS 11 PRECEDING )*12 AS DECIMAL) AS Budget --SAAR

		,PPI.Value AS PPI

		,MPMI.Value AS MPMI

		,SPMI.Value AS SPMI

	INTO #Stage

	FROM [x].[Mnth] AS M

	LEFT JOIN [stg].[GBRGBVL] AS Budget

	ON Budget.DATE = M.EOM

	LEFT JOIN stg.GBRPPI AS PPI

	ON PPI.Date = M.EOM

	LEFT JOIN stg.GBRMPMI AS MPMI

	ON M.EOM = MPMI.DATE

	LEFT JOIN stg.GBRSPMI AS SPMI

	ON M.EOM = SPMI.DATE

	WHERE COALESCE(Budget.Value, PPI.Value, MPMI.Value, SPMI.Value) IS NOT NULL



UPDATE [bp].[Monthly]

SET Budget = #Stage.Budget

,PPI = #Stage.PPI

,MPMI = #Stage.MPMI

,SPMI = #Stage.SPMI

FROM #Stage

WHERE [bp].[Monthly].Date = #Stage.DATE



INSERT INTO [bp].[Monthly]

(

[Date]

,Budget

,PPI

,MPMI

,SPMI

)

SELECT DATE

		,Budget

		,PPI

		,MPMI

		,SPMI

	FROM #Stage

	WHERE DATE > @MAX_DATE

	ORDER BY DATE



END
