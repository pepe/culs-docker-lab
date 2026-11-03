# PowerShell ISE command sheet

Run one selected command at a time, or a deliberately selected block. F8 runs the selection in ISE. Do not run this entire sheet as a script: some sections stop the databases or reset data.

ISE does not support fully interactive console applications. Commands here supply their input as arguments or files. `-T --interactive=false` avoids a pseudo-terminal and interactive stdin. Use browser clients for interactive query editing. No execution-policy change is required to paste these commands into ISE.

## 1. Startup and inspection

Adjust the path to your lab folder, cloned or extracted:

```powershell
Set-Location 'H:\culs-docker-lab'
Get-ChildItem
docker version
docker compose version
docker compose config --quiet
docker compose pull
docker compose up -d
docker compose ps
docker compose logs --tail 30 postgres
docker compose logs --tail 30 neo4j
```

Expect both services healthy before seeding. Repeat `ps` if needed. Use finite log output rather than `logs -f` in ISE.

ISE shows Docker's ordinary progress in red, because Docker writes it to stderr. Red alone is not an error: enter `$LASTEXITCODE`, and 0 means success.

## 2. A one-off container

This reuses the downloaded PostgreSQL image, runs its client to print a version, then removes the temporary container. It starts no additional database server and does not affect the Compose data:

```powershell
docker run --rm postgres:17-bookworm psql --version
docker image ls
docker compose images
```

`docker run` starts a new container. `docker compose exec` starts an additional process inside an existing service container.

## 3. Seed the dedicated lab

These commands replace the sample fixture, so use them before the persistence experiment, not during it.

```powershell
docker compose cp .\sql\seed.sql postgres:/tmp/seed.sql
docker compose exec -T --interactive=false postgres psql -U teacher -d teaching -v ON_ERROR_STOP=1 -f /tmp/seed.sql
docker compose cp .\cypher\seed.cypher neo4j:/tmp/seed.cypher
docker compose exec -T --interactive=false neo4j cypher-shell -u neo4j -p TeachingOnly2026 -d neo4j --format plain -f /tmp/seed.cypher
```

To check a native command's result immediately afterwards, enter `$LASTEXITCODE`. Zero indicates success. Stop on nonzero results and inspect the error.

On the first seed, psql prints `NOTICE:  schema "lab" does not exist, skipping`, in red in ISE. It is not an error.

## 4. Run an edited query file

Save your own single-query file as `sql\my-query.sql` or `cypher\my-query.cypher`. Save it from an editor as UTF-8 without BOM; Notepad's UTF-8 is fine. `>` and `Out-File` in Windows PowerShell write UTF-16, which psql and cypher-shell refuse, and cypher-shell also refuses a file that starts with a BOM. Copy it again each time you edit it; the container copy does not update automatically.

```powershell
docker compose cp .\sql\my-query.sql postgres:/tmp/query.sql
docker compose exec -T --interactive=false postgres psql -U teacher -d teaching -v ON_ERROR_STOP=1 -f /tmp/query.sql
docker compose cp .\cypher\my-query.cypher neo4j:/tmp/query.cypher
docker compose exec -T --interactive=false neo4j cypher-shell -u neo4j -p TeachingOnly2026 -d neo4j --format plain -f /tmp/query.cypher
```

The provided starter files list students. In a regular permitted terminal at home, interactive psql/cypher-shell sessions are optional. The class does not require them.

## 5. Browser clients

```powershell
docker compose --profile web up -d
Start-Process 'http://localhost:8080'
Start-Process 'http://localhost:7474/browser/'
```

Adminer: System PostgreSQL; server `postgres`; user `teacher`; password `TeachingOnly2026`; database `teaching`. Adminer opens schema `public`, which is empty: switch to schema `lab` to see the tables. Queries use the `lab.` schema prefix.

Neo4j Browser: connection `bolt://localhost:7687`; user `neo4j`; password `TeachingOnly2026`; database `neo4j`. Enter this query to display the sample links:

```cypher
MATCH p=(n:Lab)-[r]->(m:Lab) RETURN p;
```

## 6. Persistence experiment

Add Daria in both databases:

