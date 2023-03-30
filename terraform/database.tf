resource "aws_dynamodb_table" "guestbook" {
  name         = var.table_name
  hash_key     = "id"
  range_key    = "name"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "id"
    type = "N"
  }
  attribute {
    name = "name"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "guestbook" {
  table_name = aws_dynamodb_table.guestbook.name
  hash_key   = aws_dynamodb_table.guestbook.hash_key
  range_key  = aws_dynamodb_table.guestbook.range_key
  item       = <<ITEM
    {
        "id": {"N":"686233200"},
        "name": {"S":"Matthew Ivancic"},
        "message": {"S":"first"}
    }
    ITEM
}