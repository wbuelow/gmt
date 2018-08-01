-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

create PROCEDURE [dbo].[stp_etl_futuresActiveContractVolume]



AS

BEGIN



SET NOCOUNT ON;



TRUNCATE TABLE futures.ActiveContractVolume



INSERT INTO futures.ActiveContractVolume

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

		,CMEAD.Volume    AS CMEAD

		,CMEBP.Volume 	AS CMEBP

		,CMECD.Volume 	AS CMECD

		,CMEEC.Volume 	AS CMEEC

		,CMEJY.Volume 	AS CMEJY

		,CMENE.Volume 	AS CMENE

		,CMESF.Volume 	AS CMESF

		,CMEES.Volume 	AS CMEES

		,CMEYM.Volume 	AS CMEYM

		,CMENQ.Volume 	AS CMENQ

		,CMEED.Volume 	AS CMEED

		,CMETU.Volume 	AS CMETU

		,CMEFV.Volume 	AS CMEFV

		,CMETY.Volume 	AS CMETY

		,CMEUS.Volume 	AS CMEUS

		 ,CMEC.Volume 	AS CMEC	

		 ,CMES.Volume 	AS CMES	

		 ,CMEW.Volume 	AS CMEW	

		,CMELN.Volume 	AS CMELN

		,CMELC.Volume 	AS CMELC

		,CMECL.Volume 	AS CMECL

		,CMENG.Volume 	AS CMENG

		,CMERB.Volume 	AS CMERB

		,CMEGC.Volume 	AS CMEGC

		,CMESI.Volume 	AS CMESI

		,CMEHG.Volume     AS CMEHG

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

	 CMEAD.Volume

	,CMEBP.Volume

	,CMECD.Volume

	,CMEEC.Volume

	,CMEJY.Volume

	,CMENE.Volume

	,CMESF.Volume

	,CMEES.Volume

	,CMEYM.Volume

	,CMENQ.Volume

	,CMEED.Volume

	,CMETU.Volume

	,CMEFV.Volume

	,CMETY.Volume

	,CMEUS.Volume

	 ,CMEC.Volume

	 ,CMES.Volume

	 ,CMEW.Volume

	,CMELN.Volume

	,CMELC.Volume

	,CMECL.Volume

	,CMENG.Volume

	,CMERB.Volume

	,CMEGC.Volume

	,CMESI.Volume

	,CMEHG.Volume) IS NOT NULL

	ORDER BY DATE

END



