# Intro2DataBase

## Installation Postgress

```sh
sudo apt-get install postgresql
```

## Config

Utilisation de virtualenv afin de ne pas poluer l'installation courante.

```sh
virtualenv -p python3 venv
. venv/bin/activate
pip3 install -r requirements.txt
```

Une fois que le venv est activé, il est possible d'installer de nouvaux modules dans le venv avec:

```sh
pip3 install modulename
```

Pour mettre à jour le fichier `requirements.txt` qui contient les dépendances, utiliser la ligne de commande suivante :

```sh
pip3 freeze > requirements.txt
```

## Start postgres

```sh
sudo service postgresql start
```

Ouvrir la console postgres:

```sh
sudo -u postgres psql
```

et la quitter `\q + ENTER`

## Database instructions

- `\l` to list existing database 
- `\c introdb` to connect introdb database 
- `create database introdb;` to create a new database