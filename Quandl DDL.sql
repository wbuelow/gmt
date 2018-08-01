

CREATE TABLE etl.Quandl_Datasets (--attribute table for quandl datasets

Quandl_DatasetsId INT IDENTITY(1,1),
CreatedDt DATETIME,
DatabaseCode VARCHAR(25),
DatasetCode VARCHAR(50),
QuandlDDLId INT,
TableNm VARCHAR(25),
PremiumInd INT,
TruncAndReloadInd INT

)

WITH 
(	
     DISTRIBUTION = HASH (QuandlId),
     CLUSTERED COLUMNSTORE INDEX  
)
GO

CREATE TABLE etl.Quandl_ProcessAudit (--audit table for dataset loads

Quandl_ProcessAudit INT IDENTITY(1,1),
Quandl_DatasetsId INT,
LoadDt DATETIME,


)
WITH 
(	
     DISTRIBUTION = HASH (QuandlProcessAudit),
     CLUSTERED COLUMNSTORE INDEX  
)
GO

CREATE TABLE etl.Quandl_DataAudit (--audit table for dataset tables

Quandl_DataAuditId INT IDENTITY(1,1),
Quandl_DatasetsId INT,
LastRefreshDate DATETIME,
LastRefreshCheckDate DATETIME,
NewestAvailableDate DATETIME,
OldestAvailableDate DATETIME,

)
WITH 
(	
     DISTRIBUTION = HASH (QuandlProcessAudit),
     CLUSTERED COLUMNSTORE INDEX  
)
GO


CREATE etl.QuandlConstants (--set of constants used in connection string

QuandlConstantsId INT IDENTITY(1,1),
BaseUrl VARCHAR(100),
APIKey VARCHAR(50),
FileTypeName VARCHAR(10),

)

WITH 
(	
     DISTRIBUTION = HASH (QuandlConstantsId),
     CLUSTERED COLUMNSTORE INDEX  
)
GO

CREATE etl.QuandlDDL (--DDL for dynamic creation of tables

QuandlDDLId INT IDENTITY(1,1),
DDL NVARCHAR(MAX)

)
WITH 
(	
     DISTRIBUTION = HASH (QuandlDDLId),
     CLUSTERED COLUMNSTORE INDEX  
)
GO