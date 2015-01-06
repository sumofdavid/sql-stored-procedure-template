USE [<DB_NAME, sysname, >]
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Drop procedure
IF OBJECT_ID(N'<schema_name, sysname, dbo>.<proc_name, sysname, s_ProcName>', 'P') IS NOT NULL
	DROP PROCEDURE [<schema_name, sysname, dbo>].[<proc_name, sysname, s_ProcName>]
GO

/*************************************************************************************************
	
	<scope></scope>
	
	<returns> 
		<return code="0"	message="Success"	type="Success" /> 
	</returns>
	
	<samples> 
		<sample>
		   <description></description>
		   <code></code> 
		</sample>
	</samples> 

	<historylog> 
		<log PAC2000="----------" revision="1.0" date="00/00/2010" modifier="">Created</log> 
	</historylog>         

**************************************************************************************************/
CREATE PROCEDURE [<schema_name, sysname, dbo>].[<proc_name, sysname, s_ProcName>]
(
	<@param1, sysname, @p1> <datatype_for_param1,,> = <default_value_for_param1, , >, 
	<@param2, sysname, @p2> <datatype_for_param2,,> = <default_value_for_param2, , >
)
-- WITH EXECUTE AS OWNER
AS
SET NOCOUNT ON
SET XACT_ABORT ON

	-- Auditing variables
	DECLARE @err_sec varchar(128) = NULL,
			@exec_start datetimeoffset(7) = SYSDATETIMEOFFSET(),
			@sec_exec_start datetimeoffset(7) = SYSDATETIMEOFFSET(),			
			@exec_end datetimeoffset(7) = NULL,
			@params nvarchar(2000) = NULL,
			@rows int = 0,
			@db_id int = DB_ID(),
			@version uniqueidentifier = NEWID();

    -- Common variables
    DECLARE @ret_val int,
            @sql nvarchar(max) = N'',
		    @crlf nchar(1) = NCHAR(13),
		    @tab nchar(1) = NCHAR(9);

	-- audit parameters
	SET @err_sec = 'log parameters';		

	-- uncomment if you want to log the individual parameters
	--SELECT @params =	N'<@param1, sysname, @p1> = ' + ISNULL('''' + CAST(<@param1, sysname, @p1> AS nvarchar(xxx)) + '''',N'NULL') + N' , ' +
	--					N'<@param2, sysname, @p2> = ' + ISNULL('''' + CAST(<@param2, sysname, @p2> AS nvarchar(xxx)) + '''',N'NULL')
	--					-- Choose which lines to use based on the data type of the parameters.  For character and dates, use above, for numbers use below syntax
	--					N'<@param1, sysname, @p1> = ' + ISNULL(CAST(<@param1, sysname, @p1> AS nvarchar(xxx)),N'NULL') + N' , ' +
	--					N'<@param2, sysname, @p2> = ' + ISNULL(CAST(<@param2, sysname, @p2> AS nvarchar(xxx)),N'NULL')
	

	-- Validate calling parameters here
	SET @err_sec = 'validate parameters';

	--------------------------------------------------
	-- parameter validation code here
	-------------------------------------------------
				
	BEGIN TRY

        -- Make sure that temp tables don't already exist
		SET @err_sec = 'Drop temp tables';
		
		EXEC [DBA].[s_DropObject] @object_name = '#t', @object_type = 'TEMP TABLE', @schema_name = 'dbo', @log_id = @version;
		
		-- Declare local variables
		SET @err_sec = 'Declare local variables';		

		-------------------------------------------------
		-- declare local variables here
		-------------------------------------------------
       
		-- Main procedure logic
		SET @err_sec = 'Procedure Logic';

		-------------------------------------------------
		-- The main logic of the stored procedure will go here
		-------------------------------------------------

		-- Log a particular section of the proc
		SET @rows = @@ROWCOUNT;
		SET @err_sec = 'Log execution of particular section';
		
		SET @exec_end = SYSDATETIMEOFFSET();
		EXEC [DBA].[s_AddProcExecLog] @db_id = @db_id, @object_id = @@PROCID, @start = @sec_exec_start, @end = @exec_end, @extra_info = @params, @rows = @rows, @section = @err_sec, @version = @version;
		SET @sec_exec_start = SYSDATETIMEOFFSET();


		-- Log the entire time execution of the proc
		SET @rows = @@ROWCOUNT;
		SET @err_sec = 'Log Stored Procedure Execution';

		SET @exec_end = SYSDATETIMEOFFSET();
		EXEC [DBA].[s_AddProcExecLog] @db_id = @db_id, @object_id = @@PROCID, @start = @exec_start, @end = @exec_end, @extra_info = @params, @rows = @rows, @section = @err_sec, @version = @version;

		-- Clean up and drop any temp tables	
		SET @err_sec = 'Drop temp tables';
		
		EXEC [DBA].[s_DropObject] @object_name = '#t', @object_type = 'TEMP TABLE', @schema_name = 'dbo', @log_id = @version;

		RETURN(0)
				
	END TRY
	BEGIN CATCH

	   BEGIN

			-------------------------------------------------
			-- Close any cursors here
			-------------------------------------------------
			--IF CURSOR_STATUS('LOCAL','curs') > 0
			--	BEGIN
			--		CLOSE curs
			--		DEALLOCATE curs
			--	END

			-- Declare local variables so we can return them to the caller			
			DECLARE @err_msg varchar(1000),
					@err_severity int;
			
			SELECT	@err_msg = ERROR_MESSAGE(),
					@err_severity = ERROR_SEVERITY();

			-- This will forcibly rollback a transaction that is marked as uncommitable
			IF (XACT_STATE()) = -1 AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			-- Log the error
			EXEC [DBA].[s_AddSQLErrorLog] @section = @err_sec, @extrainfo = @params, @announce = 1;

		END

		-- Return error message to calling code via @@ERROR and error number via return code
		RAISERROR (@err_msg, @err_severity, 1)
		RETURN(ERROR_NUMBER())

	END CATCH
GO

-- add documentation
EXEC sys.sp_addextendedproperty N'MS_Description', N'Placeholder', N'SCHEMA', N'<schema_name, sysname, dbo>', N'PROCEDURE', N'<proc_name, sysname, s_ProcName>'
EXEC sys.sp_addextendedproperty N'MS_Description', N'Placeholder', N'SCHEMA', N'<schema_name, sysname, dbo>', N'PROCEDURE', N'<proc_name, sysname, s_ProcName>', N'PARAMETER', N'<@param1, sysname, @p1>'
EXEC sys.sp_addextendedproperty N'MS_Description', N'Placeholder', N'SCHEMA', N'<schema_name, sysname, dbo>', N'PROCEDURE', N'<proc_name, sysname, s_ProcName>', N'PARAMETER', N'<@param2, sysname, @p1>'
GO