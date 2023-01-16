use UniformesEscolares
go

DROP PROCEDURE IF EXISTS MantenimientoIndices
GO
CREATE PROCEDURE MantenimientoIndices
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TableName VARCHAR(255)
    DECLARE @sql NVARCHAR(500)
    DECLARE @fillfactor INT
    SET @fillfactor = 80
    DECLARE TableCursor CURSOR FOR
        SELECT QUOTENAME(OBJECT_SCHEMA_NAME([object_id]))+'.' + QUOTENAME(name) AS TableName
        FROM sys.tables;

    OPEN TableCursor
        FETCH NEXT FROM TableCursor INTO @TableName
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @sql = 'ALTER INDEX ALL ON ' + @TableName + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ')'
            EXEC (@sql)
            FETCH NEXT FROM TableCursor INTO @TableName
            END
        CLOSE TableCursor
    DEALLOCATE TableCursor
END;
GO

DROP PROCEDURE IF EXISTS BackupFull
GO
CREATE PROCEDURE BackupFull
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER OFF;
    DECLARE @Location nvarchar(100);
    SELECT @Location = CONCAT('C:\SQL Server Backups\UniformesEscolaresFull', CONVERT(date, GETDATE()), '.bak')
    BACKUP DATABASE UniformesEscolares
    TO DISK = @Location
       WITH FORMAT,
          MEDIANAME = 'SQLServerBackups',
          NAME = 'Full Backup of Uniformes Escolares';
END;
GO

DROP PROCEDURE IF EXISTS BackupDiferential
GO
CREATE PROCEDURE BackupDiferential
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER OFF;
    DECLARE @Location nvarchar(100);
    SELECT @Location = CONCAT('C:\SQL Server Backups\UniformesEscolaresDiferential', CONVERT(date, GETDATE()), '.bak')
    BACKUP DATABASE UniformesEscolares
       TO DISK = @Location
       WITH DIFFERENTIAL
END;
GO

DROP PROCEDURE IF EXISTS LogBackup
GO
CREATE PROCEDURE LogBackup
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    SET ANSI_NULLS ON;
    SET QUOTED_IDENTIFIER OFF;
    DECLARE @Location nvarchar(100);
    SELECT @Location = CONCAT('C:\SQL Server Backups\UniformesEscolaresLog', CONVERT(date, GETDATE()), 'T', REPLACE(Convert(Time(0), GetDate()),':','-'),'.bak');;
    BACKUP LOG UniformesEscolares
        TO DISK =  @Location
END;
GO

DROP PROCEDURE IF EXISTS PlanMantenimientoBackpupHistory
GO
CREATE PROCEDURE PlanMantenimientoBackpupHistory
AS
BEGIN
    DECLARE @Date datetime = DATEADD(dd, -28, GETDATE());
    EXEC msdb.dbo.sp_delete_backuphistory @oldest_date = @Date;
END;
GO

DROP PROCEDURE IF EXISTS PlanMantenimientoJobHistory
GO
CREATE PROCEDURE PlanMantenimientoJobHistory
AS
BEGIN
    EXEC msdb.dbo.sp_purge_jobhistory;
END;
GO

/*
Full Backup Job
*/
DECLARE @jobId binary(16)
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Full backup')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END
EXEC msdb.dbo.sp_add_job
    @job_name = N'Full backup' ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Full backup',
    @step_name = N'Set database to read only',
    @subsystem = N'TSQL',
    @command = N'ALTER DATABASE UniformesEscolares SET READ_ONLY',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Full backup',
    @step_name = N'Full Database backup',
    @subsystem = N'TSQL',
    @command = N'Execute BackupFull',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Full backup',
    @step_name = N'Set database to read write',
    @subsystem = N'TSQL',
    @command = N'ALTER DATABASE UniformesEscolares SET READ_WRITE',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'RunWeekly',
    @freq_type = 8, -- semanal
    @freq_interval = 2, -- lunes
     @freq_recurrence_factor = 1,
    @active_start_time = 000000 ; -- 12PM
EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'Full backup',
   @schedule_name = N'RunWeekly';
GO
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Full backup';
GO

