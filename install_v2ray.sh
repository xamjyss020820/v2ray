#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cd "$(
    cd "$(dirname "$0")" || exit
    pwd
)" || exit
#====================================================
#	System Request:Debian 9+/Ubuntu 18.04+/Centos 7+
#	Author:	wulabing
#	Dscription: V2ray ws+tls onekey Management
#	Version: 1.0
#	email:admin@wulabing.com
#	Official document: www.v2ray.com
#====================================================

#fonts color
Green="\033[32m"
Red="\033[31m"
# Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#notification information
# Info="${Green}[INFORMATION]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[ERROR]${Font}"

# VERSION
shell_version="1.1.5.7"
shell_mode="None"
github_branch="master"
version_cmp="/tmp/version_cmp.tmp"
v2ray_conf_dir="/etc/v2ray"
nginx_conf_dir="/etc/nginx/conf/conf.d"
v2ray_conf="${v2ray_conf_dir}/config.json"
nginx_conf="${nginx_conf_dir}/v2ray.conf"
nginx_dir="/etc/nginx"
web_dir="/home/wwwroot"
nginx_openssl_src="/usr/local/src"
v2ray_bin_dir_old="/usr/bin/v2ray"
v2ray_bin_dir="/usr/local/bin"
v2ray_info_file="$HOME/v2ray_info.inf"
v2ray_qr_config_file="/usr/local/vmess_qr.json"
nginx_systemd_file="/etc/systemd/system/nginx.service"
v2ray_systemd_file="/etc/systemd/system/v2ray.service"
v2ray_access_log="/var/log/v2ray/access.log"
v2ray_error_log="/var/log/v2ray/error.log"
amce_sh_file="/root/.acme.sh/acme.sh"
ssl_update_file="/usr/bin/ssl_update.sh"
nginx_version="1.18.0"
openssl_version="1.1.1g"
jemalloc_version="5.2.1"
old_config_status="off"
# v2ray_plugin_version="$(wget -qO- "https://github.com/shadowsocks/v2ray-plugin/tags" | grep -E "/shadowsocks/v2ray-plugin/releases/tag/" | head -1 | sed -r 's/.*tag\/v(.+)\">.*/\1/')"

#Mobile old version configuration information Adapt to version less than 1.1.0
[[ -f "/etc/v2ray/vmess_qr.json" ]] && mv /etc/v2ray/vmess_qr.json $v2ray_qr_config_file

#Simple random number
random_num=$((RANDOM%12+4))
#Generate camouflage path
#camouflage="/$(head -n 10 /dev/urandom | md5sum | head -c ${random_num})/"
 apt-get update
 apt-get upgrade -y
 gem install lolcat
 clear
[[ ! "$(command -v curl)" ]] && apt install curl -y -qq
[[ ! "$(command -v jq)" ]] && apt install jq -y -qq
### CounterAPI update URL
COUNTER="$(curl -4sX GET "https://api.countapi.xyz/hit/BonvScripts/DebianVPS-Installer" | jq -r '.value')"

IPADDR="$(curl -4skL http://ipinfo.io/ip)"

GLOBAL_API_KEY="48f416ac6a55e0ff8525812f3480edbb1ca8f"
CLOUDFLARE_EMAIL="jorjanseenearlbade@gmail.com"
DOMAIN_NAME_TLD="origenesdev.codes"
DOMAIN_ZONE_ID="db412141e7eda53f113735404d9b77ef"
### DNS hostname / Payload here
## Setting variable

####
## Creating file dump for DNS Records 
TMP_FILE='/tmp/abonv.txt'
curl -sX GET "https://api.cloudflare.com/client/v4/zones/$DOMAIN_ZONE_ID/dns_records?type=A&count=1000&per_page=1000" -H "X-Auth-Key: $GLOBAL_API_KEY" -H "X-Auth-Email: $CLOUDFLARE_EMAIL" -H "Content-Type: application/json" | python -m json.tool > "$TMP_FILE"

## Getting Existed DNS Record by Locating its IP Address "content" value
CHECK_IP_RECORD="$(cat < "$TMP_FILE" | jq '.result[]' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' | jq '. | select(.content=='\"$IPADDR\"')' | jq -r '.content' | awk '!a[$0]++')"

cat < "$TMP_FILE" | jq '.result[]' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' | jq '. | select(.content=='\"$IPADDR\"')' | jq -r '.name' | awk '!a[$0]++' | head -n1 > /tmp/abonv_existed_hostname

cat < "$TMP_FILE" | jq '.result[]' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' | jq '. | select(.content=='\"$IPADDR\"')' | jq -r '.id' | awk '!a[$0]++' | head -n1 > /tmp/abonv_existed_dns_id

function ExistedRecord(){
 MYDNS="$(cat /tmp/abonv_existed_hostname)"
 MYDNS_ID="$(cat /tmp/abonv_existed_dns_id)"
}


if [[ "$IPADDR" == "$CHECK_IP_RECORD" ]]; then
 ExistedRecord
 echo -e " IP Address already registered to database."
 echo -e " DNS: $MYDNS"
 echo -e " DNS ID: $MYDNS_ID"
 echo -e ""
 else


echo -e "Your IP Address:\033[0;35m $IPADDR\033[0m"
read -p "Enter desired servername: "  servername


