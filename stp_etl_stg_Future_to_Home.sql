-- =============================================

-- Author:		<Author,,Name>

-- Create date: <Create Date,,>

-- Description:	<Description,,>

-- =============================================

CREATE PROCEDURE [dbo].[stp_etl_stg_Future_to_Home]

						@Contract_Nm VARCHAR(100)

AS

BEGIN



SET NOCOUNT ON;



--DECLARE @Contract_Nm VARCHAR(100) = 'SGX_CFF'



DECLARE @dynSQL VARCHAR(8000) = ''

DECLARE @Home_Schema_Nm VARCHAR(100) = (SELECT [Home_Schema_Nm] FROM [etl].[stg_to_home] WHERE [Contract_Nm] = @Contract_Nm)

DECLARE @Home_Table_Nm VARCHAR(100) = (SELECT [Home_Table_Nm] FROM [etl].[stg_to_home] WHERE [Contract_Nm] = @Contract_Nm)

DECLARE @Home VARCHAR(100) = (SELECT @Home_Schema_Nm + '.' + @Home_Table_Nm)

DECLARE @DATE VARCHAR(20) = '1900-01-01'

DECLARE @Metadata_Type VARCHAR(100) = (SELECT DISTINCT Metadata_Type

											FROM etl.Quandl_to_Local

											WHERE LEFT(File_Nm, LEN(File_Nm) - 1) = @Contract_Nm)



IF @Metadata_Type = 'cme future'



BEGIN



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @Home_Table_Nm AND TABLE_SCHEMA = @Home_Schema_Nm)



BEGIN



SET @dynSQL = 'CREATE TABLE ' + @Home  + ' (

			[Seq_Id] INT Identity(1,1) Primary Key,

			[Created_Dttm] DATETIME DEFAULT GETDATE(),

			[Date] date,

			[Open] DECIMAL(38,19),

			[High] DECIMAL(38,19),

			[Low] DECIMAL(38,19),

			[Last] DECIMAL(38,19),

			[Change] DECIMAL(38,19),

			[Settle] DECIMAL(38,19),

			[Volume] BIGINT,

			[Open_Interest] BIGINT

			) 

		INSERT INTO ' + @Home + '

		(

		[Date]

		,[Open]

		,[High]

		,[Low]

		,[Last]

		,[Change]

		,[Settle]

		,[Volume]

		,[Open_Interest]

		)

		SELECT ISNULL(F.DATE, S.DATE) AS DATE

					,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Open]          ELSE S.[Open]          END AS [Open]

					,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[High]          ELSE S.[High]          END AS [High]

					,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Low]           ELSE S.[Low]           END AS [Low]

					,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Last]          ELSE S.[Last]          END AS [Last]

					,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Change]        ELSE S.[Change]        END AS [Change]

					,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Settle]        ELSE S.[Settle]        END AS [Settle]

					,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Volume]        ELSE S.[Volume]        END AS [Volume]

					,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Open_Interest] ELSE S.[Open_Interest] END AS [Open_Interest]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



ELSE--cme future insert



SET @dynSQL = 'TRUNCATE TABLE ' +  @Home + ' INSERT INTO ' + @Home + '

		(

		[Date]

		,[Open]

		,[High]

		,[Low]

		,[Last]

		,[Change]

		,[Settle]

		,[Volume]

		,[Open_Interest]

		)

		SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Open]          ELSE S.[Open]          END AS [Open]

				,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[High]          ELSE S.[High]          END AS [High]

				,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Low]           ELSE S.[Low]           END AS [Low]

				,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Last]          ELSE S.[Last]          END AS [Last]

				,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Change]        ELSE S.[Change]        END AS [Change]

				,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Settle]        ELSE S.[Settle]        END AS [Settle]

				,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Volume]        ELSE S.[Volume]        END AS [Volume]

				,CASE WHEN ISNULL(F.Open_Interest, 1) >= ISNULL(S.Open_Interest, 1) THEN F.[Open_Interest] ELSE S.[Open_Interest] END AS [Open_Interest]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



