#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

CUSTOMER_CHECKIN() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then 
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  fi

  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/[[:space:]]//g')
  echo -e "\nWhat time would you like your $1, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE  phone = '$CUSTOMER_PHONE'")
  CUSTOMER_ID_FORMATTED=$(echo $CUSTOMER_ID | sed 's/[[:space:]]//g')

  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $2, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $1 at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID SERVICE_NAME
  do
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/[[:space:]]//g'  | sed 's/|//g')

    echo "$SERVICE_ID) $SERVICE_NAME_FORMATTED"
  done

  read SERVICE_ID_SELECTED

  SERVICE_QUERY=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_QUERY ]]
  then
    SERVICE_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_QUERY | sed 's/[[:space:]]//g')
    CUSTOMER_CHECKIN "$SERVICE_NAME_FORMATTED" $SERVICE_ID_SELECTED
  fi
}


echo -e "\n~~~~~ MY SALON ~~~~~\n"
SERVICE_MENU "Welcome to My Salon, how can I help you?\n"