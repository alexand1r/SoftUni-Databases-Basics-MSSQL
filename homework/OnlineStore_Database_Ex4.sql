create database TableRelations2

use TableRelations2

CREATE TABLE Cities (
	CityID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL
)

CREATE TABLE Customers (
	CustomerID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL,
	Birthday date NOT NULL,
	CityID int NOT NULL,
	CONSTRAINT FK_CityID FOREIGN KEY (CityID) REFERENCES Cities(CityID)
)

CREATE TABLE Orders (
	OrderID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	CustomerID int NOT NULL,
	CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
)

CREATE TABLE ItemTypes (
	ItemTypeID int Primary KEY IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL	
)

CREATE TABLE Items (
	ItemID int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Name varchar(50) NOT NULL,
	ItemTypeID int NOT NULL,
	CONSTRAINT FK_ItemTypeID FOREIGN KEY (ItemTypeID) REFERENCES ItemTypes(ItemTypeID)
)

CREATE TABLE OrderItems (
	OrderID int NOT NULL,
	ItemID int NOT NULL,
	CONSTRAINT PK_Orders_Items
	PRIMARY KEY(OrderID, ItemID),
	CONSTRAINT FK_OrderID
	FOREIGN KEY(OrderID)
	REFERENCES Orders(OrderID),
	CONSTRAINT FK_Items
	FOREIGN KEY(ItemID)
	REFERENCES Items(ItemID)
)

