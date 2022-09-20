#!/bin/bash

# Select Backup type
if [ $BACKUP_TYPE ]; then
    echo "Running backup type: $BACKUP_TYPE"
    backup_signature = ${BACKUP_NAME:-$(date +%Y-%m-%d_%s)}
    backup_name = 'backup_'
    

    echo "Creating backup directory..."
    mkdir -p $BACKUP_DIR

    case ${BACKUP_TYPE} in
        "full")
            echo "Running full backup..."
            echo "Creating backup file..."
            backup_name=${BACKUP_NAME:-"mysql-bkf_${backup_signature}.sql.gz"}
            mysqldump --defaults-extra-file=$MYSQL_CLIENT_CONFIG --all-databases > $BACKUP_DIR/$backup_name
            echo "Backup created."
            ;;
        "database")
            echo "Running database backup..."
            echo "Creating backup file..."
            backup_name=${BACKUP_NAME:-"mysql-bkd_${backup_signature}.sql.gz"}
            databases=$(echo $BACKUP_DATABASE_NAME | tr "," " ")
            mysqldump --defaults-extra-file=$MYSQL_CLIENT_CONFIG --databases $databases > $BACKUP_DIR/$backup_name
            echo "Backup created."
            ;;
        "table")
            echo "Running table backup..."
            echo "Creating backup file..."
            database=$(echo "$BACKUP_DATABASE_NAME" | cut -d',' -f1)
            tables=$(echo $BACKUP_TABLE_NAME | tr "," " ")
            backup_name=${BACKUP_NAME:-"mysql-bkt_${backup_signature}.sql.gz"}
            mysqldump --defaults-extra-file=$MYSQL_CLIENT_CONFIG $database $tables > $BACKUP_DIR/$backup_name
            echo "Backup created."
            ;;
        *)
            echo "Unknown Backup type: $BACKUP_TYPE"
            exit 1
            ;;
    esac
else 
    echo "No backup type selected. Skipping..."
    exit 1
fi

# Select backup file system
if [ $BACKUP_TO_S3 == 'yes' ]; then
    echo "Backing up to S3..."

    if [ $S3_SSL != 'yes' ]; then
        S3_SSL_FLAG="--insecure"
    else
        S3_SSL_FLAG=""
    fi

    alias_name='db_backup'

    # Add S3 alias
    mc alias set $alias_name "$S3_ENDPOINT" "$S3_ACCESS_KEY" "$S3_SECRET_KEY" --api "s3v4" $S3_SSL_FLAG

    mc cp $BACKUP_DIR $alias_name/$S3_FOLDER            
fi