```powershell
docker compose cp .\sql\persistence-add.sql postgres:/tmp/add.sql
docker compose exec -T --interactive=false postgres psql -U teacher -d teaching -v ON_ERROR_STOP=1 -f /tmp/add.sql
docker compose cp .\cypher\persistence-add.cypher neo4j:/tmp/add.cypher
docker compose exec -T --interactive=false neo4j cypher-shell -u neo4j -p TeachingOnly2026 -d neo4j --format plain -f /tmp/add.cypher
docker compose --profile web down
docker compose up -d
docker compose ps
```

Wait until both databases are healthy. Container recreation removes the copied files in /tmp, so copy the verification files now:

```powershell
docker compose cp .\sql\persistence-check.sql postgres:/tmp/check.sql
docker compose exec -T --interactive=false postgres psql -U teacher -d teaching -v ON_ERROR_STOP=1 -f /tmp/check.sql
docker compose cp .\cypher\persistence-check.cypher neo4j:/tmp/check.cypher
docker compose exec -T --interactive=false neo4j cypher-shell -u neo4j -p TeachingOnly2026 -d neo4j --format plain -f /tmp/check.cypher
```

Both return s04 Daria. Do not rerun seeds between addition and verification. The optional Adminer service is not restarted by the ordinary `up -d`; start the web profile again if needed.

## 7. Separate Compose files

Use the root file for the class. These alternatives are for independent practice. First stop the root environment, including Adminer:

```powershell
docker compose --profile web down
docker compose -f .\postgres\compose.yaml up -d
docker compose -f .\postgres\compose.yaml ps
docker compose -f .\postgres\compose.yaml down
docker compose -f .\neo4j\compose.yaml up -d
docker compose -f .\neo4j\compose.yaml ps
docker compose -f .\neo4j\compose.yaml down
```

When using an alternative, include the same `-f` option in every `cp`, `exec`, `logs` and `down` command. The root, standalone PostgreSQL and standalone Neo4j projects do not share volumes. Returning to the root project restores its own data.

## Troubleshooting

| Symptom | Check / action |
|---|---|
| `docker` not found | Check Docker Desktop installation and the approved machine setup. |
| Client works but no Server in `docker version` | Start Docker Desktop; wait for engine readiness and check Linux-container mode. |
| `compose` not recognised | Check `docker compose version`. This bundle targets Compose V2. Do not switch blindly to an old docker-compose installation. |
| ISE command waits for interactive input | Stop the operation; use the supplied non-interactive file command with `-T --interactive=false`. |
| Cannot use H: | Check the actual permitted folder and drive. Keep YAML and query files together; do not alter school restrictions. |
| Image download fails | Teacher's pre-pulled cache, or pair at a machine with working images. Installation is not a student exercise. |
| Port already allocated | Inspect Docker Desktop for another copy of this lab. Stop that copy. If the port belongs to another service, change only the host side and update client addresses. |
| Neo4j not healthy | Inspect its finite logs and allow startup time. Start services sequentially on a constrained PC. |
| Red text in ISE | Enter `$LASTEXITCODE`. 0 means the command worked; Docker writes its progress to stderr. |
| psql: `invalid byte sequence for encoding "UTF8": 0xff` | The file is UTF-16, for example written with `>`. Save it again as UTF-8 from an editor. |
| cypher-shell: `Invalid input` at the very start of a file that looks right | The file starts with a BOM, or is UTF-16. Save it as UTF-8 without BOM. |
| Adminer cannot connect to localhost | Set Adminer's server field to `postgres`. |
| Adminer shows no tables | It opened schema `public`. Switch to schema `lab`. |
| Neo4j Browser loads but cannot connect | Check both HTTP 7474 and Bolt 7687, credentials, and service health. |
| Password changed in YAML but login unchanged | Initial passwords do not overwrite credentials already stored in database volumes. Reuse the lab password or intentionally reset only this disposable lab. |
| `relation lab.student does not exist` | Seed that project's PostgreSQL database and check the `lab.` prefix. |
| Old query executes after editing | Repeat `docker compose cp` before executing the file. |
| Data disappeared after switching PCs or projects | Named volumes belong to a Docker installation and Compose project. YAML on H: does not contain database data. |

A host port change such as `127.0.0.1:15432:5432` changes the host connection to 15432. Internal PostgreSQL clients still use `postgres:5432`.
