#Log in to MariaDB:
#Access the MariaDB shell as the root user:

sudo mysql -u root -p

#Create a Database:
#Inside the MariaDB shell, create a new database:

CREATE DATABASE mydatabase;

#Create a User and Grant Privileges:
#Create a user and grant access to the database:

CREATE USER 'myuser'@'%' IDENTIFIED BY 'mypassword';
GRANT ALL PRIVILEGES ON mydatabase.* TO 'myuser'@'%';
FLUSH PRIVILEGES;

EXIT;
