#!/bin/bash

get_mac_address() {
    read -p "Ingrese la IP de la contraparte: " counterpart_ip
    read -p "Ingrese el nombre de usuario de la contraparte: " counterpart_user

    if [[ ! $counterpart_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "IP no válida. Por favor, intente de nuevo."
        exit 1
    fi
    ping -c 1 $counterpart_ip > /dev/null
    mac_address=$(arp -n | grep $counterpart_ip | awk '{print $3}')
    if [ -z "$mac_address" ]; then
        echo "No se pudo obtener la dirección MAC de la IP proporcionada."
        exit 1
    else
        echo "La dirección MAC de la contraparte es: $mac_address"
    fi

    # Verificar si el usuario, la IP y la MAC están en la lista permitida
    if grep -q "$counterpart_user $counterpart_ip $mac_address" allowed_users.txt; then
        echo "El usuario, la IP y la dirección MAC son válidos y están permitidos."
    else
        echo "El usuario, la IP o la dirección MAC no coinciden con la lista permitida."
        exit 1
    fi
}

get_mac_address