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
for service in openssh-server nginx rsyslog ufw vsftpd mariadb-server git tcpdump; do
    apt install "$service" -y
    if [ $? -eq 0 ]; then
        print_success "$service instalado..."
    else
        print_error "Error al instalar $service..."
        exit 1
    fi
    sleep 2
done

sleep 2
for on in ssh nginx rsyslog ufw vsftpd mariadb.service; do
    systemctl start "$on"
    systemctl enable "$on"
    if [ $? -eq 0 ]; then
        print_success "$service activado..."
    else
        print_error "Error al activar $service..."
        exit 1
    fi
    sleep 2
    done


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
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html/web-empresita;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files $uri $uri/ =404;
                # proxy_pass http://localhost:8080;
                # proxy_http_version 1.1;
                # proxy_set_header Upgrade $http_upgrade;
                # proxy_set_header Connection upgrade;
                # proxy_set_header Host $host;
                # proxy_cache_bypass $http_upgrade;
        }

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #       include snippets/fastcgi-php.conf;
        #
        #       # With php7.0-cgi alone:
        #       fastcgi_pass 127.0.0.1:9000;
        #       # With php7.0-fpm:
        #       fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        #}

}
EOT'

if [ $? -eq 0 ]; then
    print_success
    echo "Fichero web-empresita creado correctamente..."
else
    print_error
    echo "Fallo al momento de crear el fichero /etc/nginx/sites-available/web-empresita..."
    echo "Crear el fichero de manera de manual o cambiar el default..."
fi
sleep 4

print_info
echo "Configurando página web como principal..."
sleep 2

sudo ln -s /etc/nginx/sites-available/web-empresita /etc/nginx/sites-enabled/web-empresita


if [ $? -eq 0 ]; then
    print_success
    echo "Página web establecida correctamenta..."
else
    print_error
    echo "Fallo al establecer el link simbólico al /etc/nginx/sites-enabled/..."
    echo "Ejecutar el comando de manera manual..."
fi
sleep 4

print_info
echo "Borrando fichero defaul..."
sleep 2

rm /etc/nginx/sites-enabled/default
if [ $? -eq 0 ]; then
    print_success
    echo "Fichero default borrado..."
else
    print_error
    echo "Fallo al borrar el fichero default..."
    echo "Es posible que la página web no se muestre hasta que se elimine el fichero default..."
    echo "Deberá borrarse manualmente..."
fi
sleep 4

print_success
echo "Configuración web establecida correctamente..."
sleep 2

#print_info
#echo "Configurando MariaDB"

# Variables para MariaDB

#vDB_NAME="usuarios"
#vDB_USER="root"
#vDB_PASSWORD="P@ssw0rd!"
#vROOT_PASSWORD="P@ssw0rd!"
#vCONFIG_FILE="/etc/mysql/my.cnf"


