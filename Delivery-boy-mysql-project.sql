create database delivery_management;
use delivery_management;
create	table delivery_boy (
boy_id int	primary key auto_increment,
name	varchar(100) not null,
phone varchar(15) unique not null,
vehicle_type enum('bike' , 'scooter' , 'car') not null,
status enum('available' , 'on delivery' , 'offline') default 'available',
joining_date date not null,
created_at timestamp default current_timestamp
);
create table customer(
cust_id int primary key	auto_increment,
name varchar(100) not null,
phone varchar(15) unique not null,
address text not null,
created_at timestamp default current_timestamp
);
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    cust_id INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    delivery_address TEXT NOT NULL,
    status ENUM('Pending', 'Assigned', 'Picked Up', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    delivery_boy_id INT,
    assigned_time DATETIME,
    delivered_time DATETIME,
    FOREIGN KEY (cust_id) REFERENCES customer(cust_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_boy_id) REFERENCES delivery_boy(boy_id) ON DELETE SET NULL
);
CREATE TABLE payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT UNIQUE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    method ENUM('Cash', 'Card', 'UPI') NOT NULL,
    status ENUM('Pending', 'Completed', 'Failed') DEFAULT 'Pending',
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);
CREATE TABLE rating (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT UNIQUE NOT NULL,
    delivery_boy_id INT NOT NULL,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (delivery_boy_id) REFERENCES delivery_boy(boy_id) ON DELETE CASCADE
);
INSERT INTO delivery_boy (name, phone, vehicle_type, status, joining_date) VALUES
('Rajesh Kumar', '9876543210', 'Bike', 'Available', '2024-01-15'),
('Amit Sharma', '9876543211', 'Scooter', 'Available', '2024-02-20'),
('Vikram Singh', '9876543212', 'Car', 'On Delivery', '2024-03-01'),
('Priya Mehta', '9876543213', 'Bike', 'Offline', '2024-04-10');
INSERT INTO customer (name, phone, address) VALUES
('Suresh Gupta', '9988776655', '123, MG Road, Bangalore'),
('Anjali Nair', '9988776656', '45, Lake View, Chennai'),
('Rahul Verma', '9988776657', '78, Sector 15, Noida');
INSERT INTO orders (cust_id, total_amount, delivery_address, status, delivery_boy_id, assigned_time, delivered_time) VALUES
(1, 350.00, '123, MG Road, Bangalore', 'Delivered', 1, '2024-08-10 10:30:00', '2024-08-10 11:15:00'),
(2, 520.50, '45, Lake View, Chennai', 'Assigned', 2, '2024-08-10 12:00:00', NULL),
(3, 200.00, '78, Sector 15, Noida', 'Pending', NULL, NULL, NULL),
(1, 180.00, '123, MG Road, Bangalore', 'Delivered', 3, '2024-08-09 18:00:00', '2024-08-09 18:45:00');
INSERT INTO payment (order_id, amount, method, status) VALUES
(1, 350.00, 'UPI', 'Completed'),
(2, 520.50, 'Cash', 'Pending'),
(3, 200.00, 'Card', 'Pending'),
(4, 180.00, 'Cash', 'Completed');
INSERT INTO rating (order_id, delivery_boy_id, rating, comment) VALUES
(1, 1, 5, 'Very fast delivery!'),
(4, 3, 4, 'Good service, but a bit late.');
SELECT boy_id, name, phone, vehicle_type
FROM delivery_boy
WHERE status = 'Available';

-- Assume we assign boy_id = 2 to order_id = 3
UPDATE orders
SET delivery_boy_id = 2, status = 'Assigned', assigned_time = NOW()
WHERE order_id = 3;

UPDATE delivery_boy
SET status = 'On Delivery'
WHERE boy_id = 2;

SELECT o.order_id, c.name AS customer, o.delivery_address, o.total_amount, o.status
FROM orders o
JOIN customer c ON o.cust_id = c.cust_id
WHERE o.delivery_boy_id = 2 AND o.status IN ('Assigned', 'Picked Up');

UPDATE orders
SET status = 'Delivered', delivered_time = NOW()
WHERE order_id = 2;

UPDATE delivery_boy
SET status = 'Available'
WHERE boy_id = (SELECT delivery_boy_id FROM orders WHERE order_id = 2);

SELECT 
    db.boy_id, 
    db.name, 
    COUNT(o.order_id) AS total_deliveries,
    SUM(o.total_amount) AS total_earnings
FROM delivery_boy db
LEFT JOIN orders o ON db.boy_id = o.delivery_boy_id AND o.status = 'Delivered'
GROUP BY db.boy_id, db.name;

SELECT o.order_id, c.name AS customer, db.name AS delivery_boy, o.delivered_time
FROM orders o
JOIN customer c ON o.cust_id = c.cust_id
LEFT JOIN delivery_boy db ON o.delivery_boy_id = db.boy_id
WHERE o.status = 'Delivered' 
  AND DATE(o.delivered_time) BETWEEN '2024-08-09' AND '2024-08-10';
  
SELECT 
    db.boy_id, 
    db.name, 
    AVG(r.rating) AS avg_rating,
    COUNT(r.rating_id) AS total_ratings
FROM delivery_boy db
LEFT JOIN rating r ON db.boy_id = r.delivery_boy_id
GROUP BY db.boy_id, db.name;

DELIMITER //

CREATE PROCEDURE auto_assign_delivery_boy(IN order_id_input INT)
BEGIN
    DECLARE v_boy_id INT;

    -- Find an available delivery boy
    SELECT boy_id INTO v_boy_id
    FROM delivery_boy
    WHERE status = 'Available'
    LIMIT 1;

    -- If found, assign
    IF v_boy_id IS NOT NULL THEN
        UPDATE orders
        SET delivery_boy_id = v_boy_id, status = 'Assigned', assigned_time = NOW()
        WHERE order_id = order_id_input;

        UPDATE delivery_boy
        SET status = 'On Delivery'
        WHERE boy_id = v_boy_id;

        SELECT 'Delivery boy assigned successfully' AS message, v_boy_id AS boy_id;
    ELSE
        SELECT 'No available delivery boy found' AS message;
    END IF;
END //

DELIMITER ;

CALL auto_assign_delivery_boy(3);

DELIMITER //

CREATE TRIGGER after_order_assigned
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.delivery_boy_id IS NOT NULL AND OLD.delivery_boy_id IS NULL THEN
        UPDATE delivery_boy
        SET status = 'On Delivery'
        WHERE boy_id = NEW.delivery_boy_id;
    END IF;
END //

DELIMITER ;

CREATE VIEW pending_deliveries AS
SELECT 
    o.order_id, 
    c.name AS customer_name, 
    c.phone AS customer_phone,
    o.delivery_address,
    o.total_amount,
    o.status,
    o.assigned_time,
    db.name AS delivery_boy
FROM orders o
JOIN customer c ON o.cust_id = c.cust_id
LEFT JOIN delivery_boy db ON o.delivery_boy_id = db.boy_id
WHERE o.status IN ('Pending', 'Assigned', 'Picked Up');

SELECT * FROM pending_deliveries;

