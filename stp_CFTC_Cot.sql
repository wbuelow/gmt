-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================



--drop PROCEDURE dbo.stp_CFTC_Cot



CREATE PROCEDURE [dbo].[stp_CFTC_Cot]

AS

BEGIN



SET NOCOUNT ON;



IF OBJECT_ID('tempdb..#Currencies') IS NOT NULL

DROP TABLE #Currencies

IF OBJECT_ID('tempdb..#Equities') IS NOT NULL

DROP TABLE #Equities

IF OBJECT_ID('tempdb..#Ags') IS NOT NULL

DROP TABLE #Ags

IF OBJECT_ID('tempdb..#Energy') IS NOT NULL

DROP TABLE #Energy

IF OBJECT_ID('tempdb..#Rates') IS NOT NULL

DROP TABLE #Rates

IF OBJECT_ID('tempdb..#Metals') IS NOT NULL

DROP TABLE #Metals



SELECT DISTINCT EC.[Date]

		,EC.[Asset Manager Longs]  + EC.[Leveraged Funds Longs]  AS EC_Long

		,EC.[Asset Manager Shorts] + EC.[Leveraged Funds Shorts] AS EC_Short

		,BP.[Asset Manager Longs]  + BP.[Leveraged Funds Longs]  AS BP_Long

		,BP.[Asset Manager Shorts] + BP.[Leveraged Funds Shorts] AS BP_Short

		,CD.[Asset Manager Longs]  + CD.[Leveraged Funds Longs]  AS CD_Long

		,CD.[Asset Manager Shorts] + CD.[Leveraged Funds Shorts] AS CD_Short

		,AD.[Asset Manager Longs]  + AD.[Leveraged Funds Longs]  AS AD_Long

		,AD.[Asset Manager Shorts] + AD.[Leveraged Funds Shorts] AS AD_Short

		,JY.[Asset Manager Longs]  + JY.[Leveraged Funds Longs]  AS JY_Long

		,JY.[Asset Manager Shorts] + JY.[Leveraged Funds Shorts] AS JY_Short

		,SF.[Asset Manager Longs]  + SF.[Leveraged Funds Longs]  AS SF_Long

		,SF.[Asset Manager Shorts] + SF.[Leveraged Funds Shorts] AS SF_Short

	INTO #Currencies

	FROM [gmt].[stg].COTEC AS EC

	JOIN [gmt].[stg].COTBP AS BP

	ON EC.Date = BP.Date

	JOIN [gmt].[stg].COTSF AS SF

	ON EC.Date = SF.Date

	JOIN [gmt].[stg].COTCD AS CD

	ON EC.Date = CD.Date

	JOIN [gmt].[stg].COTAD AS AD

	ON EC.Date = AD.Date

	JOIN [gmt].[stg].COTJY AS JY

	ON EC.Date = JY.Date



SELECT DISTINCT ES.Date

		,ES.[Asset Manager Longs]  + ES.[Leveraged Funds Longs] AS ES_Long

		,ES.[Asset Manager Shorts] + ES.[Leveraged Funds Shorts] AS ES_Short

		,NQ.[Asset Manager Longs]  + NQ.[Leveraged Funds Longs] AS NQ_Long

		,NQ.[Asset Manager Shorts] + NQ.[Leveraged Funds Shorts] AS NQ_Short

		,YM.[Asset Manager Longs]  + YM.[Leveraged Funds Longs] AS YM_Long

		,YM.[Asset Manager Shorts] + YM.[Leveraged Funds Shorts] AS YM_Short

		,N1Y.[Asset Manager Longs]  + N1Y.[Leveraged Funds Longs] AS N1Y_Long

		,N1Y.[Asset Manager Shorts] + N1Y.[Leveraged Funds Shorts] AS N1Y_Short

	INTO #Equities

	FROM [gmt].[stg].COTES AS ES

	JOIN [gmt].[stg].COTN1Y AS N1Y

	ON ES.Date = N1Y.Date

	JOIN [gmt].[stg].COTYM AS YM

	ON ES.Date = YM.Date

	JOIN [gmt].[stg].COTNQ AS NQ

	ON ES.Date = NQ.Date



SELECT DISTINCT C.Date

		,C.[Money Manager Longs] AS C_Long

		,C.[Money Manager Shorts] AS C_Short

		,W.[Money Manager Longs] AS W_Long

		,W.[Money Manager Shorts] AS W_Short

		,S.[Money Manager Longs] AS S_Long

		,S.[Money Manager Shorts] AS S_Short

		,LN.[Money Manager Longs] AS LN_Long

		,LN.[Money Manager Shorts] AS LN_Short

		,LC.[Money Manager Longs] AS LC_Long

		,LC.[Money Manager Shorts] AS LC_Short

	INTO #Ags

	FROM [gmt].[stg].COTC AS C

	JOIN [gmt].[stg].COTW AS W

	ON C.Date = W.Date

	JOIN [gmt].[stg].COTS AS S

	ON C.Date = S.Date

	JOIN [gmt].[stg].COTLN AS LN

	ON C.Date = LN.Date

	JOIN [gmt].[stg].COTLC AS LC

	ON C.Date = LC.Date



