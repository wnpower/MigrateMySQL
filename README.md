# MigrateMySQL
Scripts para exportar e importar bases de datos MySQL.

## Export
Asistente interactivo para exportar la base de datos. Exporta la base en la locación actual y permite transferirla remotamente con Rsync.

    wget https://raw.githubusercontent.com/wnpower/MigrateMySQL/master/exportMySQL.sh -O ./exportMySQL.sh | bash ./exportMySQL.sh
## Import
Una vez exportado, ingresar al servidor de destino y ejecutar el siguiente script para importar la base de datos.

    wget https://raw.githubusercontent.com/wnpower/MigrateMySQL/master/importMySQL.sh -O ./importMySQL.sh | bash ./importMySQL.sh

