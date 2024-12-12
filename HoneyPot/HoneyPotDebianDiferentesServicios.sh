#!/bin/bash

#Para ejecucción remota
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

function print_ejecución_correcta() {
    echo -e "${GREEN}[COMANDOS EJECUTADOS CORRECTAMENTE]${NC} $1"
}

function print_atención() {
    echo -e "${BLUE}[ATENCIÓN]${NC} $1"
}
# ACTUALIZAR LISTA DE CONTENEDORES
  print_info "Actualizando La Lista De Plantillas De Contenedores..."
  pveam update
  if [ $? -eq 0 ]; then
    print_ejecución_correcta "La Actualización Se Ha Completado Satisfactoriamente..."
 else
     print_error "La Actualización Ha Fallado Se Va a Parar El Script..."
     exit
fi

ID_CONTENEDOR = 112

# DESCARGA DEL CONTENEDOR DE DEBIAN 12
  print_info "Descargando la Plantilla de Debian 12..."
  pveam download local debian-12-standard_12.7-1_amd64.tar.zst
  if [ $? -eq 0 ]; then
    print_ejecución_correcta "La Descarga Se Ha Completado Satisfactoriamente..."
 else
     print_error "La Descarga Ha Fallado Se Va a Parar El Script..."
     exit
fi

# CREACIÓN DEL CONTENEDOR
  print_info "Creando el Contenedor Debian..."
  pct create $ID_CONTENEDOR local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst \
  --hostname servidores-importantes \
  --storage local-lvm \
  --rootfs 8 \
  --memory 2048 \
  --cores 2 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --password P@ssw0rd!
if [ $? -eq 0 ]; then
    print_ejecución_correcta "Se Ha Creado El Contenedor Debian Con ID $ID_CONTENEDOR..."
 else
     print_error "La Creación Ha Fallado Se Va a Parar el Script..."
     exit
fi
   

# INICIANDO EL CONTENEDOR
  print_info "Iniciando el contenedor Debian..."
  pct start $ID_CONTENEDOR
  if [ $? -eq 0 ]; then
    print_ejecución_correcta "Contenedor $ID_CONTENEDOR Iniciado Correctamente..."
 else
     print_error "La Inicialización ha Fallado Se Va a Parar el Script..."
     exit
fi

# CONEXIÓN AL DEBIAN
print_info "Iniciando Los Comandos De Configuración..."
pct exec $ID_CONTENEDOR

# ACTUALIZAR EL SISTEMA
    print_message "Actualizando el sistema dentro del contenedor..."
    apt update
    if [ $? -eq 0 ]; then
    print_ejecución_correcta "Descarga De Repositorios En El Contenedor $ID_CONTENEDOR Correcta..."
 else
     print_error "La Descarga De Repositorios Ha Fallado Se Va a Parar el Script..."
     exit
fi
     apt upgrade -y
    if [ $? -eq 0 ]; then
    print_ejecución_correcta "Actualización Del Sistema Correcta..."
 else
     print_error "La Actualización Ha Fallado Se Va a Parar el Script..."
     exit
fi
   
    

