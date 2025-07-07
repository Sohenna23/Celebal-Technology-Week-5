-- Turn off extra messages
SET NOCOUNT ON;

-- Drop tables and procedure if they already exist
IF OBJECT_ID('SubjectAllotments') IS NOT NULL DROP TABLE SubjectAllotments;
IF OBJECT_ID('SubjectRequest') IS NOT NULL DROP TABLE SubjectRequest;
IF OBJECT_ID('UpdateSubjectAllotments') IS NOT NULL DROP PROCEDURE UpdateSubjectAllotments;
GO

-- Create SubjectAllotments table
CREATE TABLE SubjectAllotments (
    StudentId VARCHAR(50),
    SubjectId VARCHAR(50),
    Is_Valid BIT
);
GO

-- Create SubjectRequest table
CREATE TABLE SubjectRequest (
    StudentId VARCHAR(50),
    SubjectId VARCHAR(50)
);
GO

-- Insert sample data into SubjectAllotments
INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid) VALUES
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);
GO

-- Insert new request into SubjectRequest
INSERT INTO SubjectRequest (StudentId, SubjectId) VALUES
('159103036', 'PO1496');
GO

-- Create stored procedure to update subject allotments
CREATE PROCEDURE UpdateSubjectAllotments
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StudentId VARCHAR(50), @RequestedSubjectId VARCHAR(50), @CurrentSubjectId VARCHAR(50);

    DECLARE cur CURSOR FOR
        SELECT StudentId, SubjectId FROM SubjectRequest;

    OPEN cur;
    FETCH NEXT FROM cur INTO @StudentId, @RequestedSubjectId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @CurrentSubjectId = SubjectId
        FROM SubjectAllotments
        WHERE StudentId = @StudentId AND Is_Valid = 1;

        IF @CurrentSubjectId IS NULL
        BEGIN
            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@StudentId, @RequestedSubjectId, 1);
        END
        ELSE IF @CurrentSubjectId <> @RequestedSubjectId
        BEGIN
            UPDATE SubjectAllotments
            SET Is_Valid = 0
            WHERE StudentId = @StudentId AND SubjectId = @CurrentSubjectId;

            INSERT INTO SubjectAllotments (StudentId, SubjectId, Is_Valid)
            VALUES (@StudentId, @RequestedSubjectId, 1);
        END

        FETCH NEXT FROM cur INTO @StudentId, @RequestedSubjectId;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

-- Execute the procedure
EXEC UpdateSubjectAllotments;
GO

-- OUTPUT 1: Show SubjectRequest
PRINT '?? 1. SubjectRequest Table';
SELECT * FROM SubjectRequest;
PRINT '--------------------------------------------';

-- OUTPUT 2: Show All SubjectAllotments (history)
PRINT '?? 2. Full SubjectAllotments Table (Valid + Invalid)';
SELECT * FROM SubjectAllotments ORDER BY StudentId, SubjectId;
PRINT '--------------------------------------------';
-- OUTPUT 3: Show Only Active SubjectAllotments
PRINT '? 3. Active SubjectAllotments (Is_Valid = 1)';
SELECT * FROM SubjectAllotments 
WHERE Is_Valid = 1 
ORDER BY StudentId, SubjectId;
PRINT '--------------------------------------------';