### Creating a DNS Record
function CreateRecord(){
TMP_FILE2='/tmp/abonv2.txt'
curl -sX POST "https://api.cloudflare.com/client/v4/zones/$DOMAIN_ZONE_ID/dns_records" -H "X-Auth-Email: $CLOUDFLARE_EMAIL" -H "X-Auth-Key: $GLOBAL_API_KEY" -H "Content-Type: application/json" --data "{\"type\":\"A\",\"name\":\"$servername\",\"content\":\"$IPADDR\",\"ttl\":86400,\"proxied\":false}" | python -m json.tool > "$TMP_FILE2"

cat < "$TMP_FILE2" | jq '.result' | jq 'del(.meta)' | jq 'del(.created_on,.locked,.modified_on,.proxiable,.proxied,.ttl,.type,.zone_id,.zone_name)' > /tmp/abonv22.txt
rm -f "$TMP_FILE2"
mv /tmp/abonv22.txt "$TMP_FILE2"

MYDNS="$(cat < "$TMP_FILE2" | jq -r '.name')"
MYDNS_ID="$(cat < "$TMP_FILE2" | jq -r '.id')"
}

 CreateRecord
 echo -e " Registering your IP Address.."
 echo -e " DNS: $MYDNS"
 echo -e " DNS ID: $MYDNS_ID"
 echo -e ""
fi

rm -rf /tmp/abonv*
echo -e "$DOMAIN_NAME_TLD" > /tmp/abonv_mydns_domain
echo -e "$MYDNS" > /tmp/abonv_mydns
echo -e "$MYDNS_ID" > /tmp/abonv_mydns_id
function  Instupdate() {
 export DEBIAN_FRONTEND=noninteractive

clear
v2path = "xamjyss143"
clear
domain = "$MYDNS"
clear
camouflage="/$v2path/"

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

source '/etc/os-release'

#Extract the English name of the distribution system from VERSION, in order to add the corresponding Nginx apt source under debian/ubuntu
VERSION=$(echo "${VERSION}" | awk -F "[()]" '{print $2}')

check_system() {
    if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]]; then
        echo -e "${OK} ${GreenBG} The current system is Centos ${VERSION_ID} ${VERSION} ${Font}"
        INS="yum"
    elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]]; then
        echo -e "${OK} ${GreenBG} The current system is Debian ${VERSION_ID} ${VERSION} ${Font}"
        INS="apt"
        $INS update
	apt-get upgrade -y
        ## Add Nginx apt source
    elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 16 ]]; then
        echo -e "${OK} ${GreenBG} The current system is Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME} ${Font}"
        INS="apt"
        $INS update
	apt-get upgrade -y
    else
        echo -e "${Error} ${RedBG} The current system is ${ID} ${VERSION_ID} Not in the list of supported systems, installation interrupted ${Font}"
        exit 1
    fi

    $INS install dbus

    systemctl stop firewalld
    systemctl disable firewalld
    echo -e "${OK} ${GreenBG} firewalld closed ${Font}"

    systemctl stop ufw
    systemctl disable ufw
    echo -e "${OK} ${GreenBG} ufw closed ${Font}"
}

is_root() {
    if [ 0 == $UID ]; then
        echo -e "${OK} ${GreenBG} The current user is the root user, enter the installation process ${Font}"
        sleep 3
    else
        echo -e "${Error} ${RedBG} The current user is not the root user, please switch to the root user and re-execute the script ${Font}"
        exit 1
    fi
}
judge() {
    if [[ 0 -eq $? ]]; then
        echo -e "${OK} ${GreenBG} $1 carry out ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} $1 failure ${Font}"
        exit 1
    fi
}
chrony_install() {
    ${INS} -y install chrony
    judge "Install chrony time synchronization service "

    timedatectl set-ntp true

    if [[ "${ID}" == "centos" ]]; then
        systemctl enable chronyd && systemctl restart chronyd
    else
        systemctl enable chrony && systemctl restart chrony
    fi

    judge "chronyd start"

    timedatectl set-timezone Asia/Manila

    echo -e "${OK} ${GreenBG} Waiting time synchronization ${Font}"
    sleep 10

    chronyc sourcestats -v
    chronyc tracking -v
    date
    chrony_install="Y"
    #read -rp "Please confirm whether the time is accurate, the error range is ±3 minutes(Y/N): " chrony_install
    #[[ -z ${chrony_install} ]] && chrony_install="Y"
    #case $chrony_install in
    #[yY][eE][sS] | [yY])
    #    echo -e "${GreenBG} Continue installation ${Font}"
    #    sleep 2
    #    ;;
    #*)
    #    echo -e "${RedBG} Installation terminated ${Font}"
    #    exit 2
    #    ;;
    #esac
}

