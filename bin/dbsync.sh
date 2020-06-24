root@geomapfish-new-dbsync:~# cat /root/bin/SyncGoelandDBPython.sh
#!/bin/bash
LOG="/root/log/SyncGoelandDBPython.log"
function count_table {
TABLE=$1
DATABASE=${2:-goeland}
sudo -u  postgres  psql -tc "SELECT COUNT(*) FROM ${TABLE}" ${DATABASE}
}

echo "*****************************************" >> ${LOG} 2>&1
echo "*****************************************" >> ${LOG} 2>&1
echo "******** BEGIN  sync of goeland  data at" `date` >> ${LOG} 2>&1
cd /root/bin/mssql2pgsql/
./copy_Mssql_Table_to_Postgresql.py CHHistoNbrHabiParAdr  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py DicoBuildingCodeStatus  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py DicoCPRueLS  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py DicoPays  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py Parcelle  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ParcelleDicoType  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py parcelle_etat_separatif >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py Thing >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiBuilding >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThingPosition  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiParcelle >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiStreet  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiStreetBuildingAddress  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiSondageGeoTherm >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiSondageGeoThermEtat >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiArbreNomenclature >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiArbre >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiArbreGenre >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiArbreCultivar >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiArbreEspece >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py TypeThing >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py TypeThiStreet >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py ThiFontaine  >> ${LOG} 2>&1
./copy_Mssql_Table_to_Postgresql.py aff_rm_utildp_export >> ${LOG} 2>&1
if [ -d /tmp/syncdb/ ]; then
	rm -rf /tmp/syncdb/*
else
	mkdir /tmp/syncdb/
fi
chown -R postgres:postgres /tmp/syncdb
su -c "pg_dump --table=thi_arbre       --data-only --format=p  -f /tmp/syncdb/backup_thi_arbre_plain.sql goeland" postgres
su -c "pg_dump --table=thi_arbre_cultivar      --data-only --format=p  -f /tmp/syncdb/backup_thi_arbre_cultivar_plain.sql goeland" postgres
su -c "pg_dump --table=thi_arbre_espece           --data-only --format=p  -f /tmp/syncdb/backup_thi_arbre_espece_plain.sql goeland" postgres
su -c "pg_dump --table=thi_arbre_genre            --data-only --format=p  -f /tmp/syncdb/backup_thi_arbre_genre_plain.sql goeland" postgres
su -c "pg_dump --table=thi_arbre_nomenclature    --data-only --format=p  -f /tmp/syncdb/backup_thi_arbre_nomenclature_plain.sql goeland" postgres
su -c "pg_dump --table=thi_sondage_geo_therm      --data-only --format=p  -f /tmp/syncdb/backup_thi_sondage_geo_therm_plain.sql goeland" postgres
su -c "pg_dump --table=thi_sondage_geo_therm_etat --data-only --format=p  -f /tmp/syncdb/backup_thi_sondage_geo_therm_etat_plain.sql goeland" postgres
su -c "pg_dump --table=ch_histo_nbr_habi_par_adr --data-only --format=p  -f /tmp/syncdb/backup_ch_histo_nbr_habi_par_adr_plain.sql goeland" postgres
su -c "pg_dump --table=dico_building_code_status  --data-only --format=p  -f /tmp/syncdb/backup_dico_building_code_status_plain.sql goeland" postgres
su -c "pg_dump --table=dico_cprue_ls              --data-only --format=p  -f /tmp/syncdb/backup_dico_cprue_ls_plain.sql goeland" postgres
su -c "pg_dump --table=dico_pays                  --data-only --format=p  -f /tmp/syncdb/backup_dico_pays_plain.sql goeland" postgres
su -c "pg_dump --table=parcelle                   --data-only --format=p  -f /tmp/syncdb/backup_parcelle_plain.sql goeland" postgres
su -c "pg_dump --table=parcelle_dico_type         --data-only --format=p  -f /tmp/syncdb/backup_parcelle_dico_type_plain.sql goeland" postgres
su -c "pg_dump --table=parcelle_etat_separatif    --data-only --format=p  -f /tmp/syncdb/backup_parcelle_etat_separatif_plain.sql goeland" postgres
su -c "pg_dump --table=thi_building               --data-only --format=p  -f /tmp/syncdb/backup_thi_building_plain.sql goeland" postgres
su -c "pg_dump --table=thi_parcelle               --data-only --format=p  -f /tmp/syncdb/backup_thi_parcelle_plain.sql goeland" postgres
su -c "pg_dump --table=thi_street                 --data-only --format=p  -f /tmp/syncdb/backup_thi_street_plain.sql goeland" postgres
su -c "pg_dump --table=thi_street_building_address --data-only --format=p  -f /tmp/syncdb/backup_thi_street_building_address_plain.sql goeland" postgres
su -c "pg_dump --table=thing                      --data-only --format=p  -f /tmp/syncdb/backup_thing_plain.sql goeland" postgres
su -c "pg_dump --table=thing_position             --data-only --format=p  -f /tmp/syncdb/backup_thing_position_plain.sql goeland" postgres
su -c "pg_dump --table=type_thi_street            --data-only --format=p  -f /tmp/syncdb/backup_type_thi_street_plain.sql goeland" postgres
su -c "pg_dump --table=type_thing --data-only --format=p  -f /tmp/syncdb/backup_type_thing_plain.sql goeland" postgres
su -c "pg_dump --table=thi_fontaine --data-only --format=p  -f /tmp/syncdb/backup_thi_fontaine_plain.sql goeland" postgres
su -c "pg_dump --table=aff_rm_utildp_export --data-only --format=p  -f /tmp/syncdb/backup_aff_rm_utildp_export_plain.sql goeland" postgres

echo "*** About to copy this files to geomapfish-new-dev" >> ${LOG} 2>&1
ls -1 /tmp/syncdb/ >> ${LOG} 2>&1
ssh geomapfish-new-dev mkdir /tmp/syncdbgo
ssh geomapfish-new-dev chown -R postgres:postgres  /tmp/syncdbgo
scp /tmp/syncdb/*.sql geomapfish-new-dev:/tmp/syncdbgo/
echo "*** About to copy same files to geomapfish-new PROD" >> ${LOG} 2>&1
ssh geomapfish-new mkdir /tmp/syncdbgo
ssh geomapfish-new chown -R postgres:postgres  /tmp/syncdbgo
scp /tmp/syncdb/*.sql geomapfish-new:/tmp/syncdbgo/

echo "******** END sync of goeland  data at" `date` >> ${LOG} 2>&1
echo "*****************************************" >> ${LOG} 2>&1
echo "*****************************************" >> ${LOG} 2>&1
