# MySQL Scriptor Container

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)

## About <a name = "about"></a>

This tool helps to automate common scripts with [MySQL Containers](https://hub.docker.com/_/mysql) without writting any command on [MySQL CLI](https://dev.mysql.com/doc/refman/8.0/en/mysql.html).

Supported tasks for the moment are:
- User creation (with grant privileges) and dropping.
- Database creating and dropping.
- Multiple `.sql` scripts execution.
- Connection testing.

This tool is util for automation and _CI/CD_ proccess since it allows run scripts on MySQL database faster and in a secure way.

## Getting Started <a name = "getting_started"></a>

To use this tool you must pull the image from [Docker Hub](https://hub.docker.com/r/jorgmassih/mysql-scriptor-container), and run a container in the **same network** as your database container, additionally you must pass the environments variables that describes what you want to achieve. 

```shell
docker run jorgmassih/mysql-scriptor-container \
    -e MYSQL_HOST='<your-database-host>' \
    -e MYSQL_PORT='<your-database-port>' \
    -e MYSQL_USER='<your-database-user>' \
    -e MYSQL_PASSWORD='<your-database-password>' \
    -e ACTION_DATABASE='create' \
    -e ACTION_DATABASE_NAME='testdb' \
    -e ACTION_USER='create' \
    -e ACTION_USER_NAME='test-user' \
    -e ACTION_USER_PASSWORD='P@ssw0rd' \
    -e ACTION_USER_ALLOWED_HOSTS='%' \
    -e ACTION_USER_GRANT_ALL='yes'
    --network <my-database-network>
```
The previous command will attempt to create a database called `testdb` and also a user called `test-user` identified by the password `P@ssw0rd` allowed to be connected from everywhere (since was set with `%`) and with all grants to that databse.

You can also write that long line in a `docker-compose` file for an elegant solution.

```yaml
---
version: '3'
services:
  msc: 
    image: jorgmassih/mysql-scriptor-container 
    container_name: mysql-client
    environment:
      - MYSQL_HOST=database
      - MYSQL_PORT=3306
      - MYSQL_USER=root
      - MYSQL_PASSWORD=root
      - ACTION_DATABASE=create
      - ACTION_DATABASE_NAME=testdb
      - ACTION_USER=create
      - ACTION_USER_NAME=test-user
      - ACTION_USER_PASSWORD=P@ssw0rd
      - ACTION_USER_ALLOWED_HOSTS=%
      - ACTION_USER_GRANT_ALL=yes
    depends_on: 
      - mysql
    networks:
      - database

  mysql:
    image: mysql:5.7
    container_name: dummy-mysql
    environment:
      - MYSQL_ROOT_PASSWORD=root
    networks:
      - database

  adminer:
    image: adminer
    depends_on: 
      - mysql
    ports:
      - 8080:8080
    networks:
      - database

networks:
  database:
```

> **Important Note**: make sure the user you are using has Privileges to Grant to other users. In the above example, the user `root` were used.

You can specify the MySQL configuration in a file and create a bind volume to the path `/etc/mysql/my.cnf` in the container. Thi configuration file must have to follow the [MySQL documentation](https://dev.mysql.com/doc/refman/8.0/en/option-files.html) for `my.cnf` file but just with the `[client]` group.

```ini
# my-config.cnf
[client]
host=database
user=jorgmassih
password=root
port=3306
protocol=tcp
```

```yml
---
version: '3'
services:
  msc: 
    image: jorgmassih/mysql-scriptor-container 
    container_name: mysql-client
    environment:
      - ACTION_DATABASE=create
      - ACTION_DATABASE_NAME=testdb
      - ACTION_USER=create
      - ACTION_USER_NAME=test-user
      - ACTION_USER_PASSWORD=P@ssw0rd
      - ACTION_USER_ALLOWED_HOSTS=%
      - ACTION_USER_GRANT_ALL=yes
    volumes: 
      - /path/to/my-config.cnf:/etc/mysql/my.cnf
    networks:
      - mysql-database-network
```

### Prerequisites

What things you need to install the software and how to install them.

```
Give examples
```

### Environmental Variables

A step by step series of examples that tell you how to get a development env running.

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo.

## Usage <a name = "usage"></a>

Add notes about how to use the system.
