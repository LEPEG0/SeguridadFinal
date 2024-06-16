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

# Main function
main() {
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
    echo "HASH SHA384 del mensaje: $sha384_hash" > "$hash_file"
    echo "HASH SHA512 del mensaje encriptado: $sha512_hash" >> "$hash_file"
    echo "HASH Blake2 de la imagen con el archivo oculto: $blake2_hash" >> "$hash_file"

    zenity --info --text="Hashes guardados en $hash_file"

    # Enviar el mensaje al otro equipo (esto se puede hacer mediante SCP o cualquier otro método)
    destino_ip=$(zenity --entry --title="Enviar mensaje" --text="Ingrese la IP del equipo destinatario:")
    if [ -z "$destino_ip" ]; then
        zenity --error --title="Error" --text="La IP del equipo destinatario no puede estar vacía."
        exit 1
    fi

    scp "$image" "$destino_ip:~/"
    scp "$hash_file" "$destino_ip:~/"

    zenity --info --text="Mensaje enviado al equipo con IP $destino_ip"
}

main
