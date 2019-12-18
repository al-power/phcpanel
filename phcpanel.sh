#!/bin/bash
#######
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOSTNAME=$(hostname -f)
host=$(hostname -d)
port=1295
TIME="$(date +%F_%T)"
PASSV_PORT="50000:50100";
PASSV_MIN=$(echo $PASSV_PORT | cut -d':' -f1)
PASSV_MAX=$(echo $PASSV_PORT | cut -d':' -f2)
ISVPS=$(((dmidecode -t system 2>/dev/null | grep "Manufacturer" | grep -i 'VMware\|KVM\|Bochs\|Virtual\|HVM' > /dev/null) || [ -f /proc/vz/veinfo ]) && echo "SI" || echo "NO")
#######
clear
#######
###############
echo -n "ingrese el correo para el servidor:"
read mail
###############
echo -n ingrese la dns1:
read dns1
############
echo -n ingrese la dns2:
read dns2
##############

echo "#################################"
echo "#### Pre-Configurando Cpanel ####"
echo "#################################"

echo "### Desactivando yum-cron y NetworkManager ###"
yum erase yum-cron -y
sleep 5
systemctl stop NetworkManager.service
systemctl disable NetworkManager.service
yum erase NetworkManager -y

echo "### instalando cpanel ###"
if [ -f /usr/local/cpanel/cpanel ]; then
        echo "cPanel ya detectado, no se instala, sólo se configura (CTRL + C para cancelar)"
        sleep 10
else
        cd /home && curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest
fi

sleep 5
clear
echo "#########################"
echo "######### CSF ###########"
echo "#########################"

if [ ! -d /etc/csf ]; then
        echo "csf no detectado, descargando!"
	touch /etc/sysconfig/iptables
	touch /etc/sysconfig/iptables6
	systemctl start iptables
	systemctl start ip6tables
	systemctl enable iptables
	systemctl enable ip6tables
	cd /root && rm -f ./csf.tgz; wget https://download.configserver.com/csf.tgz && tar xvfz ./csf.tgz && cd ./csf && sh ./install.sh
fi

echo "### Configurando CSF ###"

cp /etc/csf/csf.conf cp /etc/csf/csf.conf.bak.$TIME 

yum remove firewalld -y
yum -y install iptables-services wget perl unzip net-tools perl-libwww-perl perl-LWP-Protocol-https perl-GDGraph
sed -i 's/^TESTING = .*/TESTING = "0"/g' /etc/csf/csf.conf
sed -i 's/^RESTRICT_SYSLOG = "0"=/RESTRICT_SYSLOG = "3"/g' /etc/csf/csf.conf
sed -i 's/^ICMP_IN = .*/ICMP_IN = "0"/g' /etc/csf/csf.conf
sed -i 's/^IPV6 = .*/IPV6 = "0"/g' /etc/csf/csf.conf
sed -i 's/^DENY_IP_LIMIT = .*/DENY_IP_LIMIT = "400"/g' /etc/csf/csf.conf
sed -i 's/^SAFECHAINUPDATE = .*/SAFECHAINUPDATE = "1"/g' /etc/csf/csf.conf
sed -i 's/^CC_DENY = .*/CC_DENY = ""/g' /etc/csf/csf.conf
sed -i 's/^CC_IGNORE = .*/CC_IGNORE = ""/g' /etc/csf/csf.conf
sed -i 's/^SMTP_BLOCK = .*/SMTP_BLOCK = "1"/g' /etc/csf/csf.conf
sed -i 's/^LF_FTPD = .*/LF_FTPD = "30"/g' /etc/csf/csf.conf
sed -i 's/^LF_SMTPAUTH = .*/LF_SMTPAUTH = "90"/g' /etc/csf/csf.conf
sed -i 's/^LF_EXIMSYNTAX = .*/LF_EXIMSYNTAX = "0"/g' /etc/csf/csf.conf
sed -i 's/^LF_POP3D = .*/LF_POP3D = "100"/g' /etc/csf/csf.conf
sed -i 's/^LF_IMAPD = .*/LF_IMAPD = "100"/g' /etc/csf/csf.conf
sed -i 's/^LF_HTACCESS = .*/LF_HTACCESS = "40"/g' /etc/csf/csf.conf
sed -i 's/^LF_CPANEL = .*/LF_CPANEL = "40"/g' /etc/csf/csf.conf
sed -i 's/^LF_MODSEC = .*/LF_MODSEC = "100"/g' /etc/csf/csf.conf
sed -i 's/^LF_CXS = .*/LF_CXS = "10"/g' /etc/csf/csf.conf
sed -i 's/^LT_POP3D =  .*/LT_POP3D = "180"/g' /etc/csf/csf.conf
sed -i 's/^CT_SKIP_TIME_WAIT = .*/CT_SKIP_TIME_WAIT = "1"/g' /etc/csf/csf.conf
sed -i 's/^PT_LIMIT = .*/PT_LIMIT = "0"/g' /etc/csf/csf.conf
sed -i 's/^ST_MYSQL = .*/ST_MYSQL = "1"/g' /etc/csf/csf.conf
sed -i 's/^ST_APACHE = .*/ST_APACHE = "1"/g' /etc/csf/csf.conf
sed -i 's/^CONNLIMIT = .*/CONNLIMIT = "80;70,110;50,993;50,143;50,25;30"/g' /etc/csf/csf.conf
sed -i 's/^LF_PERMBLOCK_INTERVAL = .*/LF_PERMBLOCK_INTERVAL = "14400"/g' /etc/csf/csf.conf
sed -i 's/^LF_INTERVAL = .*/LF_INTERVAL = "900"/g' /etc/csf/csf.conf
sed -i 's/^PS_INTERVAL = .*/PS_INTERVAL = "60"/g' /etc/csf/csf.conf
sed -i 's/^PS_LIMIT = .*/PS_LIMIT = "20"/g' /etc/csf/csf.conf

