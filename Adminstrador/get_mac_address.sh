#!/bin/bash

get_mac_address() {
    # 1
    read -p "Ingrese la IP de la contraparte: " counterpart_ip
    # 2
    read -p "Ingrese el nombre de usuario de la contraparte: " counterpart_user

    # 3
    if [[ ! $counterpart_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # 4
        echo "IP no válida. Por favor, intente de nuevo."
        exit 1
    fi
    # 5
    ping -c 1 $counterpart_ip > /dev/null
    # 6
    mac_address=$(arp -n | grep $counterpart_ip | awk '{print $3}')
    # 7
    if [ -z "$mac_address" ]; then
        # 8
        echo "No se pudo obtener la dirección MAC de la IP proporcionada."
        exit 1
    else
        # 9
        echo "La dirección MAC de la contraparte es: $mac_address"
    fi

    # 10
    if grep -q "$counterpart_user $counterpart_ip $mac_address" allowed_users.txt; then
        # 11
        echo "El usuario, la IP y la dirección MAC son válidos y están permitidos."
    else
        # 12
        echo "El usuario, la IP o la dirección MAC no coinciden con la lista permitida."
        exit 1
    fi
}

get_mac_address
