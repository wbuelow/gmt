

CREATE PROCEDURE [dbo].[stpTruncateOrCreateStgTable] 

@TableName VARCHAR(100)

,@TableTypeId INT



AS

BEGIN



--declare @TableName VARCHAR(100) = 'COTLN'

--declare @TableTypeId INT = 1



DECLARE @SQLCommand2 NVARCHAR(MAX)



IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @tablename AND TABLE_SCHEMA = 'stg')

BEGIN

SELECT @SQLCommand2 = 'TRUNCATE TABLE stg.[' + @tablename + ']'

EXEC(@SQLCommand2)

END



ELSE

/* Build the section with most of the columns, but this leaves a trailing comma, so we put it in a variable */

DECLARE @SQLCommand NVARCHAR(MAX) = 

   'SELECT @Columns = (SELECT CASE WHEN PrecisionScale IS NOT NULL	

					   THEN ''['' + ColumnName + ''] '' +  DataType + '' '' + PrecisionScale + '', ''

				       ELSE ''['' + ColumnName + ''] '' +  DataType + '', ''

				 END 

		FROM etl.tableDDL

		WHERE TableTypeId = ' + CAST(@TableTypeId AS VARCHAR(2))+ 

		' GROUP BY TableTypeId

					,PrecisionScale

					,ColumnName

					,DataType

					,ColumnOrder

		ORDER BY ColumnOrder

		FOR XML PATH(''''))'



DECLARE @Columns2 NVARCHAR(MAX)

EXECUTE sp_executesql @SQLCommand, N'@Columns nvarchar(max) OUTPUT', @Columns = @Columns2 output



SET @SQLCommand2 = 



'CREATE TABLE stg.' + @TableName + ' (

ID INT IDENTITY(1,1),

CreatedDttm DATETIME DEFAULT GETDATE(),' + 



LEFT(@Columns2, LEN(@Columns2)-1) + 



')'



--select @SQLCommand2



EXEC(@SQLCommand2)



END









