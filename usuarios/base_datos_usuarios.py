import json

class BaseDatosUsuarios:
    def __init__(self, archivo):
        self.archivo = archivo

    def cargar_usuarios(self):
        try:
            with open(self.archivo, 'r') as file:
                return json.load(file)
        except FileNotFoundError:
            return {}

    def guardar_usuario(self, usuario, contraseña):
        usuarios = self.cargar_usuarios()
        if usuario in usuarios:
            return False  # El usuario ya existe
        usuarios[usuario] = contraseña
        with open(self.archivo, 'w') as file:
            json.dump(usuarios, file)
        return True  # Usuario agregado correctamente

    def verificar_usuario(self, usuario, contraseña):
        usuarios = self.cargar_usuarios()
        if usuario in usuarios and usuarios[usuario] == contraseña:
            return True
        else:
            return False
