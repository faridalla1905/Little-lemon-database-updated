DROP DATABASE IF EXISTS LittleLemonDB;
CREATE DATABASE LittleLemonDB;
USE LittleLemonDB;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100)
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2)
);

CREATE TABLE MenuItems (
    MenuItemID INT PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    StarterName VARCHAR(100),
    DessertName VARCHAR(100),
    DrinkName VARCHAR(100),
    Price DECIMAL(10,2) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    Quantity INT NOT NULL,
    TotalCost DECIMAL(10,2) NOT NULL,
    CustomerID INT NOT NULL,
    MenuItemID INT NOT NULL,
    CONSTRAINT fk_orders_customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT fk_orders_menuitems
        FOREIGN KEY (MenuItemID) REFERENCES MenuItems(MenuItemID)
);

CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY,
    BookingDate DATE NOT NULL,
    TableNumber INT NOT NULL,
    CustomerID INT NOT NULL,
    StaffID INT,
    CONSTRAINT uq_booking_table_date UNIQUE (BookingDate, TableNumber),
    CONSTRAINT fk_bookings_customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT fk_bookings_staff
        FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

INSERT INTO Customers (CustomerID, FullName, PhoneNumber, Email) VALUES
(1, 'Anna Iversen', '111-111-1111', 'anna@example.com'),
(2, 'Joakim Iversen', '222-222-2222', 'joakim@example.com'),
(3, 'Vanessa McCarthy', '333-333-3333', 'vanessa@example.com'),
(99, 'Python Client Customer', '999-999-9999', 'customer99@example.com');

INSERT INTO Staff (StaffID, FullName, Role, Salary) VALUES
(1, 'Mario Gollini', 'Manager', 70000.00),
(2, 'Adrian Gollini', 'Assistant Manager', 55000.00);

INSERT INTO MenuItems
(MenuItemID, CourseName, StarterName, DessertName, DrinkName, Price) VALUES
(1, 'Greek Salad', 'Olives', 'Greek Yogurt', 'Athens White Wine', 25.00),
(2, 'Bean Soup', 'Flatbread', 'Ice Cream', 'Italian Coffee', 18.00),
(3, 'Pizza', 'Minestrone', 'Cheesecake', 'Mineral Water', 22.00);

INSERT INTO Orders
(OrderID, OrderDate, Quantity, TotalCost, CustomerID, MenuItemID) VALUES
(1, '2022-10-10', 2, 50.00, 1, 1),
(2, '2022-10-11', 3, 54.00, 2, 2),
(3, '2022-10-12', 5, 110.00, 3, 3);

INSERT INTO Bookings
(BookingID, BookingDate, TableNumber, CustomerID, StaffID) VALUES
(1, '2022-12-10', 5, 1, 1),
(2, '2022-12-11', 3, 2, 2);

DROP PROCEDURE IF EXISTS GetMaxQuantity;
DROP PROCEDURE IF EXISTS ManageBooking;
DROP PROCEDURE IF EXISTS AddBooking;
DROP PROCEDURE IF EXISTS UpdateBooking;
DROP PROCEDURE IF EXISTS CancelBooking;

DELIMITER $$

CREATE PROCEDURE GetMaxQuantity()
BEGIN
    SELECT MAX(Quantity) AS `Max Quantity in Order`
    FROM Orders;
END$$

CREATE PROCEDURE ManageBooking(
    IN p_BookingDate DATE,
    IN p_TableNumber INT
)
BEGIN
    DECLARE v_BookingID INT;

    IF EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingDate = p_BookingDate
          AND TableNumber = p_TableNumber
    ) THEN
        SELECT CONCAT(
            'Table ', p_TableNumber,
            ' is already booked on ', DATE_FORMAT(p_BookingDate, '%Y-%m-%d'), '.'
        ) AS `Booking status`;
    ELSE
        SELECT COALESCE(MAX(BookingID), 0) + 1
        INTO v_BookingID
        FROM Bookings;

        INSERT INTO Bookings
            (BookingID, BookingDate, TableNumber, CustomerID, StaffID)
        VALUES
            (v_BookingID, p_BookingDate, p_TableNumber, 1, 1);

        SELECT CONCAT(
            'Table ', p_TableNumber,
            ' was booked successfully for ', DATE_FORMAT(p_BookingDate, '%Y-%m-%d'), '.'
        ) AS `Booking status`;
    END IF;
END$$

CREATE PROCEDURE AddBooking(
    IN p_BookingID INT,
    IN p_CustomerID INT,
    IN p_TableNumber INT,
    IN p_BookingDate DATE
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingID = p_BookingID
    ) THEN
        SELECT CONCAT(
            'Booking ', p_BookingID, ' already exists.'
        ) AS `Confirmation`;
    ELSEIF EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingDate = p_BookingDate
          AND TableNumber = p_TableNumber
    ) THEN
        SELECT CONCAT(
            'Table ', p_TableNumber,
            ' is already booked on ', DATE_FORMAT(p_BookingDate, '%Y-%m-%d'), '.'
        ) AS `Confirmation`;
    ELSE
        INSERT INTO Bookings
            (BookingID, BookingDate, TableNumber, CustomerID, StaffID)
        VALUES
            (p_BookingID, p_BookingDate, p_TableNumber, p_CustomerID, NULL);

        SELECT CONCAT(
            'New booking ', p_BookingID, ' added successfully.'
        ) AS `Confirmation`;
    END IF;
END$$

CREATE PROCEDURE UpdateBooking(
    IN p_BookingID INT,
    IN p_NewBookingDate DATE
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingID = p_BookingID
    ) THEN
        UPDATE Bookings
        SET BookingDate = p_NewBookingDate
        WHERE BookingID = p_BookingID;

        SELECT CONCAT(
            'Booking ', p_BookingID, ' updated successfully.'
        ) AS `Confirmation`;
    ELSE
        SELECT CONCAT(
            'Booking ', p_BookingID, ' does not exist.'
        ) AS `Confirmation`;
    END IF;
END$$

CREATE PROCEDURE CancelBooking(
    IN p_BookingID INT
)
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Bookings
        WHERE BookingID = p_BookingID
    ) THEN
        DELETE FROM Bookings
        WHERE BookingID = p_BookingID;

        SELECT CONCAT(
            'Booking ', p_BookingID, ' cancelled successfully.'
        ) AS `Confirmation`;
    ELSE
        SELECT CONCAT(
            'Booking ', p_BookingID, ' does not exist.'
        ) AS `Confirmation`;
    END IF;
END$$

DELIMITER ;

CALL GetMaxQuantity();

CALL ManageBooking('2022-12-12', 8);
CALL ManageBooking('2022-12-10', 5);

CALL AddBooking(99, 99, 99, '2022-12-10');
CALL UpdateBooking(99, '2022-01-10');
CALL CancelBooking(99);
