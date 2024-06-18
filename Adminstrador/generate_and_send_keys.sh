#!/bin/bash

generate_keys() {
    # 1
    openssl genpkey -algorithm RSA -out ~/.ssh/private_key.pem -pkeyopt rsa_keygen_bits:2048
    # 2
    openssl rsa -pubout -in ~/.ssh/private_key.pem -out ~/.ssh/public_key.pem
    # 3
    echo "Claves generadas: private_key.pem y public_key.pem"
}

send_keys() {
    # 4
    read -p "Ingrese la IP de la contraparte: " counterpart_ip
    # 5
    read -p "Ingrese el puerto SSH de la contraparte: " counterpart_port
    # 6
    read -p "Ingrese el nombre de usuario de la contraparte: " counterpart_user

    # 7
    scp -P "$counterpart_port" ~/.ssh/private_key.pem "$counterpart_user@$counterpart_ip:"
    # 8
    scp -P "$counterpart_port" ~/.ssh/public_key.pem "$counterpart_user@$counterpart_ip:"
    # 9
    if [ $? -eq 0 ]; then
        # 10
        echo "Claves enviadas correctamente a la contraparte"
    else
        # 11
        echo "Error al enviar las claves a la contraparte."
        exit 1
    fi
}

generate_keys
send_keys
