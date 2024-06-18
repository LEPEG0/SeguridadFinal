#!/bin/bash

send_encrypted_file() {
    # 1
    read -p "Ingrese la IP del destinatario: " dest_ip
    # 2
    read -p "Ingrese el puerto SSH del destinatario: " dest_port
    # 3
    read -p "Ingrese el nombre del archivo cifrado (mensaje_cifrado.bin o archivo_cifrado.bin): " encrypted_file
    # 4
    read -p "Ingrese el nombre de usuario del destinatario: " dest_user

    # 5
    if [ ! -f "$encrypted_file" ]; then
        echo "El archivo cifrado no existe."
        exit 1
    fi
    # 6
    if [ ! -f "$encrypted_file.sha384" ]; then
        echo "El archivo de hash SHA-384 no existe."
        exit 1
    fi
    # 7
    if [ ! -f "$encrypted_file.sha512" ]; then
        echo "El archivo de hash SHA-512 no existe."
        exit 1
    fi
    # 8
    if [ ! -f "$encrypted_file.blake2" ]; then
        echo "El archivo de hash BLAKE2 no existe."
        exit 1
    fi

    # 9
    if [ -f "stego_output" ]; then
        scp -P "$dest_port" "stego_output" "$dest_user@$dest_ip:~"
        if [ $? -eq 0 ]; then
            echo "Archivo de esteganografía enviado correctamente a $dest_ip"
        else
            echo "Error al enviar el archivo de esteganografía."
            exit 1
        fi
    fi

    # 10
    scp -P "$dest_port" "$encrypted_file" "$dest_user@$dest_ip:~"
    # 11
    scp -P "$dest_port" "$encrypted_file.sha384" "$dest_user@$dest_ip:~"
    # 12
    scp -P "$dest_port" "$encrypted_file.sha512" "$dest_user@$dest_ip:~"
    # 13
    scp -P "$dest_port" "$encrypted_file.blake2" "$dest_user@$dest_ip:~"
    # 14
    if [ $? -eq 0 ]; then
        echo "Archivo cifrado y hashes enviados correctamente a $dest_ip"
    else
        echo "Error al enviar el archivo cifrado o los hashes."
        exit 1
    fi

}

send_encrypted_file
