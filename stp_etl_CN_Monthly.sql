





-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_CN_Monthly]

AS

BEGIN



	SET NOCOUNT ON;



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [cn].[Monthly])



SELECT BOM AS DATE

		,CAST(AVG(Budget.Value) OVER ( ORDER BY Budget.Date ROWS 11 PRECEDING )*12 AS DECIMAL) AS Budget --SAAR

		,PPI.Value AS PPI 

		,MPMI.Value AS MPMI

	INTO #Stage

	FROM [x].[Mnth] AS M

	LEFT JOIN [stg].[CANGBVL] AS Budget

	ON Budget.DATE = M.EOM

	LEFT JOIN stg.CANPPI AS PPI

	ON PPI.Date = M.EOM

	LEFT JOIN stg.CANMPMI AS MPMI

	ON M.EOM = MPMI.DATE

	WHERE COALESCE(Budget.Value, PPI.Value, MPMI.Value) IS NOT NULL



UPDATE [cn].[Monthly]

SET Budget = #Stage.Budget

,PPI = #Stage.PPI

,MPMI = #Stage.MPMI

FROM #Stage

WHERE [cn].[Monthly].Date = #Stage.DATE



INSERT INTO [cn].[Monthly]

(

[Date]

,Budget

,PPI

,MPMI

)

SELECT DATE

		,Budget

		,PPI

		,MPMI

	FROM #Stage

	WHERE DATE > @MAX_DATE

	ORDER BY DATE



END