SELECT DISTINCT CL.Date

		,CL.[Money Manager Longs] AS CL_Long

		,CL.[Money Manager Shorts] AS CL_Short

		,NG.[Money Manager Longs] AS NG_Long

		,NG.[Money Manager Shorts] AS NG_Short

		,RB.[Money Manager Longs] AS RB_Long

		,RB.[Money Manager Shorts] AS RB_Short

	INTO #Energy

	FROM [gmt].[stg].COTCL AS CL

	JOIN [gmt].[stg].COTRB AS RB

	ON CL.Date = RB.Date

	JOIN [gmt].[stg].COTNG AS NG

	ON CL.Date = NG.Date

	ORDER BY Date



SELECT DISTINCT ED.Date

		,ED.[Asset Manager Longs]  + ED.[Leveraged Funds Longs] AS ED_Long

		,ED.[Asset Manager Shorts] + ED.[Leveraged Funds Shorts] AS ED_Short

		,TU.[Asset Manager Longs]  + TU.[Leveraged Funds Longs] AS TU_Long

		,TU.[Asset Manager Shorts] + TU.[Leveraged Funds Shorts] AS TU_Short

		,FV.[Asset Manager Longs]  + FV.[Leveraged Funds Longs] AS FV_Long

		,FV.[Asset Manager Shorts] + FV.[Leveraged Funds Shorts] AS FV_Short

		,TY.[Asset Manager Longs]  + TY.[Leveraged Funds Longs] AS TY_Long

		,TY.[Asset Manager Shorts] + TY.[Leveraged Funds Shorts] AS TY_Short

		,US.[Asset Manager Longs]  + US.[Leveraged Funds Longs] AS US_Long

		,US.[Asset Manager Shorts] + US.[Leveraged Funds Shorts] AS US_Short

	INTO #Rates

	FROM [gmt].[stg].COTED AS ED

	JOIN [gmt].[stg].COTTU AS TU

	ON ED.Date = TU.Date

	JOIN [gmt].[stg].COTFV AS FV

	ON ED.Date = FV.Date

	JOIN [gmt].[stg].COTTY AS TY

	ON ED.Date = TY.Date

	JOIN [gmt].[stg].COTUS AS US

	ON ED.Date = US.Date



SELECT DISTINCT GC.Date

		,HG.[Money Manager Longs] AS HG_Long

		,HG.[Money Manager Shorts] AS HG_Short

		,GC.[Money Manager Longs] AS GC_Long

		,GC.[Money Manager Shorts] AS GC_Short

		,SI.[Money Manager Longs] AS SI_Long

		,SI.[Money Manager Shorts] AS SI_Short

	INTO #Metals

	FROM [gmt].[stg].COTGC AS GC

	JOIN [gmt].[stg].COTHG AS HG

	ON GC.Date = HG.Date

	JOIN [gmt].[stg].COTSI AS SI

	ON GC.Date = SI.Date



SELECT DISTINCT C.DATE 

		,C.AD_Long

		,C.AD_Short

		,C.BP_Long

		,C.BP_Short

		,C.CD_Long

		,C.CD_Short

		,C.EC_Long

		,C.EC_Short

		,C.JY_Long

		,C.JY_Short

		,C.SF_Long

		,C.SF_Short

		,A.C_Long

		,A.C_Short

		,A.LC_Long

		,A.LC_Short

		,A.LN_Long

		,A.LN_Short

		,A.S_Long

		,A.S_Short

		,A.W_Long

		,A.W_Short

		,E.CL_Long

		,E.CL_Short

		,E.NG_Long

		,E.NG_Short

		,E.RB_Long

		,E.RB_Short

		,EQ.ES_Long

		,EQ.ES_Short

		,EQ.N1Y_Long

		,EQ.N1Y_Short

		,EQ.NQ_Long

		,EQ.NQ_Short

		,EQ.YM_Long

		,EQ.YM_Short

		,M.GC_Long

		,M.GC_Short

		,M.HG_Long

		,M.HG_Short

		,M.SI_Long

		,M.SI_Short

		,R.ED_Long

		,R.ED_Short

		,R.FV_Long

		,R.FV_Short

		,R.TU_Long

		,R.TU_Short

		,R.TY_Long

		,R.TY_Short

		,R.US_Long

		,R.US_Short

	FROM #Currencies AS C

	JOIN #Ags AS A

	ON C.Date = A.Date

	JOIN #Energy AS E

	ON C.Date = E.Date

	JOIN #Equities AS EQ

	ON C.Date = EQ.Date

	JOIN #Metals AS M

	ON C.Date = M.Date

	JOIN #Rates AS R

	ON C.Date = R.Date

	ORDER BY DATE



END





