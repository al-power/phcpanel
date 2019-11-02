#!/bin/bash
clear
opcion=2
while [ $opcion -ne 3 ]
do
echo "-------------------------------------------------------------"
echo "Menu"
echo "1.pre-configuracion de centos e instalacion de cpanel"
echo "2.configuracion de cpanel y compliacion de apache"
echo "3.instalacion y configuracion de nginx/engintron para cpanel"
echo "4.salir"
echo "--------------------------------------------------------------"
echo -n "Ingrese su opcion:"
read opt
case $opt in
     "1" )
        clear
        echo "pre-configuracion de centos"
        echo
        sh phcentos.sh
        echo "se inicia la instalcion de cpanel"
        sh phcpanel.sh
        read -p "presione enter para continuar"
        ;;
      "2" )
      clear
        echo "Configurar cpanel y compilar apache"
        echo
        phconf.sh
        echo "se ha terminado con la configurarcion cpanel y compilacion de apache"
        read -p "presione enter para continuar"
        ;;
       "3" )
      clear
        echo "instalacion y configuracion de nginx"
        echo
        phnginx.sh
        echo "se ha terminado la instalacion y configuracion de nginx"
        read -p "presione enter para continuar"
        ;;
      "4" )
      clear
      echo "chao"
      exit
      ;;
esac
clear
done
