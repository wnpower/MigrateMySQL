#!/bin/bash

if ! command -v gzip > /dev/null; then
	echo "gzip no se encuentra, no se comprime"
fi

if ! command -v mysqldump > /dev/null; then
	echo "mysqldump no se encuentra, abortando"
	exit 1
fi

# EXPORT

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

if [ "$USUARIO_DB" != "root" ]; then
	echo -n "MySQL " # PARA QUE SE ACOPLE AL PEDIDO DE PASSWORD DEL COMANDO MYSQLDUMP
fi

echo -n "Host (default 127.0.0.1): "
read HOST
if [ ! -z $HOST ]; then
	HOST="-h $HOST"
fi

if command -v gzip > /dev/null; then
	MYSQLFILE="./$NOMBRE_DB.sql.gz"
	mysqldump $USUARIO_COMMAND $HOST --no-create-db --routines --skip-comments --add-drop-table $NOMBRE_DB | sed -E 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' | gzip > $MYSQLFILE
else
	MYSQLFILE="./$NOMBRE_DB.sql"
	mysqldump $USUARIO_COMMAND $HOST --no-create-db --routines --skip-comments --add-drop-table $NOMBRE_DB | sed -E 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' > $MYSQLFILE
fi

if [ ! -f $MYSQLFILE ] || [ ! -s $MYSQLFILE ]; then
	echo ""
	echo "El archivo exportado no parece válido, abortando."
	exit 1
fi

echo "Base de datos $NOMBRE_DB exportada en $MYSQLFILE."

# TRANSFERENCIA

echo -n "¿Quieres transferir el export a un servidor remoto? [s/n] (Default s): "
read TRANSFER

if [ "$TRANSFER" = "n" ] || [ -z "$TRANSFER" ]; then
	echo "No se tranfiere"
	exit 0
fi

if ! command -v rsync > /dev/null; then
	echo "rsync no detectado, no se transfiere."
	exit 0
fi

echo -n "Host remoto: "
read HOST_REMOTO

echo -n "Usuario remoto: "
read USUARIO_REMOTO

echo -n "Puerto SSH (default 22): "
read PUERTO_SSH
if [ -z $PUERTO_SSH ]; then
	PUERTO_SSH=22
fi

echo -n "Path remoto (default ~): "
read PATH_REMOTO
if [ -z $PATH_REMOTO ]; then
	PATH_REMOTO="~"
fi

echo "Tranfiriendo archivo $MYSQLFILE a $HOST_REMOTO..."
rsync -avz -e "ssh -p $PUERTO_SSH" --progress $MYSQLFILE $USUARIO_REMOTO@$HOST_REMOTO:$PATH_REMOTO

