#!/bin/bash

/opt/mssql/bin/sqlservr &
SQLSERVR_PID=$!

echo "Waiting for SQL Server to accept connections..."
for i in $(seq 1 60); do
    if /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -Q "SELECT 1" -No -b >/dev/null 2>&1; then
        echo "SQL Server ready after ${i} polls."
        break
    fi
    sleep 2
done

echo "Running init script..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -i /initdb/init.sql -No -b

echo "Database initialized."
wait $SQLSERVR_PID
