terraform {
  backend "s3" {} # Makeが良い感じにします
}

provider aws {
  version = "2.53"
  region  = "ap-northeast-1"
  profile = var.profile
}