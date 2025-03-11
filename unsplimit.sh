#!/bin/bash

# 输出解除限速操作
echo "解除 X-UI 限速中..."

# 如果是 Xray/V2Ray 的 API 管理限速，移除或清空限速
# 假设你通过配置文件设置了限制，这里只是示例
# 替换为实际的路径和配置

# 删除或恢复 Xray/V2Ray 配置文件中的限速部分
# 示例：将 upload 和 download 设置为 0 或清空

echo "修改配置文件以解除限速..."
sed -i 's/"upload": [0-9]*/"upload": 0/' /etc/xray/config.json
sed -i 's/"download": [0-9]*/"download": 0/' /etc/xray/config.json

# 重启 Xray 或 V2Ray 服务以应用更改
echo "重启 Xray 服务以应用配置..."
systemctl restart xray

echo "限速已解除！"