IF @Metadata_Type = 'HKEX future'



BEGIN



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @Home_Table_Nm AND TABLE_SCHEMA = @Home_Schema_Nm)



BEGIN



SET @dynSQL = 'CREATE TABLE ' + @Home  + ' (

			[Seq_Id] INT Identity(1,1) Primary Key,

			[Created_Dttm] DATETIME DEFAULT GETDATE(),

			[Date] date,

			[Open] DECIMAL(38,19),

			[Bid] DECIMAL(38,19),

			[Ask] DECIMAL(38,19),

			[Last_Traded] DECIMAL(38,19),

			[High] DECIMAL(38,19),

			[Low] DECIMAL(38,19),

			[Volume] BIGINT,

			[Previous_Day_Settlement_Price] DECIMAL(38,19),

			[Net_Change] DECIMAL(38,19),

			[Previous_Day_Open_Interest] BIGINT

			) 

		INSERT INTO ' + @Home + '

		(

		[Date],

		[Open],

		[Bid],

		[Ask],

		[Last_Traded],

		[High],

		[Low],

		[Volume],

		[Previous_Day_Settlement_Price],

		[Net_Change],

		[Previous_Day_Open_Interest]

		)

		SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Open] ELSE S.[Open] END AS [Open]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Bid] ELSE S.[Bid] END AS [Bid]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Ask] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Last_Traded] ELSE S.[Last_Traded] END AS [Last_Traded]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[High] ELSE S.[High] END AS [High]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Low] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Previous_Day_Settlement_Price] ELSE S.[Previous_Day_Settlement_Price] END AS [Previous_Day_Settlement_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Net_Change] ELSE S.[Net_Change] END AS [Net_Change]

		[Volume],

		[Last_Close_Price],

		[Net_Change],

		[Open_Price],

		[High_Price],

		[Low_Price],

		[Total_Value],

		[NB_Trades],

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Previous_Day_Open_Interest] ELSE S.[Previous_Day_Open_Interest] END AS [Previous_Day_Open_Interest]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



ELSE --hkek insert



SET @dynSQL = 'TRUNCATE TABLE ' +  @Home + ' INSERT INTO ' + @Home + '

		(

		[Date],

		[Open],

		[Bid],

		[Ask],

		[Last_Traded],

		[High],

		[Low],

		[Volume],

		[Previous_Day_Settlement_Price],

		[Net_Change],

		[Previous_Day_Open_Interest]

		)

		SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Open] ELSE S.[Open] END AS [Open]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Bid] ELSE S.[Bid] END AS [Bid]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Ask] ELSE S.[Low] END AS [Low]
				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Last_Traded] E
LSE S.[Last_Traded] END AS [Last_Traded]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[High] ELSE S.[High] END AS [High]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Low] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Previous_Day_Settlement_Price] ELSE S.[Previous_Day_Settlement_Price] END AS [Previous_Day_Settlement_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Net_Change] ELSE S.[Net_Change] END AS [Net_Change]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Previous_Day_Open_Interest] ELSE S.[Previous_Day_Open_Interest] END AS [Previous_Day_Open_Interest]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



IF @Metadata_Type = 'mx future' 



BEGIN



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @Home_Table_Nm AND TABLE_SCHEMA = @Home_Schema_Nm)



BEGIN



