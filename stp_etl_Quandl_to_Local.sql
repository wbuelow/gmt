

-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_Quandl_to_Local] 

						@Url VARCHAR(500),

						@Metadata_Type VARCHAR(100)

AS

BEGIN

	SET NOCOUNT ON;



	DECLARE @Url_Component_1 VARCHAR(500) = LEFT(@Url, 39)

	DECLARE @Url_Component_2 VARCHAR(500) = RIGHT(@Url, LEN(@Url) - LEN(@Url_Component_1))

	DECLARE @Dataset_Nm VARCHAR(500) = LEFT(@Url_Component_2, CHARINDEX('/', @Url_Component_2) - 1)

	DECLARE @Url_Component_3 VARCHAR(500) = RIGHT(@Url_Component_2, LEN(@Url_Component_2) - LEN(@Dataset_Nm) - 1)

	DECLARE @File_Nm VARCHAR(500) = LEFT(@Url_Component_3, CHARINDEX('.', @Url_Component_3) - 1)

	DECLARE @Url_Component_4 VARCHAR(100) = RIGHT(@Url_Component_3, LEN(@Url_Component_3) - LEN(@File_Nm) - 1)

	DECLARE @File_Type VARCHAR(500) = LEFT(@Url_Component_4, CHARINDEX('?', @Url_Component_4) - 1)

	DECLARE @Api_Key VARCHAR(500) = RIGHT(@Url, 20)



	INSERT INTO etl.Quandl_to_Local

	(

	First_Url_Component,

	Dataset_Nm,

	File_Nm,

	File_Type,

	Api_Key,

	Metadata_Type

	)



	SELECT @Url_Component_1

	,@Dataset_Nm

	,@File_Nm

	,@File_Type

	,@Api_Key

	,@Metadata_Type



	

END



