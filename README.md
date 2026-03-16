This project (ON-GOING) aims to create the complete website for B2C Pharmacity. The nearly-complete section right now belongs to Databases.
The project is the archive of the original database's project in HCMUT.

Author: Ngo Chi Luc, Huynh Ho Nam, Vo Truong Trinh, Ngo Minh Triet, Ngo Duc Thang

# Databases

The database's design, schema and other related is almost-complete and needs little fixes, still it is still on prototype and need refactoring hencefore.

To know more about the database's design, schema and implementation, read `Dac-ta-van-de-thiet-ke-database.docx` and `Hien-thuc-Database.docx` for more information.
`Pharmacy-EERD.drawio.png` is the Enhanced Entity Relationship Diagram for the database and `Relational-Database-Schema.drawio.png` is a schema table for implementation of database.

The set up of databases is as follow:
  1. Install MSSQL (Microsoft SQL Server)
  2. run the script `GreenLeaf-Pharm-SQL.sql` for databases installization
  3. Create username and passwords
  4. Change databases's username and password for database connection in `.env` at `Backend/`

# Server

The Server (both frontend and backend) is written in Node.js (Javascript). The server is rush upon completion so the code is messy and contain little documentations.
However "completion" in this context is to complete the HCMUT's project. The authors have been motivated to continue the development even after the course complete.

Nevertheless, it still provides basic functionallity as
  1. Login

  2. Product's page / find project you need

  3. Project's detail page
  
  4. Product's management for Admind (CRUD) (*We can not be sure if this functionality is yet brought over*)

