#!/bin/bash
# X-UI 限速功能安装脚本
# 适用于 Xray/V2ray，使用 API 进行限速

# 1. 修改 X-UI 前端，添加限速按钮
echo "正在修改 X-UI 前端..."
cat << EOF > /usr/local/x-ui/web/js/speed_limit.js
function openSpeedLimitModal(userId) {
    let uploadSpeed = prompt("请输入上传限速（单位：KB/s）：", "1000");
    let downloadSpeed = prompt("请输入下载限速（单位：KB/s）：", "1000");

    if (uploadSpeed && downloadSpeed) {
        fetch("/api/set_speed_limit", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                id: userId,
                upload: parseInt(uploadSpeed),
                download: parseInt(downloadSpeed)
            })
        }).then(response => {
            if (response.ok) {
                alert("限速设置成功！");
            } else {
                alert("设置失败，请检查服务器！");
            }
        });
    }
}
EOF

# 2. 修改 X-UI 后端，添加限速 API
echo "正在修改 X-UI 后端..."
cat << EOF > /usr/local/x-ui/internal/controller/speed_limit.go
package controller

import (
    "encoding/json"
    "net/http"
    "x-ui/internal/service"
)

type SpeedLimitRequest struct {
    ID       string \`json:"id"\`
    Upload   int    \`json:"upload"\`
    Download int    \`json:"download"\`
}

func SetSpeedLimit(w http.ResponseWriter, r *http.Request) {
    var req SpeedLimitRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "Invalid request", http.StatusBadRequest)
        return
    }

    err := service.SetUserSpeedLimit(req.ID, req.Upload, req.Download)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }

    w.WriteHeader(http.StatusOK)
    w.Write([]byte("Speed limit updated"))
}
EOF

# 3. 添加限速逻辑到 Service 层
echo "正在更新 X-UI Service..."
cat << EOF > /usr/local/x-ui/internal/service/speed_limit_service.go
package service

import (
    "bytes"
    "encoding/json"
    "fmt"
    "net/http"
)

const xrayAPIURL = "http://127.0.0.1:10085/config"

func SetUserSpeedLimit(userID string, upload int, download int) error {
    requestData := map[string]interface{}{
        "inbounds": []map[string]interface{}{
            {
                "settings": map[string]interface{}{
                    "clients": []map[string]interface{}{
                        {
                            "id": userID,
                            "speed": map[string]int{
                                "upload":   upload * 1024,
                                "download": download * 1024,
                            },
                        },
                    },
                },
            },
        },
    }

    jsonData, _ := json.Marshal(requestData)
    req, err := http.NewRequest("POST", xrayAPIURL, bytes.NewBuffer(jsonData))
    if err != nil {
        return err
    }
    req.Header.Set("Content-Type", "application/json")

    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        return err
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        return fmt.Errorf("failed to update speed limit, status: %d", resp.StatusCode)
    }

    return nil
}
EOF

# 4. 重新编译 X-UI
echo "正在编译 X-UI..."
cd /usr/local/x-ui
go build -o x-ui

# 5. 重启 X-UI 服务
echo "正在重启 X-UI..."
systemctl restart x-ui

echo "✅ 限速功能安装完成！请刷新 X-UI 界面测试！"
