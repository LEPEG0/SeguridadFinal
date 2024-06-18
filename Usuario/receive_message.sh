#!/bin/bash

# Validar el HASH Blake2
validate_blake2() {
    echo "Validando el hash BLAKE2..."
    calculated_blake2=$(b2sum mensaje_cifrado.bin | awk '{ print $1 }')
    stored_blake2=$(cat mensaje_cifrado.bin.blake2)
    if [ "$calculated_blake2" == "$stored_blake2" ]; then
        echo "El hash BLAKE2 es correcto."
    else
        echo "Comunicación alterada. Eliminando mensaje..."
        #rm mensaje_cifrado.bin mensaje_cifrado.bin.blake2 mensaje_cifrado.bin.sha384 mensaje_cifrado.bin.sha512 stego_output
        exit 1
    fi
}

# Extraer el mensaje del archivo de esteganografía
extract_message() {
    steghide extract -sf stego_output -p "passphrase"
    if [ $? -eq 0 ]; then
        echo "Mensaje extraído correctamente."
        #rm stego_output
    else
        echo "Error al extraer el mensaje."
        exit 1
    fi
}

# Validar el HASH sha512
validate_sha512() {
    echo "Validando el hash SHA-512..."
    calculated_sha512=$(sha512sum mensaje_cifrado.bin | awk '{ print $1 }')
    stored_sha512=$(cat mensaje_cifrado.bin.sha512)
    if [ "$calculated_sha512" == "$stored_sha512" ]; then
        echo "El hash SHA-512 es correcto."
    else
        echo "Error en la verificación SHA-512. Eliminando mensaje..."
        #rm mensaje_cifrado.bin mensaje_cifrado.bin.sha384 mensaje_cifrado.bin.sha512 mensaje_cifrado.bin.blake2
        exit 1
    fi
}

# Desencriptar el mensaje usando la clave privada recibida
decrypt_message() {
    private_key_path="private_key.pem"
    if [ ! -f "$private_key_path" ]; then
        echo "La clave privada no existe en la ruta especificada."
        exit 1
    fi

    openssl pkeyutl -decrypt -inkey "$private_key_path" -in mensaje_cifrado.bin -out mensaje.txt
    if [ $? -eq 0 ]; then
        echo "Mensaje desencriptado y guardado en mensaje.txt"
    else
        echo "Error al desencriptar el archivo."
        #rm mensaje_cifrado.bin mensaje_cifrado.bin.sha384 mensaje_cifrado.bin.sha512 mensaje_cifrado.bin.blake2
        exit 1
    fi
}

# Validar el HASH sha384
validate_sha384() {
    echo "Validando el hash SHA-384..."
    calculated_sha384=$(sha384sum mensaje.txt | awk '{ print $1 }')
    stored_sha384=$(cat mensaje_cifrado.bin.sha384)
    if [ "$calculated_sha384" == "$stored_sha384" ]; then
        echo "El hash SHA-384 del mensaje es correcto. El mensaje está listo."
    else
        echo "El sistema fue vulnerado. Eliminando mensaje..."
        #rm mensaje_cifrado.bin mensaje_cifrado.bin.sha384 mensaje_cifrado.bin.sha512 mensaje_cifrado.bin.blake2 mensaje_desencriptado.txt
        exit 1
    fi
}

# Ejecución del proceso
validate_blake2
extract_message
validate_sha512
decrypt_message
validate_sha384