SET @dynSQL = 'CREATE TABLE ' + @Home  + ' (

			[Seq_Id] INT Identity(1,1) Primary Key,

			[Created_Dttm] DATETIME DEFAULT GETDATE(),

			[Date] date,

			[Bid_Price] DECIMAL(38,19),

			[Ask_Price] DECIMAL(38,19),

			[Bid_Size] BIGINT,

			[Ask_Size] BIGINT,

			[Last_Price] DECIMAL(38,19),

			[Volume] BIGINT,

			[Last_Close_Price] DECIMAL(38,19),

			[Net_Change] DECIMAL(38,19),

			[Open_Price] DECIMAL(38,19),

			[High_Price] DECIMAL(38,19),

			[Low_Price] DECIMAL(38,19),

			[Total_Value] DECIMAL(38,19),

			[NB_Trades] BIGINT,

			[Settlement_Price] DECIMAL(38,19),

			[Previous_Day_Open_Interest] BIGINT,

			[Implied_Volatility] DECIMAL(38,19)

			) 

			INSERT INTO ' + @Home + '

		(

		[Date],

		[Bid_Price],

		[Ask_Price],

		[Bid_Size],

		[Ask_Size],

		[Last_Price],

		[Settlement_Price],

		[Previous_Day_Open_Interest],

		[Implied_Volatility]

		)

		SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Bid_Price] ELSE S.[Bid_Price] END AS [Bid_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Ask_Price] ELSE S.[Ask_Price] END AS [Ask_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Bid_Size] ELSE S.[Bid_Size] END AS [Bid_Size]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Ask_Size] ELSE S.[Ask_Size] END AS [Ask_Size]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Last_Price] ELSE S.[Last_Price] END AS [Last_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Last_Close_Price] ELSE S.[Last_Close_Price] END AS [Last_Close_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Net_Change] ELSE S.[Net_Change] END AS [Net_Change]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Open_Price] ELSE S.[Open_Price] END AS [Open_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[High_Price] ELSE S.[High_Price] END AS [High_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Low_Price] ELSE S.[Low_Price] END AS [Low_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Total_Value] ELSE S.[Total_Value] END AS [Total_Value]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[NB_Trades] ELSE S.[NB_Trades] END AS [NB_Trades]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Settlement_Price] ELSE S.[Settlement_Price] END AS [Settlement_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Previous_Day_Open_Interest] ELSE S.[Previous_Day_Open_Interest] END AS [Previous_Day_Open_Interest]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Implied_Volatility] ELSE S.[Implied_Volatility] END AS [Implied_Volatility]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



ELSE --mx future



SET @dynSQL = 'TRUNCATE TABLE ' +  @Home + ' INSERT INTO ' + @Home + '

		(

		[Date],

		[Bid_Price],

		[Ask_Price],

		[Bid_Size],

		[Ask_Size],

		[Last_Price],

		[Volume],

		[Last_Close_Price],

		[Net_Change],

		[Open_Price],

		[High_Price],

		[Low_Price],

		[Total_Value],

		[NB_Trades],

		[Settlement_Price],

		[Previous_Day_Open_Interest],

		[Implied_Volatility]

		)

		SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Bid_Price] ELSE S.[Bid_Price] END AS [Bid_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Ask_Price] ELSE S.[Ask_Price] END AS [Ask_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Bid_Size] ELSE S.[Bid_Size] END AS [Bid_Size]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Ask_Size] ELSE S.[Ask_Size] END AS [Ask_Size]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Last_Price] ELSE S.[Last_Price] END AS [Last_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Last_Close_Price] ELSE S.[Last_Close_Price] END AS [Last_Close_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Net_Change] ELSE S.[Net_Change] END AS [Net_Change]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Open_Price] ELSE S.[Open_Price] END AS [Open_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[High_Price] ELSE S.[High_Price] END AS [High_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Low_Price] ELSE S.[Low_Price] END AS [Low_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Total_Value] ELSE S.[Total_Value] END AS [Total_Value]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[NB_Trades] ELSE S.[NB_Trades] END AS [NB_Trades]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Settlement_Price] ELSE S.[Settlement_Price] END AS [Settlement_Price]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Previous_Day_Open_Interest] ELSE S.[Previous_Day_Open_Interest] END AS [Previous_Day_Open_Interest]

				,CASE WHEN ISNULL(F.Previous_Day_Open_Interest,1) >= ISNULL(S.Previous_Day_Open_Interest,1) THEN F.[Implied_Volatility] ELSE S.[Implied_Volatility] END AS [Implied_Volatility]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



IF @Metadata_Type = 'shfe future' 



BEGIN



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @Home_Table_Nm AND TABLE_SCHEMA = @Home_Schema_Nm)



BEGIN



