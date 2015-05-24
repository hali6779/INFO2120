*WRITTEN BY SIMON BAEG 430374115*

DROP TABLE IF EXISTS CarModel CASCADE;
DROP TABLE IF EXISTS Pod CASCADE;
DROP TABLE IF EXISTS Car CASCADE;
DROP TABLE IF EXISTS OnBoardComputer CASCADE;
DROP TABLE IF EXISTS MembershipPlan CASCADE;
DROP TABLE IF EXISTS Account CASCADE;
DROP TABLE IF EXISTS Member CASCADE;
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Trip CASCADE;
DROP TABLE IF EXISTS PaymentMethod CASCADE;
DROP TABLE IF EXISTS PrivateAccount CASCADE;
DROP TABLE IF EXISTS CompanyAccount CASCADE;

CREATE TABLE CarModel (
make 			VARCHAR(20) 		NOT NULL,
model 			VARCHAR(20) 		NOT NULL,
category		VARCHAR(20),
capacity 		SMALLINT		NOT NULL,

PRIMARY KEY (make, model)
);

CREATE TABLE Pod (
id			SMALLINT,
name			VARCHAR(40)		NOT NULL,
address			VARCHAR(50)		NOT NULL,
description		VARCHAR(50)		NOT NULL,
latitude 		numeric			NOT NULL,
longitude		numeric			NOT NULL, 
PRIMARY KEY(id)
);

CREATE TABLE CAR (
regNo 			INTEGER,		
name 			VARCHAR(20)		NOT NULL,
year 			DATE			NOT NULL,
transmission		VARCHAR(10),
make 			VARCHAR(20),		
model 			VARCHAR(30)		NOT NULL,
pod_id			INTEGER			NOT NULL,
PRIMARY KEY	(regno),
FOREIGN KEY	(make,model)	REFERENCES CarModel(make,model) ON UPDATE CASCADE,
FOREIGN KEY	(pod_id)	REFERENCES Pod(id) ON UPDATE CASCADE
);

CREATE TABLE OnBoardComputer(
id			numeric,
regNo 			INTEGER		NOT NULL,	
PRIMARY KEY(id),
FOREIGN KEY(regno)		REFERENCES Car(regno) ON UPDATE CASCADE
);

CREATE TABLE MembershipPlan(
plan			VARCHAR(10),
monthly_fee		numeric		DEFAULT 5 NOT NULL CHECK (monthly_fee > 0),
hourly_rate		numeric		DEFAULT 1 NOT NULL CHECK (hourly_rate > 0),
km_rate			numeric		DEFAULT 1 NOT NULL CHECK (km_rate > 0),
daily_rate		numeric		DEFAULT 1 NOT NULL CHECK (daily_rate > 0),
daily_km_rate		numeric		DEFAULT 1 NOT NULL CHECK (daily_km_rate > 0),
daily_km_included 	numeric		DEFAULT 1 NOT NULL CHECK (daily_km_included > 0),
PRIMARY KEY	(plan)
);

CREATE TABLE Account(
accountNo 		INTEGER,
name			VARCHAR(40)		NOT NULL,
since			DATE			NOT NULL,
plan		 	VARCHAR(10)		NOT NULL,
PRIMARY KEY	(accountNo),
FOREIGN KEY	(plan)		REFERENCES MembershipPlan(plan) ON UPDATE CASCADE
);

CREATE TABLE Member(
memberNo		INTEGER,
password		VARCHAR(20)		NOT NULL,
birthdate		DATE,
licenseNo		INTEGER			NOT NULL,
licExpiry		DATE			NOT NULL,
address			VARCHAR(50)		NOT NULL,
title			VARCHAR(10)		NOT NULL,
givenName		VARCHAR(20)		NOT NULL,
familyName		VARCHAR(20)		NOT NULL,
pod_id			INTEGER			NOT NULL,
accountNo 		INTEGER			NOT NULL,
PRIMARY KEY	(memberNo),
UNIQUE		(licenseNo,accountNo),
FOREIGN KEY	(pod_id)		REFERENCES Pod(id) ON UPDATE CASCADE,
FOREIGN KEY (accountNo)			REFERENCES Account(accountNo) ON UPDATE CASCADE
);

CREATE TABLE Review(
regNo 			INTEGER		NOT NULL,
memberNo		INTEGER			NOT NULL UNIQUE,
whenDone		TIMESTAMP,
rating			SMALLINT,
description		VARCHAR(100),
rateDate		TIMESTAMP,
rateUsefull		SMALLINT,
PRIMARY KEY 	(regno, memberNo),
FOREIGN KEY	(regno)			REFERENCES Car(regno) ON UPDATE CASCADE,
FOREIGN KEY	(memberNo)		REFERENCES Member(memberNo) ON UPDATE CASCADE
);

CREATE TABLE Booking(
id			INTEGER,
status			VARCHAR(5),
startTime		TIMESTAMP,
endTime			TIMESTAMP,
regno 			INTEGER		NOT NULL DEFAULT 1,
memberNo		INTEGER			NOT NULL DEFAULT 1,
whenBooked		TIMESTAMP,
PRIMARY KEY(id),
FOREIGN KEY(regno)		REFERENCES Car(regno) ON UPDATE CASCADE ON DELETE SET DEFAULT,
FOREIGN KEY(memberNo)		REFERENCES Member(memberNo) ON UPDATE CASCADE ON DELETE SET DEFAULT
);

CREATE TABLE Trip(
id			INTEGER,
tripNo			INTEGER,
tripDate		DATE,
startTime		TIME,
endTime			TIME,
startOdo		INTEGER,
distance		INTEGER,
regNo 			INTEGER		NOT NULL ,
memberNo		INTEGER,
PRIMARY KEY(id,tripNo),
FOREIGN KEY(regNo)		REFERENCES Car(regNo) ON UPDATE CASCADE,
FOREIGN KEY(memberNo)		REFERENCES Member(memberNo) ON UPDATE CASCADE ON DELETE SET DEFAULT,
FOREIGN KEY(id)			REFERENCES OnBoardComputer(id) ON UPDATE CASCADE ON DELETE SET DEFAULT

);
CREATE TABLE PaymentMethod(
accountNo 		INTEGER,
nr			INTEGER,
accountName		VARCHAR(20),
accountBsb		SMALLINT,
expires			DATE,
type			VARCHAR(10),
preferred		VARCHAR(10),
PRIMARY KEY(accountNo,nr),
FOREIGN KEY (accountNo) REFERENCES Account(accountNo) ON UPDATE CASCADE 
);

CREATE TABLE PrivateAccount(
address 		VARCHAR(50) 	NOT NULL,
walkscore		INTEGER,
category 		VARCHAR(50) 	NOT NULL,
accountNo		INTEGER,
PRIMARY KEY (accountNo),
FOREIGN KEY (accountNo) REFERENCES Account(accountNo) ON UPDATE CASCADE ON DELETE SET DEFAULT
);

CREATE TABLE CompanyAccount(
abn 			INTEGER 		UNIQUE ,
gst 			INTEGER 		NOT NULL,
accountNo 		INTEGER,
PRIMARY KEY (accountNo),
FOREIGN KEY (accountNo) REFERENCES Account(accountNo) ON UPDATE CASCADE ON DELETE SET DEFAULT
);











