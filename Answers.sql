CREATE DATABASE IF NOT EXISTS bookstore;
USE bookstore;

-- Table: author
CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Table: book_language
CREATE TABLE book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    language_name VARCHAR(50)
);

-- Table: publisher
CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100)
);

-- Table: book
CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    language_id INT,
    publisher_id INT,
    FOREIGN KEY (language_id) REFERENCES book_language(language_id),
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
);

-- Table: book_author (many-to-many between book and author)
CREATE TABLE book_author (
    book_id INT,
    author_id INT,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (author_id) REFERENCES author(author_id)
);


CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(150) UNIQUE
);

-- Parent table must be created first because:
-- 1. Foreign keys can only reference existing tables
-- 2. The database needs to verify the referenced column exists during creation
-- 3. This establishes the "one" side of the one-to-many relationship
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100)
);

-- Child table contains the foreign key constraint
-- This creates the "many" side of the relationship (many addresses per country)
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    street VARCHAR(255),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- Create status lookup table first
CREATE TABLE address_status (
    address_status_id INT AUTO_INCREMENT PRIMARY KEY,  -- Note the column name
    status_name VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

-- Create junction table with proper foreign keys
CREATE TABLE customer_address (
    customer_id INT,
    address_id INT,
    address_status_id INT,
    PRIMARY KEY (customer_id, address_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (address_status_id) REFERENCES address_status(address_status_id)  -- Fixed column reference
);

-- Add index for better queries on status
CREATE INDEX idx_status ON customer_address(address_status_id);

-- Table: shipping_method
CREATE TABLE shipping_method (
    method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    delivery_time_days INT
);

-- Table: order_status
CREATE TABLE order_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

-- Table: cust_order
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    customer_id INT NOT NULL,
    shipping_address_id INT NOT NULL,
    shipping_method_id INT,
    order_total DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (shipping_address_id) REFERENCES address(address_id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_method(method_id)
);

-- Table: order_line
CREATE TABLE order_line (
    line_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id)
);

-- Table: order_history
CREATE TABLE order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status_id INT NOT NULL,
    status_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (status_id) REFERENCES order_status(status_id)
);

-- Insert countries into the 'country' table
-- If a country already exists (based on a unique key or primary key), update its name
INSERT INTO country (country_name) 
VALUES ('France'), ('Kenya'), ('Spain')
ON DUPLICATE KEY UPDATE country_name = NEW.country_name; -- Update the country_name if a duplicate key is found


-- Insert countries into the 'country' table
-- If a country already exists (based on a unique key or primary key), update its name
INSERT INTO country (country_name) 
VALUES ('France'), ('Kenya'), ('Spain')
ON DUPLICATE KEY UPDATE country_name = NEW.country_name; -- Update the country_name if a duplicate key is found


-- Insert addresses into the 'address' table
-- Use a subquery to get the country_id for each address based on the country_name
INSERT INTO address (street, city, postal_code, country_id)
VALUES 
    -- Insert an address in France
    ('39 Rue Vincent Scotto', 'Tarbes', '', 
     (SELECT country_id FROM country WHERE country_name = 'France')),
    
    -- Insert an address in Kenya
    ('40 Haille Sellasie Avenue', 'Nairobi', '', 
     (SELECT country_id FROM country WHERE country_name = 'Kenya')),
    
    -- Insert an address in Spain
    ('1 Rue De Barcelona', 'Barcelona', '', 
     (SELECT country_id FROM country WHERE country_name = 'Spain'));


     -- Insert customers into the 'customer' table
-- Each customer has a first name, last name, and a unique email address
INSERT INTO customer (first_name, last_name, email)
VALUES
    -- Insert a customer named Louay Hamdache
    ('Louay', 'Hamdache', 'louay@gmail.com'),
    
    -- Insert a customer named Leo Penuela
    ('Leo', 'Penuela', 'leo@gmail.com'),
    
    -- Insert a customer named George Saitoti
    ('George', 'Saitoti', 'george@gmail.com');


        -- First, retrieve the address_status_id for the 'current' status
    -- This assumes that the 'current' status already exists in the address_status table
    SET @current_status = (SELECT address_status_id FROM address_status WHERE status_name = 'current');
    
    -- Link customers to their respective addresses in the 'customer_address' table
    -- Use subqueries to fetch the customer_id and address_id dynamically
    INSERT INTO customer_address (customer_id, address_id, address_status_id)
    VALUES
        -- Link Louay Hamdache to the address on Rue Vincent Scotto
        ((SELECT customer_id FROM customer WHERE first_name = 'Louay' AND last_name = 'Hamdache'),
         (SELECT address_id FROM address WHERE street LIKE '%Vincent Scotto%'), @current_status),
         
        -- Link Leo Penuela to the address on Haille Sellasie Avenue
        ((SELECT customer_id FROM customer WHERE first_name = 'Leo' AND last_name = 'Penuela'),
         (SELECT address_id FROM address WHERE street LIKE '%Haille Sellasie%'), @current_status),
         
        -- Link George Saitoti to the address on Rue De Barcelona
        ((SELECT customer_id FROM customer WHERE first_name = 'George' AND last_name = 'Saitoti'),
         (SELECT address_id FROM address WHERE street LIKE '%Barcelona%'), @current_status);

