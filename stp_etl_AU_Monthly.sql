





-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_AU_Monthly]

AS

BEGIN



	SET NOCOUNT ON;



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [au].[Monthly])





SELECT M.BOM AS DATE

		,CAST(AVG(Budget.Value) OVER ( ORDER BY Budget.Date ROWS 11 PRECEDING )*12 AS DECIMAL) AS Budget --SAAR

		,MPMI.Value AS MPMI

		,SPMI.Value AS SPMI

	INTO #Staged

	FROM [x].[Mnth] AS M

	LEFT JOIN [stg].[AUSGBVL] AS Budget

	ON M.EOM = Budget.DATE

	LEFT JOIN stg.AUSMPMI AS MPMI

	ON M.EOM = MPMI.DATE

	LEFT JOIN stg.AUSSPMI AS SPMI

	ON M.EOM = SPMI.DATE

	WHERE COALESCE(Budget.Value, MPMI.Value, SPMI.Value) IS NOT NULL

	



UPDATE [au].[Monthly]

SET Budget = #Staged.Budget

,MPMI = #Staged.MPMI

,SPMI = #Staged.SPMI

FROM #Staged

WHERE #Staged.DATE = [Monthly].DATE



INSERT INTO [au].[Monthly]

(

[Date]

,Budget

,MPMI

,SPMI

)

SELECT DATE

		,Budget

		,MPMI

		,SPMI

	FROM #Staged

	WHERE DATE > @MAX_DATE

	ORDER BY DATE



END

