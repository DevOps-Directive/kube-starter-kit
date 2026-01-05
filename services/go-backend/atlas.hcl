env "local" {
  url = "postgres://postgres:password@localhost:5432/example?search_path=public&sslmode=disable"
  migration {
    dir = "file://migrations"
  }
}