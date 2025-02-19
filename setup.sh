#!/bin/bash

set -e

POSTGRES_CONTAINER_NAME="postgres-container"
LIFERAY_CONTAINER_NAME="liferay-container"

restore_database() {
  # Listing dump files in the /dump/ folder inside the container
  DUMP_FILES=$(docker exec "$POSTGRES_CONTAINER_NAME" sh -c 'ls /dump/*.dump /dump/*.sql 2>/dev/null')

  if [ -z "$DUMP_FILES" ]; then
    echo "No dump files found in /dump/."
    exit 1
  fi

  # Displaying the numbered list of dump files
  echo "Dump files found:"
  i=1
  FILES_ARRAY=()
  while IFS= read -r FILE; do
    FILES_ARRAY+=("$FILE")
    echo "$i. $(basename "$FILE")"
    i=$((i + 1))
  done <<< "$DUMP_FILES"

  # Asking the user to select which dump to restore
  echo "Enter the number of the dump file you want to restore:"
  read -r SELECTION

  # Checking if the selection is within a valid range
  if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || [ "$SELECTION" -lt 1 ] || [ "$SELECTION" -gt "${#FILES_ARRAY[@]}" ]; then
    echo "Invalid selection. Aborting operation."
    exit 1
  fi

  # Getting the corresponding file for the selection
  DUMP_FILE="${FILES_ARRAY[$((SELECTION - 1))]}"

  # Checking if the file was correctly selected
  if [ -z "$DUMP_FILE" ]; then
    echo "File not found. Aborting operation."
    exit 1
  fi

  echo "Checking if the 'lportal' database exists..."
  DB_EXISTS=$(docker exec "$POSTGRES_CONTAINER_NAME" psql -U liferay -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='lportal'")

  if [[ "$DB_EXISTS" == "1" ]]; then
    echo "Database found. Terminating connections and recreating..."
    docker exec "$POSTGRES_CONTAINER_NAME" psql -U liferay -d postgres -c "
      SELECT pg_terminate_backend(pg_stat_activity.pid)
      FROM pg_stat_activity
      WHERE datname = 'lportal' AND pid <> pg_backend_pid();
    " > /dev/null 2>&1

    docker exec "$POSTGRES_CONTAINER_NAME" psql -U liferay -d postgres -c "DROP DATABASE lportal;"
  else
    echo "Database does not exist. Creating..."
  fi

  docker exec "$POSTGRES_CONTAINER_NAME" psql -U liferay -d postgres -c "CREATE DATABASE lportal;"

  # Getting the correct filename
  DUMP_BASENAME=$(basename "$DUMP_FILE")

  # Identifying the dump type and restoring correctly
  if [[ "$DUMP_BASENAME" == *.sql ]]; then
    echo "Restoring SQL dump: $DUMP_BASENAME"
    docker exec -i "$POSTGRES_CONTAINER_NAME" psql -U liferay -d lportal < <(docker exec "$POSTGRES_CONTAINER_NAME" cat "/dump/$DUMP_BASENAME")
  elif [[ "$DUMP_BASENAME" == *.dump ]]; then
    echo "Restoring custom dump: $DUMP_BASENAME"
    docker exec -i "$POSTGRES_CONTAINER_NAME" pg_restore -U liferay -d lportal "/dump/$DUMP_BASENAME"
  else
    echo "Unknown file type. Aborting operation."
    exit 1
  fi

  echo "Database successfully restored."
  restart_liferay
}

create_dump() {
  DUMP_FILE="/dump/liferay_dump_$(date +%Y%m%d%H%M%S).dump"
  
  echo "Creating a dump of the lportal database..."
  
  # Using pg_dump to create the dump in custom format
  docker exec "$POSTGRES_CONTAINER_NAME" pg_dump -U liferay -d lportal -F c -f "$DUMP_FILE"
  
  # Checking if the dump was successfully created
  if [ $? -eq 0 ]; then
    echo "Dump successfully created at: $DUMP_FILE"
  else
    echo "Error creating dump."
    exit 1
  fi
}

create_sql_dump() {
  DUMP_FILE="/dump/liferay_sql_dump_$(date +%Y%m%d%H%M%S).sql"
  
  echo "Creating a dump of the lportal database in SQL format..."

  # Using pg_dump to create the dump in plain SQL format
  docker exec "$POSTGRES_CONTAINER_NAME" pg_dump -U liferay -d lportal -F p -f "$DUMP_FILE"
  
  # Checking if the dump was successfully created
  if [ $? -eq 0 ]; then
    echo "SQL dump successfully created at: $DUMP_FILE"
  else
    echo "Error creating SQL dump."
    exit 1
  fi
}

restart_liferay() {
  echo "Restarting the Liferay container..."
  docker restart "$LIFERAY_CONTAINER_NAME"

  echo "Waiting for Liferay to start on port 8443..."
  
  # Loop to check if Liferay is accessible on port 8443
  while ! curl -ks --head --request GET "https://localhost:8443" | grep -q "HTTP/1.1 200"; do
    echo "Waiting for Liferay to become available..."
    sleep 5
  done

  echo "Liferay successfully restarted."
}

case "$1" in
  restore_database)
    restore_database
    ;;
  restart_liferay)
    restart_liferay
    ;;
  create_dump)
    create_dump
    ;;
  create_sql_dump)
    create_sql_dump
    ;;
  *)
    echo "Usage: $0 {restore_database|restart_liferay|create_dump|create_sql_dump}"
    exit 1
    ;;
esac
