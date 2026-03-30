# Delivery Boy Job Management System – MySQL Project

A complete MySQL database project for managing delivery boys, orders, customers, payments, and ratings. It includes tables, sample data, useful queries, a stored procedure for auto-assignment, a trigger, and a view.

## Features
- Delivery boy management (name, phone, vehicle type, availability status)
- Customer details and order history
- Order lifecycle: Pending → Assigned → Picked Up → Delivered / Cancelled
- Payment tracking (method, status)
- Customer ratings for delivery boys
- Stored procedure to auto-assign an available delivery boy to an order
- Trigger to update delivery boy status when an order is assigned
- View for pending deliveries with customer info

## Database Schema

| Table         | Description                         |
|---------------|-------------------------------------|
| delivery_boy | Delivery personnel details          |
| customer     | Customer information                |
| orders       | Order details, status, assignments  |
| payment      | Payments associated with orders     |
| rating       | Ratings given by customers          |

## Setup Instructions

1. *Prerequisites*  
   Install MySQL Server (or use XAMPP / WAMP).

2. *Import the database*  
   - Open MySQL command line or MySQL Workbench.  
   - Run the script:  
     bash
     mysql -u root -p < delivery_boy_management.sql
       
   - Or copy the entire script and execute it in your MySQL client.

3. *Explore the data*  
   - Use the sample queries provided in the script to test the system.

## Sample Queries

- List available delivery boys:  
  ```sql
  SELECT * FROM delivery_boy WHERE status = 'Available';



· Assign a delivery boy to an order (use the stored procedure):
  sql
  CALL auto_assign_delivery_boy(3);
  
· View pending deliveries (using the view):
  sql
  SELECT * FROM pending_deliveries;
  
· Calculate earnings per delivery boy:
  sql
  SELECT db.name, COUNT(o.order_id) AS deliveries, SUM(o.total_amount) AS earnings
  FROM delivery_boy db
  LEFT JOIN orders o ON db.boy_id = o.delivery_boy_id AND o.status = 'Delivered'
  GROUP BY db.boy_id;
  

How to Contribute

Feel free to fork this repository and add more features like real-time tracking, route optimization, or an admin dashboard.

License

This project is open-source and available under the MIT License.

Author

[Krishna]