/*
Diferential Backup Job
*/
DECLARE @jobId binary(16)

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Backup diferencial')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END
EXEC msdb.dbo.sp_add_job
    @job_name = N'Backup diferencial' ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup diferencial',
    @step_name = N'Set database to read only',
    @subsystem = N'TSQL',
    @command = N'ALTER DATABASE UniformesEscolares SET READ_ONLY',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup diferencial',
    @step_name = N'Do Diferential backup',
    @subsystem = N'TSQL',
    @command = N'Execute BackupDiferential',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backup diferencial',
    @step_name = N'Set database to read write mode',
    @subsystem = N'TSQL',
    @command = N'ALTER DATABASE UniformesEscolares SET READ_WRITE',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'RunDaily',
    @freq_type = 4,
    @freq_interval = 1,
    @active_start_time = 000000 ;
EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'Backup diferencial',
   @schedule_name = N'RunDaily';
GO
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Backup diferencial';
GO

/*
Log Backup Job
*/
DECLARE @jobId binary(16)
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Log Backup')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END
EXEC msdb.dbo.sp_add_job
    @job_name = N'Log Backup' ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Log Backup',
    @step_name = N'Set database to read only',
    @subsystem = N'TSQL',
    @command = N'ALTER DATABASE UniformesEscolares SET READ_ONLY',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Log Backup',
    @step_name = N'Do log backup',
    @subsystem = N'TSQL',
    @command = N'Execute LogBackup',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Log Backup',
    @step_name = N'Set database to read write only',
    @subsystem = N'TSQL',
    @command = N'ALTER DATABASE UniformesEscolares SET READ_WRITE',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_schedule
    @schedule_name = N'RunEvery15Minutes',
    @freq_type = 4, -- on daily basis
    @freq_interval = 1, -- don't use this one
    @freq_subday_type = 4,  -- units between each exec: minutes
    @freq_subday_interval = 15,  -- number of units between each exec
    @active_start_time = 000000 ;
EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'Log Backup',
   @schedule_name = N'RunEvery15Minutes';
GO
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Log Backup' ;
GO

/*
Index, rebuild index and stadistics
-- auto create
*/
DECLARE @jobId binary(16)
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Mantenimiento de indices')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END
EXEC msdb.dbo.sp_add_job
    @job_name = N'Mantenimiento de indices' ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Mantenimiento de indices' ,
    @step_name = N'Rebuild indexes',
    @subsystem = N'TSQL',
    @command = N'EXECUTE MantenimientoIndices',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Mantenimiento de indices' ,
    @step_name = N'Actualizar stadistics',
    @subsystem = N'TSQL',
    @command = N'USE UniformesEscolares; GO
    EXEC sp_updatestats;',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'Mantenimiento de indices' ,
   @schedule_name = N'RunWeekly';
GO
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Mantenimiento de indices';
GO

/*
check database integrity
*/
DECLARE @jobId binary(16)
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Revision de integridad')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END
EXEC msdb.dbo.sp_add_job
    @job_name = N'Revision de integridad' ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Revision de integridad',
    @step_name = N'Check database integrity',
    @subsystem = N'TSQL',
    @command = N'USE UniformesEscolares; DBCC CHECKDB',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'Revision de integridad',
   @schedule_name = N'RunWeekly';
GO
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Revision de integridad' ;
GO

/*
History cleanup
*/
DECLARE @jobId binary(16)
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'Limpiar historial')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END
EXEC msdb.dbo.sp_add_job
    @job_name = N'Limpiar historial' ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Backups Limpiar historial',
    @step_name = N'Clear database backups history',
    @subsystem = N'TSQL',
    @command = N'EXEC UniformesEscolares.dbo.spMaintanceCleanBackpupHistory',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_add_jobstep
    @job_name = N'Jobs Limpiar historial',
    @step_name = N'Clear jobs history',
    @subsystem = N'TSQL',
    @command = N'EXEC UniformesEscolares.dbo.spMaintanceCleanJobHistory',
    @retry_attempts = 5,
    @retry_interval = 5 ;
GO
EXEC msdb.dbo.sp_attach_schedule
   @job_name = N'Limpiar historial',
   @schedule_name = N'RunWeekly';
GO
EXEC msdb.dbo.sp_add_jobserver
    @job_name = N'Limpiar historial';
GO

