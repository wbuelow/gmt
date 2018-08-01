





-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_SF_Annual]

AS

BEGIN



	TRUNCATE TABLE [sf].[Annual]



	SET NOCOUNT ON;



	INSERT INTO [sf].[Annual]

	(

	[Date]

	,Budget

	)

	SELECT CASE WHEN DATEPART(M, [Date]) = 6

			  THEN DATEADD(M, -6, DATEADD(D, 1, [Date]))

			  ELSE DATEADD(D, 1, DATEADD(YEAR, -1, [Date]))

		 END AS DATE

		 ,Value

		FROM [stg].[CHEGBVL]

		ORDER BY DATE





END



