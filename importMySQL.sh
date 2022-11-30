#!/bin/bash

if ! command -v gunzip > /dev/null; then
	echo "gzip no se encuentra, no se comprime"
fi

if ! command -v mysqldump > /dev/null; then
	echo "mysqldump no se encuentra, abortando"
	exit 1
fi

# IMPORT

echo -n "Archivo de DB: "
read ARCHIVO_DB

if [ ! -f "$ARCHIVO_DB" ]; then
	echo "Archivo $ARCHIVO_DB no encontrado, abortando."
	exit 1
fi

echo -n "Usuario DB: "
read USUARIO_DB

if [ "$USUARIO_DB" != "root" ]; then
	USUARIO_COMMAND="-u$USUARIO_DB -p"
else
	if [ -f /root/.my.cnf ]; then
		echo "Exportando utilizando credenciales de /root/.my.cnf"
	else
		USUARIO_COMMAND="-u$USUARIO_DB -p"
	fi
fi

echo -n "Nombre de la DB: "
read NOMBRE_DB

echo -n "Host (default 127.0.0.1): "
read HOST
if [ ! -z $HOST ]; then
	HOST="-h $HOST"
fi

if [ "$USUARIO_DB" != "root" ]; then
	echo -n "MySQL " # PARA QUE SE ACOPLE AL PEDIDO DE PASSWORD DEL COMANDO MYSQLDUMP
fi

if command -v gunzip > /dev/null && (echo "$ARCHIVO_DB" | grep ".gz$" > /dev/null); then
	gunzip < "$ARCHIVO_DB" | sed -E 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' | mysql $USUARIO_COMMAND $HOST $NOMBRE_DB && echo "Base de datos $ARCHIVO_DB importada en $NOMBRE_DB"
else
	cat "$ARCHIVO_DB" | sed -E 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' | mysql $USUARIO_COMMAND $HOST $NOMBRE_DB && echo "Base de datos $ARCHIVO_DB importada en $NOMBRE_DB"
fi

