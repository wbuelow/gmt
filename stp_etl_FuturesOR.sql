



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_FuturesOR]



AS

BEGIN



SET NOCOUNT ON;



TRUNCATE TABLE futures.[OR]



INSERT INTO futures.[OR]

(

DATE 

,[CMEAD1]

,[CMEBP1]

,[CMECD1]

,[CMEEC1]

,[CMEJY1]

,[CMENE1]

,[CMEMP1]

,[CMESF1]

,[CMEES1]

,[CMEYM1]

,[CMENQ1]

,[CMENK1]

,[EUREXFESX1]

,[EUREXFDAX1]

,[CMEED1]

,[CMETU1]

,[CMEFV1]

,[CMETY1]

,[CMEUS1]

,[EUREXFOAT1]

,[EUREXFBTP1]

,[EUREXFGBS1]

,[EUREXFGBM1]

,[EUREXFGBL1]

,[CMEC1]

,[CMES1]

,[CMEW1]

,[CMEKW1]

,[CMEBO1]

,[CMESM1]

,[CMELN1]

,[CMELC1]

,[CMECL1]

,[CMENG1]

,[CMERB1]

,[CMEHO1]

,[CMEGC1]

,[CMESI1]

,[CMEHG1]

,[CMEPA1]

,[CMEPL1]

)

