#!/bin/bash

# Mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # Sin color

function print_message() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# ACTUALIZAR LISTA DE CONTENEDORES
  print_message "Actualizando la lista de plantillas de contenedores..."
  pveam update

# DESCARGA DEL CONTENEDOR DE DEBIAN 12
  print_message "Descargando la plantilla de Debian 12..."
  pveam download local debian-12-standard_12.7-1_amd64.tar.zst

# CREACIÓN DEL CONTENEDOR
  print_message "Creando el contenedor Debian..."
  pct create 112 local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
  --hostname servidores-importantes \
  --storage local-lvm \
  --rootfs 8 \
  --memory 2048 \
  --cores 2 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --password P@ssw0rd!

# INICIANDO EL CONTENEDOR
  print_message "Iniciando el contenedor Debian..."
  pct start 112

# CONEXIÓN AL DEBIAN
  print_message "Entrando al Debian para configurar el Sistema..."
  #TODO LO QUE ESTA DENTRO DE << EOF-----EOF>> SE EJECUTARÁ DENTRO DEL CONTENDOR
  pct enter 112 << EOF

# ACTUALIZAR EL SISTEMA
print_message "Actualizando el sistema dentro del contenedor..."
apt update && apt upgrade -y

# Instalar los programas necesarios
print_message "Instalando programas necesarios para el honeypot..."
apt install openssh-server -y && apt install nginx -y && apt install curl -y && apt install tcpdump -y && apt install rsyslog -y && apt install ufw -y && apt install vsftpd -y && apt install mariadb-server -y

# Modificar configuración SSH para hacerla vulnerable
print_message "Modificando configuraciones de SSH para simular vulnerabilidades..."
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/#LogLevel INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config

# Reiniciar servicio SSH
print_message "Reiniciando el servicio SSH..."
/etc/init.d/ssh restart

# Crear usuarios con contraseñas débiles
print_message "Creando usuarios con contraseñas débiles..."
touch /etc/passwords.txt
useradd -m user1
echo "user:P@ssw0rd!" | chpasswd
echo "user:P@ssw0rd!" >> /etc/passwords.txt

# Configurar el servidor web
print_message "Configurando el servidor web..."
echo "<h1>Welcome to this web server</h1>" >> /var/www/html/index.html
/etc/init.d/nginx restart

# Configurar FTP
print_message "Configurando el servidor FTP..."
sed -i -e 's/anonymous_enable=NO/anonymous_enable=YES/g' /etc/vsftpd.conf
sed -i -e 's/#write_enable=YES/write_enable=YES/g' /etc/vsftpd.conf

# Crear carpetas FTP
print_message "Creando carpetas públicas en el servidor FTP..."
mkdir -p /var/ftp/pub
touch /var/ftp/pub/datos_empresita.txt
touch /var/ftp/pub/empleados_empresita.txt
systemctl restart vsftpd

# Crear servicio de monitorización
print_message "Creando servicio de monitorización de tráfico SSH y HTTP..."
cat << EOT > /etc/systemd/system/tcpdump-ssh-http.service
[Unit]
Description=Captura tráfico SSH y HTTP
After=network.target

[Service]
ExecStart=/usr/sbin/tcpdump -i eth0 -w /var/log/ssh_traffic.pcap port 22 or port 80
Restart=on-failure
User=root
Group=root
ExecStartPre=/usr/sbin/tcpdump -D
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=tcpdump-ssh-http

[Install]
WantedBy=multi-user.target
EOT

# Reiniciar systemd y activar el servicio
print_message "Activando el servicio de monitorización..."
systemctl daemon-reload
systemctl enable tcpdump-ssh-http.service
systemctl start tcpdump-ssh-http.service

# Configuración de firewall
print_message "Configurando el firewall..."
ufw allow 22
ufw allow 80
ufw --force enable

EOF

print_message "Ejecución del script completada."
