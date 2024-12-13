#!/bin/bash

# Ejecución Remota
#    curl -sL https://raw.githubusercontent.com/L1LBRO/CTF/refs/heads/main/HoneyPot/CrearConfigurarDebianHoneyPot.sh | bash

export cRED='\033[0;31m'
export cGREEN='\033[0;32m'
export cYELLOW='\033[1;33m'
export cBLUE='\033[1;34m'
export cNC='\033[0m' # Sin color

function print_info() {
    echo -e "${cYELLOW}[INFO]${NC} $1"
}

function print_error() {
    echo -e "${cRED}[ERROR EN LA EJECUCIÓN DEL SCRIPT]${NC} $1"
}

function print_success() {
    echo -e "${cGREEN}[COMANDOS EJECUTADOS CORRECTAMENTE]${NC} $1"
}

function print_atention() {
    echo -e "${cBLUE}[ATENCIÓN NAVEGANTE]${NC} $1"
}

print_info 
echo "Iniciando configuración de Debian como Honeypot..."
sleep 2


# Instalación de las dependencias necesarias
print_info 
echo "Instalando las dependencias necesarias para el HoneyPot..."
sleep 2
# OPENSSH
apt install openssh-server -y
if [ $? -eq 0 ]; then
    print_success 
    echo "OpenSSH instalado..."
else
    print_error 
    echo "Error al instalar OpenSSH..."
    exit 1
fi
sleep 4

systemctl start ssh
systemctl enable ssh
if [ $? -eq 0 ]; then
    print_success 
    echo "OpenSSH activado..."
else
    print_error 
    echo "Error al activar OpenSSH..."
    exit 1
fi
sleep 4


apt install nginx -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Nginx instalado..."
else
    print_error 
    echo "Error al activar Nginx..."
    exit 1
fi

sleep 4

systemctl start nginx
systemctl enable nginx
if [ $? -eq 0 ]; then
    print_success 
    echo "Nginx activado..."
else
    print_error 
    echo "Error al activar Nginx..."
    exit 1
fi
sleep 4


apt install rsyslog -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Rsyslog instalado..."
else
    print_error 
    echo "Error al instalar Rsyslog..."
    exit 1
fi
sleep 4

systemctl start rsyslog
systemctl enable rsyslog
if [ $? -eq 0 ]; then
    print_success 
    echo "Rsyslog activado..."
else
    print_error 
    echo "Error al activar Rsyslog..."
    exit 1
fi
sleep 4


apt install ufw -y
if [ $? -eq 0 ]; then
    print_success 
    echo "UFW instalado..."
else
    print_error 
    echo "Error al instalar UFW..."
    exit 1
fi
sleep 4

systemctl start ufw
systemctl enable ufw
if [ $? -eq 0 ]; then
    print_success 
    echo "UFW activado..."
else
    print_error 
    echo "Error al activar UFW..."
    exit 1
fi
sleep 4

apt install vsftpd -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Vsftpd instalado..."
else
    print_error 
    echo "Error al instalar Vsftpd..."
    exit 1
fi
sleep 4

systemctl start vsftpd
systemctl enable vsftpd
if [ $? -eq 0 ]; then
    print_success 
    echo "Vsftpd activado..."
else
    print_error 
    echo "Error al activar Vsftpd..."
    exit 1
fi
sleep 4

apt install mariadb-server -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Mariadb instalado..."
else
    print_error 
    echo "Error al instalar Mariadb..."
    exit 1
fi
sleep 4

systemctl start mariadb
systemctl enable mariadb
if [ $? -eq 0 ]; then
    print_success 
    echo "Mariadb activado..."
else
    print_error 
    echo "Error al activar Mariadb..."
    exit 1
fi
sleep 4

apt install git -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Git instalado..."
else
    print_error 
    echo "Error al instalar Git..."
    exit 1
fi
sleep 4

apt install tcpdump -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Tcpdump instalado..."
else
    print_error 
    echo "Error al instalar Tcpdump..."
    exit 1
fi
sleep 4

# Crear configuración vulnerable en SSH
print_atention
echo "Se va a proceder a configurar SSH de manera que sea vulnerable y atrapar a los INSIDERS de la empresa"
sleep 5

print_info 
echo "Modificando configuraciones del archivo sshd_config para simular vulnerabilidades ..."
sleep 2

sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/#LogLevel INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config
sed -i -e 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config

if [ $? -eq 0 ]; then
    print_success 
    echo "Configuración vulnerable en sshd creada..."
else
    print_error 
    echo "Error al configurar sshd..."
    exit 1
fi

print_info
echo "Redirigiendo la escucha del Puerto SSH (22) al puerto (2222)..."
sleep 2
print_info
echo "Instalado IP Tables para realizar la acción..."
apt install iptables

if [ $? -eq 0 ]; then
    print_success
    echo "IP Tables instalado correctamente..."
else
    print_error
    echo "Se ha producido un error en la instalación..."
    exit 1

print_info
echo "Redirigiendo la escucha del puerto 22 al puerto 2222..."
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222

if [ $? -eq 0 ]; then
    print_success
    echo "Redirección creada correctamente..."
else
    print_error
    echo "Se ha producido un error en la redirección..."
    exit 1
