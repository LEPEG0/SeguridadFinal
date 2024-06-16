#!/bin/bash

# Función para capturar el mensaje o archivo
capture_message_or_file() {
    choice=$(zenity --list --radiolist \
        --title="Seleccionar acción" \
        --text="¿Deseas capturar un mensaje o elegir un archivo?" \
        --column="" --column="Opción" \
        TRUE "Capturar mensaje" FALSE "Elegir archivo")

    if [ "$choice" == "Capturar mensaje" ]; then
        message=$(zenity --entry --title="Capturar mensaje" --text="Escribe el mensaje que deseas enviar:")
        if [ -z "$message" ]; then
            zenity --error --title="Error" --text="El mensaje no puede estar vacío."
            exit 1
        fi
        echo "$message" > message.txt
        echo "message.txt"
    else
        file=$(zenity --file-selection --title="Elegir archivo")
        if [ -z "$file" ]; then
            zenity --error --title="Error" --text="No se seleccionó ningún archivo."
            exit 1
        fi
        echo "$file"
    fi
}

# Función para generar el hash sha384
generate_sha384_hash() {
    sha384sum "$1" | awk '{print $1}'
}

# Función para encriptar con RSA
encrypt_with_rsa() {
    openssl pkeyutl -encrypt -in "$1" -pubin -inkey "$2" -out encrypted_data.enc
    if [ $? -eq 0 ]; then
        echo "encrypted_data.enc"
    else
        zenity --error --text="Error al encriptar el archivo."
        exit 1
    fi
}

# Función para generar el hash sha512
generate_sha512_hash() {
    sha512sum "$1" | awk '{print $1}'
}

# Función para ocultar el mensaje en una imagen
hide_message_in_image() {
    steghide embed -cf "$1" -ef "$2" -p ''
    if [ $? -eq 0 ]; then
        zenity --info --text="Mensaje ocultado correctamente en la imagen."
    else
        zenity --error --text="Error al ocultar el mensaje en la imagen."
        exit 1
    fi
}

# Función para generar el hash Blake2
generate_blake2_hash() {
    b2sum "$1" | awk '{print $1}'
}

# Función para validar hashes
validar_hash() {
    local file=$1
    local expected_hash=$2
    local actual_hash=$(sha512sum "$file" | awk '{print $1}')
    if [ "$actual_hash" == "$expected_hash" ]; then
        echo "Hash válido"
    else
        echo "Hash inválido"
        rm "$file"
        exit 1
    fi
}
