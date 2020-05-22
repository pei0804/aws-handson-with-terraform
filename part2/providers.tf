terraform {
  backend s3 {}
}

provider aws {
  version = "2.61.0"
  region = "ap-northeast-1"
  profile = "default"
}
