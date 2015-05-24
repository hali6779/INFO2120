/*
 * INFo2120 / INFO2820
 * Database Systems I
 *
 * Reference Schema for INFO2120/2820 Assignment - Car-Sharing Database
 * version 2.2
 *
 * PostgreSQL version...
 *
 * IMPORTANT!
 * You need to replace <your-login> with your PostgreSQL user name in line 247
 * of this file (the ALTER USER  command)
 */

/* clean-up to make script idempotent */
BEGIN TRANSACTION;
SET search_Path = CarSharing, '$user', public, unidb;
DROP TABLE IF EXISTS TripLog;
DROP TABLE IF EXISTS Computer;
DROP TABLE IF EXISTS Rating;
DROP TABLE IF EXISTS Review;
DROP TABLE IF EXISTS InvoiceLine;  /* new for invoicing extension */
DROP TABLE IF EXISTS Invoice;      /* new for invoicing extension */
DROP TABLE IF EXISTS Booking;
DROP TABLE IF EXISTS Car;
DROP TABLE IF EXISTS CarModel;
DROP TABLE IF EXISTS MemberStats;  /* new */
DROP TABLE IF EXISTS Member;
DROP TABLE IF EXISTS Pod;
DROP TABLE IF EXISTS Location;
DROP TABLE IF EXISTS CompanyAccount;
DROP TABLE IF EXISTS PrivateAccount;
DROP TABLE IF EXISTS PaymentMethod;
DROP TABLE IF EXISTS Account;
DROP TABLE IF EXISTS MembershipPlan;
DROP DOMAIN IF EXISTS CarRegType;
DROP DOMAIN IF EXISTS AmountInCents;
DROP DOMAIN IF EXISTS RatingDomain;
DROP SCHEMA IF EXISTS CarSharing CASCADE;
COMMIT;


/* let's go */
CREATE SCHEMA CarSharing;

/* this line will ensure that all following CREATE statements use the CarSharing schema */
/* it assumes that you have loaded our unidb schema from tutorial in week 6             */
SET search_Path = CarSharing, '$user', public, unidb;

/* we will keep all monetary data as integer values representing cents */
CREATE DOMAIN AmountInCents AS INTEGER CHECK (VALUE >= 0);
/* for car registrations; */
/* Could check along lines of http://abitsmart.com/2010/02/validating-an-australian-drivers-license-number-using-regex/ */
CREATE DOMAIN CarRegType AS CHAR(6);
/* for ratings */
CREATE DOMAIN RatingDomain AS SMALLINT CHECK ( VALUE BETWEEN 1 AND 5 );


CREATE TABLE MembershipPlan ( /* Note that all fees are in CENTS! */
   title         VARCHAR(20)   PRIMARY KEY,
   monthly_fee   AmountInCents NOT NULL, -- in cents!
   hourly_rate   AmountInCents NOT NULL, -- in cents!
   km_rate       AmountInCents NOT NULL, -- in cents!
   daily_rate    AmountInCents NOT NULL, -- in cents! for rents >= 12h, take this rate
   daily_km_rate AmountInCents NOT NULL, -- in cents! for rents >= 12h, km rate is reduced
   daily_km_included INTEGER   NOT NULL  --           for rents >= 12h, some km are free
);

CREATE TABLE Account (
   accountNo INTEGER     PRIMARY KEY,
   name      VARCHAR(50) NOT NULL,
   since     DATE        DEFAULT CURRENT_DATE,
   plan      VARCHAR(20) NOT NULL REFERENCES MembershipPlan ON DELETE RESTRICT
);

CREATE TABLE PrivateAccount (
   accountNo INTEGER PRIMARY KEY REFERENCES Account ON DELETE CASCADE,
   address   VARCHAR(200) NOT NULL,
   category  VARCHAR(10)  NOT NULL DEFAULT 'novice',
   walkscore INTEGER,
   CONSTRAINT category_CHK CHECK (category IN ('novice', 'veteran'))
);

