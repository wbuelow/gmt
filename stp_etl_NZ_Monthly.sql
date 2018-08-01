







-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_NZ_Monthly]

AS

BEGIN



	SET NOCOUNT ON;



DECLARE @MAX_DATE AS DATE = (SELECT ISNULL(MAX(DATE), '1900-01-01') FROM [nz].[Monthly])



SELECT M.BOM AS DATE

		,MPMI.Value AS MPMI

		,SPMI.Value AS SPMI

	INTO #Staged

	FROM [x].[Mnth] AS M

	LEFT JOIN stg.NZLMPMI AS MPMI

	ON M.EOM = MPMI.DATE

	LEFT JOIN stg.NZLSPMI AS SPMI

	ON M.EOM = SPMI.DATE

	WHERE COALESCE(MPMI.Value, SPMI.Value) IS NOT NULL

	



UPDATE [nz].[Monthly]

SET MPMI = #Staged.MPMI

,SPMI = #Staged.SPMI

FROM #Staged

WHERE #Staged.DATE = [Monthly].DATE



INSERT INTO [nz].[Monthly]

(

[Date]

,MPMI

,SPMI

)

SELECT DATE

		,MPMI

		,SPMI

	FROM #Staged

	WHERE DATE > @MAX_DATE

	ORDER BY DATE



END



