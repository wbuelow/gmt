-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

create PROCEDURE [dbo].[stp_etl_futuresActiveContractOI]



AS

BEGIN



SET NOCOUNT ON;



TRUNCATE TABLE futures.ActiveContractOI



INSERT INTO futures.ActiveContractOI

(

DATE 

,CMEAD 

,CMEBP	

,CMECD	

,CMEEC	

,CMEJY	

,CMENE	

,CMESF	

,CMEES	

,CMEYM	

,CMENQ	

,CMEED	

,CMETU	

,CMEFV	

,CMETY	

,CMEUS	

,CMEC	

,CMES	

,CMEW	

,CMELN	

,CMELC

,CMECL	

,CMENG	

,CMERB	

,CMEGC	

,CMESI	

,CMEHG

)

SELECT x.Date.Date

		,CMEAD.Open_Interest   AS CMEAD

		,CMEBP.Open_Interest	AS CMEBP

		,CMECD.Open_Interest	AS CMECD

		,CMEEC.Open_Interest	AS CMEEC

		,CMEJY.Open_Interest	AS CMEJY

		,CMENE.Open_Interest	AS CMENE

		,CMESF.Open_Interest	AS CMESF

		,CMEES.Open_Interest	AS CMEES

		,CMEYM.Open_Interest	AS CMEYM

		,CMENQ.Open_Interest	AS CMENQ

		,CMEED.Open_Interest	AS CMEED

		,CMETU.Open_Interest	AS CMETU

		,CMEFV.Open_Interest	AS CMEFV

		,CMETY.Open_Interest	AS CMETY

		,CMEUS.Open_Interest	AS CMEUS

		 ,CMEC.Open_Interest	AS CMEC	

		 ,CMES.Open_Interest	AS CMES	

		 ,CMEW.Open_Interest	AS CMEW	

		,CMELN.Open_Interest	AS CMELN

		,CMELC.Open_Interest	AS CMELC

		,CMECL.Open_Interest	AS CMECL

		,CMENG.Open_Interest	AS CMENG

		,CMERB.Open_Interest	AS CMERB

		,CMEGC.Open_Interest	AS CMEGC

		,CMESI.Open_Interest	AS CMESI

		,CMEHG.Open_Interest    AS CMEHG

	FROM x.Date

	LEFT JOIN UAOIfutures.CME_AD AS CMEAD ON X.Date.Date =  CMEAD.Date

	LEFT JOIN UAOIfutures.CME_BP AS CMEBP ON X.Date.Date =  CMEBP.Date

	LEFT JOIN UAOIfutures.CME_CD AS CMECD ON X.Date.Date =	CMECD.Date

	LEFT JOIN UAOIfutures.CME_EC AS CMEEC ON X.Date.Date =	CMEEC.Date

	LEFT JOIN UAOIfutures.CME_JY AS CMEJY ON X.Date.Date =	CMEJY.Date

	LEFT JOIN UAOIfutures.CME_NE AS CMENE ON X.Date.Date =	CMENE.Date

	LEFT JOIN UAOIfutures.CME_SF AS CMESF ON X.Date.Date =	CMESF.Date

	LEFT JOIN UAOIfutures.CME_ES AS CMEES ON X.Date.Date =	CMEES.Date

	LEFT JOIN UAOIfutures.CME_YM AS CMEYM ON X.Date.Date =	CMEYM.Date

	LEFT JOIN UAOIfutures.CME_NQ AS CMENQ ON X.Date.Date =	CMENQ.Date

	LEFT JOIN UAOIfutures.CME_ED AS CMEED ON X.Date.Date =	CMEED.Date

	LEFT JOIN UAOIfutures.CME_TU AS CMETU ON X.Date.Date =	CMETU.Date

	LEFT JOIN UAOIfutures.CME_FV AS CMEFV ON X.Date.Date =	CMEFV.Date

	LEFT JOIN UAOIfutures.CME_TY AS CMETY ON X.Date.Date =	CMETY.Date

	LEFT JOIN UAOIfutures.CME_US AS CMEUS ON X.Date.Date =	CMEUS.Date

	LEFT JOIN UAOIfutures.CME_C	 AS CMEC  ON X.Date.Date =	CMEC.Date

	LEFT JOIN UAOIfutures.CME_S	 AS CMES  ON X.Date.Date =	CMES.Date

	LEFT JOIN UAOIfutures.CME_W	 AS CMEW  ON X.Date.Date =	CMEW.Date

	LEFT JOIN UAOIfutures.CME_LN AS CMELN ON X.Date.Date =	CMELN.Date

	LEFT JOIN UAOIfutures.CME_LC AS CMELC ON X.Date.Date =	CMELC.Date

	LEFT JOIN UAOIfutures.CME_CL AS CMECL ON X.Date.Date =	CMECL.Date

	LEFT JOIN UAOIfutures.CME_NG AS CMENG ON X.Date.Date =	CMENG.Date

	LEFT JOIN UAOIfutures.CME_RB AS CMERB ON X.Date.Date =	CMERB.Date

	LEFT JOIN UAOIfutures.CME_GC AS CMEGC ON X.Date.Date =	CMEGC.Date

	LEFT JOIN UAOIfutures.CME_SI AS CMESI ON X.Date.Date =	CMESI.Date

	LEFT JOIN UAOIfutures.CME_HG AS CMEHG ON X.Date.Date =	CMEHG.Date

	WHERE COALESCE(

	 CMEAD.Open_Interest

	,CMEBP.Open_Interest

	,CMECD.Open_Interest

	,CMEEC.Open_Interest

	,CMEJY.Open_Interest

	,CMENE.Open_Interest

	,CMESF.Open_Interest

	,CMEES.Open_Interest

	,CMEYM.Open_Interest

	,CMENQ.Open_Interest

	,CMEED.Open_Interest

	,CMETU.Open_Interest

	,CMEFV.Open_Interest

	,CMETY.Open_Interest

	,CMEUS.Open_Interest

	 ,CMEC.Open_Interest

	 ,CMES.Open_Interest

	 ,CMEW.Open_Interest

	,CMELN.Open_Interest

	,CMELC.Open_Interest

	,CMECL.Open_Interest

	,CMENG.Open_Interest

	,CMERB.Open_Interest

	,CMEGC.Open_Interest

	,CMESI.Open_Interest

	,CMEHG.Open_Interest) IS NOT NULL

	ORDER BY DATE

END