CREATE TABLE CompanyAccount (
   accountNo INTEGER PRIMARY KEY REFERENCES Account ON DELETE CASCADE,
   abn       VARCHAR(11) NOT NULL UNIQUE,
   gst       REAL        NOT NULL
);

CREATE TABLE PaymentMethod (
   accountNo       INTEGER REFERENCES Account On DELETE CASCADE,
   nr              SMALLINT,
   preferred       CHAR,
   payType         VARCHAR(6) NOT NULL, -- how do we pay
   acctName        VARCHAR(50),         -- either account name, or CC holder name, or paypal account name
   acctNumber      INTEGER,             -- either account nr, or CC nr
   acctBSB         INTEGER,             -- only set for bank accounts
   expires         VARCHAR(5),          -- only set for credit cards
   PRIMARY KEY (accountNo, nr),
   CONSTRAINT preferred_CHK CHECK (preferred IN ('Y','N')),
   CONSTRAINT payType_CHK   CHECK (payType IN ('visa','master','amex','paypal','bank'))
);

CREATE TABLE Location (
   id        INTEGER     PRIMARY KEY,
   name      VARCHAR(80) NOT NULL,
   type      VARCHAR(10) NOT NULL,
   partOf    INTEGER     NULL REFERENCES Location,
   CONSTRAINT location_KEY UNIQUE(name, partOf),
   CONSTRAINT location_CHK CHECK (type IN ('suburb','area','region','city','state','country'))
);

