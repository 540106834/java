#!/bin/bash

# ===== 固定字段 =====
HEADER="DIRM01"
LENGTH="0032"
FUNC="0900"
DEVICE_SN="860123456789012"
CHECKSUM="0A"

# ===== 循环次数 =====
COUNT=20   # 你可以改成 100 / 1000

echo "开始生成 $COUNT 条考勤数据..."
echo "--------------------------------"

for ((i=1; i<=COUNT; i++))
do
  # SN 两位递增（01~99循环）
  SN=$(printf "%02d" $((i % 100)))

  # 生成8位随机卡号
  CARD_NO=$(printf "%08d" $((RANDOM % 100000000)))

  # 当前时间 yyyyMMddHHmmss
  EVENT_TIME=$(date +"%Y%m%d%H%M%S")

  # 进出类型随机 0 或 1
  EVENT_TYPE=$((RANDOM % 2))

  # 拼接报文
  PAYLOAD="${HEADER}${LENGTH}${FUNC}${SN}${DEVICE_SN}${CARD_NO}${EVENT_TIME}${EVENT_TYPE}${CHECKSUM}"

  echo "[$i] $PAYLOAD"

  # 发送
  curl -s -X POST http://192.168.11.171:8080/api/raw/upload \
  -H "Content-Type: text/plain" \
  -d "$PAYLOAD" > /dev/null

  # 可选：每条间隔 0.2 秒（模拟真实设备）
  sleep 0.2
done

echo "--------------------------------"
echo "发送完成"