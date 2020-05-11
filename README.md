# Getting Started

tfstateを置くバケットを作成します（既存のものがあればやらなくてもOK）  
CLIで作る場合は、お好みのバージョンを使ってください。  
筆者はPCに入ってたCLIでバケットを作成しました。

```
❯ aws --version
aws-cli/1.18.56 Python/3.7.0 Darwin/17.7.0 botocore/1.16.6
❯ aws s3api --profile pei create-bucket --bucket pei-sandbox-tfstate --create-bucket-configuration LocationConstraint=ap-northeast-1
{
    "Location": "http://pei-sandbox-tfstate.s3.amazonaws.com/"
}
```

[Makefileのパラメーターをいじる](./Makefile)

作成したバケット名に変更する

```
TFSTATE_BUCKET := pei-sandbox-tfstate
```

プロファイルを設定してください。 `~/.aws/config`  
私の場合は、peiというプロファイルを作成していたので、`pei`とします。

```
AWS_PROFILE := pei
```

設定を適用

```
❯ make plan SCOPE=example/ #良さそうならapplyもしよう
❯ make apply SCOPE=example/
```
