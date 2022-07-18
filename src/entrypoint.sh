#!/bin/bash

# Load client config
echo "Loading client config..."
. $APP_SCRIPTS_DIR/config.sh

echo "Starting the application..."

echo "Testing connection to the database..." \
    && mysql -e"quit" \
    && echo "Connection to the database is OK."

if [ ${USE_SCRIPTS:-no} == 'yes' ]; then
  echo "Using scripts"
  for script in $SQL_SCRIPTS_DIR/*.sql; do
    echo "Running script: $script"
    mysql < $script
  done
  exit 0;
fi

if [ $ACTION_DATABASE ]; then
    echo "Running database action: $ACTION_DATABASE"
    case ${ACTION_DATABASE} in
        "create")
            echo "Creating database..."
            mysql -e"CREATE DATABASE IF NOT EXISTS $ACTION_DATABASE_NAME;"
            echo "Database created"
            ;;

        "drop")
            echo "Dropping database..."
            mysql -e"DROP DATABASE IF EXISTS $ACTION_DATABASE_NAME;"
            echo "Database dropped"
            ;;
        *)
            echo "Unknown action: $ACTION_DATABASE"
            exit 1
            ;;
    esac
fi


if [ $ACTION_USER ]; then
    case ${ACTION_USER} in
        "create")
            echo "Creating user..."
            mysql -e"CREATE USER IF NOT EXISTS '$ACTION_USER_NAME'@'${ACTION_USER_ALLOWED_HOSTS:-localhost}' IDENTIFIED WITH ${ACTION_USER_AUTH_PLUGIN:-mysql_native_password} BY '$ACTION_USER_PASSWORD';"
            if [ ${ACTION_USER_GRANT_ALL:-no,,} == 'yes' ]; then
                echo "Granting user access to database..."
                mysql -e"GRANT ALL PRIVILEGES ON $ACTION_DATABASE_NAME.* TO '$ACTION_USER_NAME'@'${ACTION_USER_ALLOWED_HOSTS:-localhost}'; FLUSH PRIVILEGES;"
                echo "Access granted for $ACTION_USER_NAME on $ACTION_DATABASE_NAME"
            fi
            echo "User $ACTION_USER_NAME created"
            ;;

        "drop")
            echo "Dropping user..."
            mysql -e"DROP USER IF EXISTS '$ACTION_USER_NAME'@'${ACTION_USER_ALLOWED_HOSTS:-localhost}';"
            echo "User $ACTION_USER_NAME dropped"
            ;;
        *)
            echo "Unknown action: $ACTION_USER"
            exit 1
            ;;
    esac
fi

exit 0;