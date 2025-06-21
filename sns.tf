resource "aws_sns_topic" "event_topic" {
  name = "event-announcement-topic"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.event_topic.arn
  protocol  = "email"
  endpoint  = "shaikhazhar11603@gmail.com"  # replace with your email
}
