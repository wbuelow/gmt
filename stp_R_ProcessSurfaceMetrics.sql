USE [vol]
GO

/****** Object:  StoredProcedure [owf].[stp_R_ProcessSurfaceMetrics]    Script Date: 8/1/2018 9:35:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--[owf].[stp_R_ProcessSurfaceMetrics] 'stg.owfRTYivs'
--[owf].[stp_R_ProcessSurfaceMetrics] 'stg.owfCivs'

CREATE procedure [owf].[stp_R_ProcessSurfaceMetrics] @TableName VARCHAR(100) AS

--declare @TableName varchar(100) = 'stg.owfRTYivs'

DECLARE @SQL NVARCHAR(MAX) = N'select Date, DNSvol, P25dVol, P10dVol, C25dVol, C10dVol FROM ' + @TableName + ' order by date'
DECLARE @Seasonal tinyint = (SELECT OWFSeasonallyAdjust FROM gmt.futures.dimContract WHERE OWFTableName = RIGHT(@TableName,LEN(@TableName)-4))

IF @Seasonal = 1
BEGIN
exec sp_execute_external_script @language = N'R',
@script=N'
library(lubridate) #month and year functions
library(dplyr) #rename
library(zoo) #as.yearmon

InputDataSet$RR25 <- (InputDataSet$C25dVol-InputDataSet$P25dVol)/InputDataSet$DNSvol
InputDataSet$RR10 <- (InputDataSet$C10dVol-InputDataSet$P10dVol)/InputDataSet$DNSvol

fn_IV_Range <- function(x)
{
  (max(x) - min(x))/max(x)
}
fn_OP <- function(x) #Opportunity Percent
{
  #Calc Percentile
  a <- data.frame(x)
  b <- percent_rank(a)/length(a)
  P <- tail(b, n=1)
  #Calc Rank
  R <- (tail(x, n=1) - min(x))/(max(x) - min(x))
  OP <- (P + R)/2
  return(OP)
}

InputDataSet$month <- month(InputDataSet$Date)

InputDataSet$year <- year(InputDataSet$Date)

x.monthly <- aggregate(InputDataSet[,c("DNSvol", "RR25", "RR10")], list(InputDataSet$month, InputDataSet$year), mean)

x.monthly$Date <- as.Date(paste(paste(x.monthly$Group.2, x.monthly$Group.1,sep="-"), "-1",sep=""), format = "%Y-%m-%d")

### SAIV ###
tsx.IV <- ts(data = x.monthly$DNSvol, start = c(x.monthly$Group.2[1],x.monthly$Group.1[1])  
          , end = c(x.monthly$Group.2[nrow(x.monthly)],x.monthly$Group.1[nrow(x.monthly)]), frequency = 12)

decomp.IV   <- stl(tsx.IV  , s.window = "period")

df.IV <- cbind(as.data.frame(as.yearmon(time(decomp.IV$time.series))),as.data.frame(decomp.IV$time.series[,1]))
colnames(df.IV)[1] <- "zooyearmon"
colnames(df.IV)[2] <- "seasonal"

df.IV$Group.1 <- as.numeric(format(df.IV$zooyearmon, "%m"))
df.IV$Group.2 <- as.numeric(format(df.IV$zooyearmon, "%Y"))

### RR25###
tsx.RR25 <- ts(data = x.monthly$RR25, start = c(x.monthly$Group.2[1],x.monthly$Group.1[1])  
               , end = c(x.monthly$Group.2[nrow(x.monthly)],x.monthly$Group.1[nrow(x.monthly)]), frequency = 12)

decomp.RR25 <- stl(tsx.RR25, s.window = "period")

df.RR25 <- cbind(as.data.frame(as.yearmon(time(decomp.RR25$time.series))),as.data.frame(decomp.RR25$time.series[,1]))
colnames(df.RR25)[1] <- "zooyearmon"
colnames(df.RR25)[2] <- "seasonal"

df.RR25$Group.1 <- as.numeric(format(df.RR25$zooyearmon, "%m"))
df.RR25$Group.2 <- as.numeric(format(df.RR25$zooyearmon, "%Y"))

### RR10###
tsx.RR10 <- ts(data = x.monthly$RR10, start = c(x.monthly$Group.2[1],x.monthly$Group.1[1])  
               , end = c(x.monthly$Group.2[nrow(x.monthly)],x.monthly$Group.1[nrow(x.monthly)]), frequency = 12)

decomp.RR10 <- stl(tsx.RR10, s.window = "period")

df.RR10 <- cbind(as.data.frame(as.yearmon(time(decomp.RR10$time.series))),as.data.frame(decomp.RR10$time.series[,1]))
colnames(df.RR10)[1] <- "zooyearmon"
colnames(df.RR10)[2] <- "seasonal"

df.RR10$Group.1 <- as.numeric(format(df.RR10$zooyearmon, "%m"))
df.RR10$Group.2 <- as.numeric(format(df.RR10$zooyearmon, "%Y"))

InputDataSet <- rename(InputDataSet, Group.1 = month, Group.2 = year)

df.merged <- merge(InputDataSet, df.IV, by = c("Group.1", "Group.2"))
df.merged$Date <- as.character(as.Date(df.merged$Date))
df.merged$saDNSvol <- df.merged$DNSvol-df.merged$seasonal

df.merged <- df.merged[ ,c("Date", "DNSvol", "saDNSvol", "P25dVol", "P10dVol", "C25dVol", "C10dVol","RR25", "RR10", "Group.1", "Group.2")]
df.merged <- merge(df.merged, df.RR25, by = c("Group.1", "Group.2"))
df.merged$Date <- as.character(as.Date(df.merged$Date))
df.merged$saRR25 <- df.merged$RR25-df.merged$seasonal

df.merged <- df.merged[ ,c("Date", "DNSvol", "saDNSvol", "P25dVol", "P10dVol", "C25dVol", "C10dVol","RR25", "saRR25", "RR10","Group.1", "Group.2")]
df.merged <- merge(df.merged, df.RR25, by = c("Group.1", "Group.2"))
df.merged$Date <- as.character(as.Date(df.merged$Date))
df.merged$saRR10 <- df.merged$RR10-df.merged$seasonal

InputDataSet <- df.merged[, c("Date", "DNSvol", "saDNSvol", "P25dVol", "P10dVol", "C25dVol", "C10dVol", "saRR25", "saRR10", "RR25", "RR10")]

InputDataSet <- InputDataSet[order(InputDataSet$Date),]

InputDataSet$Fly25 <- (InputDataSet$C25dVol+InputDataSet$P25dVol-InputDataSet$DNSvol)/2
InputDataSet$Fly10 <- (InputDataSet$C10dVol+InputDataSet$P10dVol-InputDataSet$DNSvol)/2
InputDataSet$IVrange <- c(numeric(20), rollapplyr(InputDataSet$DNSvol, width = 21, FUN = fn_IV_Range))
InputDataSet$IVOP       <- c(numeric(251), rollapplyr(InputDataSet$saDNSvol, width = 252, FUN = fn_OP))
InputDataSet$RR25OP     <- c(numeric(251), rollapplyr(InputDataSet$saRR25,   width = 252, FUN = fn_OP))
InputDataSet$RR10OP     <- c(numeric(251), rollapplyr(InputDataSet$saRR10,   width = 252, FUN = fn_OP))
InputDataSet$FLY25OP    <- c(numeric(251), rollapplyr(InputDataSet$Fly25,    width = 252, FUN = fn_OP))
InputDataSet$FLY10OP    <- c(numeric(251), rollapplyr(InputDataSet$Fly10,    width = 252, FUN = fn_OP))
OutputDataSet <- InputDataSet',
@input_data_1 = @SQL
with result sets ((
[Date] VARCHAR(23), 
DNSvol   DECIMAL(8,6), 
saDNSvol DECIMAL(8,6), 
P25dVol  DECIMAL(8,6), 
P10dVol  DECIMAL(8,6), 
C25dVol  DECIMAL(8,6), 
C10dVol  DECIMAL(8,6), 
saRR25   DECIMAL(8,6), 
saRR10   DECIMAL(8,6), 
RR25     DECIMAL(8,6),
RR10     DECIMAL(8,6),
Fly25    DECIMAL(8,6),
Fly10    DECIMAL(8,6),
IVrange  DECIMAL(8,6),
IVOP     DECIMAL(8,6),
RR25OP   DECIMAL(8,6),
RR10OP 	 DECIMAL(8,6),
FLY25OP	 DECIMAL(8,6),
FLY10OP	 DECIMAL(8,6)
))

END
ELSE
IF @Seasonal = 0
BEGIN
exec sp_execute_external_script @language = N'R',
@script=N'
library(lubridate) #month and year functions
library(dplyr) #rename
library(zoo) #as.yearmon

fn_IV_Range <- function(x)
{
  (max(x) - min(x))/max(x)
}
fn_OP <- function(x) #Opportunity Percent
{
  #Calc Percentile
  a <- data.frame(x)
  b <- percent_rank(a)/length(a)
  P <- tail(b, n=1)
  #Calc Rank
  R <- (tail(x, n=1) - min(x))/(max(x) - min(x))
  OP <- (P + R)/2
  return(OP)
}
InputDataSet$saDNSvol <- InputDataSet$DNSvol
InputDataSet$saRR25 <- (InputDataSet$C25dVol-InputDataSet$P25dVol)/InputDataSet$DNSvol
InputDataSet$saRR10 <- (InputDataSet$C10dVol-InputDataSet$P10dVol)/InputDataSet$DNSvol
InputDataSet$RR25 <- (InputDataSet$C25dVol-InputDataSet$P25dVol)/InputDataSet$DNSvol
InputDataSet$RR10 <- (InputDataSet$C10dVol-InputDataSet$P10dVol)/InputDataSet$DNSvol
InputDataSet$Fly25 <- (InputDataSet$C25dVol+InputDataSet$P25dVol-InputDataSet$DNSvol)/2
InputDataSet$Fly10 <- (InputDataSet$C10dVol+InputDataSet$P10dVol-InputDataSet$DNSvol)/2
InputDataSet$IVrange <- c(numeric(20), rollapplyr(InputDataSet$DNSvol, width = 21, FUN = fn_IV_Range))
InputDataSet$IVOP       <- c(numeric(251), rollapplyr(InputDataSet$saDNSvol, width = 252, FUN = fn_OP))
InputDataSet$RR25OP     <- c(numeric(251), rollapplyr(InputDataSet$saRR25,   width = 252, FUN = fn_OP))
InputDataSet$RR10OP     <- c(numeric(251), rollapplyr(InputDataSet$saRR10,   width = 252, FUN = fn_OP))
InputDataSet$FLY25OP    <- c(numeric(251), rollapplyr(InputDataSet$Fly25,    width = 252, FUN = fn_OP))
InputDataSet$FLY10OP    <- c(numeric(251), rollapplyr(InputDataSet$Fly10,    width = 252, FUN = fn_OP))
OutputDataSet <- InputDataSet',
@input_data_1 = @SQL
with result sets ((
[Date] VARCHAR(23), 
DNSvol   DECIMAL(8,6), 
P25dVol  DECIMAL(8,6), 
P10dVol  DECIMAL(8,6), 
C25dVol  DECIMAL(8,6), 
C10dVol  DECIMAL(8,6), 
saDNSvol DECIMAL(8,6), 
saRR25   DECIMAL(8,6), 
saRR10   DECIMAL(8,6), 
RR25     DECIMAL(8,6),
RR10     DECIMAL(8,6),
Fly25    DECIMAL(8,6),
Fly10    DECIMAL(8,6),
IVrange  DECIMAL(8,6),
IVOP     DECIMAL(8,6),
RR25OP   DECIMAL(8,6),
RR10OP 	 DECIMAL(8,6),
FLY25OP	 DECIMAL(8,6),
FLY10OP	 DECIMAL(8,6)
))

END

;





GO


