#!/bin/bash

encrypt_message() {
    read -p "Desea capturar un mensaje (1) o seleccionar un archivo (2)? " choice
    if [ "$choice" -eq 1 ]; then
        read -p "Ingrese el mensaje a cifrar: " message
        echo "$message" > mensaje.txt
        openssl rsautl -encrypt -inkey ~/.ssh/public_key.pem -pubin -in mensaje.txt -out mensaje_cifrado.bin
        if [ $? -eq 0 ]; then
            echo "Mensaje cifrado y guardado en mensaje_cifrado.bin"
            sha384sum mensaje.txt | awk '{ print $1 }' > mensaje_cifrado.bin.sha384
            echo "Hash SHA-384 del mensaje generado y guardado en mensaje_cifrado.bin.sha384"
            sha512sum mensaje_cifrado.bin | awk '{ print $1 }' > mensaje_cifrado.bin.sha512
            echo "Hash SHA-512 del mensaje cifrado generado y guardado en mensaje_cifrado.bin.sha512"
            b2sum mensaje_cifrado.bin | awk '{ print $1 }' > mensaje_cifrado.bin.blake2
            echo "Hash BLAKE2 del mensaje cifrado generado y guardado en mensaje_cifrado.bin.blake2"
        else
            echo "Error al cifrar el mensaje."
            exit 1
        fi
    elif [ "$choice" -eq 2 ]; then
        read -p "Ingrese la ruta del archivo a cifrar: " file_path
        if [ ! -f "$file_path" ]; then
            echo "El archivo no existe."
            exit 1
        fi
        openssl rsautl -encrypt -inkey ~/.ssh/public_key.pem -pubin -in "$file_path" -out archivo_cifrado.bin
        if [ $? -eq 0 ]; then
            echo "Archivo cifrado y guardado en archivo_cifrado.bin"
            sha384sum "$file_path" | awk '{ print $1 }' > archivo_cifrado.bin.sha384
            echo "Hash SHA-384 del archivo generado y guardado en archivo_cifrado.bin.sha384"
            sha512sum archivo_cifrado.bin | awk '{ print $1 }' > archivo_cifrado.bin.sha512
            echo "Hash SHA-512 del archivo cifrado generado y guardado en archivo_cifrado.bin.sha512"
            b2sum archivo_cifrado.bin | awk '{ print $1 }' > archivo_cifrado.bin.blake2
            echo "Hash BLAKE2 del archivo cifrado generado y guardado en archivo_cifrado.bin.blake2"
        else
            echo "Error al cifrar el archivo."
            exit 1
        fi
    else
        echo "Opción no válida. Por favor, intente de nuevo."
        exit 1
    fi

    # Opcional: Ocultar el mensaje cifrado en un archivo de esteganografía
    read -p "¿Desea ocultar el mensaje cifrado en un archivo? (s/n): " hide_choice
    if [ "$hide_choice" == "s" ]; then
        read -p "Ingrese la ruta del archivo de esteganografía (imagen, audio, etc.): " stego_file
        if [ ! -f "$stego_file" ]; then
            echo "El archivo de esteganografía no existe."
            exit 1
        fi
        steghide embed -cf "$stego_file" -ef mensaje_cifrado.bin -sf stego_output -p "passphrase"
        if [ $? -eq 0 ]; then
            echo "Mensaje ocultado en $stego_file y guardado en stego_output"
        else
            echo "Error al ocultar el mensaje."
            exit 1
        fi
    fi
}

encrypt_message
