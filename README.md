
Automated Trading Cryptocurrency by bitFlyer

- bitFlyerの自動売買プログラム

### 環境構築（ローカル環境）

```
$ cp .env.sample .env
$ vim .env
### bitFlyer API
API_KEY="<bitFlyerのAPI_KEY>"
API_SECRET="<bitFlyerのAPI_SECRET>"

### Slack
WEBHOOK_URL="<SlackのWebhook_URL>"

### Deploy Server
HOST="<デプロイ先のホスト>"
PORT="22"
USER="<デプロイ先のユーザ>"

### Order
ORDER_PERIODS="180" # 売買計算間隔：30m * 60s
ORDER_SIZE="0.001"  # 売買単価：0.001 BTC


# デーモン実行
$ ./exec_daemon.sh start
$ ./exec_daemon.sh restart
$ ./exec_daemon.sh stop
```

### 環境構築（サーバ環境）

- CircleCIで各変数を設定

```
### bitFlyer API
API_KEY="<bitFlyerのAPI_KEY>"
API_SECRET="<bitFlyerのAPI_SECRET>"

### Slack
WEBHOOK_URL="<SlackのWebhook_URL>"

### Deploy Server
HOST="<デプロイ先のホスト>"
PORT="22"
USER="<デプロイ先のユーザ>"

### Order
ORDER_PERIODS="180" # 売買計算間隔：30m * 60s
ORDER_SIZE="0.001"  # 売買単価：0.001 BTC
```

- Github / CircleCI の連携設定

- Githubにデプロイ

### 売買ルール

- ボリンジャーバンドを計算

- 現在価格が 「±2σを超える」 かつ 「最終ローソク足の高値/安値より0.01σ高い/低い」ときに売買する

### 結果

- （検証中🤔）

### Author

- Takayuki Koyama : https://twitter.com/tkoyama1988
