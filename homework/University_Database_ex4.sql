CREATE TABLE Majors (
	MajorID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL
)

CREATE TABLE Students (
	StudentID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	StudenNumber int NOT NULL,
	StudentName varchar(50) NOT NULL,
	MajorID int NOT NULL,
	CONSTRAINT FK_MajorID
	FOREIGN KEY (MajorID) REFERENCES Majors(MajorID)
)

CREATE TABLE Payments (
	PaymentID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	PaymentDate date NOT NULL,
	PaymentAmount decimal(10,2) NOT NULL,
	StudentID int,
	CONSTRAINT FK_StudentID
	FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
)

CREATE TABLE Subjects (
	SubjectID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	SubjectName varchar(50) NOT NULL
)

CREATE TABLE Agenda (
	StudentID int NOT NULL,
	SubjectID int NOT NULL,
	CONSTRAINT PK_Students_Subjects
	PRIMARY KEY (StudentID, SubjectID),
	CONSTRAINT FK_StudentID_Agenda
	FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
	CONSTRAINT FK_SubjectID
	FOREIGN KEY (SubjectID) REFERENCES Subjects(SubjectID)
)

