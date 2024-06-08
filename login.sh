#!/bin/bash

# Función para obtener la dirección IP
obtener_ip() {
    ip=$(hostname -I | awk '{print $1}')
    echo $ip
}

# Función para obtener la dirección MAC
obtener_mac() {
    mac=$(ip link show | awk '/ether/ {print $2}')
    echo $mac
}

# Solicitar al usuario que ingrese el nombre de usuario y la contraseña
usuario=$(zenity --entry --title="Inicio de Sesión" --text="Ingrese su nombre de usuario:")
contrasena=$(zenity --password --title="Inicio de Sesión" --text="Ingrese su contraseña:")
aceptar_politicas=$(zenity --question --title="Políticas de Privacidad" --text="¿Acepta las políticas de privacidad y términos de uso?" --ok-label="Aceptar" --cancel-label="Cancelar")

# Verificar si el usuario aceptó las políticas
if [ $? -ne 0 ]; then
    zenity --error --title="Error" --text="Debe aceptar las políticas de privacidad para continuar."
    exit 1
fi

# Obtener la IP y la MAC
ip=$(obtener_ip)
mac=$(obtener_mac)

# Verificar si se obtuvieron correctamente la IP y la MAC
if [[ -z "$ip" || -z "$mac" ]]; then
    zenity --error --title="Error" --text="No se pudo obtener la información de red."
    exit 1
fi

# Guardar la información de sesión en un archivo JSON
sesion_info=$(jq -n \
                --arg usuario "$usuario" \
                --arg contrasena "$contrasena" \
                --arg ip "$ip" \
                --arg mac "$mac" \
                --arg activo "1" \
                '{usuario: $usuario, password: $contrasena, ip: $ip, macAddress: $mac, activo: $activo}')

echo $sesion_info > sesion_info.json

zenity --info --title="Éxito" --text="Inicio de sesión exitoso!"
