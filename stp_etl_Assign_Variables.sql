

-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_Assign_Variables] @Pkg_Nm VARCHAR(100)

AS

BEGIN

  select Url, Local_Location,  Local_File_Nm, Metadata_Type, TableNm from v.quandl_files where File_Nm = @Pkg_Nm

END



