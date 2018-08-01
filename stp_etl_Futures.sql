-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_Futures]



AS

BEGIN



SET NOCOUNT ON;



TRUNCATE TABLE futures.Energy

TRUNCATE TABLE futures.Equities

TRUNCATE TABLE futures.Rates

TRUNCATE TABLE futures.Metals

TRUNCATE TABLE futures.FX

TRUNCATE TABLE futures.Ag



INSERT INTO futures.FX

(

DATE, 

CME_BR, BR_Volume, BR_Open_Interest,

CME_AD , AD_Volume, AD_Open_Interest,

CME_JY, JY_Volume, JY_Open_Interest,

CME_BP, BP_Volume, BP_Open_Interest,

CME_CD, CD_Volume, CD_Open_Interest,

CME_EC, EC_Volume, EC_Open_Interest,

CME_SF, SF_Volume, SF_Open_Interest,

CME_NE, NE_Volume, NE_Open_Interest

)

SELECT x.Date.Date

		,CME_BR.Settle

		,CME_BR.Volume

		,CME_BR.Open_Interest

		,AUD.Settle

		,AUD.Volume

		,AUD.Open_Interest

		,JPY.Settle

		,JPY.Volume

		,JPY.Open_Interest

		,GBP.Settle

		,GBP.Volume

		,GBP.Open_Interest

		,CAD.Settle

		,CAD.Volume

		,CAD.Open_Interest

		,EUR.Settle

		,EUR.Volume

		,EUR.Open_Interest

		,CHF.Settle

		,CHF.Volume

		,CHF.Open_Interest

		,NE.Settle

		,NE.Volume

		,NE.Open_Interest

	FROM x.Date

	LEFT JOIN future.CME_BR

	ON X.Date.Date = CME_BR.DATE

	LEFT JOIN [au].[AUD]

	ON X.Date.Date = [AUD].Date

	LEFT JOIN [bp].[GBP]

	ON X.Date.Date = [GBP].Date

	LEFT JOIN [cn].[CAD]

	ON X.Date.Date = [CAD].Date

	LEFT JOIN [eu].[EUR]

	ON X.Date.Date = [EUR].Date

	LEFT JOIN [jp].[JPY]

	ON X.Date.Date = [JPY].Date

	LEFT JOIN [sf].[CHF]

	ON X.Date.Date = [CHF].Date

	LEFT JOIN [nz].[NE]

	ON X.Date.Date = [NE].Date

	WHERE COALESCE(CME_BR.Settle, AUD.Settle, JPY.Settle, GBP.Settle, CAD.Settle, EUR.Settle, CHF.Settle) IS NOT NULL



INSERT INTO futures.Ag 

(

Date, 

CME_C, C_Volume, C_Open_Interest,

CME_LC, LC_Volume, LC_Open_Interest,

CME_LN, LN_Volume, LN_Open_Interest,

CME_S, S_Volume, S_Open_Interest,

CME_W, W_Volume, W_Open_Interest

)

SELECT x.Date.Date

		,CME_C.Settle

		,CME_C.Volume

		,CME_C.Open_Interest

		,CME_LC.Settle

		,CME_LC.Volume

		,CME_LC.Open_Interest

		,CME_LN.Settle

		,CME_LN.Volume

		,CME_LN.Open_Interest

		,CME_S.Settle

		,CME_S.Volume

		,CME_S.Open_Interest

		,CME_W.Settle

		,CME_W.Volume

		,CME_W.Open_Interest

	FROM x.Date

	LEFT JOIN future.CME_C

	ON X.Date.Date = CME_C.Date

	LEFT JOIN future.CME_LC

	ON X.Date.Date = CME_LC.Date

	LEFT JOIN future.CME_LN

	ON X.Date.Date = CME_LN.Date

	LEFT JOIN future.CME_S

	ON X.Date.Date = CME_S.Date

	LEFT JOIN future.CME_W

	ON X.Date.Date = CME_W.Date

	WHERE COALESCE(CME_C.Settle, CME_LC.Settle, CME_LN.Settle, CME_S.Settle, CME_W.Settle) IS NOT NULL



INSERT INTO futures.Energy 

(

Date, 

CME_CL, CL_Volume, CL_Open_Interest,

CME_NG, NG_Volume, NG_Open_Interest,

CME_RB, RB_Volume, RB_Open_Interest

)

SELECT x.Date.Date

		,CME_CL.Settle

		,CME_CL.Volume

		,CME_CL.Open_Interest

		,CME_NG.Settle

		,CME_NG.Volume

		,CME_NG.Open_Interest

		,CME_RB.Settle

		,CME_RB.Volume

		,CME_RB.Open_Interest

	FROM X.Date

	LEFT JOIN [future].[CME_CL]

	ON X.Date.Date = CME_CL.Date

	LEFT JOIN [future].CME_NG

	ON X.Date.Date = CME_NG.Date

	LEFT JOIN [future].CME_RB

	ON X.Date.Date = CME_RB.Date

	WHERE COALESCE(CME_CL.Settle, CME_NG.Settle, CME_RB.Settle) IS NOT NULL



INSERT INTO futures.Rates 

(

DATE,

CME_ED, ED_Volume, ED_Open_Interest,

CME_TU, TU_Volume, TU_Open_Interest,

CME_FV, FV_Volume, FV_Open_Interest,

CME_TY, TY_Volume, TY_Open_Interest,

CME_US, US_Volume, US_Open_Interest

)