CREATE TABLE Pod (
   id        INTEGER     PRIMARY KEY,
   name      VARCHAR(80) NOT NULL UNIQUE,
   addr      VARCHAR(200),
   descr     TEXT,
   longitude FLOAT,
   latitude  FLOAT,
   mapURL    VARCHAR(200), -- this wasn't asked, but we have some data for it
   walkscore INTEGER,      -- this wasn't asked, but cool to have, cf. www.walkscore.com
   isAt      INTEGER NOT NULL REFERENCES Location ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Member (
   memberNo   INTEGER      PRIMARY KEY,
   accountNo  INTEGER      NOT NULL REFERENCES Account ON DELETE CASCADE,
   passwd     VARCHAR(20)  NOT NULL, -- better store just a hash value of the password
   pw_salt    VARCHAR(10)  NOT NULL, -- newly added for better security
   title      VARCHAR(10)  NOT NULL,
   givenName  VARCHAR(50)  NOT NULL,
   familyName VARCHAR(50)  NOT NULL,
   nickName   VARCHAR(10)  UNIQUE NOT NULL, -- we require a nickname from everyone, good to be used for login
   address    VARCHAR(200) NOT NULL,
   birthdate  DATE,
   licenseNr  BIGINT       NOT NULL UNIQUE,
   expires    DATE         NOT NULL,
   homePod    INTEGER      NULL REFERENCES Pod,
   CONSTRAINT title_CHK CHECK (title IN ('Mr','Mrs','Ms','Dr','Prof'))
);

CREATE TABLE MemberStats ( /* new - to have something to play with on your Home Page */
   memberNo          INTEGER PRIMARY KEY REFERENCES Member ON DELETE CASCADE,
   stat_since        DATE    DEFAULT CURRENT_DATE,
   stat_nrOfBookings INTEGER DEFAULT 0,
   stat_sumPayments  INTEGER DEFAULT 0, -- in cents
   stat_nrOfReviews  INTEGER DEFAULT 0
);

CREATE TABLE CarModel (
   make      VARCHAR(20),
   model     VARCHAR(20),
   category  VARCHAR(8)  NOT NULL,
   capacity  INTEGER,
   PRIMARY KEY (make, model),
   CONSTRAINT carCategory_CHK  CHECK (category IN ('hatch','sedan','wagon','ute','van','minivan'))
);
CREATE TABLE Car (
   regno        CarRegType  PRIMARY KEY,
   name         VARCHAR(40) NOT NULL UNIQUE,
   make         VARCHAR(20) NOT NULL,
   model        VARCHAR(20) NOT NULL,
   year         INTEGER,
   transmission VARCHAR(6),
   parkedAt     INTEGER     REFERENCES Pod,
   FOREIGN KEY (make,model) REFERENCES CarModel
);

CREATE TABLE Booking (
   id          SERIAL     PRIMARY KEY,  -- automatic increased integer ID
   car         CarRegType NOT NULL REFERENCES Car,
   madeBy      INTEGER    NOT NULL REFERENCES Member,
   whenBooked  TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
   status      VARCHAR(8),
   startTime   TIMESTAMP  NOT NULL, -- start time is inclusive
   endTime     TIMESTAMP  NOT NULL, -- exclusive; booked time is the closed-open interval [startTime, endTime)
   CONSTRAINT bookingCandidateKey UNIQUE(car, whenBooked),
   CONSTRAINT bookingStatus_CHK  CHECK(status IN ('ok','active','canceled')),
   CONSTRAINT bookingIsValid_CHK CHECK(endTime > startTime)
);

CREATE TABLE Review (
   memberNo INTEGER    REFERENCES Member,
   regno    CarRegType REFERENCES Car,
   whenDone DATE       DEFAULT CURRENT_DATE,
   rating   RatingDomain,
   description VARCHAR(500),
   PRIMARY KEY (memberNo, regno)
);
CREATE TABLE Rating (
   memberNo   INTEGER      NOT NULL REFERENCES Member,
   reviewMem  INTEGER      NOT NULL,
   reviewCar  CarRegType   NOT NULL,
   useful     RatingDomain NOT NULL,
   whenDone   DATE         DEFAULT CURRENT_DATE,
   PRIMARY KEY (reviewMem, reviewCar, memberNo),
   FOREIGN KEY (reviewMem, reviewCar) REFERENCES Review
);

/* 
 * Extension: Invoicing (option 3 for for D-level submissions)
 */
CREATE TABLE Invoice (
   account     INTEGER NOT NULL REFERENCES Account ON DELETE RESTRICT,
   invoiceNo   INTEGER NOT NULL,
   invoiceDate DATE,
   monthlyFee  AmountInCents,     -- in cents
   totalAmount AmountInCents,     -- in cents
   PRIMARY KEY (account, invoiceNo)
);
CREATE TABLE InvoiceLine (
   account     INTEGER       NOT NULL,
   invoiceNo   INTEGER       NOT NULL,
   bookingId   INTEGER       NOT NULL REFERENCES Booking,
   distance    INTEGER,
   duration    INTEGER,
   timeCharge  AmountInCents NOT NULL,     -- in cents, charge for duration
   kmCharge    AmountInCents NOT NULL,     -- in cents, charge for distrance
   feeCharge   AmountInCents NOT NULL,     -- in cents, any late penalty etc
   FOREIGN KEY (account, invoiceNo) REFERENCES Invoice ON DELETE CASCADE,
   PRIMARY KEY (account, invoiceNo, bookingId)
);

CREATE TABLE Computer (
   id          INTEGER    PRIMARY KEY,
   installedIn CarRegType REFERENCES Car
);
CREATE TABLE TripLog (
   computer    INTEGER    REFERENCES Computer,
   tripNo      INTEGER,
   car         CarRegType NOT NULL REFERENCES Car,
   driver      INTEGER    NOT NULL REFERENCES Member,
   startTime   TIMESTAMP  NOT NULL, -- start time is inclusive
   endTime     TIMESTAMP  NOT NULL, -- exclusive; actual trip time is the closed-open interval [startTime, endTime)
   startOdo    INTEGER    NULL,     -- in actual data set can be NULL???
   distance    INTEGER    NOT NULL,  -- in km
   PRIMARY KEY (computer, tripNo)
);
/* end schema definition */


/* IMPORTANT TODO: */
/* please replace <your-login> with the name of your PostgreSQL login */
/* in the following ALTER USER username SET search_path ... command   */
/* this ensures that the carsharing schema is automatically used when you query one of its tables */
/* it assumes that you have loaded our unidb schema from tutorial in week 6             */
ALTER USER wbae1633 SET search_Path = '$user', public, unidb, carsharing;



