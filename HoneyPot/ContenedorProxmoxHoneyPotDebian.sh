#!/bin/bash

# EJECUCIÓN REMOTA
    # curl -sL https://raw.githubusercontent.com/L1LBRO/CTF/refs/heads/main/HoneyPot/ContenedorProxmoxHoneyPotDebian.sh | bash


# Mensajes
cRED='\033[0;31m'
cGREEN='\033[0;32m'
cYELLOW='\033[1;33m'
cBLUE='\033[1;34m'
cNC='\033[0m' # Sin color

function print_info() {
    echo -e "${cYELLOW}[INFO]${NC} $1"
}

function print_error() {
    echo -e "${cRED}[ERROR EN LA EJECUCIÓN DEL CÓDIGO]${NC} $1"
}

function print_success() {
    echo -e "${cGREEN}[COMANDOS EJECUTADOS CORRECTAMENTE]${NC} $1"
}

# Actualizar lista de plantillas
print_info "Actualizando la lista de plantillas de contenedores..."
sleep 5
pveam update
if [ $? -eq 0 ]; then
    print_success "Lista de plantillas actualizada correctamente..."
else
    print_error "Error al actualizar la lista de plantillas. Abortando..."
    exit 1
fi
sleep 5

# Variables
vID_CONTENEDOR=112
vTEMPLATE="debian-12-standard_12.7-1_amd64.tar.zst"
vSTORAGE="local-lvm"
vPASSWORD="P@ssw0rd!"


# Descargar la plantilla Debian 12
print_info "Descargando la plantilla de Debian 12..."
sleep 5
pveam download local $vTEMPLATE
if [ $? -eq 0 ]; then
    print_success "Plantilla descargada correctamente."
else
    print_error "Error al descargar la plantilla. Abortando..."
    exit 1
fi
sleep 5

# Crear el contenedor
print_info "Creando el contenedor Debian..."
sleep 5
pct create $vID_CONTENEDOR local:vztmpl/$vTEMPLATE \
    --hostname servidores-importantes \
    --storage $vSTORAGE \
    --rootfs 8 \
    --memory 2048 \
    --cores 2 \
    --net0 name=eth0,bridge=vmbr0,ip=dhcp \
    --password $vPASSWORD
if [ $? -eq 0 ]; then
    print_success "Contenedor creado correctamente."
else
    print_error "Error al crear el contenedor. Abortando..."
    exit 1
fi
sleep 5

# Iniciar el contenedor
print_info "Iniciando el contenedor Debian..."
sleep 5
pct start $vID_CONTENEDOR
if [ $? -eq 0 ]; then
    print_success "Contenedor iniciado correctamente."
else
    print_error "Error al iniciar el contenedor. Abortando..."
    exit 1
fi
sleep 5

# Actualizar el contenedor
print_info "Entrando al contenedor Debian para su configuración..."
pct enter $vID_CONTENEDOR
curl -sL https://raw.githubusercontent.com/L1LBRO/CTF/refs/heads/main/HoneyPot/CrearConfigurarDebianHoneyPot.sh | bash
sleep 5
