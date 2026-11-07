# SamAwtrix2

使用 Eclipse Temurin Java 8 / Ubuntu Jammy 重建 AWTRIX 2 執行環境，不依賴舊的 whyet/awtrix2，也不在啟動時下載程式。
這是容器執行環境，不是重新編譯 AWTRIX 2 原始碼。

## 準備與建置

先將自己合法持有的 AWTRIX 2 `awtrix.jar` 放在 Dockerfile 同一層。第三方 JAR 不包含在 GitHub 中。
啟動 Docker 的 Linux containers 環境後執行：

```sh
docker build --pull --platform linux/amd64 -t awtrix2:latest .
```

Java 8 保留舊程式相容性。ARM NAS 請改為相符的平台建置。

## 檢查與本機測試

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\test.ps1
```

測試驗證 Compose 設定，以及首次複製 JAR、保留既有 JAR、拒絕空 JAR。
`docker compose up -d --build` 可啟動獨立本機測試資料；網頁位於 http://localhost:17000 。
`docker compose down` 停止服務並保留測試資料。本機 bridge 測試不代表實體時鐘已驗證。

## 發布到自己的 registry

以下是範例，請替換為自己的 registry 與版本：

```sh
docker login registry.example.com
docker tag awtrix2:latest registry.example.com/your-namespace/awtrix2:VERSION
docker push registry.example.com/your-namespace/awtrix2:VERSION
```

私人推送腳本 `pushDocker.bat` 與部署設定 `compose-online.yml` 僅留在本機，由 .gitignore 排除，不提交 GitHub。

## Synology 部署

1. 停止舊容器並備份完整資料，避免新舊容器同時占用連接埠。
2. 複製 `compose-example.yml` 為本機的 `compose-online.yml`。
3. 將 image 改為自己的映像位址與版本，source 改為 File Station 顯示的 NAS 實際資料夾。Windows 網路磁碟代號不能用於 NAS 掛載。
4. 如有需要，設定 registry 登入。
5. 在 Container Manager「專案」匯入自己的 compose-online.yml，拉取並啟動。

採 bridge 網路，時鐘連線填 NAS IP。TCP 7000 用於網頁管理與 HTTP API，TCP 7001 是實體時鐘的 Matrix Port，UDP 5568 接收 E1.31 / sACN 燈光控制資料。若連接埠被占用，修改 ports 冒號左側的 NAS 連接埠並同步調整連線設定。Premium 授權相容性需實測。

## 資料、更新與回退

掛載資料夾中既有 awtrix.jar 優先，啟動時不覆寫；不存在時才複製映像內附版本，空檔案會報錯。因此更新映像僅更新執行環境，不會更新現有 JAR。

發布新映像後，在 NAS 拉取並重建容器：

```sh
docker compose -f compose-online.yml pull
docker compose -f compose-online.yml up -d
```

保留每次發布的版本標籤以便回退。回退映像不會還原資料；需要還原資料時先停止容器，再還原備份。
更換 AWTRIX 程式前，先另行驗證 JAR，備份並替換資料夾內的版本；新安裝使用的專案 JAR 也需更新並重建。

## 授權與限制

本專案新增的 Dockerfile、腳本、Compose、測試與文件採 GNU GPL v3.0 only（SPDX: GPL-3.0-only），詳見 LICENSE。
第三方 AWTRIX 2 程式、Java 基底與既有資源依各自原授權，不因本專案的 LICENSE 改為 GPLv3。
私人設定、帳密、日誌、執行資料與第三方 JAR 均不應提交。

已驗證 linux/amd64 建置、隔離容器啟動及上述啟動邏輯。尚未驗證 NAS、實體時鐘與外部服務；舊 AWTRIX 2 程式的外部服務相容性不會因換基底自動修好。
