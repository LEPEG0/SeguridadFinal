#!/bin/bash

generate_keys() {
    openssl genpkey -algorithm RSA -out ~/.ssh/private_key.pem -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in ~/.ssh/private_key.pem -out ~/.ssh/public_key.pem
    echo "Claves generadas: private_key.pem y public_key.pem"
}

send_keys() {
    read -p "Ingrese la IP de la contraparte: " counterpart_ip
    read -p "Ingrese el puerto SSH de la contraparte: " counterpart_port
    read -p "Ingrese el nombre de usuario de la contraparte: " counterpart_user

    scp -P "$counterpart_port" ~/.ssh/private_key.pem "$counterpart_user@$counterpart_ip:"
    scp -P "$counterpart_port" ~/.ssh/public_key.pem "$counterpart_user@$counterpart_ip:"
    if [ $? -eq 0 ]; then
        echo "Claves enviadas correctamente a la contraparte"
    else
        echo "Error al enviar las claves a la contraparte."
        exit 1
    fi
}

generate_keys
send_keys