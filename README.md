# SamAwtrix2

使用 Eclipse Temurin Java 8 / Ubuntu Jammy 重建 AWTRIX 2 執行環境。使用者直接建置自己的映像，不需要私人 registry，也不依賴 whyet/awtrix2。
這是容器執行環境，不是重新編譯 AWTRIX 2 原始碼。

## 準備與啟動

先將自己合法持有的 AWTRIX 2 `awtrix.jar` 放在 Dockerfile 同一層。GitHub 不包含第三方 JAR。
在支援 Linux containers 的 Docker 環境中執行：

```sh
docker compose up -d --build
```

`compose.yml` 以 `build: .` 從專案直接建置，`awtrix2:latest` 是本機映像標籤。首次建置需要下載公開的 Java 基底映像。
瀏覽 `http://主機IP:7000`，實體時鐘連線填主機 IP。

採 bridge 網路，開放 TCP 7000（網頁管理與 HTTP API）、TCP 7001（Matrix Port，實體時鐘連線）與 UDP 5568（E1.31 / sACN 燈光控制）。若被占用，修改 ports 冒號左側的主機連接埠並同步調整連線設定。Premium 授權相容性需實測。

## Synology 建置與部署

將專案與自己的 awtrix.jar 上傳 NAS，在 Container Manager「專案」使用專案資料夾中的 compose.yml 建置並啟動；不需要預先推送或登入映像管理系統。
啟動前停止舊容器並備份完整資料，避免連接埠衝突。

預設使用 Docker 命名資料卷 `awtrix2-data`，全新資料卷會使用映像內附 JAR。
若要沿用既有資料，將服務的 volumes 改為自己的 NAS 資料夾掛載到 `/data`，使用 File Station 顯示的 NAS 本機路徑，不可填 Windows 網路磁碟代號。
更改掛載來源不會自動搬移資料，請先備份並確認來源。

## 檢查

```sh
docker compose build
```

Windows 可執行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\test.ps1
```

檢查包含 Compose 設定、首次複製 JAR、保留既有 JAR，以及拒絕空 JAR。

## 更新與資料保留

更新 Java 基底並重建：

```sh
docker compose build --pull
docker compose up -d
```

停止服務可執行 `docker compose down`，資料卷會保留。不要使用 `docker compose down -v`，這會刪除資料卷。

資料夾中既有 awtrix.jar 優先，啟動時不覆寫；不存在時才複製映像內附版本。因此重建映像只更新執行環境，不會更新資料卷內既有的 AWTRIX 程式。
更換 JAR 前先停止容器並備份資料，另行驗證相容性。回退映像不會還原執行資料。

## 私人設定與授權

私人發布腳本 pushDocker.bat、私人部署檔 compose-online.yml、帳密、日誌、執行資料與第三方 JAR 均不提交 GitHub。

本專案新增的 Dockerfile、腳本、Compose、測試與文件採 GNU GPL v3.0 only（SPDX: GPL-3.0-only），詳見 LICENSE。
第三方 AWTRIX 2 程式、Java 基底與既有資源依各自原授權，不因本專案的 LICENSE 改為 GPLv3。

已驗證 linux/amd64 建置、隔離容器啟動及上述啟動邏輯。尚未驗證 NAS、實體時鐘與外部服務；舊程式的外部服務相容性不會因換基底自動修好。
