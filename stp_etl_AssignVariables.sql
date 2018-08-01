



-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_AssignVariables] @Pkg_Nm VARCHAR(100)

AS

BEGIN

  select Url, Local_Location,  Local_File_Nm, TableTypeId, TableNm from v.quandl_files where File_Nm = @Pkg_Nm

END