echo "### Deshabilitando alertas ###"

sed -i 's/^LF_PERMBLOCK_ALERT = .*/LF_PERMBLOCK_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^LF_NETBLOCK_ALERT = .*/LF_NETBLOCK_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^LF_EMAIL_ALERT = .*/LF_EMAIL_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^LF_CPANEL_ALERT = .*/LF_CPANEL_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^LF_QUEUE_ALERT = .*/LF_QUEUE_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^LF_DISTFTP_ALERT = .*/LF_DISTFTP_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^LF_DISTSMTP_ALERT = .*/LF_DISTSMTP_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^LT_EMAIL_ALERT = .*/LT_EMAIL_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^RT_RELAY_ALERT = .*/RT_RELAY_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^RT_AUTHRELAY_ALERT = .*/RT_AUTHRELAY_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^RT_POPRELAY_ALERT = .*/RT_POPRELAY_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^RT_LOCALRELAY_ALERT = .*/RT_LOCALRELAY_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^RT_LOCALHOSTRELAY_ALERT = .*/RT_LOCALHOSTRELAY_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^CT_EMAIL_ALERT = .*/CT_EMAIL_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^PT_USERKILL_ALERT = .*/PT_USERKILL_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^PS_EMAIL_ALERT = .*/PS_EMAIL_ALERT = "0"/g' /etc/csf/csf.conf
sed -i 's/^PT_USERMEM = .*/PT_USERMEM = "0"/g' /etc/csf/csf.conf
sed -i 's/^PT_USERTIME = .*/PT_USERTIME = "0"/g' /etc/csf/csf.conf
sed -i 's/^PT_USERPROC = .*/PT_USERPROC = "0"/g' /etc/csf/csf.conf
sed -i 's/^PT_USERRSS = .*/PT_USERRSS = "0"/g' /etc/csf/csf.conf

echo "Habilitando listas negras..."
sed -i '/^#SPAMDROP/s/^#//' /etc/csf/csf.blocklists
sed -i '/^#SPAMEDROP/s/^#//' /etc/csf/csf.blocklists
sed -i '/^#DSHIELD/s/^#//' /etc/csf/csf.blocklists
sed -i '/^#HONEYPOT/s/^#//' /etc/csf/csf.blocklists
sed -i '/^#MAXMIND/s/^#//' /etc/csf/csf.blocklists
sed -i '/^#BDE|/s/^#//' /etc/csf/csf.blocklists
sed -i '/^SPAMDROP/s/|0|/|300|/' /etc/csf/csf.blocklists
sed -i '/^SPAMEDROP/s/|0|/|300|/' /etc/csf/csf.blocklists
sed -i '/^DSHIELD/s/|0|/|300|/' /etc/csf/csf.blocklists
sed -i '/^HONEYPOT/s/|0|/|300|/' /etc/csf/csf.blocklists
sed -i '/^MAXMIND/s/|0|/|300|/' /etc/csf/csf.blocklists
sed -i '/^BDE|/s/|0|/|300|/' /etc/csf/csf.blocklists
sed -i '/^TOR/s/^TOR/#TOR/' /etc/csf/csf.blocklists
sed -i '/^ALTTOR/s/^ALTTOR/#ALTTOR/' /etc/csf/csf.blocklists
sed -i '/^CIARMY/s/^CIARMY/#CIARMY/' /etc/csf/csf.blocklists
sed -i '/^BFB/s/^BFB/#BFB/' /etc/csf/csf.blocklists
sed -i '/^OPENBL/s/^OPENBL/#OPENBL/' /etc/csf/csf.blocklists
sed -i '/^BDEALL/s/^BDEALL/#BDEALL/' /etc/csf/csf.blocklists
	
cat << EOF > /etc/csf/csf.rignore 
.cpanel.net
.googlebot.com
.crawl.yahoo.net
.search.msn.com
EOF

echo "### Abriendo puertos en CSF para TCP_OUT migraciones cPanel ###"

CPANEL_PORTS="2082,2083"
CURR_CSF_OUT=$(grep "^TCP_OUT" /etc/csf/csf.conf | cut -d'=' -f2 | sed 's/\ //g' | sed 's/\"//g' | sed "s/,$CPANEL_PORTS,/,/g" | sed "s/,$CPANEL_PORTS//g" | sed "s/$CPANEL_PORTS,//g" | sed "s/,,//g")

sed -i "s/^TCP_OUT.*/TCP_OUT = \"$CURR_CSF_OUT,$CPANEL_PORTS\"/" /etc/csf/csf.conf

echo "### Activando DYNDNS ###"
sed -i 's/^DYNDNS = .*/DYNDNS = "300"/g' /etc/csf/csf.conf
sed -i 's/^DYNDNS_IGNORE = .*/DYNDNS_IGNORE = "1"/g' /etc/csf/csf.conf

echo "### reinicio de csf ###"
csf -r
service lfd restart

