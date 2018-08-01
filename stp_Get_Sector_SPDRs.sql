-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE dbo.stp_Get_Sector_SPDRs

AS

BEGIN



	SET NOCOUNT ON;



    SELECT D.[Date]

		,CAST(D.Adjusted_Close AS decimal(8,2)) AS Dow

		,B.[Close] AS [MaterialsXLB] 

		,E.[Close] AS [EnergyXLE]    

		,F.[Close] AS [FinXLF]       

		,I.[Close] AS [IndustXLI]    

		,K.[Close] AS [TechXLK]      

		,P.[Close] AS [ConStapXLP]   

		,U.[Close] AS [UtilXLU]      

		,V.[Close] AS [HealthXLV]    

		,Y.[Close] AS [ConDisXLY]    

	FROM us.sp500 AS D

	JOIN [spdr].[MaterialsXLB] AS B ON D.[Date] = B.[Date] 

	JOIN [spdr].[EnergyXLE]    AS E ON D.[Date] = E.[Date]

	JOIN [spdr].[FinXLF]       AS F ON D.[Date] = F.[Date]

	JOIN [spdr].[IndustXLI]    AS I ON D.[Date] = I.[Date]

	JOIN [spdr].[TechXLK]      AS K ON D.[Date] = K.[Date]

	JOIN [spdr].[ConStapXLP]   AS P ON D.[Date] = P.[Date]

	JOIN [spdr].[UtilXLU]      AS U ON D.[Date] = U.[Date]

	JOIN [spdr].[HealthXLV]    AS V ON D.[Date] = V.[Date]

	JOIN [spdr].[ConDisXLY]    AS Y ON D.[Date] = Y.[Date]

	ORDER BY [Date]



END

