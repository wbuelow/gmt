



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_EU_Annual]

AS

BEGIN



	TRUNCATE TABLE [eu].[Annual]



	SET NOCOUNT ON;



	INSERT INTO [eu].[Annual]

	(

	[Date]

	,Budget_over_GDP

	)

	SELECT DATEADD(D, 1, DATEADD(YEAR, -1, [Date]))

			,Value/100

		FROM [stg].[EURGBGT]

		ORDER BY DATE



END