dependency_install() {
    ${INS} install wget git lsof -y

    if [[ "${ID}" == "centos" ]]; then
        ${INS} -y install crontabs
    else
        ${INS} -y install cron
    fi
    judge "Install crontab"

    if [[ "${ID}" == "centos" ]]; then
        touch /var/spool/cron/root && chmod 600 /var/spool/cron/root
        systemctl start crond && systemctl enable crond
    else
        touch /var/spool/cron/crontabs/root && chmod 600 /var/spool/cron/crontabs/root
        systemctl start cron && systemctl enable cron

    fi
    judge "crontab self-starting configuration "

    ${INS} -y install bc
    judge "installation bc"

    ${INS} -y install unzip
    judge "installation unzip"

    ${INS} -y install qrencode
    judge "installation qrencode"

    ${INS} -y install curl
    judge "installation curl"

    if [[ "${ID}" == "centos" ]]; then
        ${INS} -y groupinstall "Development tools"
    else
        ${INS} -y install build-essential
    fi
    judge "Compilation toolkit installation"

    if [[ "${ID}" == "centos" ]]; then
        ${INS} -y install pcre pcre-devel zlib-devel epel-release
    else
        ${INS} -y install libpcre3 libpcre3-dev zlib1g-dev dbus
    fi

    #    ${INS} -y install rng-tools
    #    judge "rng-tools installation"

    ${INS} -y install haveged
    #    judge "haveged installation"

    #    sed -i -r '/^HRNGDEVICE/d;/#HRNGDEVICE=\/dev\/null/a HRNGDEVICE=/dev/urandom' /etc/default/rng-tools

    if [[ "${ID}" == "centos" ]]; then
        #       systemctl start rngd && systemctl enable rngd
        #       judge "rng-tools start up"
        systemctl start haveged && systemctl enable haveged
        #       judge "haveged start up"
    else
        #       systemctl start rng-tools && systemctl enable rng-tools
        #       judge "rng-tools start up"
        systemctl start haveged && systemctl enable haveged
        #       judge "haveged start up"
    fi
}
basic_optimization() {
    # Maximum number of open files
    sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
    sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
    echo '* soft nofile 65536' >>/etc/security/limits.conf
    echo '* hard nofile 65536' >>/etc/security/limits.conf

    # shut down Selinux
    if [[ "${ID}" == "centos" ]]; then
        sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
        setenforce 0
    fi

}
port_alterid_set() {
    if [[ "on" != "$old_config_status" ]]; then
    	port="443"
	alterID="2"
        #read -rp "Please enter the connection port（default:443）:" port
        #[[ -z ${port} ]] && port="443"
        #read -rp "Please enter alterID（default:2 Only numbers allowed）:" alterID
        #[[ -z ${alterID} ]] && alterID="2"
    fi
}
modify_path() {
    if [[ "on" == "$old_config_status" ]]; then
        camouflage="$(grep '\"path\"' $v2ray_qr_config_file | awk -F '"' '{print $4}')"
    fi
    sed -i "/\"path\"/c \\\t  \"path\":\"${camouflage}\"" ${v2ray_conf}
    judge "V2ray Camouflage path modification"
}
modify_alterid() {
    if [[ "on" == "$old_config_status" ]]; then
        alterID="$(grep '\"aid\"' $v2ray_qr_config_file | awk -F '"' '{print $4}')"
    fi
    sed -i "/\"alterId\"/c \\\t  \"alterId\":${alterID}" ${v2ray_conf}
    judge "V2ray alterid modification"
    [ -f ${v2ray_qr_config_file} ] && sed -i "/\"aid\"/c \\  \"aid\": \"${alterID}\"," ${v2ray_qr_config_file}
    echo -e "${OK} ${GreenBG} alterID:${alterID} ${Font}"
}
modify_inbound_port() {
    if [[ "on" == "$old_config_status" ]]; then
        port="$(info_extraction '\"port\"')"
    fi
    if [[ "$shell_mode" != "h2" ]]; then
        PORT=$((RANDOM + 10000))
        sed -i "/\"port\"/c  \    \"port\":${PORT}," ${v2ray_conf}
    else
        sed -i "/\"port\"/c  \    \"port\":${port}," ${v2ray_conf}
    fi
    judge "V2ray inbound_port modify"
}
modify_UUID() {
    [ -z "$UUID" ] && UUID=$(cat /proc/sys/kernel/random/uuid)
    if [[ "on" == "$old_config_status" ]]; then
        UUID="$(info_extraction '\"id\"')"
    fi
    sed -i "/\"id\"/c \\\t  \"id\":\"${UUID}\"," ${v2ray_conf}
    judge "V2ray UUID modify"
    [ -f ${v2ray_qr_config_file} ] && sed -i "/\"id\"/c \\  \"id\": \"${UUID}\"," ${v2ray_qr_config_file}
    echo -e "${OK} ${GreenBG} UUID:${UUID} ${Font}"
}
modify_nginx_port() {
    if [[ "on" == "$old_config_status" ]]; then
        port="$(info_extraction '\"port\"')"
    fi
    sed -i "/ssl http2;$/c \\\tlisten ${port} ssl http2;" ${nginx_conf}
    sed -i "3c \\\tlisten [::]:${port} http2;" ${nginx_conf}
    judge "V2ray port modify"
    [ -f ${v2ray_qr_config_file} ] && sed -i "/\"port\"/c \\  \"port\": \"${port}\"," ${v2ray_qr_config_file}
    echo -e "${OK} ${GreenBG} 端口号:${port} ${Font}"
}
modify_nginx_other() {
    sed -i "/server_name/c \\\tserver_name ${domain};" ${nginx_conf}
    sed -i "/location/c \\\tlocation ${camouflage}" ${nginx_conf}
    sed -i "/proxy_pass/c \\\tproxy_pass http://127.0.0.1:${PORT};" ${nginx_conf}
    sed -i "/return/c \\\treturn 301 https://${domain}\$request_uri;" ${nginx_conf}
    #sed -i "27i \\\tproxy_intercept_errors on;"  ${nginx_dir}/conf/nginx.conf
}
web_camouflage() {
    ##Please note that this conflicts with the default path of the LNMP script. Do not use this script in an environment where LNMP is installed, otherwise you will be responsible for the consequences
    rm -rf /home/wwwroot
    mkdir -p /home/wwwroot
    cd /home/wwwroot || exit
    git clone https://github.com/itsgelogomayee/3DCEList.git
    judge "web site camouflage"
}
v2ray_install() {
    if [[ -d /root/v2ray ]]; then
        rm -rf /root/v2ray
    fi
    if [[ -d /etc/v2ray ]]; then
        rm -rf /etc/v2ray
    fi
    mkdir -p /root/v2ray
    cd /root/v2ray || exit
    wget -N --no-check-certificate https://raw.githubusercontent.com/itsgelogomayee/v2ray/${github_branch}/v2ray.sh

    if [[ -f v2ray.sh ]]; then
        rm -rf $v2ray_systemd_file
        systemctl daemon-reload
        bash v2ray.sh --force
        judge "Install V2ray"
    else
        echo -e "${Error} ${RedBG} V2ray The installation file download failed, please check if the download address is available ${Font}"
        exit 4
    fi
    # Clear temporary files
    rm -rf /root/v2ray
}
nginx_exist_check() {
    if [[ -f "/etc/nginx/sbin/nginx" ]]; then
        echo -e "${OK} ${GreenBG} Nginx already exists, skip the compilation and installation process ${Font}"
        sleep 2
    elif [[ -d "/usr/local/nginx/" ]]; then
        echo -e "${OK} ${GreenBG} Nginx installed by other packages is detected. Continue to install will cause conflicts. Please install after handling ${Font}"
        exit 1
    else
        nginx_install
    fi
}
nginx_install() {
    #    if [[ -d "/etc/nginx" ]];then
    #        rm -rf /etc/nginx
    #    fi

    wget -nc --no-check-certificate http://nginx.org/download/nginx-${nginx_version}.tar.gz -P ${nginx_openssl_src}
    judge "Nginx download"
    wget -nc --no-check-certificate https://www.openssl.org/source/openssl-${openssl_version}.tar.gz -P ${nginx_openssl_src}
    judge "openssl download"
    wget -nc --no-check-certificate https://github.com/jemalloc/jemalloc/releases/download/${jemalloc_version}/jemalloc-${jemalloc_version}.tar.bz2 -P ${nginx_openssl_src}
    judge "jemalloc download"

    cd ${nginx_openssl_src} || exit

    [[ -d nginx-"$nginx_version" ]] && rm -rf nginx-"$nginx_version"
    tar -zxvf nginx-"$nginx_version".tar.gz

    [[ -d openssl-"$openssl_version" ]] && rm -rf openssl-"$openssl_version"
    tar -zxvf openssl-"$openssl_version".tar.gz

    [[ -d jemalloc-"${jemalloc_version}" ]] && rm -rf jemalloc-"${jemalloc_version}"
    tar -xvf jemalloc-"${jemalloc_version}".tar.bz2

    [[ -d "$nginx_dir" ]] && rm -rf ${nginx_dir}

    echo -e "${OK} ${GreenBG} About to start compiling and installing jemalloc ${Font}"
    sleep 2

    cd jemalloc-${jemalloc_version} || exit
    ./configure
    judge "Compile check"
    make -j "${THREAD}" && make install
    judge "jemalloc compile and install"
    echo '/usr/local/lib' >/etc/ld.so.conf.d/local.conf
    ldconfig

    echo -e "${OK} ${GreenBG} The compilation and installation of Nginx will begin soon, the process will take a little longer, please be patient ${Font}"
    sleep 4

    cd ../nginx-${nginx_version} || exit

    ./configure --prefix="${nginx_dir}" \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --with-http_stub_status_module \
        --with-pcre \
        --with-http_realip_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_secure_link_module \
        --with-http_v2_module \
        --with-cc-opt='-O3' \
        --with-ld-opt="-ljemalloc" \
        --with-openssl=../openssl-"$openssl_version"
    judge "Compile check"
    make -j "${THREAD}" && make install
    judge "Nginx compile and install"

    # Modify the basic configuration
    sed -i 's/#user  nobody;/user  root;/' ${nginx_dir}/conf/nginx.conf
    sed -i 's/worker_processes  1;/worker_processes  3;/' ${nginx_dir}/conf/nginx.conf
    sed -i 's/    worker_connections  1024;/    worker_connections  4096;/' ${nginx_dir}/conf/nginx.conf
    sed -i '$i include conf.d/*.conf;' ${nginx_dir}/conf/nginx.conf

    # Delete temporary files
    rm -rf ../nginx-"${nginx_version}"
    rm -rf ../openssl-"${openssl_version}"
    rm -rf ../nginx-"${nginx_version}".tar.gz
    rm -rf ../openssl-"${openssl_version}".tar.gz

    # Add a configuration folder to adapt to the old script
    mkdir ${nginx_dir}/conf/conf.d
}
ssl_install() {
    if [[ "${ID}" == "centos" ]]; then
        ${INS} install socat nc -y
    else
        ${INS} install socat netcat -y
    fi
    judge "Install SSL certificate generation script dependency"
    domain_email = "$CLOUDFLARE_EMAIL"
    curl https://get.acme.sh | sh -s email=$domain_email
    judge "Install the SSL certificate generation script"
}
domain_check() {
    
    domain_ip=$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')
    echo -e "${OK} ${GreenBG} Obtaining public network ip information, please be patient ${Font}"
    local_ip=$(curl https://api-ipv4.ip.sb/ip)
    echo -e "Domain name dns resolve IP：${domain_ip}"
    echo -e "Local IP: ${local_ip}"
    sleep 2
    if [[ $(echo "${local_ip}" | tr '.' '+' | bc) -eq $(echo "${domain_ip}" | tr '.' '+' | bc) ]]; then
        echo -e "${OK} ${GreenBG} Domain name dns resolution IP matches the local IP ${Font}"
        sleep 2
    else
        echo -e "${Error} ${RedBG} Please make sure that the correct A record is added to the domain name, otherwise V2ray cannot be used normally ${Font}"
	sleep 2
        #echo -e "${Error} ${RedBG} The DNS resolution IP of the domain name does not match the local IP. Do you want to continue the installation? （y/n）${Font}" && read -r install
        #case $install in
        #[yY][eE][sS] | [yY])
        #    echo -e "${GreenBG} Continue installation ${Font}"
        #    sleep 2
        #    ;;
       	#*)
        #    echo -e "${RedBG} Installation terminated ${Font}"
        #    exit 2
        #    ;;
        # esac
    fi
}

port_exist_check() {
    if [[ 0 -eq $(lsof -i:"$1" | grep -i -c "listen") ]]; then
        echo -e "${OK} ${GreenBG} $1 Port is not occupied ${Font}"
        sleep 1
    else
        echo -e "${Error} ${RedBG} detected $1 The port is occupied, the following is $1 Port occupation information ${Font}"
        lsof -i:"$1"
        echo -e "${OK} ${GreenBG} 5s Will try to automatically kill the occupied process ${Font}"
        sleep 5
        lsof -i:"$1" | awk '{print $2}' | grep -v "PID" | xargs kill -9
        echo -e "${OK} ${GreenBG} kill carry out ${Font}"
        sleep 1
    fi
}
acme() {
    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force --test; then
        echo -e "${OK} ${GreenBG} The SSL certificate test is issued successfully, and the official issuance begins ${Font}"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        sleep 2
    else
        echo -e "${Error} ${RedBG} SSL certificate test issuance failed ${Font}"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        exit 1
    fi

    if "$HOME"/.acme.sh/acme.sh --issue -d "${domain}" --standalone -k ec-256 --force; then
        echo -e "${OK} ${GreenBG} SSL certificate generated successfully ${Font}"
        sleep 2
        mkdir /data
        if "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc --force; then
            echo -e "${OK} ${GreenBG} Certificate configuration is successful ${Font}"
            sleep 2
        fi
    else
        echo -e "${Error} ${RedBG} SSL certificate generation failed ${Font}"
        rm -rf "$HOME/.acme.sh/${domain}_ecc"
        exit 1
    fi
}
v2ray_conf_add_tls() {
    cd /etc/v2ray || exit
    wget --no-check-certificate https://raw.githubusercontent.com/itsgelogomayee/v2ray/${github_branch}/tls/config.json -O config.json
    modify_path
    modify_alterid
    modify_inbound_port
    modify_UUID
}
v2ray_conf_add_h2() {
    cd /etc/v2ray || exit
    wget --no-check-certificate https://raw.githubusercontent.com/itsgelogomayee/v2ray/${github_branch}/http2/config.json -O config.json
    modify_path
    modify_alterid
    modify_inbound_port
    modify_UUID
}
old_config_exist_check() {
    if [[ -f $v2ray_qr_config_file ]]; then
        echo -e "${OK} ${GreenBG} The old configuration file is detected, whether to read the old file configuration [Y/N]? ${Font}"
        read -r ssl_delete
        case $ssl_delete in
        [yY][eE][sS] | [yY])
            echo -e "${OK} ${GreenBG} Old configuration has been retained  ${Font}"
            old_config_status="on"
            port=$(info_extraction '\"port\"')
            ;;
        *)
            rm -rf $v2ray_qr_config_file
            echo -e "${OK} ${GreenBG} Old configuration deleted  ${Font}"
            ;;
        esac
    fi
}
nginx_conf_add() {
    touch ${nginx_conf_dir}/v2ray.conf
    cat >${nginx_conf_dir}/v2ray.conf <<EOF
    server {
        listen 443 ssl http2;
        listen [::]:443 http2;
        ssl_certificate       /data/v2ray.crt;
        ssl_certificate_key   /data/v2ray.key;
        ssl_protocols         TLSv1.3;
        ssl_ciphers           TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
        server_name           serveraddr.com;
        index index.html index.htm;
        root  /home/wwwroot/3DCEList;
        error_page 400 = /400.html;
        # Config for 0-RTT in TLSv1.3
        ssl_early_data on;
        ssl_stapling on;
        ssl_stapling_verify on;
        add_header Strict-Transport-Security "max-age=31536000";
        location /ray/
        {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        # Config for 0-RTT in TLSv1.3
        proxy_set_header Early-Data \$ssl_early_data;
        }
}
    server {
        listen 80;
        listen [::]:80;
        server_name serveraddr.com;
        return 301 https://use.shadowsocksr.win\$request_uri;
    }
EOF

    modify_nginx_port
    modify_nginx_other
    judge "Nginx configuration modification"

}

