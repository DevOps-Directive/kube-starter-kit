table "users" {
  schema = schema.public
  column "id" {
    null = false
    type = bigint
  }
  column "id2" {
    null = false
    type = bigint
  }
  column "name" {
    null = false
    type = character_varying
  }
  primary_key {
    columns = [column.id]
  }
}
schema "public" {
  comment = "standard public schema"
}
