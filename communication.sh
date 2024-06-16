#!/bin/bash

# Función para solicitar la llave pública de la contraparte
solicitar_llave_publica() {
    ip=$(zenity --entry --title="Solicitar llave pública" --text="Ingrese la IP de la contraparte:")
    if [ -z "$ip" ]; then
        zenity --error --title="Error" --text="La IP no puede estar vacía."
        exit 1
    fi

    mac=$(arp -n $ip | grep $ip | awk '{print $3}')
    if [ -z "$mac" ]; then
        zenity --error --text="No se pudo obtener la MAC address del equipo con IP $ip."
        exit 1
    fi

    zenity --info --text="La MAC address del equipo con IP $ip es: $mac"

    public_key=$(zenity --file-selection --title="Seleccionar clave pública recibida")
    if [ -z "$public_key" ]; then
        zenity --error --title="Error" --text="No se seleccionó ninguna clave pública."
        exit 1
    fi
    echo "$public_key"
}

# Función para recibir y validar el mensaje
recibir_y_validar() {
    local destino_ip=$1

    # Descargar el archivo y los hashes
    scp "$destino_ip:~/imagen_oculta.png" .
    scp "$destino_ip:~/hashes.txt" .

    # Leer los hashes
    read -r sha384_hash sha512_hash blake2_hash < hashes.txt

    # Validar el hash Blake2
    blake2_hash_local=$(b2sum imagen_oculta.png | awk '{print $1}')
    if [ "$blake2_hash_local" != "$blake2_hash" ]; then
        zenity --error --title="Error" --text="Comunicación alterada. El hash Blake2 no coincide."
        rm imagen_oculta.png
        exit 1
    fi

    # Extraer el archivo oculto
    steghide extract -sf imagen_oculta.png -p "" -xf mensaje_encriptado.enc

    # Validar el hash SHA-512 del mensaje encriptado
    sha512_hash_local=$(sha512sum mensaje_encriptado.enc | awk '{print $1}')
    if [ "$sha512_hash_local" != "$sha512_hash" ]; then
        zenity --error --title="Error" --text="Error de integridad. El hash SHA-512 no coincide."
        rm mensaje_encriptado.enc
        exit 1
    fi

    # Desencriptar el mensaje
    openssl pkeyutl -decrypt -in mensaje_encriptado.enc -inkey llave_privada.pem -out mensaje.txt
    if [ $? -ne 0 ]; then
        zenity --error --title="Error" --text="Error al desencriptar el mensaje."
        rm mensaje_encriptado.enc mensaje.txt
        exit 1
    fi

    # Validar el hash SHA-384 del mensaje desencriptado
    sha384_hash_local=$(sha384sum mensaje.txt | awk '{print $1}')
    if [ "$sha384_hash_local" != "$sha384_hash" ]; then
        zenity --error --title="Error" --text="Error de integridad. El hash SHA-384 no coincide."
        rm mensaje.txt
        exit 1
    fi

    zenity --info --title="Éxito" --text="Mensaje recibido y validado correctamente."
}

# Función principal para enviar el mensaje
enviar_mensaje() {
    # Solicitar la llave pública
    public_key=$(solicitar_llave_publica)

    # Capturar el mensaje o archivo
    message_or_file=$(capture_message_or_file)

    # Generar el HASH sha384 del mensaje o archivo
    sha384_hash=$(generate_sha384_hash "$message_or_file")

    # Encriptar el mensaje con RSA invertido (Usando la llave pública recibida)
    encrypted_file=$(encrypt_with_rsa "$message_or_file" "$public_key")

    # Generar el HASH sha512 del mensaje encriptado
    sha512_hash=$(generate_sha512_hash "$encrypted_file")

    # Mostrar los hashes generados
    zenity --info --text="HASH SHA384 del mensaje: $sha384_hash\nHASH SHA512 del mensaje encriptado: $sha512_hash"

    # Selección de imagen para ocultar el archivo
    image=$(zenity --file-selection --title="Seleccionar imagen (PNG, JPG, etc.) para ocultar el archivo")
    if [ -z "$image" ]; then
        zenity --error --title="Error" --text="No se seleccionó ninguna imagen."
        exit 1
    fi

    # Ocultar archivo en la imagen
    hide_message_in_image "$image" "$encrypted_file"

    # Generar el HASH Blake2 de la imagen con el mensaje oculto
    blake2_hash=$(generate_blake2_hash "$image")

    # Guardar los hashes en un archivo txt
    hash_file="hashes.txt"
    echo "$sha384_hash $sha512_hash $blake2_hash" > "$hash_file"

    zenity --info --text="Hashes guardados en $hash_file"

    # Enviar el mensaje al otro equipo
    destino_ip=$(zenity --entry --title="Enviar mensaje" --text="Ingrese la IP del equipo destinatario:")
    if [ -z "$destino_ip" ]; then
        zenity --error --title="Error" --text="La IP del equipo destinatario no puede estar vacía."
        exit 1
    fi

    scp "$image" "$destino_ip:~/imagen_oculta.png"
    scp "$hash_file" "$destino_ip:~/hashes.txt"

    zenity --info --text="Mensaje enviado al equipo con IP $destino_ip"
}

# Función principal para recibir el mensaje
recibir_mensaje() {
    destino_ip=$(zenity --entry --title="Recibir mensaje" --text="Ingrese la IP del equipo que envía el mensaje:")
    if [ -z "$destino_ip" ]; then
        zenity --error --title="Error" --text="La IP del equipo que envía el mensaje no puede estar vacía."
        exit 1
    fi

    recibir_y_validar "$destino_ip"
}

# Mostrar menú para enviar o recibir mensaje
choice=$(zenity --list --radiolist \
    --title="Seleccionar acción" \
    --text="¿Deseas enviar o recibir un mensaje?" \
    --column="" --column="Opción" \
    TRUE "Enviar mensaje" FALSE "Recibir mensaje")

if [ "$choice" == "Enviar mensaje" ]; then
    enviar_mensaje
else
    recibir_mensaje
fi
