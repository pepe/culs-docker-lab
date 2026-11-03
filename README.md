# Docker database workshop

EIED5E · Formal Techniques of Data Modelling · 3 November 2026

PostgreSQL and Neo4j side by side in Docker Compose, with the same small course-enrollment data in both.
The slides are the "Docker — Our Database Workbench" part of the [seminar deck](https://github.com/pepe/present-star/blob/master/presentations/Formal-Techniques-of-Data-Modeling-Seminar.md).

Work through `STUDENT-WORKSHEET.md` in pairs. `COMMANDS-POWERSHELL.md` has the exact commands, written for PowerShell ISE.

## Get the lab

With Git:

```powershell
git clone https://github.com/pepe/culs-docker-lab.git
```

Without Git: on GitHub choose **Code → Download ZIP** and extract the ZIP before using it. It extracts to `culs-docker-lab-main`; use that folder or rename it.

Put the folder where you are allowed to write. On school PCs that may be a network drive such as H:.

## One folder, one environment

Open Docker Desktop and wait for the engine to start with Linux containers selected. Open PowerShell ISE if that is the permitted command host. Adjust the path to your lab folder:

```powershell
Set-Location 'H:\culs-docker-lab'
docker version
docker compose version
docker compose config --quiet
docker compose pull
docker compose up -d
docker compose ps
```

`docker version` must show a working Server section. Wait until both database services report healthy. Neo4j may take a minute or more on school machines. ISE shows Docker's ordinary progress in red: `$LASTEXITCODE` 0 means success.

Root `compose.yaml` starts both databases. The `web` profile adds an optional PostgreSQL web client:

```powershell
docker compose --profile web up -d
```

The files under `postgres/` and `neo4j/` are independent alternatives, not overrides. Do not start them alongside the root configuration: they publish the same host ports. Each alternative has separate project-scoped data volumes.

To start just one database while retaining the root project, use `docker compose up -d postgres` or `docker compose up -d neo4j` instead.

## Connections

| Client | Address / server | User | Password | Database |
|---|---|---|---|---|
| Host PostgreSQL client | localhost:5432 | teacher | TeachingOnly2026 | teaching |
| Adminer web page | http://localhost:8080 | teacher | TeachingOnly2026 | teaching |
| Adminer login: System | PostgreSQL | | | |
| Adminer login: Server | postgres | | | |
| Neo4j Browser | http://localhost:7474/browser/ | neo4j | TeachingOnly2026 | neo4j |
| Neo4j Browser connection | bolt://localhost:7687 | neo4j | TeachingOnly2026 | neo4j |

These are disposable teaching credentials. Published ports bind to 127.0.0.1. This is a local practice environment, not a deployment template for real accounts or data.

The official PostgreSQL image provides the server and psql. Adminer is a separate optional client. In Adminer, `postgres` resolves through Compose networking. `localhost` inside Adminer's container would mean Adminer's own container. Adminer opens schema `public`, which is empty: the lab's tables are in schema `lab`.

## Load the sample data

These seed files reset their sample data. Run them only in this dedicated lab. SQL replaces the `lab` schema. Cypher deletes Lab-labelled nodes and their incident relationships, then rebuilds the fixture.

Run from the lab folder after both services are healthy:

```powershell
docker compose cp .\sql\seed.sql postgres:/tmp/seed.sql
docker compose exec -T --interactive=false postgres psql -U teacher -d teaching -v ON_ERROR_STOP=1 -f /tmp/seed.sql
docker compose cp .\cypher\seed.cypher neo4j:/tmp/seed.cypher
docker compose exec -T --interactive=false neo4j cypher-shell -u neo4j -p TeachingOnly2026 -d neo4j --format plain -f /tmp/seed.cypher
```

There are no host bind mounts. Compose copies text files into the running containers. Named volumes hold database data inside Docker's storage, not in your lab folder. This avoids depending on Docker being able to bind-mount H:.

Save your own query files as UTF-8 without BOM. `>` in Windows PowerShell writes UTF-16, which psql and cypher-shell refuse.

## Folder contents

- `compose.yaml`: both DBs, optional Adminer, health checks, named volumes.
- `postgres/compose.yaml`, `neo4j/compose.yaml`: standalone alternatives.
- `sql/`, `cypher/`: seeds, starter queries, persistence experiments and a constraint demonstration.
- `data/dataset.json`: shared source fixture for checking the two representations.
- `STUDENT-WORKSHEET.md`: practical tasks.
- `COMMANDS-POWERSHELL.md`: ISE-compatible commands, startup and troubleshooting.
- `SOURCES.md`: official references checked during preparation.

## Image choices

PostgreSQL uses `postgres:17-bookworm` and the PostgreSQL 17 data path `/var/lib/postgresql/data`, a path inside the Linux container. Neo4j uses the Community 5.26 line. Adminer uses version line 5. Tags deliberately avoid `latest`, but still move within their selected release lines.

## Ending the lab

```powershell
docker compose --profile web down
```

This removes this project's containers and network, retaining named volumes. The databases survive in those volumes on this Docker installation. A network-drive copy of the YAML does not carry the databases to another PC.

Only for an intentional complete reset of this dedicated lab, after saving any work you want:

```powershell
docker compose --profile web down --volumes
```

This deletes this project's named database volumes. Do not use a system-wide prune command in class.

## License

MIT, see `LICENSE`.
