#!/bin/bash

export cRED='\033[0;31m'
export cGREEN='\033[0;32m'
export cYELLOW='\033[1;33m'
export cBLUE='\033[1;34m'
export cNC='\033[0m' # Sin color

function print_info() {
    echo -e "${cYELLOW}[INFO]${NC} $1"
}

function print_error() {
    echo -e "${cRED}[ERROR EN LA EJECUCIÓN DEL CÓDIGO]${NC} $1"
}

function print_success() {
    echo -e "${cGREEN}[COMANDOS EJECUTADOS CORRECTAMENTE]${NC} $1"
}

print_info 
echo "Iniciando configuración de Debian como Honeypot..."
sleep 2


# Instalación de las dependencias necesarias
print_info 
echo "Instalando las dependencias necesarias para el HoneyPot..."
sleep 5
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
sleep 5

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
sleep 5


apt install nginx -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Nginx instalado..."
else
    print_error 
    echo "Error al activar Nginx..."
    exit 1
fi

sleep 5

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
sleep 5


apt install rsyslog -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Rsyslog instalado..."
else
    print_error 
    echo "Error al instalar Rsyslog..."
    exit 1
fi
sleep 5

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
sleep 5


apt install ufw -y
if [ $? -eq 0 ]; then
    print_success 
    echo "UFW instalado..."
else
    print_error 
    echo "Error al instalar UFW..."
    exit 1
fi
sleep 5

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
sleep 5

apt install vsftpd -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Vsftpd instalado..."
else
    print_error 
    echo "Error al instalar Vsftpd..."
    exit 1
fi
sleep 5

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
sleep 5

apt install mariadb-server -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Mariadb instalado..."
else
    print_error 
    echo "Error al instalar Mariadb..."
    exit 1
fi
sleep 5

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
sleep 5

apt install git -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Git instalado..."
else
    print_error 
    echo "Error al instalar Git..."
    exit 1
fi
sleep 5

apt install tcpdump -y
if [ $? -eq 0 ]; then
    print_success 
    echo "Tcpdump instalado..."
else
    print_error 
    echo "Error al instalar Tcpdump..."
    exit 1
fi
sleep 5

# Modificación del fichero SSH para hacerlo parecer vulnerable
print_info 
echo "Modificando configuraciones del archivo sshd_config para simular vulnerabilidades ..."

sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/#LogLevel INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config

if [ $? -eq 0 ]; then
    print_success 
    echo "Configuración vulnerable de SSH creada..."
else
    print_error 
    echo "Error al configurar SSH..."
    exit 1
fi