start_process_systemd() {
    systemctl daemon-reload
    chown -R root.root /var/log/v2ray/
    if [[ "$shell_mode" != "h2" ]]; then
        systemctl restart nginx
        judge "Nginx start"
    fi
    systemctl restart v2ray
    judge "V2ray start"
}

enable_process_systemd() {
    systemctl enable v2ray
    judge "Set v2ray to boot automatically"
    if [[ "$shell_mode" != "h2" ]]; then
        systemctl enable nginx
        judge "Set Nginx to start automatically"
    fi

}

stop_process_systemd() {
    if [[ "$shell_mode" != "h2" ]]; then
        systemctl stop nginx
    fi
    systemctl stop v2ray
}
nginx_process_disabled() {
    [ -f $nginx_systemd_file ] && systemctl stop nginx && systemctl disable nginx
}

#Debian 9 10 adaptation
#rc_local_initialization(){
#    if [[ -f /etc/rc.local ]];then
#        chmod +x /etc/rc.local
#    else
#        touch /etc/rc.local && chmod +x /etc/rc.local
#        echo "#!/bin/bash" >> /etc/rc.local
#        systemctl start rc-local
#    fi
#
#    judge "rc.local Configuration"
#}
acme_cron_update() {
    wget -N -P /usr/bin --no-check-certificate "https://raw.githubusercontent.com/itsgelogomayee/v2ray/master/ssl_update.sh"
    if [[ $(crontab -l | grep -c "ssl_update.sh") -lt 1 ]]; then
      if [[ "${ID}" == "centos" ]]; then
          #        sed -i "/acme.sh/c 0 3 * * 0 \"/root/.acme.sh\"/acme.sh --cron --home \"/root/.acme.sh\" \
          #        &> /dev/null" /var/spool/cron/root
          sed -i "/acme.sh/c 0 3 * * 0 bash ${ssl_update_file}" /var/spool/cron/root
      else
          #        sed -i "/acme.sh/c 0 3 * * 0 \"/root/.acme.sh\"/acme.sh --cron --home \"/root/.acme.sh\" \
          #        &> /dev/null" /var/spool/cron/crontabs/root
          sed -i "/acme.sh/c 0 3 * * 0 bash ${ssl_update_file}" /var/spool/cron/crontabs/root
      fi
    fi
    judge "cron scheduled task update"
}

