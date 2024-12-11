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
    print_message "Sistema actualizado..."

# INSTALAR LOS PROGRAMAS NECESARIOS
    print_message "Descargando servicios necesarios para el correcto funcionamiento del honeypot..."
    apt install openssh-server -y && apt install nginx -y && apt install curl -y && apt install tcpdump -y && apt install rsyslog -y && apt install ufw -y && apt install vsftpd -y && apt install mariadb-server -y \
    apt install git -y
    print_message "Servicios necesarios descargados..."

# MODIFICACIÓN DEL FICHERO SSH PARA HACERLO PARECER VULNERABLE
    print_message "Modificando configuraciones de SSH para simular vulnerabilidades..."
    sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
    sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    sed -i -e 's/#LogLevel INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config
    print_message "SSH vulnerable creado..."

# REINICIO DEL SERVICIO SSH
    print_message "Reiniciando el servicio SSH..."
    /etc/init.d/ssh restart
    print_message "Servicio Reiniciado..."

# CREACIÓN DE USUARIOS Y CONTRASEÑAS INSEGURAS
    print_message "Creando usuarios con contraseñas débiles..."
    touch /etc/passwords.txt
    useradd -m user1
    echo "user:P@ssw0rd!" | chpasswd
    echo "user:P@ssw0rd!" >> /etc/passwords.txt
    print_message "Usuarios y contraseñas creadas correctamente..."

# CONFIGURACIÓN DEL SERVICIO WEB
    print_message "Configurando el servidor web..."
    print_message "Clonando el repositorio de la página web..."
    git clone https://github.com/L1LBRO/CTF.git
    mv CTF/HoneyPot/HoneyPotPage /var/www/html/
    rm -r CTF
    print_message "Servicio web en correcto funcionamiento en el Puerto 80..."
    
# REINICIO DEL SERVICIO WEB
    print_message "Reinicio de NGINX..."
    /etc/init.d/nginx restart
    print_message "Servicio reiniciado correctamente..."

# CONFIGURAR SERVIDOR FTP
    print_message "Configurando el servidor FTP..."
    sed -i -e 's/anonymous_enable=NO/anonymous_enable=YES/g' /etc/vsftpd.conf
    sed -i -e 's/#write_enable=YES/write_enable=YES/g' /etc/vsftpd.conf
    print_message "FTP vulnerable configurado correctamente..."

# CREAR CARPETAS FTP
    print_message "Creando carpetas públicas en el servidor FTP..."
    mkdir -p /var/ftp/pub
    touch /var/ftp/pub/datos_empresita.txt
    touch /var/ftp/pub/empleados_empresita.txt
    systemctl restart vsftpd
    print_message "Carpetas FTP creadas correctamente..."

# CREAR SERVICIO EN SYSTEMD PARA MONITORIZAR SHH
    print_message "Creando servicio de monitorización de tráfico SSH..."
    # TODO LO ESCRITO DENTRO DE EOT SE ESCRIBE DENTRO DEL TXT DE CONFIGURACIÓN
    cat << EOT > /etc/systemd/system/tcpdump-ssh.service
        [Unit]
        Description=Captura tráfico SSH
        After=network.target
    
        [Service]
        ExecStart=/usr/sbin/tcpdump -i eth0 -w /var/log/ssh_traffic.pcap port 22
        Restart=on-failure
        User=root
        Group=root
        ExecStartPre=/usr/sbin/tcpdump -D
        StandardOutput=syslog
        StandardError=syslog
        SyslogIdentifier=tcpdump-ssh
    
        [Install]
        WantedBy=multi-user.target
    EOT
    print_message "Servicio en systemd para SSH creado..."

# CREAR SERVICIO EN SYSTEMD PARA MONITORIZAR EL SERVICIO WEB
    print_message "Creando servicio de monitorización de tráfico web (HTTP)..."
    # TODO LO ESCRITO DENTRO DE EOT SE ESCRIBE DENTRO DEL TXT DE CONFIGURACIÓN
    cat << EOT > /etc/systemd/system/tcpdump-http.service
    [Unit]
    Description=Captura tráfico HTTP
    After=network.target

    [Service]
    ExecStart=/usr/sbin/tcpdump -i eth0 -w /var/log/http_traffic.pcap port 80
    Restart=on-failure
    User=root
    Group=root
    ExecStartPre=/usr/sbin/tcpdump -D
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=tcpdump-http

    [Install]
    WantedBy=multi-user.target
    EOT
    print_message "Servicio en systemd para HTTP creado..."

# CREAR SERVICIO EN SYSTEMD PARA MONITORIZAR FTP
    print_message "Creando servicio de monitorización de tráfico FTP..."
    # TODO LO ESCRITO DENTRO DE EOT SE ESCRIBE DENTRO DEL TXT DE CONFIGURACIÓN
    cat << EOT > /etc/systemd/system/tcpdump-ftp.service
    [Unit]
    Description=Captura tráfico FTP
    After=network.target
    
    [Service]
    ExecStart=/usr/sbin/tcpdump -i eth0 -w /var/log/ftp_traffic.pcap port 21
    Restart=on-failure
    User=root
    Group=root
    ExecStartPre=/usr/sbin/tcpdump -D
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=tcpdump-ftp
    
    [Install]
    WantedBy=multi-user.target
    EOT
    print_message "Servicio en systemd para ssh creado..."

# CREAR SERVICIO EN SYSTEMD PARA MONITORIZAR MARIADB
    print_message "Creando servicio de monitorización de tráfico MARIADB..."
    # TODO LO ESCRITO DENTRO DE EOT SE ESCRIBE DENTRO DEL TXT DE CONFIGURACIÓN
    cat << EOT > /etc/systemd/system/tcpdump-mariadb.service
    [Unit]
    Description=Captura tráfico MARIADB
    After=network.target
    
    [Service]
    ExecStart=/usr/sbin/tcpdump -i eth0 -w /var/log/mariadb_traffic.pcap port 3306
    Restart=on-failure
    User=root
    Group=root
    ExecStartPre=/usr/sbin/tcpdump -D
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=tcpdump-mariadb
    
    [Install]
    WantedBy=multi-user.target
    EOT
    print_message "Servicio en systemd para MARIADB creado..."

# REINICIAR SYSTEMD Y ACTIVAR LOS SERVICIOS RECIÉN CREADOS
    print_message "Activando los servicios de monitorización..."
    
    print_message "Reiniciando SYSTEMD..."
    systemctl daemon-reload
    
    print_message "Inicializando el servicio de monitoreo de SSH..."
    systemctl enable tcpdump-ssh.service
    systemctl start tcpdump-ssh.service

    print_message "Inicializando el servicio de monitoreo de HTTP..."
    systemctl enable tcpdump-http.service
    systemctl start tcpdump-http.service

    print_message "Inicializando el servicio de monitoreo de FTP..."
    systemctl enable tcpdump-ftp.service
    systemctl start tcpdump-ftp.service

    print_message "Inicializando el servicio de monitoreo de mariadb..."
    systemctl enable tcpdump-mariadb.service
    systemctl start tcpdump-mariadb.service
    
    print_message "Servicios Inicializados correctamente..."

# CONFIGURACIÓN BÁSICA DEL FW
print_message "Configurando el firewall..."
ufw allow 22
ufw allow 80
ufw allow 21
ufw allo 3306
ufw --force enable
print_message "FW Básico configurado..."

EOF

print_message "Ejecución del script completada."
