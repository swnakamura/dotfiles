---
name: rerun-sdk
description: rerun SDK (rerun-sdk, Python) や rerun viewer を使った 3D/2D 可視化、Pinhole カメラ + 画像オーバーレイ、Blueprint 設定、.rrd ファイル生成・配布などに関する作業で呼び出すこと。トリガー語: "rerun", "rerun-sdk", "rerun viewer", ".rrd", "rr.log", "Pinhole", "Spatial3DView", "Spatial2DView", "Mesh3D", "EyeControls", "serve_grpc", "Blueprint" 等。バージョン 0.31 で検証済みの知見を提供する
version: 1.0.0
---

# rerun SDK 利用ガイド (バージョン 0.31 系で検証済)

rerun (rerun-sdk Python) で 3D シーン + カメラ画像 + メッシュ投影などを可視化する際の実践的な知見集。
鵜呑みにせず、バージョンが変わっている場合は適宜公式ドキュメント (https://rerun.io/docs) で確認すること。

## 推奨インストール

- **必ずバージョンをピン留めすること**: 本 SKILL.md の知見は 0.31 系で検証済み。新しい系列ではAPI差分が出るので、何も指定せず `uv add rerun-sdk` で latest を引くと SKILL.md の記述と齟齬が出る。最低限 `uv add 'rerun-sdk~=0.31.0'` のように `~=` か `==` で固定する。バージョンを更新したくなったら本 SKILL.md も検証し直してから上げる。
- `uv add` で `pyproject.toml` + `uv.lock` に追加
- `uv pip install` は禁止 (ロックされず再現性が壊れる)

## API のクセ

### タイムライン
- 整数 sequence: `rr.set_time("frame", sequence=N)`
- 秒単位 duration: `rr.set_time("time", duration=t_seconds)`
- 一つのタイムラインで型は固定 (sequence と duration を混ぜない)
- `frame` と `time` 等を並行で持てる

### サーバ系 (0.31 で API 変更あり、要注意)
- **古い**: `rr.serve_web(...)` ← 廃止された
- **新しい**: `rr.serve_grpc()` で gRPC server 起動 (default port 9876) → `rr.serve_web_viewer(connect_to=server_uri)` で web viewer ホスト (default port 9090)
- `serve_web_viewer(open_browser=False, connect_to=URI)` の `connect_to` は **`open_browser=True` の時だけ自動接続に使われる**。手動ブラウザアクセス時はクエリ `?url=<URL_ENCODED_server_uri>` を付けて開く必要あり (例: `http://localhost:9090/?url=rerun%2Bhttp%3A%2F%2F127.0.0.1%3A9876%2Fproxy`)
- SSH 越しは **9090 と 9876 両方フォワード必要**

### Transform3D
- `from_parent=False/True` は deprecated → `relation=rr.TransformRelation.ParentFromChild` / `ChildFromParent`
- `ParentFromChild` は「親フレームから見た子フレームの姿勢」を意味する (= world から見たカメラの位置・姿勢)。CV の world2cam を log するときは inverse を取って world_from_cam にする必要あり

### Pinhole カメラ
- `Pinhole(image_from_camera=K, width=w, height=h, camera_xyz=rr.ViewCoordinates.RDF, image_plane_distance=d)`
- `camera_xyz=RDF` (right-down-forward) は OpenCV 標準と同じなので CV パラメータをそのまま渡せる
- **`image_plane_distance` で 3D ビューでの画像プレーン表示距離を制御** (デフォルトでは小さく見えがち)
- **重要: `width`/`height` と intrinsics は実際に log する Image の解像度に合わせる必要あり**。画像をリサイズしたら K の fx, fy, cx, cy も同倍率でスケールしないと、画像が frustum の左上の小領域に貼られて表示される

### カメラを 3D ビューで frustum 表示する (`2D visualizers require a pinhole ancestor` 回避)

2026-06 検証済 (rerun 0.31)。下記 2 つを外すと、frustum が出ず Points マーカー(balls)だけ表示され、
viewer に **`2D visualizers require a pinhole ancestor to be shown in a 3D view`** が出る。

1. **Pinhole は Image の「祖先」に置く (同一エンティティ不可)**。
   - カメラエンティティ `…/cam` に `Transform3D`(姿勢) + `Pinhole`(intrinsics) を一緒に log。
   - 画像は **子エンティティ** `…/cam/image` に `Image`/`EncodedImage` で log。
   - Pinhole と Image を**同じエンティティに置くと祖先にならず frustum が出ない**。
   - 2D ビューは `Spatial2DView(origin="…/cam")`(Pinhole を持つエンティティ)を指定。
2. **姿勢が動かないカメラ(固定カメラ等)は Transform3D+Pinhole を `static=True` で log**。
   - static にしないと、別エンティティが時刻付き(`set_time`)で log された瞬間にタイムラインが
     生成され、**その時刻に固定カメラの Pinhole が存在しない**ため同じエラーになり frustum が消える。
   - 動くカメラ(SLAM/PnP 軌跡)は毎フレーム `set_time`+log するので Pinhole が各時刻に存在し問題ない。
     → 固定カメラだけ取りこぼしやすい。

### 固定カメラでも「映像」は時間変化する (静止画で固定しない)

カメラの**姿勢が固定でも動画は撮れている**。固定カメラの 2D ビューを 1 枚の静止画で log すると
ずっと同じ絵のままになる。**姿勢/Pinhole は `static=True`、画像 (`…/cam/image`) は時刻付きで
per-frame に log** すると動画として再生される (Pinhole が static なので画像はどの時刻でも祖先を持つ)。
- 全カメラ(固定/移動)を**共通タイムライン**(例: 同期済みの ref フレーム軸)に載せると相互に同期する。
  各カメラのローカルフレーム番号をオフセットで ref に変換してから `set_time` する。
- 画像 log は重いので **stride で間引き** + 縮小(K も同倍率スケール)で `.rrd` 肥大を防ぐ。

## 座標系まわり

- world 用に `rr.log("/", rr.ViewCoordinates.RIGHT_HAND_Z_UP, static=True)` (Z 軸が上) や `RIGHT_HAND_Y_UP` を最初に指定する
- カメラ姿勢 (`Transform3D`) の R は **world_from_cam** (ParentFromChild). world2cam (CV 標準) を持っている場合は `R^T`, `-R^T @ t` で変換
- 投影が画面に出ない/逆方向に見える場合、**メッシュがカメラ後方** にある可能性をまず疑え (Transform3D の R を inverse 向きに組んでないか確認)

## Mesh3D の 2D 投影 (Spatial2DView 経由)

検証済み (rerun 0.31): **Mesh3D は Pinhole 経由で自動的に 2D 投影される**。

```python
rrb.Spatial2DView(
    origin="/world/cam/image",                          # Pinhole エンティティ
    contents=["+ $origin/**", "+ /world/mesh/**"],     # 投影したい 3D メッシュを足す
)
```

### ViewContents の syntax (公式)
```
+ /world/**           # add everything…
- /world/roads/**     # …but remove all roads…
+ /world/roads/main   # …but show main road
```
- `+` または `-` の後にスペース + パス。`/**` は再帰サブツリーマッチ
- prefix なしは `+` と同義
- 後ろのルールほど優先

### 投影されない時のチェックリスト
1. メッシュがカメラ前方にあるか (cam frame で z > 0)
2. `contents` に対象 3D エンティティのパスが含まれているか
3. Pinhole エンティティが Transform3D を持つ親 (=3D カメラ姿勢) を持っているか
4. Transform3D の relation 方向が合っているか (CV の world2cam を直接渡してないか)
5. **複数カメラのシーンで `contents=["+ /world/**"]` (catch-all) を使っていないか** — 他カメラの Pinhole まで contents に入ると、rerun が `No transform path from tf#/world/cam_X/image to the view's target frame` エラーを出して **投影が silent fail** する (3D ビューには出るが 2D ビューに出ない)。必ず **self image + 各メッシュを明示列挙** する:
   ```python
   contents=["+ $origin/**", "+ /world/object", "+ /world/hand_right", "+ /world/smplx"]
   ```
   2026-05-11 検証済 (rerun 0.31)

### 魚眼などピンホール以外のカメラ
**重要**: rerun の `Pinhole` は名前通り pinhole 投影しか持っていない。fisheye (KannalaBrandt8 等) や radial-tangential 歪みの強いカメラで撮った **生画像** に対し、3D エンティティを `Spatial2DView` の `contents` に含めて自動投影させると、**端ほど数十〜100 px ズレる**（コード上のバグではなくモデル限界）。

回避策:
- 3D ビューの frustum 用には Pinhole エンティティを残す（CG 表示目的なので OK）
- 2D ビューの `contents` から **3D エンティティを除外**（`+ $origin/**` だけにする等）して自動投影を切る
- 投影点が欲しいなら **自前で `cv2.fisheye.projectPoints` / `cv2.projectPoints` で uv を計算し、`{cam}/image/proj` の Points2D として log**
- フレームによって投影点数が変わるとき、untracked フレームでは `rr.log(path, rr.Clear(recursive=False))` を入れないと前フレームのオーバーレイが残る

代替: 画像側を undistort して pinhole 化してから渡す手もあるが、SLAM/解析パイプラインで生画像を使っている場合「viz 用に別画像を作る」と「SLAM に undistort 後を食わせた」のかと疑念を生むので、自前投影の方が混乱が少ない。2026-05-19 検証済 (rerun 0.31, ORB-SLAM3 + Go3 fisheye)。

### 自力で投影する場合 (Points2D オーバーレイ)
Mesh3D の投影で十分でない場合 (wireframe にしたい、特定の頂点だけプロットしたい等) は自前で:

```python
def project_vertices(verts_world, R_w2c, t_w2c, K, w, h):
    v_cam = verts_world @ R_w2c.T + t_w2c
    z = v_cam[:, 2]
    valid = z > 1e-3
    v = v_cam[valid]
    uvw = v @ K.T
    uv = uvw[:, :2] / uvw[:, 2:3]
    inside = (uv[:,0]>=0)&(uv[:,0]<w)&(uv[:,1]>=0)&(uv[:,1]<h)
    return uv[inside]

# Pinhole エンティティの子に Points2D として log
rr.log(f"{cam_entity}/proj", rr.Points2D(uv, radii=1.0, colors=[r,g,b]))
```
- 画像をリサイズしている場合は **K もリサイズ倍率でスケールする** こと

## Blueprint (初期レイアウト/視点)

```python
import rerun.blueprint as rrb

# 3D ビューを被写体中心に Orbital 固定
spatial3d = rrb.Spatial3DView(
    origin="/world", name="3D",
    eye_controls=rrb.EyeControls3D(
        kind=rrb.Eye3DKind.Orbital,   # Orbital だと look_target が orbit 中心
        position=(cx+2, cy-2, cz+0.5),
        look_target=(cx, cy, cz),
        eye_up=(0.0, 0.0, 1.0),       # Z-up world の場合
    ),
)

# 複数の 2D カメラビューをグリッドに
image_views = [rrb.Spatial2DView(origin=f"/world/cam_{i}/image", name=f"cam{i}") for i in range(8)]

bp = rrb.Blueprint(
    rrb.Vertical(
        spatial3d,
        rrb.Grid(*image_views, grid_columns=3),
        row_shares=[2, 1],
    ),
    collapse_panels=True,
)

# .rrd に blueprint を確実に焼くには send_blueprint を呼ぶ (default_blueprint だけだと永続化されない)
rr.init("app", spawn=False)
rr.save("out.rrd")
rr.send_blueprint(bp)
```

### Blueprint で覚えておくこと
- **`.rrd` に焼きたいなら `rr.send_blueprint(bp)`**。`rr.init(default_blueprint=bp)` は live セッションでしか効かず、`rr.save()` で書き出した `.rrd` を後から viewer で開いてもデフォルトレイアウトに戻ってしまう (2026-05-11 検証済)
- Blueprint を変更したら `.rrd` を作り直すこと
- `Spatial3DView` の auto-frame は scene bbox 全体に合わせるので、カメラが広く散らばっていると被写体が小さくなる → 上記の eye_controls で明示的に視点指定する

### メッシュの不透明度
- `Mesh3D(albedo_factor=[r,g,b,a])` の a で alpha (0-255). 投影オーバーレイで画像が透けて見えるよう調整
- per-vertex の `vertex_colors` も同様に RGBA を渡せる (shape `(N, 4)` uint8)
- viewer 内では Selection panel から AlbedoFactor を編集して動的調整も可能
- `EyeControls3D.kind=Orbital` で初期視点を look_target に向ける + その後のマウス操作も中心固定

## .rrd ファイル

- `rr.save("path.rrd")` でファイル出力 (頂点・面・タイムライン・blueprint 全部埋め込み済)
- 他マシンでも `rerun path.rrd` で開ける (元データセット不要)
- 配布用に使うのが便利 (リモート計算 → ローカル viewer)

## 動作確認のコツ

- ヘッドレス環境では `.rrd` を保存して別マシンの viewer で確認するのが現実的
- web viewer 動作確認: `serve_grpc` + `serve_web_viewer` で 9090 にアクセス、`?url=...` クエリでサーバ指定
- まずは小さな試行 (cube + 1 カメラ) で blueprint や投影の挙動を切り分けるとデバッグが速い
