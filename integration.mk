PROFILE:=pei
TARGET:="i-hogehoge"
ssm:
	aws --profile $(PROFILE) ssm start-session --target $(TARGET)
