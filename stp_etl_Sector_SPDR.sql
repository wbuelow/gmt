-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE dbo.stp_etl_Sector_SPDR

AS

BEGIN



SET NOCOUNT ON;



INSERT INTO spdr.MaterialsXLB

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLBS

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.MaterialsXLB)

INSERT INTO spdr.[EnergyXLE]

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLES

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.[EnergyXLE])

INSERT INTO spdr.[IndustXLI]

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLIS

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.[IndustXLI])

INSERT INTO spdr.[TechXLK]

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLKS

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.[TechXLK])

INSERT INTO spdr.[ConStapXLP]

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLPS

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.[ConStapXLP])

INSERT INTO spdr.[UtilXLU]

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLUS

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.[UtilXLU])

INSERT INTO spdr.[HealthXLV]

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLVS

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.[HealthXLV])

INSERT INTO spdr.[ConDisXLY]

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLYS

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.[ConDisXLY])

INSERT INTO spdr.FinXLF

(

[Date]

,[Close]

)

SELECT [Date]

		,[Last_Close]

	FROM stg.XLFS

	WHERE [Date] > (SELECT MAX([Date]) FROM spdr.FinXLF)



END

