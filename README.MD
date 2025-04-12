## Step-by-Step Instructions

1. Create a new database to store bookstore data.
2. Determine the table schema and data types.
3. Write the SQL commands to create tables that match the data structure.
4. Set up user groups and roles to control access to the database.
5. Test the database by running queries to retrieve and analyze the data.

## Tables to Be Created

Below are the key tables to design and implement for the bookstore database:

1. **book**: A list of all books available in the store.
2. **book_author**: A table to manage the many-to-many relationship between books and authors.
3. **author**: A list of all authors.
4. **book_language**: A list of the possible languages of books.
5. **publisher**: A list of publishers for books.
6. **customer**: A list of the bookstore's customers.
7. **customer_address**: A list of addresses for customers. Each customer can have multiple addresses.
8. **address_status**: A list of statuses for an address (e.g., current, old).
9. **address**: A list of all addresses in the system.
10. **country**: A list of countries where the addresses are located.
11. **cust_order**: A list of orders placed by customers.
12. **order_line**: A list of books that are part of each order.
13. **shipping_method**: A list of possible shipping methods for an order.
14. **order_history**: A record of the history of an order (e.g., ordered, cancelled, delivered).
15. **order_status**: A list of possible statuses for an order (e.g., pending, shipped, delivered).