SELECT x.Date.Date

		,CME_ED.Settle

		,CME_ED.Volume

		,CME_ED.Open_Interest

		,CME_TU.Settle

		,CME_TU.Volume

		,CME_TU.Open_Interest

		,CME_FV.Settle

		,CME_FV.Volume

		,CME_FV.Open_Interest

		,CME_TY.Settle

		,CME_TY.Volume

		,CME_TY.Open_Interest

		,CME_US.Settle

		,CME_US.Volume

		,CME_US.Open_Interest

	FROM X.Date

	LEFT JOIN [future].[CME_ED]

	ON X.Date.Date = CME_ED.Date

	LEFT JOIN [future].CME_TU

	ON X.Date.Date = CME_TU.Date

	LEFT JOIN [future].CME_FV

	ON X.Date.Date = CME_FV.Date

	LEFT JOIN [future].CME_TY

	ON X.Date.Date = CME_TY.Date

	LEFT JOIN [future].CME_US

	ON X.Date.Date = CME_US.Date

	WHERE COALESCE(CME_ED.Settle, CME_TU.Settle, CME_FV.Settle, CME_TY.Settle, CME_US.Settle) IS NOT NULL 



INSERT INTO futures.Equities 

(

DATE,

CME_ES, ES_Volume, ES_Open_Interest,

CME_N1Y, N1Y_Volume, N1Y_Open_Interest,

CME_NQ, NQ_Volume, NQ_Open_Interest,

DAX, FDAX_Volume, FDAX_Open_Interest,

CME_YM, YM_Volume, YM_Open_Interest,

Stoxx50, FESX_Volume, FESX_Open_Interest,

TSX60, SXF_Volume, SXF_Open_Interest,

HangSeng, HSI_Volume, HSI_Open_Interest,

CAC, FCE_Volume, FCE_Open_Interest,

FTSE100, Z_Volume, Z_Open_Interest

)

SELECT x.Date.Date

		,CME_ES.Settle

		,CME_ES.Volume

		,CME_ES.Open_Interest

		,CME_N1Y.Settle

		,CME_N1Y.Volume

		,CME_N1Y.Open_Interest

		,CME_NQ.Settle

		,CME_NQ.Volume

		,CME_NQ.Open_Interest

		,EUREX_FDAX.Settle

		,EUREX_FDAX.Volume

		,EUREX_FDAX.Open_Interest

		,CME_YM.Settle

		,CME_YM.Volume

		,CME_YM.Open_Interest

		,EUREX_FESX.Settle

		,EUREX_FESX.Volume

		,EUREX_FESX.Open_Interest

		,MX_SXF.Settlement_Price

		,MX_SXF.Volume

		,MX_SXF.Previous_Day_Open_Interest

		,HKEX_HSI.Previous_Day_Settlement_Price

		,HKEX_HSI.Volume

		,HKEX_HSI.Previous_Day_Open_Interest

		,LIFFE_FCE.Settle

		,LIFFE_FCE.Volume

		,LIFFE_FCE.Open_Interest

		,LIFFE_Z.Settle

		,LIFFE_Z.Volume

		,LIFFE_Z.Open_Interest

	FROM X.Date

	LEFT JOIN [future].[CME_ES]

	ON X.Date.Date = CME_ES.Date

	LEFT JOIN [future].[CME_N1Y]

	ON X.Date.Date = CME_N1Y.Date

	LEFT JOIN [future].CME_NQ

	ON X.Date.Date = CME_NQ.Date

	LEFT JOIN [future].CME_YM

	ON X.Date.Date = CME_YM.Date

	LEFT JOIN [future].EUREX_FDAX

	ON X.Date.Date =EUREX_FDAX.Date

	LEFT JOIN [future].EUREX_FESX

	ON X.Date.Date = EUREX_FESX.Date

	LEFT JOIN [future].MX_SXF

	ON X.Date.Date = MX_SXF.Date

	LEFT JOIN [future].HKEX_HSI

	ON X.Date.Date = HKEX_HSI.Date

	LEFT JOIN [future].LIFFE_FCE

	ON X.Date.Date = LIFFE_FCE.Date

	LEFT JOIN [future].LIFFE_Z

	ON X.Date.Date = LIFFE_Z.Date

	WHERE COALESCE(CME_ES.Settle, CME_N1Y.Settle, CME_NQ.Settle, EUREX_FDAX.Settle, CME_YM.Settle, EUREX_FESX.Settle

		, MX_SXF.Settlement_Price, HKEX_HSI.Previous_Day_Settlement_Price, LIFFE_FCE.Settle, LIFFE_Z.Settle) IS NOT NULL 



INSERT INTO futures.Metals 

(

Date, 

CME_GC, GC_Volume, GC_Open_Interest,

CME_HG, HG_Volume, HG_Open_Interest,

CME_SI, SI_Volume, SI_Open_Interest

)

SELECT x.Date.Date

		,CME_GC.Settle AS Gold

		,CME_GC.Volume

		,CME_GC.Open_Interest

		,CME_HG.Settle AS Copper

		,CME_HG.Volume

		,CME_HG.Open_Interest

		,CME_SI.Settle AS Silver

		,CME_SI.Volume

		,CME_SI.Open_Interest

	FROM X.Date

	LEFT JOIN [future].[CME_GC]

	ON X.Date.Date = CME_GC.Date

	LEFT JOIN [future].[CME_HG]

	ON X.Date.Date = [CME_HG].Date

	LEFT JOIN [future].CME_SI

	ON X.Date.Date = CME_SI.Date

	WHERE COALESCE(CME_GC.Settle, CME_HG.Settle, CME_SI.Settle) IS NOT NULL 



END