SET @dynSQL = 'CREATE TABLE ' + @Home  + ' (

			[Seq_Id] INT Identity(1,1) Primary Key,

			[Created_Dttm] DATETIME DEFAULT GETDATE(),

			[Date] date,

			[Prev_Settle] DECIMAL(38,19),

			[Open] DECIMAL(38,19),

			[High] DECIMAL(38,19),

			[Low] DECIMAL(38,19),

			[Close] DECIMAL(38,19),  

			[Settle] DECIMAL(38,19),

			[CH1] DECIMAL(38,19),

			[CH2] DECIMAL(38,19),

			[Volume] BIGINT,

			[OI] DECIMAL(38,19)

			)

			INSERT INTO ' + @Home + '

		([Date],

			[Prev_Settle],

			[Open],

			[High],

			[Low],

			[Close],  

			[Settle],

			[CH1],

			[CH2],

			[Volume],

			[OI]

			)

			SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Prev_Settle] ELSE S.[Prev_Settle] END AS [Prev_Settle]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Open] ELSE S.[Open] END AS [Open]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[High] ELSE S.[High] END AS [High]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Low] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Close] ELSE S.[Close] END AS [Close]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Settle] ELSE S.[Settle] END AS [Settle]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[CH1] ELSE S.[CH1] END AS [CH1]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[CH2] ELSE S.[CH2] END AS [CH2]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[OI] ELSE S.[OI] END AS [OI]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



ELSE 



SET @dynSQL = 'TRUNCATE TABLE ' +  @Home + ' INSERT INTO ' + @Home + '

		(

		[Date],

			[Prev_Settle],

			[Open],

			[High],

			[Low],

			[Close],  

			[Settle],

			[CH1],

			[CH2],

			[Volume],

			[OI]

		)

		SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Prev_Settle] ELSE S.[Prev_Settle] END AS [Prev_Settle]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Open] ELSE S.[Open] END AS [Open]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[High] ELSE S.[High] END AS [High]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Low] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Close] ELSE S.[Close] END AS [Close]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Settle] ELSE S.[Settle] END AS [Settle]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[CH1] ELSE S.[CH1] END AS [CH1]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[CH2] ELSE S.[CH2] END AS [CH2]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.OI,1) >= ISNULL(S.OI,1) THEN F.[OI] ELSE S.[OI] END AS [OI]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



IF @Metadata_Type = 'sgx future' 



BEGIN



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @Home_Table_Nm AND TABLE_SCHEMA = @Home_Schema_Nm)



BEGIN



SET @dynSQL = 'CREATE TABLE ' + @Home  + ' (

			[Seq_Id] INT Identity(1,1) Primary Key,

			[Created_Dttm] DATETIME DEFAULT GETDATE(),

			[Date] date,

			[Open] DECIMAL(38,19),

			[High] DECIMAL(38,19),

			[Low] DECIMAL(38,19),

			[Close] DECIMAL(38,19),

			[Settle] DECIMAL(38,19),

			[Volume] BIGINT,

			[Prev_Day_Open_Interest] BIGINT

			)

			INSERT INTO ' + @Home + '

			(

			[Date],

			[Open],

			[High],

			[Low],

			[Close],  

			[Settle],

			[Volume],

			[Prev_Day_Open_Interest]

			)

			SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Open] ELSE S.[Open] END AS [Open]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[High] ELSE S.[High] END AS [High]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Low] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Close] ELSE S.[Close] END AS [Close]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Settle] ELSE S.[Settle] END AS [Settle]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Prev_Day_Open_Interest] ELSE S.[Prev_Day_Open_Interest] END AS [Prev_Day_Open_Interest]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'

END



ELSE



SET @dynSQL = 'TRUNCATE TABLE ' +  @Home + ' INSERT INTO ' + @Home + '

		([Date],

			[Open],

			[High],

			[Low],

			[Close],  

			[Settle],

			[Volume],

			[Prev_Day_Open_Interest]

			)

			SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Open] ELSE S.[Open] END AS [Open]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[High] ELSE S.[High] END AS [High]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Low] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Close] ELSE S.[Close] END AS [Close]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Settle] ELSE S.[Settle] END AS [Settle]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Prev_Day_Open_Interest] ELSE S.[Prev_Day_Open_Interest] END AS [Prev_Day_Open_Interest]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'

			+ 

			'DELETE FROM ' +  @Home + ' WHERE Settle = 0'