vmess_qr_config_tls_ws() {
    cat >$v2ray_qr_config_file <<-EOF
{
  "v": "2",
  "ps": "$v2path_${domain}",
  "add": "${domain}",
  "port": "${port}",
  "id": "${UUID}",
  "aid": "${alterID}",
  "net": "ws",
  "type": "none",
  "host": "${domain}",
  "path": "${camouflage}",
  "tls": "tls"
}
EOF
}

vmess_qr_config_h2() {
    cat >$v2ray_qr_config_file <<-EOF
{
  "v": "2",
  "ps": "$v2path_${domain}",
  "add": "${domain}",
  "port": "${port}",
  "id": "${UUID}",
  "aid": "${alterID}",
  "net": "h2",
  "type": "none",
  "path": "${camouflage}",
  "tls": "tls"
}
EOF
}

vmess_qr_link_image() {
    vmess_link="vmess://$(base64 -w 0 $v2ray_qr_config_file)"
    {
        echo -e "$Red QR code: $Font"
        echo -n "${vmess_link}" | qrencode -o - -t utf8
        echo -e "${Red} URL import link:${vmess_link} ${Font}"
    } >>"${v2ray_info_file}"
}

vmess_quan_link_image() {
    echo "$(info_extraction '\"ps\"') = vmess, $(info_extraction '\"add\"'), \
    $(info_extraction '\"port\"'), chacha20-ietf-poly1305, "\"$(info_extraction '\"id\"')\"", over-tls=true, \
    certificate=1, obfs=ws, obfs-path="\"$(info_extraction '\"path\"')\"", " > /tmp/vmess_quan.tmp
    vmess_link="vmess://$(base64 -w 0 /tmp/vmess_quan.tmp)"
    {
        echo -e "$Red QR code: $Font"
        echo -n "${vmess_link}" | qrencode -o - -t utf8
        echo -e "${Red} URL import link:${vmess_link} ${Font}"
    } >>"${v2ray_info_file}"
}

