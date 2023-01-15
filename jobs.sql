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