END





IF @Metadata_Type = 'ice future' 



BEGIN



IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = @Home_Table_Nm AND TABLE_SCHEMA = @Home_Schema_Nm)



BEGIN



SET @dynSQL = 'CREATE TABLE ' + @Home  + ' (

			[Seq_Id] INT Identity(1,1) Primary Key,

			[Created_Dttm] DATETIME DEFAULT GETDATE(),

			[Date] date,

			[Open] DECIMAL(38,19),

			[High] DECIMAL(38,19),

			[Low] DECIMAL(38,19),

			[Settle] DECIMAL(38,19),

			[Change] DECIMAL(38,19),  

			[Wave] DECIMAL(38,19),  

			[Volume] BIGINT,

			[Prev_Day_Open_Interest] DECIMAL(38,19),

			[EPP_Volume] DECIMAL(38,19),

			[EPS_Volume] DECIMAL(38,19),

			[Block_Volume] DECIMAL(38,19)

			)

			INSERT INTO ' + @Home + '

			(

			[Date],

			[Open],

			[High],

			[Low],

			[Settle],

			[Change],  

			[Wave],  

			[Volume],

			[Prev_Day_Open_Interest],

			[EPP_Volume],

			[EPS_Volume],

			[Block_Volume]

			)

			SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Open] ELSE S.[Open] END AS [Open]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[High] ELSE S.[High] END AS [High]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Low] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Settle] ELSE S.[Settle] END AS [Settle]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Change] ELSE S.[Change] END AS [Change]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Wave] ELSE S.[Wave] END AS [Wave]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Prev_Day_Open_Interest] ELSE S.[Prev_Day_Open_Interest] END AS [Prev_Day_Open_Interest]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[EPP_Volume] ELSE S.[EPP_Volume] END AS [EPP_Volume]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[EPS_Volume] ELSE S.[EPS_Volume] END AS [EPS_Volume]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Block_Volume] ELSE S.[Block_Volume] END AS [Block_Volume]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'

END



ELSE



SET @dynSQL = 'TRUNCATE TABLE ' +  @Home + ' INSERT INTO ' + @Home + '

		(

		[Date],

			[Open],

			[High],

			[Low],

			[Settle],

			[Change],  

			[Wave],  

			[Volume],

			[Prev_Day_Open_Interest],

			[EPP_Volume],

			[EPS_Volume],

			[Block_Volume]

			)

			SELECT ISNULL(F.DATE, S.DATE) AS DATE

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Open] ELSE S.[Open] END AS [Open]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[High] ELSE S.[High] END AS [High]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Low] ELSE S.[Low] END AS [Low]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Settle] ELSE S.[Settle] END AS [Settle]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Change] ELSE S.[Change] END AS [Change]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Wave] ELSE S.[Wave] END AS [Wave]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Volume] ELSE S.[Volume] END AS [Volume]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Prev_Day_Open_Interest] ELSE S.[Prev_Day_Open_Interest] END AS [Prev_Day_Open_Interest]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[EPP_Volume] ELSE S.[EPP_Volume] END AS [EPP_Volume]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[EPS_Volume] ELSE S.[EPS_Volume] END AS [EPS_Volume]

				,CASE WHEN ISNULL(F.Prev_Day_Open_Interest,1) >= ISNULL(S.Prev_Day_Open_Interest,1) THEN F.[Block_Volume] ELSE S.[Block_Volume] END AS [Block_Volume]

			FROM ' + 'stg.' + @Contract_Nm + '1' + ' AS F

			FULL JOIN ' + 'stg.' + @Contract_Nm + '2' + ' AS S

			ON F.Date = S.Date

			WHERE F.Date > (SELECT ISNULL(MAX(Date), ''' + @DATE + ''') FROM ' + @Home + ')'



END



EXEC(@dynSQL)



END









