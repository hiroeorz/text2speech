#!/bin/bash
# install.sh - t2s (Text-to-Speech) CLI コマンド インストーラスクリプト
#
# このスクリプトは、t2sとその依存関係をユーザー環境の独立したディレクトリに配置し、
# 仮想環境の構築を行った上で、どこからでも呼び出せるように ~/.local/bin/t2s に
# シンボリックリンクを作成します。

set -e

INSTALL_DIR="$HOME/.local/share/t2s"
BIN_DIR="$HOME/.local/bin"
SCRIPT_SRC="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "      t2s (Text-to-Speech) インストーラ"
echo "=========================================="

# 1. 必要なソースファイルの存在確認
if [ ! -f "$SCRIPT_SRC/t2s" ] || [ ! -f "$SCRIPT_SRC/requirements.txt" ]; then
    echo "エラー: インストールに必要なファイル (t2s または requirements.txt) が見つかりません。" >&2
    echo "リポジトリのルートディレクトリでこのスクリプトを実行してください。" >&2
    exit 1
fi

# 2. インストール先ディレクトリの作成とコピー
echo "1. インストール用ディレクトリを作成してファイルを配置しています..."
echo "   インストール先: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
cp "$SCRIPT_SRC/t2s" "$INSTALL_DIR/t2s"
cp "$SCRIPT_SRC/requirements.txt" "$INSTALL_DIR/requirements.txt"
chmod +x "$INSTALL_DIR/t2s"

# 3. 仮想環境の構築と依存パッケージのインストール
echo "2. Python仮想環境の構築と依存ライブラリのインストールを行っています..."
python3 -m venv "$INSTALL_DIR/.venv"

echo "   pipをアップデート中..."
"$INSTALL_DIR/.venv/bin/pip" install --upgrade pip -q

echo "   必要なライブラリ (google-genai) をインストール中..."
"$INSTALL_DIR/.venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt" -q

# 4. シンボリックリンクの作成
echo "3. システムから呼び出すためのシンボリックリンクを作成しています..."
mkdir -p "$BIN_DIR"
ln -sf "$INSTALL_DIR/t2s" "$BIN_DIR/t2s"

echo "=========================================="
echo "✨ インストールが正常に完了しました！"
echo "=========================================="
echo ""
echo "👉 動作確認方法:"
echo "   任意のディレクトリで以下のコマンドを実行してください。"
echo "   t2s --help"
echo ""
# ~/.local/bin が PATH に通っているか確認する警告
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "⚠️ 警告: $BIN_DIR に実行パスが通っていない可能性があります。"
    echo "   シェル設定ファイル (~/.bashrc または ~/.zshrc) に以下を追加してください:"
    echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
fi
echo "🔑 使用方法の注意:"
echo "   Gemini APIを利用するため、実行前に環境変数 GEMINI_API_KEY を設定してください:"
echo "   export GEMINI_API_KEY=\"あなたのAPIキー\""
echo "=========================================="
