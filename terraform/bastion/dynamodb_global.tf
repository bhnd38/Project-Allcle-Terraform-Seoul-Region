provider "aws" {
  alias = "us-east-2"
  region = "us-east-2"
}

resource "aws_dynamodb_table_replica" "schedule_table" {
  provider = aws.us-east-2
  global_table_arn = aws_dynamodb_table.schedule_table.arn

  depends_on = [ aws_dynamodb_table.schedule_table ]
}

resource "aws_dynamodb_table_replica" "professor_table" {
  provider = aws.us-east-2
  global_table_arn = aws_dynamodb_table.professor_table.arn

  depends_on = [ aws_dynamodb_table.professor_table ]
}

resource "aws_dynamodb_table_replica" "course_table" {
  provider = aws.us-east-2
  global_table_arn = aws_dynamodb_table.course_table.arn
}

resource "aws_dynamodb_table_replica" "student_table" {
  provider = aws.us-east-2
  global_table_arn = aws_dynamodb_table.student_table.arn

  depends_on = [ aws_dynamodb_table.student_table ]
}

resource "aws_dynamodb_table_replica" "enrollment_table" {
  provider = aws.us-east-2
  global_table_arn = aws_dynamodb_table.enrollment_table.arn

  depends_on = [ aws_dynamodb_table.enrollment_table ]
}

resource "aws_dynamodb_table_replica" "pre_enroll_table" {
  provider = aws.us-east-2
  global_table_arn = aws_dynamodb_table.pre_enroll_table.arn

  depends_on = [ aws_dynamodb_table.pre_enroll_table ]
}
