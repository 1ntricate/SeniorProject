DROP PROCEDURE IF EXISTS RegisterUser;

DELIMITER //
CREATE PROCEDURE RegisterUser(
    IN pUserName varchar(20),
    IN pEmail varchar(50),
    IN pPassword varchar(60)
)
BEGIN
    DECLARE accountNumber INT;
    INSERT INTO PlayerAccount (UserName, Email, Password)
    VALUES (pUserName, pEmail, pPassword);
    SET accountNumber = LAST_INSERT_ID();
    SELECT accountNumber AS AccountNumber;
END ;
//
DELIMITER ;
