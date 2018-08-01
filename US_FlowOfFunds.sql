CREATE PROCEDURE dbo.US_FlowOfFunds

AS

BEGIN

SET NOCOUNT ON;



SELECT Date

	   ,HH             /NGDP/100 HH             

	   ,NonfinNoncorp  /NGDP/100 NonfinNoncorp  

	   ,NonfinCorp	   /NGDP/100 NonfinCorp	   

	   ,Fin			   /NGDP/100 Fin			   

	   ,Fed			   /NGDP/100 Fed			   

	   ,SLGov		   /NGDP/100 SLGov		   

	   ,RoW			   /NGDP/100 RoW

	FROM (

		SELECT Q.January AS Date

				,RGDP.Value*DEFL.Value/100 AS NGDP

				,HH.Value            HH

				,NonfinNoncorp.Value NonfinNoncorp

				,NonfinCorp.Value    NonfinCorp

				,Fin.Value           Fin

				,Fed.Value           Fed

				,SLGov.Value         SLGov

				,RoW.Value           RoW

				,ROW_NUMBER () OVER (ORDER BY CASE WHEN HH.Value IS NOT NULL AND

											  NonfinNoncorp.Value IS NOT NULL AND

												NonfinCorp.Value  IS NOT NULL AND

														Fin.Value IS NOT NULL AND

														Fed.Value IS NOT NULL AND

													  SLGov.Value IS NOT NULL AND

														RoW.Value IS NOT NULL THEN 1 ELSE 0 END, January) AS Row_N

			FROM X.Qtr AS Q

			LEFT JOIN [stg].[USAGCP] AS RGDP

			ON Q.March = RGDP.Date

			LEFT JOIN [stg].[USAGD] AS DEFL

			ON Q.March = DEFL.Date

			LEFT JOIN stg.HNOLACQ027S AS HH

			ON Q.January = HH.Date

			LEFT JOIN stg.NNBLACQ027S AS NonfinNoncorp

			ON Q.January = NonfinNoncorp.Date

			LEFT JOIN stg.NCBLACQ027S AS NonfinCorp

			ON Q.January = NonfinCorp.Date

			LEFT JOIN stg.FBLCABQ027S AS Fin

			ON Q.January = Fin.Date

			LEFT JOIN stg.FGLBCAQ027S AS Fed

			ON Q.January = Fed.Date

			LEFT JOIN stg.SLGLCAQ027S AS SLGov

			ON Q.January = SLGov.Date

			LEFT JOIN stg.RWLBCAQ027S AS RoW

			ON Q.January = RoW.Date

			WHERE Q.January >= '1951-10-01'

	) AS D

	WHERE Row_N BETWEEN 1 AND 4

	OR 

	(

	HH			  IS NOT NULL AND

	NonfinNoncorp IS NOT NULL AND

	NonfinCorp    IS NOT NULL AND

	Fin			  IS NOT NULL AND

	Fed			  IS NOT NULL AND

	SLGov		  IS NOT NULL AND

	RoW			  IS NOT NULL

	)

	ORDER BY Date



END