--Inserting address statuses into the 'address_status' table after  finding zero (this had not been include)
         INSERT INTO address_status (status_name, description)
VALUES ('current', 'Primary address'), ('old', 'Previous address');



-- Option A: Update existing records instead of inserting (found an error of duplicate entries e.tc)
UPDATE customer_address 
SET address_status_id = @current_status 
WHERE customer_id = 1 AND address_id = 1;

-- For customer 2, update the address status to 'current'
UPDATE customer_address 
SET address_status_id = @current_status 
WHERE customer_id = 2 AND address_id = 2;

-- For customer 3, update the address status to 'current'
UPDATE customer_address 
SET address_status_id = @current_status 
WHERE customer_id = 3 AND address_id = 3;

-- Insert sample publishers into the 'publisher' table
-- Each publisher has a unique name
INSERT INTO publisher (publisher_name) VALUES 
    -- Insert the publisher 'Longhorn Publishers'
    ('Longhorn Publishers'), 
    
    -- Insert the publisher 'Butere Girls'
    ('Butere Girls'), 
    
    -- Insert the publisher 'Story Moja'
    ('Story Moja');

    -- Insert book languages into the 'book_language' table
-- Each language has a unique name
INSERT INTO book_language (language_name) VALUES 
    -- Insert the language 'Swahili'
    ('Swahili'), 
    
    -- Insert the language 'English'
    ('English'), 
    
    -- Insert the language 'French'
    ('French');

    -- Insert authors into the 'author' table
-- Each author has a unique name
INSERT INTO author (name) VALUES 
    -- Insert the author 'Alifa Chokocho'
    ('Alifa Chokocho'), 
    
    -- Insert the author 'Cleophas Malala'
    ('Cleophas Malala'), 
    
    -- Insert the author 'Pauline Kea'
    ('Pauline Kea');
    
    -- Insert sample books into the 'book' table
-- Each book has a title, a language ID, and a publisher ID
INSERT INTO book (title, language_id, publisher_id) VALUES 
    -- Insert the book 'Tumbolisiloshiba' with language ID 1 and publisher ID 1
    ('Tumbolisiloshiba', 1, 1), 
    
    -- Insert the book 'Echoes of War' with language ID 1 and publisher ID 2
    ('Echoes of War', 1, 2), 
    
    -- Insert the book 'Kigogo' with language ID 1 and publisher ID 3
    ('Kigogo', 1, 3);

    -- Link books to authors in the 'book_author' table
-- Each entry links a book to an author using their respective IDs
INSERT INTO book_author (book_id, author_id) VALUES 
    -- Link the book with ID 1 to the author with ID 1
    (1, 1), 
    
    -- Link the book with ID 2 to the author with ID 2
    (2, 2), 
    
    -- Link the book with ID 3 to the author with ID 3
    (3, 3);

    -- Insert shipping methods into the 'shipping_method' table
-- Each shipping method has a name, cost, and delivery time in days
INSERT INTO shipping_method (method_name, cost, delivery_time_days) VALUES 
    -- Insert the 'Standard' shipping method with a cost of 5.99 and delivery time of 5 days
    ('Standard', 5.99, 5), 
    
    -- Insert the 'Express' shipping method with a cost of 12.99 and delivery time of 2 days
    ('Express', 12.99, 2), 
    
    -- Insert the 'International' shipping method with a cost of 24.99 and delivery time of 10 days
    ('International', 24.99, 10);


    -- Insert order statuses into the 'order_status' table
-- Each status has a unique name and a description
INSERT INTO order_status (status_name, description) VALUES 
    -- Insert the 'Pending' status with a description
    ('Pending', 'Order received but not processed'), 
    
    -- Insert the 'Processing' status with a description
    ('Processing', 'Order is being prepared for shipment'), 
    
    -- Insert the 'Shipped' status with a description
    ('Shipped', 'Order has been dispatched'), 
    
    -- Insert the 'Delivered' status with a description
    ('Delivered', 'Order has been delivered to customer');

    -- Insert sample orders into the 'cust_order' table
-- Each order includes a customer ID, shipping address ID, shipping method ID, and the total order amount
INSERT INTO cust_order (customer_id, shipping_address_id, shipping_method_id, order_total) VALUES 
    -- Insert an order for customer ID 1 with shipping address ID 1, shipping method ID 1, and a total of 29.98
    (1, 1, 1, 29.98), 
    
    -- Insert an order for customer ID 2 with shipping address ID 2, shipping method ID 2, and a total of 19.99
    (2, 2, 2, 19.99), 
    
    -- Insert an order for customer ID 3 with shipping address ID 3, shipping method ID 3, and a total of 49.97
    (3, 3, 3, 49.97);

    -- Insert order history into the 'order_history' table
