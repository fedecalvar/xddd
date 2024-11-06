#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Función para mostrar la lista de servicios
DISPLAY_SERVICES() {
  echo -e "\nHere are the available services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Mostrar la lista de servicios al inicio
DISPLAY_SERVICES

# Solicitar al usuario que elija un servicio
echo -e "\nPlease enter the number of the service you would like:"
read SERVICE_ID_SELECTED

# Validar el servicio seleccionado y repetir la lista si no existe
VALID_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
while [[ -z $VALID_SERVICE ]]
do
  echo -e "\nI could not find that service. What would you like today?"
  DISPLAY_SERVICES
  read SERVICE_ID_SELECTED
  VALID_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
done

# Solicitar número de teléfono
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Verificar si el cliente ya existe
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Si el cliente no existe, solicitar el nombre y agregar a la base de datos
if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
fi

# Obtener el customer_id del cliente
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# Solicitar el horario de la cita
echo -e "\nWhat time would you like your appointment?"
read SERVICE_TIME

# Insertar la cita en la base de datos
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Mostrar mensaje de confirmación
echo -e "\nI have put you down for a $VALID_SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
