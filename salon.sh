#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

HOME_MENU(){
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi

    SERVICES=$($PSQL "SELECT service_id, name FROM services")
        echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    HOME_MENU "Please input a number"
    else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]] 
    then
      HOME_MENU "I could not find that service. What would you like today?\n"
    else
      REGISTERATION_MENU "$SERVICE_ID_SELECTED" "$SERVICE_NAME"
    fi
    fi
}

REGISTERATION_MENU(){
    SERVICE_ID_SELECTED=$1
    SERVICE_NAME=$2
    
# Ask for phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
  echo -e "\nThere's no record of that number. What's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME, $CUSTOMER_NAME? | sed -E 's/^ +| +$//g')"
  read SERVICE_TIME    
  ADD_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VAlUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  if [[ $ADD_APPOINTMENT_RESULT != "INSERT 0 1" ]] 
  then
  HOME_MENU "Could not schedule appointment, please schedule another service or try again later."
  else
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME | sed -E 's/^ +| +$//g')."
  fi

}

HOME_MENU "Welcome to my Salon, how can I help you?"