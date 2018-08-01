



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_US_Quarterly]

AS

BEGIN



truncate table [us].[Quarterly]



	SET NOCOUNT ON;

	

	;WITH EOQ AS (

	SELECT Q.January

			,CA.VALUE AS CA

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[USACA] AS CA

		ON Q.March = CA.Date

		LEFT JOIN [stg].[USAGCP] AS RGDP

		ON Q.March = RGDP.Date

		LEFT JOIN [stg].[USAGD] AS DEFL

		ON Q.March = DEFL.Date

	)

	, MOQ AS (

	SELECT Q.January

			,CA.VALUE AS CA

			,RGDP.Value AS RGDP

			,DEFL.Value AS DEFL

		FROM X.Qtr AS Q

		LEFT JOIN [stg].[USACA] AS CA

		ON Q.February = CA.Date

		LEFT JOIN [stg].[USAGCP] AS RGDP

		ON Q.February = RGDP.Date

		LEFT JOIN [stg].[USAGD] AS DEFL

		ON Q.February = DEFL.Date

	)

	, Combined AS (

	SELECT ISNULL(EOQ.January, MOQ.January) AS [Date]

			,ISNULL(EOQ.CA, MOQ.CA) AS CA

			,ISNULL(EOQ.RGDP, MOQ.RGDP) AS RGDP

			,ISNULL(EOQ.DEFL, MOQ.DEFL) AS DEFL

			,HH.Value    HH

			,NFB.Value	 NFB

			,[RoW].Value [RoW]

			,Gov.Value	 Gov

		FROM EOQ

		FULL JOIN MOQ

		ON EOQ.January = MOQ.January

		LEFT JOIN [stg].[HNOLACQ027S] AS HH

		ON EOQ.January = HH.Date

		LEFT JOIN [stg].NCBLACQ027S AS NFB

		ON EOQ.January = NFB.Date

		LEFT JOIN [stg].[RWLBCAQ027S] AS [RoW]

		ON EOQ.January = [RoW].Date

		LEFT JOIN [stg].[FGLBCAQ027S] AS Gov

		ON EOQ.January = Gov.Date

		WHERE COALESCE(EOQ.CA, MOQ.CA, EOQ.RGDP, MOQ.RGDP, EOQ.DEFL, MOQ.DEFL

		,HH.Value   

		,NFB.Value	

		,[RoW].Value

		,Gov.Value	

		) IS NOT NULL

		AND ISNULL(EOQ.January, MOQ.January) >= '1951-10-01'

		--order by date

	)

	INSERT INTO [us].[Quarterly]

	(

	[Date]

	,[CA]

	,[RGDP]

	,[Defl]

	,[NGDP]

	,HHFlow   

	,NFBFlow  

	,[RoWFlow]

	,GovFlow  

	)

	SELECT DATE

			,4*[CA]/1000 AS CA

			,RGDP

			,DEFL

			,RGDP*DEFL/100 AS NGDP

			,(HH/1000   )/(RGDP*DEFL/100)  AS HH

			,(NFB/1000	)/(RGDP*DEFL/100) AS NFB

			,([RoW]/1000)/(RGDP*DEFL/100)	AS [RoW]

			,(Gov/1000	)/(RGDP*DEFL/100) AS Gov

		FROM Combined

		ORDER BY DATE



	UPDATE us.Quarterly

	SET RecessionFlag = R.RecessionFlag

	FROM (

	SELECT q.Date

			,p.RecessionFlag

		FROM US.Quarterly q

		OUTER APPLY (

			SELECT TOP 1 RecessionFlag

				FROM us.Monthly m

				WHERE m.Date < q.Date

				ORDER BY m.date Desc

		) AS p

	) AS R

	WHERE Quarterly.date = R.Date



END



--select *

--		,RGDP*DEFL/100

--	from #Staged

--	order by date



--drop table #Staged

/*

SELECT [Date]

		,HHFlow    AS HH

		,NFBFlow   AS NFB

		,[RoWFlow] AS RoW

		,GovFlow   AS Gov

		,ngdp

	FROM us.Quarterly

	WHERE HHFlow   IS NOT NULL

		  AND NFBFlow  IS NOT NULL

		  AND [RoWFlow]IS NOT NULL

		  AND GovFlow  IS NOT NULL

	AND DATE >= '1951-10-01'

	ORDER BY [Date]



select date

		,value

	from [stg].[HNOLACQ027S]

	order by date

*/

