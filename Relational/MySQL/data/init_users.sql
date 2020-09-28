CREATE USER 'guest'@'%' IDENTIFIED BY 'guestpwd';

GRANT ALL PRIVILEGES ON employees.* TO 'guest'@'%';
