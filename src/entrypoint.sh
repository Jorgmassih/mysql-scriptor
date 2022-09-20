#!/bin/bash

# Load client config
echo "Loading client config..."
. $APP_SCRIPTS_DIR/config.sh

echo "Starting the application..."

echo "Testing connection to the database..."
if mysql -e"quit" ;
then
    echo "Connection to the database successful."
    if [ ${TEST_CONNECTION_ONLY:-no} == 'yes' ]; then
        exit 0
    fi
else
    echo "Connection to the database failed."
    exit 1
fi

echo "Executing SQL scripts if they exist..."
find $SQL_SCRIPTS_DIR/. -maxdepth 1 -type f -name '*.sql' -exec mysql < {} \; 

if [ $ACTION_DATABASE ]; then
    echo "Running database action: $ACTION_DATABASE"
    case ${ACTION_DATABASE} in
        "create")
            echo "Creating database $ACTION_DATABASE_NAME..."
            $(mysql -e"CREATE DATABASE IF NOT EXISTS $ACTION_DATABASE_NAME;") && echo "Database created." || echo "Database creation failed."
            ;;

        "drop")
            echo "Dropping database $ACTION_DATABASE_NAME..."
            mysql -e"DROP DATABASE IF EXISTS $ACTION_DATABASE_NAME;"
            ;;
        *)
            echo "Unknown action: $ACTION_DATABASE"
            exit 1
            ;;
    esac
fi


if [ $ACTION_USER ]; then
    echo "Running database action: $ACTION_USER"
    case ${ACTION_USER} in
        "create")
            echo "Creating user ${ACTION_USER_NAME}..."
            password = $ACTION_USER_PASSWORD 

            mysql -e"CREATE USER IF NOT EXISTS '$ACTION_USER_NAME'@'${ACTION_USER_ALLOWED_HOSTS:-localhost}' IDENTIFIED WITH ${ACTION_USER_AUTH_PLUGIN:-mysql_native_password} BY '$password';" 
            
            if [ ${ACTION_USER_GRANT_ALL_ON_DB:-no} == 'yes' ]; then
                echo "Granting user access to database $ACTION_DATABASE_NAME for $ACTION_USER_NAME..."
                mysql -e"GRANT ALL PRIVILEGES ON $ACTION_DATABASE_NAME.* TO '$ACTION_USER_NAME'@'${ACTION_USER_ALLOWED_HOSTS:-localhost}'; FLUSH PRIVILEGES;"
            fi
            ;;

        "drop")
            echo "Dropping user $ACTION_USER_NAME..."
            mysql -e"DROP USER IF EXISTS '$ACTION_USER_NAME'@'${ACTION_USER_ALLOWED_HOSTS:-localhost}';"
            ;;
        *)
            echo "Unknown action: $ACTION_USER"
            exit 1
            ;;
    esac
fi

if [ $BACKUP_ENABLED == 'yes' ]; then
    echo "Running backup..."
    $APP_SCRIPTS_DIR/backup.sh
fi

exit 0;