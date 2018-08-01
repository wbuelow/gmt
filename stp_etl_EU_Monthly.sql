



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_EU_Monthly]

AS

BEGIN



SET NOCOUNT ON;



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [eu].[Monthly])



SELECT BOM AS DATE

		,CAST(AVG(CA.Value) OVER ( ORDER BY CA.Date ROWS 11 PRECEDING )*12 AS DECIMAL) AS CA --SAAR

		,PPI.Value AS PPI

		,MPMI.Value AS MPMI

		,SPMI.Value AS SPMI

	INTO #Stage

	FROM [x].[Mnth] AS M

	LEFT JOIN [stg].[EURCA] AS CA

	ON M.EOM = CA.DATE

	LEFT JOIN stg.EURPPI AS PPI

	ON M.EOM = PPI.Date

	LEFT JOIN stg.EURMPMI AS MPMI

	ON M.EOM = MPMI.DATE

	LEFT JOIN stg.EURSPMI AS SPMI

	ON M.EOM = SPMI.DATE

	WHERE COALESCE(CA.Value, PPI.Value, MPMI.Value, SPMI.Value) IS NOT NULL



UPDATE [eu].[Monthly]

SET [CA] = #Stage.CA

,PPI = #Stage.PPI

,MPMI = #Stage.MPMI

,SPMI = #Stage.SPMI

FROM #Stage

WHERE [Monthly].DATE = #Stage.DATE



INSERT INTO [eu].[Monthly]

(

[Date]

,CA

,PPI

,MPMI

,SPMI

)

SELECT DATE

		,CA

		,PPI

		,MPMI

		,SPMI

	FROM #Stage

	WHERE DATE > @MAX_DATE

	ORDER BY DATE



END