vmess_link_image_choice() {
        #echo "Please select the generated link type"
        #echo "1: V2RayNG/V2RayN"
        #echo "2: quantumult"
        link_version=1
	vmess_qr_link_image
	
	#read -rp "please enter：" link_version
        #[[ -z ${link_version} ]] && link_version=1
        #if [[ $link_version == 1 ]]; then
        #    vmess_qr_link_image
        #elif [[ $link_version == 2 ]]; then
        #    vmess_quan_link_image
        #else
        #    vmess_qr_link_image
        #fi
}
info_extraction() {
    grep "$1" $v2ray_qr_config_file | awk -F '"' '{print $4}'
}
basic_information() {
    {
        echo -e "${OK} ${GreenBG} V2ray+ws+tls Successful installation"
        echo -e "${Red} V2ray configuration information ${Font}"
        echo -e "${Red} address（address）:${Font} $(info_extraction '\"add\"') "
        echo -e "${Red} port（port）：${Font} $(info_extraction '\"port\"') "
        echo -e "${Red} Uuid（UUID）：${Font} $(info_extraction '\"id\"')"
        echo -e "${Red} Extra id（alterId）：${Font} $(info_extraction '\"aid\"')"
        echo -e "${Red} Encryption（security）：${Font} Adaptive "
        echo -e "${Red} Transfer Protocol（network）：${Font} $(info_extraction '\"net\"') "
        echo -e "${Red} Camouflage type（type）：${Font} none "
        echo -e "${Red} Path (don't fall/)：${Font} $(info_extraction '\"path\"') "
        echo -e "${Red} Underlying transmission security：${Font} tls "
    } >"${v2ray_info_file}"
}
show_information() {
    clear
    cat "${v2ray_info_file}"
}

add_v2rayclient() {
cat <<'MyV2RayClientAdd' > /usr/bin/v2rayclientadd
#!/bin/bash
while getopts u:a: flag
do
    case "${flag}" in
        u) uuid=${OPTARG};;
        a) alterid=${OPTARG};;
    esac
done
sed -i '14 a \          {\n            "id": "'"${uuid}"'",\n            "alterId": '"${alterid}"'\n          },' /etc/v2ray/config.json
systemctl restart v2ray
MyV2RayClientAdd

chmod +x /usr/bin/v2rayclientadd
}