-- Each entry includes an order ID, status ID, and notes about the order's progress
INSERT INTO order_history (order_id, status_id, notes) VALUES 
    -- Record the 'New order received' status for order ID 1
    (1, 1, 'New order received'), 
    
    -- Record the 'Processing order' status for order ID 1
    (1, 2, 'Processing order'), 
    
    -- Record the 'New order received' status for order ID 2
    (2, 1, 'New order received'), 
    
    -- Record the 'New order received' status for order ID 3
    (3, 1, 'New order received');

    -- Query: Retrieve all books written by a specific author
-- This query tests the relationship between the 'book', 'author', and 'book_author' tables
SELECT 
    b.title AS book_title, 
    a.name AS author_name
FROM 
    book b
JOIN 
    book_author ba ON b.book_id = ba.book_id
JOIN 
    author a ON ba.author_id = a.author_id
WHERE 
    a.name = 'Alifa Chokocho';

-- Query: Retrieve the order history for a specific customer
-- This query tests the relationships between 'customer', 'cust_order', 'order_line', 'book', 'order_history', and 'order_status' tables
SELECT 
    c.first_name AS customer_first_name, 
    c.last_name AS customer_last_name, 
    o.order_id, 
    o.order_date, 
    os.status_name AS order_status, 
    ol.quantity AS book_quantity, 
    b.title AS book_title
FROM 
    customer c
JOIN 
    cust_order o ON c.customer_id = o.customer_id
JOIN 
    order_line ol ON o.order_id = ol.order_id
JOIN 
    book b ON ol.book_id = b.book_id
JOIN 
    order_history oh ON o.order_id = oh.order_id
JOIN 
    order_status os ON oh.status_id = os.status_id
WHERE 
    c.customer_id = 1;
   -- Query: Calculate the total sales by each customer
-- This query tests the relationship between 'customer' and 'cust_order' tables
SELECT 
    c.first_name AS customer_first_name, 
    c.last_name AS customer_last_name, 
    SUM(o.order_total) AS total_spent
FROM 
    customer c
JOIN 
    cust_order o ON c.customer_id = o.customer_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name;

    -- Create an admin user with full privileges on the 'bookstore' database
CREATE USER 'bookstore_admin'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON bookstore.* TO 'bookstore_admin'@'localhost';

-- Create a read-only user for generating reports
CREATE USER 'bookstore_report'@'localhost' IDENTIFIED BY 'readonly_pass';
GRANT SELECT ON bookstore.* TO 'bookstore_report'@'localhost';

-- Apply the changes to ensure permissions are updated
FLUSH PRIVILEGES;


-- Comprehensive Guide to Database Testing and Validation
-- Step 1: Verifying Foreign Key Relationships

-- Test Case 1: Attempt to insert an order with a non-existent customer_id
-- This should fail because the customer_id 999 does not exist in the 'customer' table
INSERT INTO cust_order (customer_id, shipping_address_id, shipping_method_id, order_total) 
VALUES (999, 1, 1, 29.99);

-- Test Case 2: Attempt to link a customer to a non-existent address_id
-- This should fail because the address_id 999 does not exist in the 'address' table
INSERT INTO customer_address (customer_id, address_id, address_status_id)
VALUES (1, 999, 1);

-- Comprehensive Guide to Database Testing and Validation
-- Step 2: Test Orphan Records Prevention

-- Test Case 1: Attempt to delete a customer who has existing orders
-- This should fail because the customer_id 1 is referenced in the 'cust_order' table
DELETE FROM customer WHERE customer_id = 1;

-- Test Case 2: Verify the ON DELETE behavior for foreign key constraints
-- This query retrieves all foreign key relationships in the 'bookstore' database
SELECT 
    TABLE_NAME AS referencing_table, 
    COLUMN_NAME AS referencing_column, 
    REFERENCED_TABLE_NAME AS referenced_table, 
    REFERENCED_COLUMN_NAME AS referenced_column
FROM 
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE 
    TABLE_SCHEMA = 'bookstore' 
    AND REFERENCED_TABLE_NAME IS NOT NULL;


    -- Comprehensive Guide to Database Testing and Validation
-- Step 3: Testing Edge Cases

-- Test Case 1: Query with impossible conditions
-- This query should return an empty result set as no book with the specified title exists
SELECT * 
FROM book 
WHERE title = 'Non-existent Book Title';

-- Test Case 2: Aggregations with no data
-- This query should return NULL as there are no records matching the specified condition
SELECT AVG(price) AS average_price 
FROM order_line 
WHERE order_id = 999;

-- Comprehensive Guide to Database Testing and Validation
-- Step 4: Invalid Data Tests

-- Test Case 1: Data type violations
-- This should fail because the title expects a string and language_id expects an integer
INSERT INTO book (title, language_id) 
VALUES (123, 'not-a-number');

-- Test Case 2: Constraint violations
-- This should fail because the email column does not allow NULL values
INSERT INTO customer (email) 
VALUES (NULL);

-- Test Case 3: Unique constraint violations
-- This should fail because the email 'louay@gmail.com' already exists in the 'customer' table
INSERT INTO customer (email) 
VALUES ('louay@gmail.com');