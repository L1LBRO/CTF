#!/bin/bash

# Mensajes
cRED='\033[0;31m'
cGREEN='\033[0;32m'
cYELLOW='\033[1;33m'
cBLUE='\033[1;34m'
cNC='\033[0m' # Sin color

function print_info() {
    echo -e "${cYELLOW}[INFO]${cNC} $1"
}

function print_error() {
    echo -e "${cRED}[ERROR EN LA EJECUCIÓN DEL CÓDIGO]${cNC} $1"
}

function print_success() {
    echo -e "${cGREEN}[COMANDOS EJECUTADOS CORRECTAMENTE]${cNC} $1"
}

# Variables
vID_CONTENEDOR=112
vTEMPLATE="debian-12-standard_12.7-1_amd64.tar.zst"
vSTORAGE="local-lvm"
vPASSWORD="P@ssw0rd!"

# Crear el contenedor y realizar la configuración
print_info "Entrando al contenedor Debian para su configuración..."
pct enter $vID_CONTENEDOR <<EOF

# Variables de color dentro del contenedor
cRED='\033[0;31m'
cGREEN='\033[0;32m'
cYELLOW='\033[1;33m'
cBLUE='\033[1;34m'
cNC='\033[0m' # Sin color

function print_info() {
    echo -e "${cYELLOW}[INFO]${cNC} $1"
}

function print_error() {
    echo -e "${cRED}[ERROR EN LA EJECUCIÓN DEL CÓDIGO]${cNC} $1"
}

function print_success() {
    echo -e "${cGREEN}[COMANDOS EJECUTADOS CORRECTAMENTE]${cNC} $1"
}

# Actualizar repositorios
print_info "Actualizando los repositorios..."
apt update
if [ $? -eq 0 ]; then
    print_success "Repositorios actualizados correctamente."
else
    print_error "Error al actualizar los repositorios."
    exit 1
fi

# Actualizar el sistema
print_info "Actualizando el sistema..."
apt upgrade -y
if [ $? -eq 0 ]; then
    print_success "Sistema actualizado correctamente."
else
    print_error "Error al actualizar el sistema."
    exit 1
fi

# Instalar dependencias
DEPENDENCIAS=(openssh-server nginx rsyslog ufw vsftpd mariadb-server git tcpdump curl)
for DEP in "${DEPENDENCIAS[@]}"; do
    print_info "Instalando $DEP..."
    apt install -y $DEP
    if [ $? -eq 0 ]; then
        print_success "$DEP instalado correctamente."
    else
        print_error "Error al instalar $DEP."
        exit 1
    fi
    sleep 2
done

# Configurar SSH para vulnerabilidades simuladas
print_info "Modificando configuración de SSH para simular vulnerabilidades..."
sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e 's/#LogLevel INFO/LogLevel VERBOSE/g' /etc/ssh/sshd_config
if [ $? -eq 0 ]; then
    print_success "Configuración de SSH modificada correctamente."
else
    print_error "Error al modificar la configuración de SSH."
    exit 1
fi

EOF

print_success "Configuración del contenedor completada correctamente."