ssl_judge_and_install() {
    if [[ -f "/data/v2ray.key" || -f "/data/v2ray.crt" ]]; then
        echo "/data The certificate file in the directory already exists"
        echo -e "${OK} ${GreenBG} delete or not [Y/N]? ${Font}"
        read -r ssl_delete
        case $ssl_delete in
        [yY][eE][sS] | [yY])
            rm -rf /data/*
            echo -e "${OK} ${GreenBG} deleted ${Font}"
            ;;
        *) ;;

        esac
    fi

    if [[ -f "/data/v2ray.key" || -f "/data/v2ray.crt" ]]; then
        echo "The certificate file already exists"
    elif [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" && -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" ]]; then
        echo "The certificate file already exists"
        "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc
        judge "Certificate application"
    else
        ssl_install
        acme
    fi
}

nginx_systemd() {
    cat >$nginx_systemd_file <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
PIDFile=/etc/nginx/logs/nginx.pid
ExecStartPre=/etc/nginx/sbin/nginx -t
ExecStart=/etc/nginx/sbin/nginx -c ${nginx_dir}/conf/nginx.conf
ExecReload=/etc/nginx/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF

    judge "Nginx systemd ServerFile added"
    systemctl daemon-reload
}

tls_type() {
    if [[ -f "/etc/nginx/sbin/nginx" ]] && [[ -f "$nginx_conf" ]] && [[ "$shell_mode" == "ws" ]]; then
        #echo "Please select a supported TLS version（default:3）:"
        #echo "Please note that if you are using Quantaumlt X / router / old Shadowrocket / V2ray core lower than 4.18.1, please select compatibility mode"
        #echo "1: TLS1.1 TLS1.2 and TLS1.3（Compatibility mode）"
        #echo "2: TLS1.2 and TLS1.3 (Compatibility mode)"
        #echo "3: TLS1.3 only"
        
	tls_version=1
	sed -i 's/ssl_protocols.*/ssl_protocols         TLSv1.1 TLSv1.2 TLSv1.3;/' $nginx_conf
        echo -e "${OK} ${GreenBG} Switched to TLS1.1 TLS1.2 and TLS1.3 ${Font}"
	systemctl restart nginx
        judge "Nginx restart"
	    
	#read -rp "please enter：" tls_version
        #[[ -z ${tls_version} ]] && tls_version=3
        #if [[ $tls_version == 3 ]]; then
        #    sed -i 's/ssl_protocols.*/ssl_protocols         TLSv1.3;/' $nginx_conf
        #    echo -e "${OK} ${GreenBG} Switched to TLS1.3 only ${Font}"
        #elif [[ $tls_version == 1 ]]; then
        #    sed -i 's/ssl_protocols.*/ssl_protocols         TLSv1.1 TLSv1.2 TLSv1.3;/' $nginx_conf
        #    echo -e "${OK} ${GreenBG} Switched to TLS1.1 TLS1.2 and TLS1.3 ${Font}"
        #else
        #    sed -i 's/ssl_protocols.*/ssl_protocols         TLSv1.2 TLSv1.3;/' $nginx_conf
        #    echo -e "${OK} ${GreenBG} Switched to TLS1.2 and TLS1.3 ${Font}"
        #fi
	
        
    else
        echo -e "${Error} ${RedBG} Nginx Or the configuration file does not exist or the currently installed version is h2 ，Please install the script correctly and execute it${Font}"
    fi
}
show_access_log() {
    [ -f ${v2ray_access_log} ] && tail -f ${v2ray_access_log} || echo -e "${RedBG}log file does not exist ${Font}"
}
show_error_log() {
    [ -f ${v2ray_error_log} ] && tail -f ${v2ray_error_log} || echo -e "${RedBG}log file does not exist ${Font}"
}
ssl_update_manuel() {
    [ -f ${amce_sh_file} ] && "/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" || echo -e "${RedBG}The certificate issuance tool does not exist, please confirm whether you have used your own certificate ${Font}"
    domain="$(info_extraction '\"add\"')"
    "$HOME"/.acme.sh/acme.sh --installcert -d "${domain}" --fullchainpath /data/v2ray.crt --keypath /data/v2ray.key --ecc
}
bbr_boost_sh() {
    [ -f "tcp.sh" ] && rm -rf ./tcp.sh
    wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
}
mtproxy_sh() {
    echo -e "${Error} ${RedBG} Function maintenance, temporarily unavailable ${Font}"
}

uninstall_all() {
    stop_process_systemd
    [[ -f $nginx_systemd_file ]] && rm -f $nginx_systemd_file
    [[ -f $v2ray_systemd_file ]] && rm -f $v2ray_systemd_file
    [[ -d $v2ray_bin_dir ]] && rm -rf $v2ray_bin_dir
    [[ -d $v2ray_bin_dir_old ]] && rm -rf $v2ray_bin_dir_old
    if [[ -d $nginx_dir ]]; then
        echo -e "${OK} ${Green} Whether to uninstall Nginx [Y/N]? ${Font}"
        read -r uninstall_nginx
        case $uninstall_nginx in
        [yY][eE][sS] | [yY])
            rm -rf $nginx_dir
            echo -e "${OK} ${Green} Nginx uninstalled ${Font}"
            ;;
        *) ;;

        esac
    fi
    [[ -d $v2ray_conf_dir ]] && rm -rf $v2ray_conf_dir
    [[ -d $web_dir ]] && rm -rf $web_dir
    systemctl daemon-reload
    echo -e "${OK} ${GreenBG} Uninstalled, SSL certificate file has been retained ${Font}"
}
delete_tls_key_and_crt() {
    [[ -f $HOME/.acme.sh/acme.sh ]] && /root/.acme.sh/acme.sh uninstall >/dev/null 2>&1
    [[ -d $HOME/.acme.sh ]] && rm -rf "$HOME/.acme.sh"
    echo -e "${OK} ${GreenBG} The remaining certificate files have been emptied ${Font}"
}
judge_mode() {
    if [ -f $v2ray_bin_dir/v2ray ] || [ -f $v2ray_bin_dir_old/v2ray ]; then
        if grep -q "ws" $v2ray_qr_config_file; then
            shell_mode="ws"
        elif grep -q "h2" $v2ray_qr_config_file; then
            shell_mode="h2"
        fi
    fi
}
install_v2ray_ws_tls() {
    is_root
    check_system
    chrony_install
    dependency_install
    basic_optimization
    domain_check
    old_config_exist_check
    port_alterid_set
    v2ray_install
    port_exist_check 80
    port_exist_check "${port}"
    nginx_exist_check
    v2ray_conf_add_tls
    nginx_conf_add
    web_camouflage
    ssl_judge_and_install
    nginx_systemd
    vmess_qr_config_tls_ws
    basic_information
    vmess_link_image_choice
    tls_type
    start_process_systemd
    enable_process_systemd
    acme_cron_update
    add_v2rayclient
    show_information
    
}
install_v2_h2() {
    is_root
    check_system
    chrony_install
    dependency_install
    basic_optimization
    domain_check
    old_config_exist_check
    port_alterid_set
    v2ray_install
    port_exist_check 80
    port_exist_check "${port}"
    v2ray_conf_add_h2
    ssl_judge_and_install
    vmess_qr_config_h2
    basic_information
    vmess_qr_link_image
    show_information
    start_process_systemd
    enable_process_systemd

}
update_sh() {
    ol_version=$(curl -L -s https://raw.githubusercontent.com/xamjyss020820/v2ray/${github_branch}/install.sh | grep "shell_version=" | head -1 | awk -F '=|"' '{print $3}')
    echo "$ol_version" >$version_cmp
    echo "$shell_version" >>$version_cmp
    if [[ "$shell_version" < "$(sort -rV $version_cmp | head -1)" ]]; then
        echo -e "${OK} ${GreenBG} There is a new version, whether to update [Y/N]? ${Font}"
        read -r update_confirm
        case $update_confirm in
        [yY][eE][sS] | [yY])
            wget -N --no-check-certificate https://raw.githubusercontent.com/xamjyss020820/v2ray/${github_branch}/install.sh
            echo -e "${OK} ${GreenBG} update completed ${Font}"
            chmod +x install.sh && bash install.sh
            ;;
        *) ;;

        esac
    else
        echo -e "${OK} ${GreenBG} The current version is the latest version ${Font}"
    fi

}
maintain() {
    echo -e "${RedBG}This option is temporarily unavailable ${Font}"
    echo -e "${RedBG}$1${Font}"
    exit 0
}
list() {
    case $1 in
    tls_modify)
        tls_type
        ;;
    uninstall)
        uninstall_all
        ;;
    crontab_modify)
        acme_cron_update
        ;;
    boost)
        bbr_boost_sh
        ;;
    *)
        menu
        ;;
    esac
}

