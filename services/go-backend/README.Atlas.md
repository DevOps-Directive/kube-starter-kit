Create table
```
mise run-postgres
docker ps # get container id (a878a55ad87a)
docker exec -i a878a55ad87a psql -U postgres -c "CREATE TABLE \"users\" (\"id\" bigint, \"name\" varchar NOT NULL, PRIMARY KEY (\"id\"));" example
```

get schema:
```
atlas schema inspect -u "postgres://postgres:password@localhost:5432/example?search_path=public&sslmode=disable"  > schema.hcl
```

create versioned migration:
```
atlas migrate diff initial \
  --to file://migrations/schema.hcl \
  --dev-url "docker://postgres/18/test?search_path=public"
```

create atlas.hcl
```
env "local" {
  url = "postgres://postgres:password@localhost:5432/example?search_path=public&sslmode=disable"
  migration {
    dir = "file://migrations"
  }
}
```

run atlas migrate:
```
atlas migrate apply --env local
```

add another column to schema.hcl:
```
column "id2" {
  null = false
  type = bigint
}
```

add new versioned migration:
```
atlas migrate diff add_commits \
  --to file://migrations/schema.hcl \
  --dev-url "docker://postgres/18/test?search_path=public"  
```