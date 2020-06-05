-- apt install postgresql-10-plr postgresql-10-orafce postgresql-plpython3
--  apt install devscripts ncurses-doc ess r-doc-info r-doc-pdf r-mathlib r-base-html texlive-base texlive-latex-base texlive-generic-recommended texlive-fonts-recommended
CREATE USER biomonitoring WITH PASSWORD 'UDeesei2_Oyei2oa9';
CREATE DATABASE biomonitoring WITH OWNER biomonitoring;
CREATE EXTENSION postgis;
CREATE EXTENSION plpython3u;
