# Python プロジェクト共通ツーリング (ruff + pre-commit + pytest)

新規 Python プロジェクト開始時、または既存プロジェクトに品質ゲートを入れるときに
この設定を import する。グローバル CLAUDE.md の「Python コーディング方針」から参照。

狙い: コード品質を**人間の注意力ではなく機械(ruff + pre-commit)で自動的に保つ**。
型ヒント・フォーマット・よくあるバグを、コミット前に自動検出/修正する。

---

## 1. セットアップ手順 (uv 前提)

```bash
uv add --dev ruff pre-commit pytest
# 下記の pyproject 設定と .pre-commit-config.yaml を追加してから:
uv run pre-commit install            # git hook を仕込む
uv run pre-commit run --all-files     # 既存コードへ手動適用(任意)
```

## 2. pyproject.toml に追記する設定

```toml
[tool.ruff]
target-version = "py310"   # プロジェクトの最低 Python に合わせる
line-length = 100
extend-exclude = ["third_party"]  # ベンダコード等は除外

[tool.ruff.lint]
# E/F: pycodestyle+pyflakes, I: import 整列, UP: 近代化, B: bugbear(よくあるバグ),
# ANN: 型ヒント強制, SIM: 簡約, RUF: ruff 固有, PTH: pathlib 推奨。
select = ["E", "F", "I", "UP", "B", "ANN", "SIM", "RUF", "PTH"]
ignore = [
    "E501",    # 行長は formatter に任せる(長い literal/URL を切らない)
    "ANN401",  # *args/**kwargs 等で Any を許可
    "B008",    # 引数デフォルトでの関数呼び出し(argparse 等で多用)
    "SIM108",  # 三項演算子を強制しない(可読性優先)
    "RUF001",  # ★日本語(全角)コメント/文字列を ambiguous-unicode 誤検出するため除外
    "RUF002",  # ★同上(docstring)
    "RUF003",  # ★同上(comment)
]

[tool.ruff.lint.per-file-ignores]
"**/__init__.py" = ["F401"]   # 再エクスポート目的の未使用 import を許可

[tool.ruff.lint.isort]
known-first-party = ["<your_package>"]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
addopts = "-q"
```

## 3. .pre-commit-config.yaml

```yaml
# コミット前に ruff(lint) と ruff-format を自動実行。
# 初回: `uv run pre-commit install`
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.15.20  # pyproject の dev 依存 ruff と必ずバージョンを揃える
    hooks:
      - id: ruff          # lint: 安全な自動修正を適用し、残りはコミットを止めて報告
        args: [--fix]
      - id: ruff-format   # format
```

---

## 4. 既存コードへ段階導入するときの定石

大量の既存コードに後から入れると数百件の違反が出る。以下の順で**挙動を変えない範囲から**:

1. **パスA: format + 安全 autofix**(機械的等価) を1コミット。
   `uv run ruff format <files>` → `uv run ruff check --fix <files>`。クォート正規化/
   import 整列/未使用 import 除去等のみ。py_compile で構文確認。
2. **型ヒント付与**(ANN) をディレクトリ単位で。`from __future__ import annotations` を
   先頭に入れて注釈を文字列化(実行時評価を避ける=挙動ゼロ)。`--select ANN` が 0 か確認。
3. **パスB: 挙動が変わりうる修正**を別コミットで個別レビュー:
   - `B905` (`zip(..., strict=)`): 等長が構造保証される箇所のみ `strict=True`(不一致を
     loud に検出。正常入力では挙動ゼロ)。不明なら現状維持の `strict=False`。
   - `SIM115` (裸 `open` → `with`): リソース close が確定化。読取は等価。
   - `F841`/未使用: 副作用と「繋ぎ忘れ(潜在バグ)」の可能性を確認してから。
   - `B023` (ループ変数キャプチャ): 多くは default 引数束縛(`x=x`)で等価に解消。

### --no-verify の使いどころ(重要)
段階導入の途中、まだパスBが残るファイルをコミットすると pre-commit が落ちる。
これは「既知の繰り越し債務」であり、`git commit --no-verify` でその1コミットのみ
バイパスしてよい(理由をコミットメッセージに明記)。`ruff check` では全件報告され続け、
ゲートは今後のコードに有効なまま。**警告を握り潰す対症療法ではない**(全件追跡継続)。
新規プロジェクトは最初からゲートが効くので --no-verify は不要。

---

## 5. 注意点
- ruff の `rev` (pre-commit) と dev 依存の ruff バージョンは必ず一致させる(挙動差防止)。
- numpy 配列は `np.ndarray`、cv2 等は実型で注釈。dict/list/tuple は要素型まで書く。
- 型が自明でない箇所を無理に凝らない。`Any` 逃げは最後の手段。
