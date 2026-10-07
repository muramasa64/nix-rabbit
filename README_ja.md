[English](README.md) | 日本語

# nix-rabbit

Ruby 製のプレゼンテーションツール [Rabbit](https://rabbit-shocker.org/) を動かすための Nix flake の devShell です。

## 前提

- flakes を有効にした Nix
- direnv（任意）
- platform: aarch64-darwin

## 使い方

```sh
nix develop
```

初回は shell hook が `rabbit` gem を `./.gem` にインストールします。
GNOME バインディングをコンパイルするため、数分かかります。

direnv を使う場合は、一度 `direnv allow` を実行すれば、ディレクトリに入るだけで環境が有効になります。

```sh
# ウィンドウでスライドを表示する
rabbit slide.md

# スライドを PDF に出力する
rabbit --print --output-filename slide.pdf slide.md
```

macOS では GTK が Quartz でウィンドウを描画するため、X サーバーや Xvfb は不要です。

## 補足

- `rabbit` gem のバージョンは固定していません。更新するときは `./.gem` を削除してから、もう一度 shell に入ります。
- Fontconfig からは Noto CJK と macOS のシステムフォント（`/System/Library/Fonts`、`/Library/Fonts`）が見えます。
- flake には、macOS で必要になる次の回避策を入れています。
  - Ruby の `pkg-config` gem は `Requires.private` まで解決するため、追加のライブラリ（`libepoxy`、`dav1d`、`libthai`、`libdatrie`）を入れています。
  - macOS の glib は Linux 専用の `sysprof-capture-4` を参照するため、Darwin ではスタブの `.pc` ファイルを用意しています。
  - GObject の typelib を含むのは `poppler_gi` だけなので、`poppler` の代わりにこちらを使い、`GI_TYPELIB_PATH` を明示的に設定しています。
