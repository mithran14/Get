#!/bin/bash

# Configuration
THRESHOLD_CPU=80
THRESHOLD_MEM=80
THRESHOLD_DISK=80
EMAIL="mtm.vignesh.js@gmail.com"
BITNAMI_STATUS_SCRIPT="/opt/bitnami/ctlscript.sh"
DB_HOSTNAME="127.0.0.1"
DB_USERNAME="bn_opencart"
DB_PASSWORD="1243e1755712b39613d053f8997da5804143dccb5da59c4d4120206c88c00f1a"
DB_DATABASE="bitnami_opencart"
DB_PORT=3306

# Track if any checks fail
checks_passed=true

# Check CPU usage

# Check Memory usage
mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

echo "Memory Usage: $mem_usage"

if (( $(echo "$mem_usage > $THRESHOLD_MEM" |bc -l) )); then
  echo "Memory usage is higher than $THRESHOLD_MEM%, it's $mem_usage%" | \
  mail -s "High Memory usage alert" $EMAIL
  checks_passed=false
fi

# Check Disk space usage
disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

echo "Disk Usage: $disk_usage"

if (( $(echo "$disk_usage > $THRESHOLD_DISK" |bc -l) )); then
  echo "Disk usage is higher than $THRESHOLD_DISK%, it's $disk_usage%" | \
  mail -s "High Disk usage alert" $EMAIL
  checks_passed=false
fi

# Check status of Bitnami services
services_status=$(sudo $BITNAMI_STATUS_SCRIPT status)

echo "Service Status: $services_status"

if echo $services_status | grep -q "not running"; then
  echo "One or more Bitnami services are not running: $services_status" | \
  mail -s "Bitnami service status alert" $EMAIL
  checks_passed=false
fi

# Check MySQL status
if ! mysqladmin -h $DB_HOSTNAME -P $DB_PORT -u $DB_USERNAME -p$DB_PASSWORD status > /dev/null; then
  echo "MySQL is not running" | \
  mail -s "MySQL is down alert" $EMAIL
  checks_passed=false
fi

# If all checks passed, run the tests
if $checks_passed; then
  echo "All checks passed"
else
  echo "Some checks did not pass"
fi