sleep 4

print_info
echo "Configurando fichero con la conexión a la BD que se configurará posteriormente para conexión de los usuarios..."
sleep 2

print_info
echo "Cambiando el fichero sshd..."
sed -i -e 's/#UsePam no/UsePam yes/g' /etc/ssh/sshd_config

if [ $? -eq 0 ]; then
    print_success 
    echo "Fichero sshd configurado..."
else
    print_error 
    echo "Error al configurar sshd..."
    exit 1
fi
sleep 4

print_info
echo "Editando el fichero pamd.d"
sed -i '$ a auth required pam_mysql.so user=bd passwd=P@ssw0rd\! host=127.0.0.1 db=usuarios_conexiones table=users usercolumn=username passwdcolumn=password' /etc/pam.d/sshd

if [ $? -eq 0 ]; then
    print_success 
    echo "Fichero pam.d configurado posteriormente se creará la base de datos con los usuarios permitidos..."
else
    print_error 
    echo "Error al configurar sshd..."
    exit 1
fi
sleep 4

print_info
echo "Creando un servicio de systemd para monitorizar el tráfico de SSH..."
bash -c 'cat << EOT > /etc/systemd/system/custom-monitor.service
[Unit]
Description=Custom Monitor for SSH on Port 2222
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/bash -c '\''while :; do netstat -tuln | grep -q ":2222" || echo "Port 2222 is down"; sleep 10; done'\''
Restart=always

[Install]
WantedBy=multi-user.target
EOT'
systemctl enable custom-monitor
systemctl start custom-monitor

if [ $? -eq 0 ]; then
    print_success
    echo "Servicio en systemd creado y establecido correctamente..."
else
    print_error
    echo "Se ha producido un error en la creación del servicio..."
    exit 1
sleep 4

systemctl restar sshd
systemctl restar ssh

if [ $? -eq 0 ]; then
    print_success
    echo "Se ha creado correctamente un servicio SSH vulnerable..."
else
    print_error
    echo "Se ha producido un error en el reinicio del servicio ssh..."
    exit 1
sleep 4


print_info
echo "Se procederá a configurar una servicio web vulnerable..."
sleep 2

print_info 
echo "Clonando el repositorio de la página web..."
sleep 2

git clone https://github.com/L1LBRO/CTF.git

if [ $? -eq 0 ]; then
    print_success
    echo "Repositorio clonado correctamente..."
else
    print_error
    echo "Se ha producido un error en la clonación del repositorio..."
    exit 1
sleep 4

print_info
echo "Copiando página web del repositorio a /var/www/html"
sleep 2
mkdir /var/www/html/web-empresita
mv CTF/HoneyPot/HoneyPotPage/* /var/www/html/web-empresita

if [ $? -eq 0 ]; then
    print_success
    echo "Se ha copiado correctamente..."
else
    print_error
    echo "Fallo al momento de copiar la página web..."
    exit 1
sleep 4

print_info
echo "Eliminando repositorio para no dejar rastro ;)"
rm -r CTF

if [ $? -eq 0 ]; then
    print_success
    echo "Se ha borrado correctamente..."
else
    print_error
    echo "Fallo al momento de borrar el repositorio eliminarlo manualmente después..."
fi
sleep 4

print_info
echo "Aplicando la nueva página web"

bash -c 'cat << EOT > /etc/nginx/sites-available/web-empresita
server {
    listen 80;  # Puerto en el que escucha el servidor
    server_name ejemplo.com www.ejemplo.com;  # Dominio de tu página web

    root /var/www/html/web-empresita;  # Directorio donde se encuentran los archivos de la página
    index index.html index.htm index.php;  # Archivos predeterminados de índice

    access_log /var/log/nginx/ejemplo_access.log;  # Log de acceso
    error_log /var/log/nginx/ejemplo_error.log;    # Log de errores

    # Configuración para manejar solicitudes
    location / {
        try_files $uri $uri/ =404;  # Si no se encuentra el archivo, se devuelve un 404
    }

    # Configuración para manejar PHP (si es necesario)
    # Si deseas usar PHP, debes tener configurado PHP-FPM y descomentar esta sección

    # location ~ \.php$ {
    #     include snippets/fastcgi-php.conf;
    #     fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;  # Asegúrate de que la versión de PHP coincida
    #     fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    #     include fastcgi_params;
    # }

    # Seguridad adicional
    location ~ /\.ht {
        deny all;  # Niega el acceso a archivos ocultos (.htaccess, etc.)
    }
}
EOT'

if [ $? -eq 0 ]; then
    print_success
    echo "Fichero web-empresita creado correctamente..."
else
    print_error
    echo "Fallo al momento de crear el fichero /etc/nginx/sites-available/web-empresita..."
    echo "Crear el fichero de manera de manual o cambiar el default"
fi
sleep 4


sudo ln -s /etc/nginx/sites-available/web-empresita /etc/nginx/sites-enabled/


if [ $? -eq 0 ]; then
    print_success
    echo "Fichero default editado correctamente..."
else
    print_error
    echo "Fallo al momento de editar el /etc/nginx/sites-available/default..."
    echo "Cambiar el fichero de manera manual"
fi
sleep 4



