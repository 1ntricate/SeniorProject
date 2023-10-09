SET foreign_key_checks = 0;

DROP TABLE IF EXISTS PlayerAccount;
DROP TABLE IF EXISTS Image;
DROP TABLE IF EXISTS GameMap;
DROP TABLE IF EXISTS GameSave;
DROP TABLE IF EXISTS Item;
DROP TABLE IF EXISTS BackUp;
DROP TABLE IF EXISTS ProcessedImageData;
DROP TABLE IF EXISTS MapUpdate;
DROP TABLE IF EXISTS Owns;
DROP TABLE IF EXISTS Composed;


CREATE TABLE PlayerAccount(
    PlayerID int not null AUTO_INCREMENT,
    UserName varchar(50) not null,
    Email varchar(50) not null,
    Plaintext varchar(60) DEFAULT NULL,
    Password varchar(60) DEFAULT NULL,
    CurrentLevel int DEFAULT  0,
    CurrentExperience int DEFAULT  0,
    Avatar LONGBLOB,
    PRIMARY KEY (PlayerID),
    UNIQUE KEY unique_email (Email)
);

CREATE TABLE Image(
    ImageID int not null AUTO_INCREMENT,
    PlayerID int not null,
    TimeStamp DATE,
    ImageData LONGBLOB,
    FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
    PRIMARY KEY (ImageID)

);

CREATE TABLE GameMap(
    MapID int not null AUTO_INCREMENT,
    ImageID int,
    DataID int,
    Resources varchar(50),
    MapVersion double precision DEFAULT 1.0,
    MapData LONGBLOB,
    FOREIGN KEY (ImageID) REFERENCES Image(ImageID),
    FOREIGN KEY (DataID) REFERENCES ProcessedImageData(DataID),
    PRIMARY KEY (MapID)
);

CREATE TABLE GameSave(
    ProgressID int not null AUTO_INCREMENT,
    PlayerID int not null,
    TimePlayed int DEFAULT  0,
    ProgressData LONGBLOB,
    FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
    PRIMARY KEY (ProgressID)
);


CREATE TABLE Item(
    ItemID int not null AUTO_INCREMENT,
    ItemName varchar(50),
    Rarity int DEFAULT 0,
    ItemDescription varchar(50),
    PRIMARY KEY (ItemID)
);

CREATE TABLE BackUp(
    RecoveryID int not null AUTO_INCREMENT,
    PlayerID int not null,
    ProgressID int not null,
    BackUpData LONGBLOB,
    TimeStamp DATE,
    FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID),
    FOREIGN KEY (ProgressID) REFERENCES GameSave(ProgressID),
    PRIMARY KEY (RecoveryID)
);

CREATE TABLE ProcessedImageData(
    DataID int not null AUTO_INCREMENT,
    ImageID int not null,
    ImageData LONGBLOB,
    TimeStamp Date,
    FOREIGN KEY (ImageID) REFERENCES Image(ImageID),
    PRIMARY KEY (DataID)

);

CREATE TABLE MapUpdate(
    UpdateID int not null AUTO_INCREMENT,
    MapID int not null,
    UpdateData LONGBLOB,
    TimeStamp Date,
    FOREIGN KEY (MapID) REFERENCES GameMap(MapID),
    PRIMARY KEY (UpdateID)
);

-- Keeps track of items owned by players
CREATE TABLE Owns(
    ItemID int not null,
    PlayerID int not null,
    ItemQuantity int not null DEFAULT 1,
    FOREIGN KEY (ItemID) REFERENCES Item(ItemID),
    FOREIGN KEY (PlayerID) REFERENCES PlayerAccount(PlayerID),
    PRIMARY KEY (ItemID, PlayerID)
);

-- tracks of images/processed image data used in maps
CREATE TABLE Composed(
    MapID int not null,
    DataID int not null,
    ImageID int not null,
    FOREIGN KEY (MapID) REFERENCES GameMap(MapID),
    FOREIGN KEY (DataID) REFERENCES ProcessedImageData(DataID),
    FOREIGN KEY (ImageID) REFERENCES Image(ImageID),
    PRIMARY KEY (MapID, DataID, ImageID)
);

SET foreign_key_checks = 1;