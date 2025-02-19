
# liferay-ce-7.4.3.ga67-docker-compose
## Description
A Docker Compose setup with utilities for Liferay 7.4.3 GA67 development environments, designed to replicate a production environment as closely as possible locally.

### Cloning the repository
Using SSH:
```bash
git clone git@github.com:s0beran0/liferay-ce-7.4.3.ga67-docker-compose.git
```
Using HTTPS:
```bash
git clone https://github.com/s0beran0/liferay-ce-7.4.3.ga67-docker-compose.git
```
and
```bash
cd liferay-ce-7.4.3.ga67-docker-compose/
```

### System Dependencies

**Attention:** This repository is designed to run **only on Linux systems**. To ensure compatibility, **it cannot be run on Windows or macOS** without using virtual machines or containers specifically configured for those systems.
The dependencies required to run the project are:
- [Docker](https://docs.docker.com/engine/install/)
- [Docker-compose](https://docs.docker.com/compose/install/standalone/)

If you are using Windows or macOS, we suggest using a virtual machine to emulate a Linux environment.

### Starting the environment
To start the environment, run the following command in the terminal:
```bash
chmod +x setup.sh
```
and
```bash
docker-compose up --build -d
```
Once the command finishes, the following directories will be created:
```bash
volumes/
├── database/ # Database files
│   ├── data/ # Database data files
│   └── dump/ # Dump files
└── liferay/ # Liferay files
    ├── deploy/ # Directory for module deployment
    ├── files/ # Files directory
    └── scripts/ # Scripts directory
```
After a few seconds, Liferay should be accessible at: https://localhost:8443

### Viewing logs
To view Liferay logs:
```bash
docker logs -f liferay-container
```

To view ElasticSearch logs:
```bash
docker logs -f elsdesafio-container
```

To view database logs:
```bash
docker logs -f postgres-container
```

### Using the setup.sh script
#### Backup using pgdump:
This command creates a pgdump backup, generating a .dump file in the `volumes/database/dump/` folder.
```bash
./setup.sh create_dump
```

#### Backup as SQL:
This command creates a .sql backup and saves it in `volumes/database/dump/`.
```bash
./setup.sh create_sql_dump
```

#### Restoring the database:
This command allows you to restore one of the backups present in `volumes/database/dump/` (it accepts .dump and .sql files).
```bash
./setup.sh restore_database
```

#### Restarting Liferay:
This command allows you to restart the running Liferay instance.
```bash
./setup.sh restart_liferay
```
