#!/bin/bash
QGIS_PROJ_PATH=$1
## using command line to debug a qgis project on a server
## more variables are documented here : https://docs.qgis.org/3.10/en/docs/user_manual/working_with_ogc/server/config.html?highlight=server
echo "## TRYING GetCapabilities on qgis server project :"
echo "## ${QGIS_PROJ_PATH}"
QGIS_SERVER_LOG_LEVEL=0 QGIS_SERVER_LOG_STDERR=1 QUERY_STRING="MAP=${QGIS_PROJ_PATH}&SERVICE=WMS&REQUEST=GetCapabilities" /usr/lib/cgi-bin/qgis_mapserv.fcgi
