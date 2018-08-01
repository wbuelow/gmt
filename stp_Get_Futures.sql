-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_Get_Futures]



AS

BEGIN



SELECT X.Date.Date

		 ,A.CME_C Corn

		 ,A.CME_LN Hog

		 ,A.CME_LC LiveCattle

		 ,A.CME_S Beans

		 ,A.CME_W Wheat

		 ,E.CME_CL WTI

		 ,E.CME_NG AS NatGas

		 ,E.CME_RB AS RBob

		,EQ.DAX

		,EQ.CAC

		,EQ.CME_YM AS Dow

		,EQ.FTSE100

		,EQ.HangSeng

		,EQ.Stoxx50

		,EQ.TSX60

		,EQ.CME_ES AS Spoos

		,EQ.CME_N1Y AS Nikkei

		,EQ.CME_NQ AS Nasdaq

		 ,F.CME_AD AS Aussie

		 ,F.CME_CD AS Loonie

		 ,F.CME_BP AS Pound

		 ,F.CME_EC AS Euro

		 ,F.CME_JY AS Yen

		 ,F.CME_BR AS Real

		 ,F.CME_SF AS Franc

		 ,M.CME_GC AS Gold

		 ,M.CME_HG AS Copper

		 ,M.CME_SI AS Silver

		 ,R.CME_ED AS Eurodollar

		 ,R.CME_TU AS TwoYear

		 ,R.CME_FV AS FiveYear

		 ,R.CME_TY AS TenYear

		 ,R.CME_US AS ThirtyYear

	FROM X.Date

	LEFT JOIN futures.Ag AS A

	ON X.Date.Date = A.Date

	LEFT JOIN futures.Energy AS E

	ON X.Date.Date = E.Date

	LEFT JOIN futures.Equities AS EQ

	ON X.Date.Date = EQ.Date

	LEFT JOIN futures.FX AS F

	ON X.Date.Date = F.Date

	LEFT JOIN futures.Metals AS M

	ON X.Date.Date = M.Date

	LEFT JOIN futures.Rates AS R

	ON X.Date.Date = R.Date

	WHERE COALESCE(A.CME_C

		,A.CME_LN

		,A.CME_LC

		,A.CME_S

		,A.CME_W

		,E.CME_CL

		,E.CME_NG

		,E.CME_RB

		,EQ.DAX

		,EQ.CAC

		,EQ.CME_YM

		,EQ.FTSE100

		,EQ.HangSeng

		,EQ.Stoxx50

		,EQ.TSX60

		,EQ.CME_ES

		,EQ.CME_N1Y

		,EQ.CME_NQ

		,F.CME_AD

		,F.CME_CD

		,F.CME_BP

		,F.CME_EC

		,F.CME_JY

		,F.CME_BR

		,F.CME_SF

		,M.CME_GC

		,M.CME_HG

		,M.CME_SI

		,R.CME_ED

		,R.CME_TU

		,R.CME_FV

		,R.CME_TY

		,R.CME_US) IS NOT NULL

		ORDER BY DATE





END
