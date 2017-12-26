create database TableRelations

use TableRelations

CREATE TABLE Persons (
	PersonID int NOT NULL,
	FirstName nvarchar(50) NOT NULL,
	Salary decimal(7,2) NOT NULL,
	PassportID int UNIQUE NOT NULL
)

CREATE TABLE Passports (
	PassportID int UNIQUE NOT NULL,
	PassportNumber nvarchar(50) NOT NULL
)

INSERT Persons (PersonID, FirstName, Salary, PassportID)
VALUES(1, 'Roberto', 43300.00, 102),
	  (2, 'Tom', 56100.00, 103),
	  (3, 'Yana', 60200.00, 101)

INSERT Passports (PassportID, PassportNumber)
VALUES(101, 'N34FG21B'),
	  (102, 'K65LO4R7'),
	  (103, 'ZE657QP2')

ALTER TABLE Persons
ADD PRIMARY KEY(PersonID)

ALTER TABLE Passports
ADD PRIMARY KEY(PassportID)

ALTER TABLE Persons
ADD CONSTRAINT FK_Persons_Passports
FOREIGN KEY (PassportID) REFERENCES Passports(PassportID)

/*--------------------------------------------*/

CREATE TABLE Models (
	ModelID int NOT NULL,
	Name nvarchar(50) NOT NULL,
	ManufacturerID int NOT NULL
)

CREATE TABLE Manufacturers(
	ManufacturerID int NOT NULL,
	Name nvarchar(50) NOT NULL,
	EstablishedOn date NOT NULL
)

INSERT Models(ModelID, Name, ManufacturerID)
VALUES (101, 'X1', 1),
	   (102, 'i6', 1),
	   (103, 'Model S', 2),
	   (104, 'Model X', 2),
	   (105, 'Model 3', 2),
	   (106, 'Nova', 3)

INSERT Manufacturers (ManufacturerID, Name, EstablishedOn)
VALUES (1, 'BMW', '07/03/1916'),
	   (2, 'Tesla', '01/01/2003'),
	   (3, 'Lada', '01/05/1966')
	   
ALTER TABLE Models
ADD PRIMARY KEY (ModelId)

ALTER TABLE Manufacturers
ADD PRIMARY KEY (ManufacturerID)

ALTER TABLE Models 
ADD CONSTRAINT FK_Models_Manufacturers
FOREIGN KEY (ManufacturerID) REFERENCES Manufacturers(ManufacturerID)

/*--------------------------------------------*/

CREATE TABLE Students(
	StudentID int NOT NULL,
	Name nvarchar(50) NOT NULL
)

CREATE TABLE Exams(
	ExamID int NOT NULL,
	Name nvarchar(50) NOT NULL
)

CREATE TABLE StudentsExams(
	StudentID int NOT NULL,
	ExamID int NOT NULL
)

ALTER TABLE Students
ADD PRIMARY KEY (StudentID)

ALTER TABLE Exams
ADD PRIMARY KEY (ExamID)

ALTER TABLE StudentsExams
ADD CONSTRAINT PK_Students_Exams
PRIMARY KEY (StudentID, ExamID)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_StudentID
FOREIGN KEY (StudentID) REFERENCES Students(StudentID)

ALTER TABLE StudentsExams
ADD CONSTRAINT FK_ExamID
FOREIGN KEY (ExamID) REFERENCES Exams(ExamID)

/*--------------------------------------------*/

CREATE TABLE Teachers (
	TeacherID int NOT NULL,
	Name nvarchar(50) NOT NULL,
	ManagerID int
)

INSERT Teachers (TeacherID, Name, ManagerID)
VALUES (101, 'John', NULL),
	   (102, 'Maya', 106),
	   (103, 'Silvia', 106),
	   (104, 'Ted', 105),
	   (105, 'Mark', 101),
	   (106, 'Greta', 101) 

ALTER TABLE Teachers
ADD PRIMARY KEY (TeacherID)

ALTER TABLE Teachers
ADD CONSTRAINT FK_ManagerID
FOREIGN KEY (ManagerID) REFERENCES Teachers(TeacherID)

/*--------------------------------------------*/

