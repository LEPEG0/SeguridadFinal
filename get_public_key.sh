#!/bin/bash

get_public_key() {
    read -p "Ingrese la IP del administrador para obtener la llave pública: " admin_ip
    read -p "Ingrese el puerto SSH del administrador: " admin_port
    if [[ ! $admin_ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "IP no válida. Por favor, intente de nuevo."
        exit 1
    fi
    ssh -p $admin_port $USER@$admin_ip 'cat ~/.ssh/id_rsa.pub' > public_key.pem
    if [ $? -eq 0 ]; then
        echo "Llave pública recibida correctamente y guardada en public_key.pem"
    else
        echo "Error al obtener la llave pública del administrador."
        exit 1
    fi
}

get_public_key

