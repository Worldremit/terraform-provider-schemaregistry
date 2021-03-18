provider "schemaregistry" {
  version = "0.1.0"
  url = "https://username:password@hostname"
}

resource "schemaregistry_subject_schema" "kafka_schemas" {
  for_each = {
    "test-schema": "\"string\""
  }
  subject = each.key
  schema = each.value
}