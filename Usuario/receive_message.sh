#!/bin/bash

# 1
validate_blake2() {
    # 2
    echo "Validando el hash BLAKE2..."
    # 3
    calculated_blake2=$(b2sum mensaje_cifrado.bin | awk '{ print $1 }')
    # 4
    stored_blake2=$(cat mensaje_cifrado.bin.blake2)
    # 5
    if [ "$calculated_blake2" == "$stored_blake2" ]; then
        # 6
        echo "El hash BLAKE2 es correcto."
    else
        # 7
        echo "Comunicación alterada. Eliminando mensaje..."
        #rm mensaje_cifrado.bin mensaje_cifrado.bin.blake2 mensaje_cifrado.bin.sha384 mensaje_cifrado.bin.sha512 stego_output
        exit 1
    fi
}

# 8
extract_message() {
    # 9
    steghide extract -sf stego_output -p "passphrase"
    # 10
    if [ $? -eq 0 ]; then
        # 11
        echo "Mensaje extraído correctamente."
        #rm stego_output
    else
        # 12
        echo "Error al extraer el mensaje."
        exit 1
    fi
}

# 13
validate_sha512() {
    # 14
    echo "Validando el hash SHA-512..."
    # 15
    calculated_sha512=$(sha512sum mensaje_cifrado.bin | awk '{ print $1 }')
    # 16
    stored_sha512=$(cat mensaje_cifrado.bin.sha512)
    # 17
    if [ "$calculated_sha512" == "$stored_sha512" ]; then
        # 18
        echo "El hash SHA-512 es correcto."
    else
        # 19
        echo "Error en la verificación SHA-512. Eliminando mensaje..."
        #rm mensaje_cifrado.bin mensaje_cifrado.bin.sha384 mensaje_cifrado.bin.sha512 mensaje_cifrado.bin.blake2
        exit 1
    fi
}

# 20
decrypt_message() {
    # 21
    private_key_path="private_key.pem"
    # 22
    if [ ! -f "$private_key_path" ]; then
        # 23
        echo "La clave privada no existe en la ruta especificada."
        exit 1
    fi

    # 24
    openssl pkeyutl -decrypt -inkey "$private_key_path" -in mensaje_cifrado.bin -out mensaje.txt
    # 25
    if [ $? -eq 0 ]; then
        # 26
        echo "Mensaje desencriptado y guardado en mensaje.txt"
    else
        # 27
        echo "Error al desencriptar el archivo."
        #rm mensaje_cifrado.bin mensaje_cifrado.bin.sha384 mensaje_cifrado.bin.sha512 mensaje_cifrado.bin.blake2
        exit 1
    fi
}

# 28
validate_sha384() {
    # 29
    echo "Validando el hash SHA-384..."
    # 30
    calculated_sha384=$(sha384sum mensaje.txt | awk '{ print $1 }')
    # 31
    stored_sha384=$(cat mensaje_cifrado.bin.sha384)
    # 32
    if [ "$calculated_sha384" == "$stored_sha384" ]; then
        # 33
        echo "El hash SHA-384 del mensaje es correcto. El mensaje está listo."
    else
        # 34
        echo "El sistema fue vulnerado. Eliminando mensaje..."
        #rm mensaje_cifrado.bin mensaje_cifrado.bin.sha384 mensaje_cifrado.bin.sha512 mensaje_cifrado.bin.blake2 mensaje_desencriptado.txt
        exit 1
    fi
}

# 35
validate_blake2
# 36
extract_message
# 37
validate_sha512
# 38
decrypt_message
# 39
validate_sha384
