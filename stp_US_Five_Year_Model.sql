



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================



CREATE PROCEDURE [dbo].[stp_US_Five_Year_Model]



AS

BEGIN



SET NOCOUNT ON;



;WITH Daily AS (

SELECT R.Date

		,Five_Year

		,Adjusted_Close AS SP500

	FROM us.Rate AS R

	LEFT JOIN us.SP500 AS S

	ON R.Date = S.Date

	WHERE Two_Year IS NOT NULL

)

, Monthly AS (

SELECT Date

		,[Un_Rate]

		,[CPI_Core_Rate]

		,[Man_PMI_Comp]

		,[Fed_Funds_Rate]

		,[Hous_Starts]

	FROM [us].[Monthly] AS M

)

SELECT Date

		,Five_Year

		,SP500

		,[Un_Rate]

		,[CPI_Core_Rate]

		,[Man_PMI_Comp]

		,[Fed_Funds_Rate]

		,[Hous_Starts]

	FROM Daily

	OUTER APPLY (

		SELECT TOP 1 [Un_Rate]

					,[CPI_Core_Rate]

					,[Man_PMI_Comp]

					,[Fed_Funds_Rate]

					,[Hous_Starts]

			FROM Monthly

			WHERE Daily.Date >= Monthly.Date

			ORDER BY Monthly.Date desc

	) AS P

	ORDER BY Date



END



