# Docker workshop: PostgreSQL and Neo4j

EIED5E · 3 November 2026

Work in pairs. One person operates, the other predicts and checks. Swap after PostgreSQL.
Keep your query files and observations. Use COMMANDS-POWERSHELL for the exact startup, copy and execute commands.

## A. Your environment

1. Check Docker's client and server, then Compose's version.
2. Read compose.yaml. Find the image, published ports, named volume and health check for each database.
3. Start the root project. Confirm both databases are healthy before loading the seeds.
4. Explain which number is the host port in `127.0.0.1:5432:5432`.

Checkpoint: show your partner both services in `docker compose ps`.

## B. PostgreSQL

Load sql/seed.sql using the command sheet. Write queries in sql/my-query.sql, copying it into the container after each edit. Alternatively use Adminer if the teacher starts its web profile.

1. List student identifiers and names, sorted by identifier.
2. List confirmed enrollments: student name, offering identifier and course title. Sort by name and offering identifier.

SQL hint: join student to enrollment, then course_offering, then course. All tables are in schema `lab`.

## C. Neo4j

Load cypher/seed.cypher. Open Neo4j Browser using the supplied credentials. Display the graph:

```cypher
MATCH p=(n:Lab)-[r]->(m:Lab) RETURN p;
```

Find Student, Enrollment, CourseOffering and Course nodes.

1. List student identifiers and names, sorted by identifier.
2. Answer the same confirmed-enrollment question as in SQL. Follow HAS_ENROLLMENT, FOR_OFFERING and OF_COURSE.
3. Explain why an Enrollment is a node in this model.

Execute at least one Cypher query file using ISE, even if you primarily use Browser.

## D. Extension: missing data and counts

3. Find students with no Enrollment record at all. This differs from having no confirmed enrollment.
4. For every offering, show capacity and confirmed enrollment count. Include offerings with zero enrollments.
5. Explain why `COUNT(*)` can give the wrong result for an empty offering after a SQL LEFT JOIN.
6. Is Student–Offering uniqueness automatically enforced in both supplied representations? Inspect constraints, rather than inferring it from the sample data.

## Submission / exit check

- Your SQL and Cypher for the confirmed-enrollment question.
- If something failed, a precise description of the obstacle.
- One sentence distinguishing image, container and volume.

Stop your lab using the ordinary `down` command when finished. Keep the named volumes unless the teacher explicitly starts a reset exercise.