SELECT x.Date.Date

		,CMEAD1.Settle      AS CMEAD1    

		,CMEBP1.Settle     	AS CMEBP1    

		,CMECD1.Settle     	AS CMECD1    

		,CMEEC1.Settle     	AS CMEEC1    

		,CMEJY1.Settle     	AS CMEJY1    

		,CMENE1.Settle     	AS CMENE1    

		,CMEMP1.Settle     	AS CMEMP1    

		,CMESF1.Settle      AS CMESF1         

		,CMEES1.Settle     	AS CMEES1    

		,CMEYM1.Settle     	AS CMEYM1    

		,CMENQ1.Settle     	AS CMENQ1    

		,CMENK1.Settle     	AS CMENK1    

		,EUREXFESX1.Settle 	AS EUREXFESX1

		,EUREXFDAX1.Settle 	AS EUREXFDAX1

		,CMEED1.Settle     	AS CMEED1    

		,CMETU1.Settle     	AS CMETU1    

		,CMEFV1.Settle     	AS CMEFV1    

		,CMETY1.Settle     	AS CMETY1    

		,CMEUS1.Settle      AS CMEUS1    

		,EUREXFOAT1.Settle 	AS EUREXFOAT1

		,EUREXFBTP1.Settle 	AS EUREXFBTP1

		,EUREXFGBS1.Settle 	AS EUREXFGBS1

		,EUREXFGBM1.Settle 	AS EUREXFGBM1

		,EUREXFGBL1.Settle  AS EUREXFGBL1

		,CMEC1.Settle      	AS CMEC1     

		,CMES1.Settle      	AS CMES1     

		,CMEW1.Settle       AS CMEW1     

		,CMEKW1.Settle     	AS CMEKW1    

		,CMEBO1.Settle     	AS CMEBO1    

		,CMESM1.Settle     	AS CMESM1    

		,CMELN1.Settle     	AS CMELN1    

		,CMELC1.Settle      AS CMELC1         

		,CMECL1.Settle     	AS CMECL1    

		,CMENG1.Settle     	AS CMENG1    

		,CMERB1.Settle     	AS CMERB1    

		,CMEHO1.Settle      AS CMEHO1      

		,CMEGC1.Settle     	AS CMEGC1    

		,CMESI1.Settle     	AS CMESI1    

		,CMEHG1.Settle     	AS CMEHG1    

		,CMEPA1.Settle     	AS CMEPA1    

		,CMEPL1.Settle     	AS CMEPL1    

	FROM x.Date

	LEFT JOIN stg.CME_AD1_OR     AS CMEAD1     ON X.Date.Date = CMEAD1.Date

	LEFT JOIN stg.CME_BP1_OR     AS CMEBP1     ON X.Date.Date = CMEBP1.Date

	LEFT JOIN stg.CME_CD1_OR     AS CMECD1     ON X.Date.Date =	CMECD1.Date

	LEFT JOIN stg.CME_EC1_OR     AS CMEEC1     ON X.Date.Date =	CMEEC1.Date

	LEFT JOIN stg.CME_JY1_OR     AS CMEJY1     ON X.Date.Date =	CMEJY1.Date

	LEFT JOIN stg.CME_NE1_OR     AS CMENE1     ON X.Date.Date =	CMENE1.Date

	LEFT JOIN stg.CME_MP1_OR     AS CMEMP1     ON X.Date.Date =	CMEMP1.Date

	LEFT JOIN stg.CME_SF1_OR     AS CMESF1     ON X.Date.Date =	CMESF1.Date			     		      

	LEFT JOIN stg.CME_ES1_OR     AS CMEES1     ON X.Date.Date =	CMEES1.Date

	LEFT JOIN stg.CME_YM1_OR     AS CMEYM1     ON X.Date.Date =	CMEYM1.Date

	LEFT JOIN stg.CME_NQ1_OR     AS CMENQ1     ON X.Date.Date =	CMENQ1.Date

	LEFT JOIN stg.CME_NK1_OR     AS CMENK1     ON X.Date.Date =	CMENK1.Date

	LEFT JOIN stg.EUREX_FESX1_OR AS EUREXFESX1 ON X.Date.Date =	EUREXFESX1.Date

	LEFT JOIN stg.EUREX_FDAX1_OR AS EUREXFDAX1 ON X.Date.Date =	EUREXFDAX1.Date

	LEFT JOIN stg.CME_ED1_OR     AS CMEED1     ON X.Date.Date =	CMEED1.Date

	LEFT JOIN stg.CME_TU1_OR     AS CMETU1     ON X.Date.Date =	CMETU1.Date

	LEFT JOIN stg.CME_FV1_OR     AS CMEFV1     ON X.Date.Date =	CMEFV1.Date

	LEFT JOIN stg.CME_TY1_OR     AS CMETY1     ON X.Date.Date =	CMETY1.Date

	LEFT JOIN stg.CME_US1_OR     AS CMEUS1     ON X.Date.Date =	CMEUS1.Date

	LEFT JOIN stg.EUREX_FOAT1_OR AS EUREXFOAT1 ON X.Date.Date =	EUREXFOAT1.Date

	LEFT JOIN stg.EUREX_FBTP1_OR AS EUREXFBTP1 ON X.Date.Date =	EUREXFBTP1.Date

	LEFT JOIN stg.EUREX_FGBS1_OR AS EUREXFGBS1 ON X.Date.Date =	EUREXFGBS1.Date

	LEFT JOIN stg.EUREX_FGBM1_OR AS EUREXFGBM1 ON X.Date.Date =	EUREXFGBM1.Date

	LEFT JOIN stg.EUREX_FGBL1_OR AS EUREXFGBL1 ON X.Date.Date =	EUREXFGBL1.Date

	LEFT JOIN stg.CME_C1_OR	     AS CMEC1      ON X.Date.Date =	CMEC1.Date

	LEFT JOIN stg.CME_S1_OR	     AS CMES1      ON X.Date.Date =	CMES1.Date

	LEFT JOIN stg.CME_W1_OR	     AS CMEW1      ON X.Date.Date =	CMEW1.Date

	LEFT JOIN stg.CME_KW1_OR	 AS CMEKW1     ON X.Date.Date =	CMEKW1.Date

	LEFT JOIN stg.CME_BO1_OR	 AS CMEBO1     ON X.Date.Date =	CMEBO1.Date

	LEFT JOIN stg.CME_SM1_OR	 AS CMESM1     ON X.Date.Date =	CMESM1.Date

	LEFT JOIN stg.CME_LN1_OR     AS CMELN1     ON X.Date.Date =	CMELN1.Date

	LEFT JOIN stg.CME_LC1_OR     AS CMELC1     ON X.Date.Date =	CMELC1.Date	      

	LEFT JOIN stg.CME_CL1_OR     AS CMECL1     ON X.Date.Date =	CMECL1.Date

	LEFT JOIN stg.CME_NG1_OR     AS CMENG1     ON X.Date.Date =	CMENG1.Date

	LEFT JOIN stg.CME_RB1_OR     AS CMERB1     ON X.Date.Date =	CMERB1.Date

	LEFT JOIN stg.CME_HO1_OR     AS CMEHO1     ON X.Date.Date =	CMEHO1.Date   		      

	LEFT JOIN stg.CME_GC1_OR     AS CMEGC1     ON X.Date.Date =	CMEGC1.Date

	LEFT JOIN stg.CME_SI1_OR     AS CMESI1     ON X.Date.Date =	CMESI1.Date

	LEFT JOIN stg.CME_HG1_OR     AS CMEHG1     ON X.Date.Date =	CMEHG1.Date

	LEFT JOIN stg.CME_PA1_OR     AS CMEPA1     ON X.Date.Date =	CMEPA1.Date

	LEFT JOIN stg.CME_PL1_OR     AS CMEPL1     ON X.Date.Date =	CMEPL1.Date

	WHERE COALESCE(

	CMEAD1.Settle    

	,CMEBP1.Settle    

	,CMECD1.Settle    

	,CMEEC1.Settle    

	,CMEJY1.Settle    

	,CMENE1.Settle    

	,CMEMP1.Settle    

	,CMESF1.Settle    

	,CMEES1.Settle    

	,CMEYM1.Settle    

	,CMENQ1.Settle    

	,CMENK1.Settle    

	,EUREXFESX1.Settle

	,EUREXFDAX1.Settle

	,CMEED1.Settle    

	,CMETU1.Settle    

	,CMEFV1.Settle    

	,CMETY1.Settle    

	,CMEUS1.Settle    

	,EUREXFOAT1.Settle

	,EUREXFBTP1.Settle

	,EUREXFGBS1.Settle

	,EUREXFGBM1.Settle

	,EUREXFGBL1.Settle

	,CMEC1.Settle     

	,CMES1.Settle     

	,CMEW1.Settle     

	,CMEKW1.Settle    

	,CMEBO1.Settle    

	,CMESM1.Settle    

	,CMELN1.Settle    

	,CMELC1.Settle    

	,CMECL1.Settle    

	,CMENG1.Settle    

	,CMERB1.Settle    

	,CMEHO1.Settle    

	,CMEGC1.Settle    

	,CMESI1.Settle    

	,CMEHG1.Settle    

	,CMEPA1.Settle    

	,CMEPL1.Settle    

	) IS NOT NULL

	ORDER BY DATE



END	

		

		



