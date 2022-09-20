# MySQL Scriptor Container

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Avanced usage](#avanced_usage)
- [Built Using](#built_using)
- [Authors](#authors)
- [Contributing](#contribuiting)

## About <a name = "about"></a>

This tool helps to automate common scripts with [MySQL Containers](https://hub.docker.com/_/mysql) without writting any command on the [MySQL CLI](https://dev.mysql.com/doc/refman/8.0/en/mysql.html).

Supported tasks for the moment are:
- User creation (with grant privileges) and dropping.
- Database creating and dropping.
- Multiple `.sql` scripts execution.
- Connection testing.

This tool is also util for automation and _CI/CD_ procceses since it allows run scripts on MySQL database in a faster and secure way, without connecting directly to it.

## Getting Started <a name = "getting_started"></a>

To use this tool you must pull the image from [Docker Hub](https://hub.docker.com/r/jorgmassih/mysql-scriptor-container), and run the container in the **same network** as your database container, additionally you must pass the environments variables that describes what you want to achieve. 

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

> **Important Note**: make sure the user you are using has Privileges to Grant other users. In the above example, the user `root` were used.

### Environmental Variables

Available Environmental Variables at the moment will be listed below.

**MySQL connection variables**
| Variable Name              | Options                | Default | Description                |
|----------------------------|------------------------|---------|----------------------------|
| `MYSQL_USER`               | Any                    | root    | MySQL connection user.     |
| `MYSQL_PASSWORD`           | Any                    | _N/A_   | MySQL connection password. |
| `MYSQL_HOST`               | Any                    | mysql   | MySQL connection host.     |
| `MYSQL_PORT`               | Any number             | 3306    | MySQL connection port.     |
| `MYSQL_PROTOCOL`           | tcp,socket,pipe,memory | tcp     | MySQL connecto protocol.   |
| `MYSQL_CONNECTION_TIMEOUT` | Any number             | 5       | MySQL connection timeout.  |

**Actions variables**
| Variable Name                 | Options               | Default               | Description                                                           |
|-------------------------------|-----------------------|-----------------------|-----------------------------------------------------------------------|
| `ACTION_USER`                 | create,drop           | create                | Creates or Drops user.                                                |
| `ACTION_USER_NAME`            | any                   | _N/A_                 | Name of user to create or drop.                                       |
| `ACTION_USER_PASSWORD `       | any                   | _N/A_                 | User password (only with `create` action)                             |
| `ACTION_USER_ALLOWED_HOSTS`   | any ip direcction     | localhost             | Specify which hosts will be available to use the user.                |
| `ACTION_USER_AUTH_PLUGIN`     | mysql_native_password | mysql_native_password | Authentication plugin for connection.                                 |
| `ACTION_USER_GRANT_ALL_ON_DB` | yes,no                | no                    | Grants all privileges for selected database by `ACTION_DATABASE_NAME` |
| `ACTION_DATABASE`             | create,drop           | create                | Creates or Drops database.                                            |
| `ACTION_DATABASE_NAME`        | any                   | _N/A_                 | Name of database to create or drop.                                   |


**Backup variables**
| Variable Name          | Options               | Default        | Description                                                                         |
|------------------------|-----------------------|----------------|-------------------------------------------------------------------------------------|
| `BACKUP_ENABLED`       | yes,no                | no             | Backups MySQL.                                                                      |
| `BACKUP_NAME`          | any (optional)        | _N/A_          | Set backup file name.                                                               |
| `BACKUP_TYPE`          | full,database,table   | full           | Specify backup targe type.                                                          |
| `BACKUP_DATABASE_NAME` | any                   | _N/A_          | Name of the DB to backup. Comma separate if mulyiple of them. e.g db1,db2...        |
| `BACKUP_TABLE_NAME`    | any                   | _N/A_          | Name of the table to backup. Comma separate if mulyiple of them. e.g tab1,tab2...   |
| `BACKUP_TO_S3`         | yes,no                | no             | Use S3 for backups. S3 variables must be set to this work.                          |


**S3 variables**
| Variable Name           | Options              | Default               | Description                                                                   |
|-------------------------|----------------------|-----------------------|-------------------------------------------------------------------------------|
| `S3_ENDPOINT`           | any (FQDN like)      | _N/A_                 | S3 endpoint name in a FQDN format.                                            |
| `S3_REGION`             | any                  | us-east-2             | S3 region name.                                                               |
| `S3_BUCKET`             | any                  | _N/A_                 | S3 Bucket name.                                                               |
| `S3_FOLDER`             | any (optional)       | _N/A_                 | S3 folder inside Bucket.                                                      |
| `S3_ACCESS_KEY`         | any                  | _N/A_                 | S3 Access Key.                                                                |
| `S3_SECRET_KEY`         | any                  | _N/A_                 | S3 Secret Key.                                                                |
| `S3_SSL`                | yes,no               | yes                   | Specifies if SSL should be used for the endpoint connection (recommended).    |

**Others variables**
| Variable Name              | Options    | Default       | Description                     |
|----------------------------|------------|---------------|---------------------------------|
| `TEST_CONNECTION_ONLY`     | yes,no     | no            | Exits after connection testing. |


## Avanced usage <a name = "avance_usage"></a>
### Using a configuration file

You can specify the MySQL configuration in a file and create a bind volume to the path `/etc/mysql/my.cnf` in the container. This configuration file must have to follow the [MySQL documentation](https://dev.mysql.com/doc/refman/8.0/en/option-files.html) for `my.cnf` file but just with the `[client]` group.

```ini
# my-config.cnf
[client]
host=database
user=jorgmassih
password=root
port=3306
protocol=tcp
```
And inside of the `docker-compose.yml`:
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

Keeping a file ready with your connection parameters allows you to run the container without keeping your credentials in your _CI/CD_ process.

If you want a more secure approach while using it manually, you can remove the credentias from your configuration file and set to `yes` the environmental variable `PROMPT_CREDENTIALS`, and then you will be prompted for connection `user` and `password`.


## ⛏️ Built Using <a name = "built_using"></a>

- [Purely Bash 📟](https://en.wikipedia.org/wiki/Bash_(Unix_shell))

## ✍️ Authors <a name = "authors"></a>

- [@jorgmassih👨‍💻](https://github.com/jorgmassih) - Idea & Initial work

## 🤝 Contributing <a name = "contributing"></a>
I'm open to contributions!
If you are interested in collaborating, you can reach out to me via the info on [my bio](https://github.com/Jorgmassih).
