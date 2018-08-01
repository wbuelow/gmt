





-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_SF_Monthly]

AS

BEGIN



	SET NOCOUNT ON;



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [sf].[Monthly])



SELECT BOM AS DATE

		,PPI.Value AS PPI

		,MPMI.Value AS MPMI

	INTO #Stage

	FROM [x].[Mnth] AS M

	LEFT JOIN stg.CHEPPI AS PPI

	ON PPI.Date = M.EOM

	LEFT JOIN stg.CHEMPMI AS MPMI

	ON M.EOM = MPMI.DATE

	WHERE COALESCE(PPI.Value,MPMI.Value) IS NOT NULL



UPDATE [sf].[Monthly]

SET PPI = #Stage.PPI

,MPMI = #Stage.MPMI

FROM #Stage

WHERE [sf].[Monthly].Date = #Stage.DATE



INSERT INTO [sf].[Monthly]

(

[Date]

,PPI

,MPMI

)

SELECT DATE

		,PPI

		,MPMI

	FROM #Stage

	WHERE DATE > @MAX_DATE

	ORDER BY DATE



END



