# t2s (Text-to-Speech) CLI コマンド

`t2s` は、Markdown形式の日本語テキストファイルを読み込み、Google AI Studio（Gemini API）のマルチモーダル音声出力機能（TTS）を利用して、高品質な音声ファイル（WAV形式）を生成するLinux用CLIツールです。

長文のテキストであっても自動的に自然な文の境界で分割（チャンキング）してAPIへリクエストし、生成された複数の音声データをノイズなく1つの音声ファイルに綺麗に結合して保存します。

---

## 🌟 主な特徴

- **自動Markdownクレンジング**: 見出し（`#`）や箇条書き（`-`）、太字（`**`）、リンク（`[表示名](URL)`）などの記号を、音声生成前に自動で除去。AIが記号を「シャープ」や「ハイフン」と読み上げてしまうのを防ぎます。
- **長文テキストの自動分割＆シームレス結合**: APIのコンテキスト制限や生成音声制限を考慮し、句読点や改行などの自然な文末でテキストを自動分割。最後にヘッダー付きWAV形式（**24kHz, 16bit, Mono PCM**）に正確に結合・出力します。
- **スマートな自己再実行 (Self Re-exec) ロジック**: 起動時にスクリプトと同じディレクトリにある仮想環境 (`.venv`) を自動で検知し、最適なPythonインタプリタで自身を再起動します。**ユーザーが仮想環境をアクティベート (`activate`) していなくても、常に安全に動作します。**
- **検証機能付きCLIオプション**: `--help` の表示に完全対応。モデルや利用可能な声を検証（choices）付きで分かりやすく表示します。

---

## 📋 動作環境と依存関係

- **OS**: Linux (WSL含む)
- **言語**: Python 3.10 以上
- **ライブラリ**:
  - `google-genai` (最新のGoogle公式GenAI SDK)
  - ※ 音声結合にはPython標準ライブラリの `wave` のみを使用するため、`ffmpeg` などの外部ツール（バイナリ）のインストールは不要です。

---

## 🚀 インストール & セットアップ

### 1. 依存ライブラリのインストール
本ツールのディレクトリにて、仮想環境を作成しパッケージをインストールします。

```bash
# 仮想環境の作成
python3 -m venv .venv

# 仮想環境へのライブラリインストール
.venv/bin/pip install -r requirements.txt
```

### 2. コマンドへの実行権限付与
`t2s` スクリプトを直接実行できるよう、実行可能属性を付与します。

```bash
chmod +x t2s
```

### 3. APIキーのセットアップ
Google AI Studio から取得したAPIキーを環境変数 `GEMINI_API_KEY` に設定します。

```bash
export GEMINI_API_KEY="あなたのGemini_API_キー"
```
*(日常的に使用する場合は、`~/.bashrc` や `~/.zshrc` に上記の設定を記述しておくことをお勧めします)*

---

## 📖 使用方法

### 基本コマンド
```bash
./t2s [OPTIONS] <INPUT_FILE> <OUTPUT_FILE>
```
- `<INPUT_FILE>`: 読み上げる日本語Markdownファイルのパス
- `<OUTPUT_FILE>`: 出力するWAVファイルの書き出し先パス

---

## 🛠️ オプションとパラメータ

`./t2s --help` を実行することで、いつでも以下の説明を表示できます。

| オプション | 短縮 | デフォルト値 | 選択可能な値 / 説明 |
|:---|:---|:---|:---|
| `--help` | `-h` | - | ヘルプメッセージを表示して終了します。 |
| `--model` | `-m` | `gemini-3.1-flash-tts-preview` | `gemini-3.1-flash-tts-preview`<br>`gemini-2.5-pro-preview-tts`<br>`gemini-2.5-flash-preview-tts`<br>※音声生成(TTS)に対応したGeminiモデル。 |
| `--voice` | `-v` | `Despina` | `Despina`, `Puck`, `Charon`, `Kore`, `Fenrir`, `Aoede`<br>※Geminiの提供するプリビルドの各種声質。 |
| `--chunk-size`| `-c` | `1000` | テキストを自動分割する際の目安となる最大文字数。 |

---

## 📝 実際の使用サンプル

### サンプル 1: デフォルト値での基本的な読み上げ
最も標準的な設定（モデル: `gemini-3.1-flash`, 声: `Despina`）で音声を生成します。

```bash
./t2s sample.md output.wav
```

### サンプル 2: プロモデルを使って生成する
より高品質なプロプレビューモデルを使用して音声を生成します。

```bash
./t2s -m gemini-2.5-pro-preview-tts sample.md output_pro.wav
```

### サンプル 3: 男性ボイスなど声質を変更する
話者を `Puck` （男性ボイス調）や `Kore` に変更して生成します。

```bash
./t2s -v Puck sample.md output_puck.wav
```

### サンプル 4: 長文テキストの分割・結合テスト
約3,500文字（音読約10分相当）のテスト用長文テキスト `long_sample.md` を用いて、自動的に分割処理・結合処理を行わせます。

```bash
./t2s long_sample.md long_output.wav
```
**実行時の出力ログ例:**
```
テキストを 4 個のチャンクに分割しました。音声生成を開始します...
[1/4] 音声生成中... (908文字)
[2/4] 音声生成中... (854文字)
[3/4] 音声生成中... (972文字)
[4/4] 音声生成中... (832文字)
音声を結合し、WAVファイルを書き出しています: long_output.wav
音声ファイルの生成が完了しました！
```

---

## 📂 ファイル構造

```text
text2speech/
├── t2s                # Pythonスクリプト本体 (実行可能ファイル)
├── requirements.txt   # 依存Pythonライブラリ定義
├── sample.md          # 動作テスト用標準Markdown
├── long_sample.md     # 長文(10分相当)動作テスト用Markdown
├── LICENSE            # MITライセンス適用許諾書
├── AGENT.md           # AIエージェント向け共通開発・コミット規約
├── .clinerules        # Cline/Antigravity用自動ロード設定
└── README.md          # 本説明書
```

---

## 📄 ライセンス

このプロジェクトは [MIT ライセンス](LICENSE) のもとでオープンソースとして公開されています。商用・個人利用を問わず、どなたでも無償で自由に変更・再配布・使用いただくことができます。詳細は `LICENSE` ファイルをご覧ください。

