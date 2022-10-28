-- create databases
CREATE DATABASE IF NOT EXISTS `monarc_cli`;
CREATE DATABASE IF NOT EXISTS `monarc_common`;

-- create root user and grant rights
CREATE USER 'root'@'localhost' IDENTIFIED BY 'local';
GRANT ALL ON *.* TO 'root'@'%';
CREATE USER 'sqlmonarcuser'@'%' IDENTIFIED BY 'sqlmonarcuser';
GRANT ALL PRIVILEGES ON * . * TO 'sqlmonarcuser'@'%';
FLUSH PRIVILEGES;
