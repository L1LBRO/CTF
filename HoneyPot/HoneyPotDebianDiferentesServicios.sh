#!/bin/bash

# EJECUCIÓN REMOTA
    # curl -sL https://raw.githubusercontent.com/L1LBRO/CTF/refs/heads/main/HoneyPot/HoneyPotDebianDiferentesServicios.sh | bash


# Mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # Sin color

function print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

function print_error() {
    echo -e "${RED}[ERROR EN LA EJECUCIÓN DEL CÓDIGO]${NC} $1"
}

function print_success() {
    echo -e "${GREEN}[COMANDOS EJECUTADOS CORRECTAMENTE]${NC} $1"
}

# Actualizar lista de plantillas
print_info "Actualizando la lista de plantillas de contenedores..."
pveam update
if [ $? -eq 0 ]; then
    print_success "Lista de plantillas actualizada correctamente."
else
    print_error "Error al actualizar la lista de plantillas. Abortando..."
    exit 1
fi

# Variables
ID_CONTENEDOR=112
TEMPLATE="debian-12-standard_12.7-1_amd64.tar.zst"
STORAGE="local-lvm"
PASSWORD="P@ssw0rd!"

# Descargar la plantilla Debian 12
print_info "Descargando la plantilla de Debian 12..."
pveam download local $TEMPLATE
if [ $? -eq 0 ]; then
    print_success "Plantilla descargada correctamente."
else
    print_error "Error al descargar la plantilla. Abortando..."
    exit 1
fi

# Crear el contenedor
print_info "Creando el contenedor Debian..."
pct create $ID_CONTENEDOR local:vztmpl/$TEMPLATE \
    --hostname servidores-importantes \
    --storage $STORAGE \
    --rootfs 8 \
    --memory 2048 \
    --cores 2 \
    --net0 name=eth0,bridge=vmbr0,ip=dhcp \
    --password $PASSWORD
if [ $? -eq 0 ]; then
    print_success "Contenedor creado correctamente."
else
    print_error "Error al crear el contenedor. Abortando..."
    exit 1
fi

# Iniciar el contenedor
print_info "Iniciando el contenedor Debian..."
pct start $ID_CONTENEDOR
if [ $? -eq 0 ]; then
    print_success "Contenedor iniciado correctamente."
else
    print_error "Error al iniciar el contenedor. Abortando..."
    exit 1
fi

# Actualizar el contenedor
print_info "Actualización del contenedor en curso..."
pct exec $ID_CONTENEDOR -- apt update 
if [ $? -eq 0 ]; then
    print_sucess "Repositorios actualizados correctamente"
else
    print_error "Error en la actualización de repositorios..."
    exit 1
fi

pct exec $ID_CONTENEDOR -- apt upgrade -y
if [ $? -eq 0 ]; then
    print_sucess "Sistema actualizado correctamente"
else
    print_error "Error en la actualización del sistema..."
    exit 1
fi



sdfsdfs





