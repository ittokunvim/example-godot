# example-godot

Godotで作成したゲームを格納するリポジトリ

20ゲームチャレンジと言うサイトで紹介されているゲームを作成していきます。

https://20_games_challenge.gitlab.io/

## 必要な環境

- [Godot 4.7](https://godotengine.org/download/)（通常版。.NET 版は不要です）

## ゲームを起動する

1. Godot を起動し、プロジェクトマネージャーで「インポート」を押す
2. 遊びたいゲームのフォルダにある `project.godot` を選ぶ（例：`pong/project.godot`）
3. エディタが開いたら、右上の「メインシーンを実行」（▶）か `F5` で起動する

### コマンドラインから起動する場合

```
godot --path pong        # ゲームを起動する
godot -e --path pong     # エディタで開く
```

macOS で `godot` コマンドがない場合は、`/Applications/Godot.app/Contents/MacOS/Godot` を使います。

## ゲーム一覧

| ゲーム | フォルダ |
| ------ | -------- |
| Pong | `pong/` |
| Flappy Bird | `flappy-bird/` |
| Breakout | `breakout/` |
| Jetpack Joyride | `jetpack-joyride/` |

### Pongの操作

- プレイヤーのパドルは `W` / `S` または上下矢印キーで操作します。
- 先に5点取った側が勝者です。

#### アセットの帰属

- サウンド - [効果音ラボ](https://soundeffect-lab.info/)
- BGM - [Lazy night Loop (蒲鉾さちこ)](https://dova-s.jp/_contents/author/profile423.html)

### Flappy Birdの操作

- スペースキーまたはマウスクリックで鳥が羽ばたきます。
- 土管の間を通過すると1点です。
- 土管、画面上端、地面に当たるとゲームオーバーになります。
- ゲームオーバー後にスペースキーまたはマウスクリックでリトライできます。

#### アセットの帰属

- BGM - [shimtone-のほほん鳥](https://www.youtube.com/watch?v=BwypNyEz2Vo)
- サウンド - [効果音ラボ](https://soundeffect-lab.info/)

### Breakoutの操作

- `A` / `D` または左右矢印キーでパドルを操作します。
- スペースキーまたはマウスクリックでゲームを開始・再開します。
- ブロックをすべて壊すとクリアです。ボールを落とすと残機が1つ減り、残機がなくなるとゲームオーバーです。

#### アセットの帰属

- BGM - [NozomiMiura-Streets_of_Dawn](https://www.youtube.com/watch?v=VvOoZxWn5V8)
- サウンド - [効果音ラボ](https://soundeffect-lab.info/)
- フォント - [misaki_gothic](https://littlelimit.net/misaki.htm)

### Jetpack Joyrideの操作

- スペースキーまたはマウスクリックでゲームを開始します。
- プレイ中はスペースキーまたはマウスクリックで上昇して、星を獲得してスコアを伸ばします。
- 進行距離が進むごとにスクロール速度が上がり、より複雑な障害物マップが出現します。
- プレイ中に障害物に当たるとゲームオーバーです。
ゲームオーバー後にスペースキーまたはマウスクリックでリトライできます。

#### アセットの帰属

- アセット - [ToppyPlane](https://kenney.nl/assets/tappy-plane)
- サウンド - [効果音ラボ](https://soundeffect-lab.info/)
- BGM - [田中芳典-いつもの居酒屋](https://www.youtube.com/watch?v=iSIS_T2VPMQ)
- フォント - [misaki_gothic](https://littlelimit.net/misaki.htm)

## 読み込みチェック（CI）

PR と `main` への push のたびに、
GitHub Actions（`.github/workflows/godot-load-check.yml`）が
Godot 4.7.2 で各ゲームを読み込み、スクリプトの構文エラーやシーンの参照切れがないか確かめます。

手元で同じチェックをするには、リポジトリのルートで次のように実行します。

```
cp .github/godot/check_load.gd pong/ci_check_load.gd
godot --headless --path pong --import
godot --headless --path pong -s res://ci_check_load.gd
rm pong/ci_check_load.gd pong/ci_check_load.gd.uid
```

最後に `Checked N files` と出て、`LOAD FAILED` や `ERROR` が出ていなければ成功です。

## Web 向けにエクスポートする

### エクスポートテンプレートを入れる

1. エディタのメニューから「エディター」>「エクスポートテンプレートを管理」を開く
2. 「ダウンロードしてインストール」を押す

テンプレートは Godot のバージョンごとに必要です。
Godot を更新したら、もう一度入れてください。

### エクスポートする

1. 「プロジェクト」>「エクスポート」を開く
2. 「Web」を選び、「プロジェクトのエクスポート」を押す

コマンドラインからは、次のようにエクスポートできます。
出力先はプロジェクトのフォルダから見た場所です。

```
mkdir -p pong/godot-pong
godot --headless --path pong --export-release "Web" godot-pong/index.html
```

### ブラウザで確かめる

書き出した `index.html` をファイルとして直接開いても動きません。ローカルのサーバーを通して開きます。

```
cd pong/godot-pong
python3 -m http.server 8000
```

ブラウザで http://localhost:8000 を開きます。

