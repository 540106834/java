#!/bin/bash

# ===== 固定字段 =====
HEADER="DIRM01"
LENGTH="0023"
FUNC="0900"
DEVICE_SN="860123456789012"
CHECKSUM="0A"

# ===== 参数配置 =====
COUNT=20               # 发送条数
BASE_TIME="20260226073000"  # 起始时间（yyyyMMddHHmmss）
EVENT_TYPE="0"         # 0=上学 1=放学

echo "开始生成 $COUNT 条考勤数据..."
echo "--------------------------------"

for ((i=1; i<=COUNT; i++))
do
  # SN 两位递增
  SN=$(printf "%02d" $i)

  # 卡号 00000001~00000020 循环
  CARD_NO=$(printf "%08d" $i)

  # 时间递增 10 秒
  EVENT_TIME=$(date -d "now +$(( (i-1)*10 )) seconds" +"%Y%m%d%H%M%S")

  # 拼接报文
  PAYLOAD="${HEADER}${LENGTH}${FUNC}${SN}${DEVICE_SN}${CARD_NO}${EVENT_TIME}${EVENT_TYPE}${CHECKSUM}"

  echo "[$i] $PAYLOAD"

  curl -s -X POST http://192.168.11.171:8080/api/raw/upload \
  -H "Content-Type: text/plain" \
  -d "$PAYLOAD" > /dev/null

  sleep 0.2
done

echo "--------------------------------"
echo "发送完成"