menu() {
    update_sh
    echo -e "\t V2ray installation management script ${Red}[${shell_version}]${Font}"
    echo -e "\t---authored by wulabing---"
	echo -e "\t---translated by baa---"
    echo -e "\thttps://github.com/wulabing\n"
    echo -e "Currently installed version:${shell_mode}\n"

    echo -e "—————————————— installation wizard ——————————————"""
    echo -e "${Green}0.${Font}  Upgrade script"
    echo -e "${Green}1.${Font}  Install V2Ray (Nginx+ws+tls)"
    echo -e "${Green}2.${Font}  Install V2Ray (http/2)"
    echo -e "${Green}3.${Font}  Install V2Ray core"
    echo -e "—————————————— Configuration changes ——————————————"
    echo -e "${Green}4.${Font}  Change UUID"
    echo -e "${Green}5.${Font}  Change alterid"
    echo -e "${Green}6.${Font}  Change port"
    echo -e "${Green}7.${Font}  Change TLS version (only ws+tls is valid)"
    echo -e "—————————————— View information ——————————————"
    echo -e "${Green}8.${Font}  View real-time access log"
    echo -e "${Green}9.${Font}  View real-time error log"
    echo -e "${Green}10.${Font} View V2Ray configuration information"
    echo -e "—————————————— other options ——————————————"
    echo -e "${Green}11.${Font} Install 4 in 1 bbr sharp speed installation script"
    echo -e "${Green}12.${Font} Install MTproxy (support TLS obfuscation)"
    echo -e "${Green}13.${Font} Certificate Validity Update"
    echo -e "${Green}14.${Font} Uninstall V2Ray"
    echo -e "${Green}15.${Font} Update certificate crontab scheduled task"
    echo -e "${Green}16.${Font} Empty certificate legacy files"
    echo -e "${Green}17.${Font} Exit \n"

    
    read -rp "Please enter the number：" menu_num
    case $menu_num in
    0)
        update_sh
        ;;
    1)
        shell_mode="ws"
        install_v2ray_ws_tls
        ;;
    2)
        shell_mode="h2"
        install_v2_h2
        ;;
    3)
        bash <(curl -L -s https://raw.githubusercontent.com/itsgelogomayee/v2ray/${github_branch}/v2ray.sh)
        ;;
    4)
        read -rp "Please enter UUID:" UUID
        modify_UUID
        start_process_systemd
        ;;
    5)
        read -rp "Please enter alterID:" alterID
        modify_alterid
        start_process_systemd
        ;;
    6)
        read -rp "Please enter the connection port:" port
        if grep -q "ws" $v2ray_qr_config_file; then
            modify_nginx_port
        elif grep -q "h2" $v2ray_qr_config_file; then
            modify_inbound_port
        fi
        start_process_systemd
        ;;
    7)
        tls_type
        ;;
    8)
        show_access_log
        ;;
    9)
        show_error_log
        ;;
    10)
        basic_information
        if [[ $shell_mode == "ws" ]]; then
            vmess_link_image_choice
        else
            vmess_qr_link_image
        fi
        show_information
        ;;
    11)
        bbr_boost_sh
        ;;
    12)
        mtproxy_sh
        ;;
    13)
        stop_process_systemd
        ssl_update_manuel
        start_process_systemd
        ;;
    14)
        uninstall_all
        ;;
    15)
        acme_cron_update
        ;;
    16)
        delete_tls_key_and_crt
        ;;
    17)
        exit 0
        ;;
    *)
        echo -e "${RedBG}Please enter the correct number ${Font}"
        ;;
    esac
}

judge_mode
list "$1"
