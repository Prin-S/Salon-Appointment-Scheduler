#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n--- Salon Menu ---\n"

# List services
SERVICES=$($PSQL "SELECT * FROM services")

SERVICE_LIST() {
  # In case there is an argument
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Ask user to input service number
  echo -e "\nChoose your service by entering a number."
  read SERVICE_ID_SELECTED
  SERVICE_AVAIL=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # If the input is not a number or the service doesn't exist
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ || -z $SERVICE_AVAIL ]]
  then
    SERVICE_LIST "Please enter a valid service."
  else
    # Ask user to input phone number
    echo -e "\nEnter your phone number."
    read CUSTOMER_PHONE
    CHECK_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # If the phone number doesn't exist
    if [[ -z $CHECK_PHONE ]]
    then
      # Ask user to input name
      echo -e "\nEnter your name."
      read CUSTOMER_NAME

      # Insert into 'customers' table
      INSERT_CUS_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # Query customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Ask user to input appointment time
    echo -e "\nEnter the time you'd like to make the appointment."
    read SERVICE_TIME
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

    # Show appointment successful message
    OUTPUT=$($PSQL "SELECT customers.name, time, services.name FROM customers INNER JOIN appointments USING (customer_id) INNER JOIN services USING (service_id) ORDER BY appointment_id DESC LIMIT 1")
    echo $OUTPUT | while read CUS_NAME PIPE TIME PIPE SER_NAME
    do
      FORMATTED_SER_NAME=$(echo $SER_NAME | tr '[:upper:]' '[:lower:]')
      echo -e "\nI have put you down for a $FORMATTED_SER_NAME at $TIME, $CUS_NAME."
    done
  fi
}

SERVICE_LIST