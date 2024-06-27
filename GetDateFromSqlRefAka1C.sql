--DROP FUNCTION dbo.GetDateFromSqlRefAka1C;

CREATE FUNCTION dbo.GetDateFromSqlRefAka1C(@IDRRef binary(16))
RETURNS DATETIME
AS
BEGIN
-- convert idref-> 1cGuid nvarchar
declare @guid nchar(32);
SET @guid = substring(sys.fn_sqlvarbasetostr(@IDRRef),3,32);
SET @guid = substring(@guid,25,8) 
  + '-' +  substring(@guid,21,4) + '-' +   substring(@guid,17,4) 
  + '-' +   substring(@guid,1,4) + '-' +  substring(@guid,5,12);
 
-- get datetime from guid
DECLARE @combinedString NVARCHAR(16) = SUBSTRING(@guid, 15, 4) + SUBSTRING(@guid, 10, 4)  + SUBSTRING(@guid, 1, 8);
DECLARE @stringWithoutFirstChar NVARCHAR(15) = SUBSTRING(@combinedString, 2, LEN(@combinedString) - 1);
DECLARE @length INT = LEN(@stringWithoutFirstChar);
 DECLARE @position int = 1;
DECLARE @char NVARCHAR(1);
DECLARE @charValue REAL;
DECLARE @totalSeconds REAL = 0;
DECLARE @baseDate DateTime = '2000-01-01T00:00:00';
DECLARE @baseSeconds BIGINT = 13165977600; -- diff seconds 2000-01-01 - 1582-10-15
    WHILE @position <= @length
    BEGIN
        -- Calculate the contribution of this character to the total decimal value
        SET @totalSeconds = @totalSeconds 
			+ (CHARINDEX(SUBSTRING(@stringWithoutFirstChar, @position, 1), '0123456789abcdef') - 1)
			* POWER(CAST (16 as REAL),  CAST (@length - @position AS FLOAT));
	    SET @position = @position + 1;
    END
	SET @totalSeconds = @totalSeconds / 10000000.0;
	RETURN DATEADD(SECOND, @totalSeconds - @baseSeconds, @baseDate);
 
END
GO