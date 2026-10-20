# Video Slide Reconstruction Workflow

將簡報型影片重建為可編輯 PowerPoint 與獨立 PDF 的可重複工作流程. 專案以同一份 JSON 投影片規格產生兩種格式, 並包含影片檢查, 畫面取樣與結構驗證工具.

這套流程重建的是影片中的資訊結構與視覺語言, 不是取得或冒充創作者的原始簡報檔.

## 工作流程

1. 確認來源可以合法存取, 下載內容只作為暫存分析素材.
2. 讀取影片標題, 時長, 章節, 字幕與可用解析度.
3. 下載影片與帶時間軸的字幕.
4. 每 15 到 30 秒取樣, 產生 contact sheet, 再於畫面切換處補採樣.
5. 根據章節, 字幕與代表畫面辨識投影片家族及動畫狀態.
6. 先建立 `slide-spec.json`, 一張投影片只保留一個完整觀念.
7. 從同一份規格產生可編輯 `.pptx` 與 16:9 `.pdf`.
8. 驗證檔案結構, 頁數, 尺寸及缺失圖片, 最後以渲染畫面檢查裁切與碰撞.

## 重建原則

- 預設採用 professional remake, 保留內容順序並改善資訊層級與可讀性.
- 合併逐步動畫, 不把每個動畫狀態做成獨立投影片.
- 標題, 文字, 卡片, 表格與簡單流程使用 PowerPoint 原生物件.
- 複雜介面, 照片或無法合理重畫的素材才使用截圖, 並保留來源標示.
- 字幕用於還原意圖, 不直接堆成逐字稿.
- 看不清楚的數字或圖表資料標示為近似, 不自行臆測.

## 環境需求

- Python 3.10+
- yt-dlp
- OpenCV
- Pillow
- python-pptx
- ReportLab
- pypdf
- 支援中文的 Unicode 字型. Windows 預設尋找 Microsoft JhengHei.

```powershell
python -m pip install -r requirements.txt
```

## 快速開始

檢查影片:

```powershell
python scripts/inspect_video.py "https://www.youtube.com/watch?v=VIDEO_ID"
```

下載影片與繁體中文字幕:

```powershell
New-Item -ItemType Directory -Force work/source | Out-Null
python -m yt_dlp --no-playlist --write-subs --sub-langs zh-TW --sub-format vtt `
  -f "bestvideo[height<=1080]/best[height<=1080]" `
  -o "work/source/source.%(ext)s" `
  "https://www.youtube.com/watch?v=VIDEO_ID"
```

取樣畫面:

```powershell
python scripts/extract_frames.py work/source/source.mp4 work/frames --interval 20 --thumb-width 320
```

建立工作規格:

```powershell
Copy-Item examples/slide-spec.example.json work/slide-spec.json
```

建置及驗證:

```powershell
./build.ps1 -Spec work/slide-spec.json -OutputName reconstructed-deck
```

輸出位於 `output/`.

## Slide spec

每張投影片至少包含 `section`, `title`, `subtitle`, `layout` 與 `elements`. 建議保留 `source_time`, 方便回查影片.

通用版面為 `cover`, `bullets`, `cards`, `comparison`, `process`, `quote`, `image`. 圖片元素以 `path` 指向本機檔案, 並用 `caption` 標記來源.

## 產物與版本控制

`work/` 存放下載媒體, 字幕與分析畫面. `output/` 存放產生的 PPTX, PDF 與檢查結果. 兩者預設不提交 Git, 避免把大型或受著作權保護的素材納入版本庫.

建議提交流程程式, 經整理的 slide spec 範本與必要的自製圖像資產.

## 驗證標準

- PPTX 是有效 ZIP package, 且可由 `python-pptx` 開啟.
- PPTX 與 PDF 頁數一致.
- 兩者皆為 16:9.
- PDF 使用支援內容語言的 Unicode 字型.
- 所有圖片路徑存在, 沒有不必要的外部關聯.
- 渲染後沒有明顯裁切, 重疊或錯誤換行.

## 本次對話案例

流程源自一次公開 YouTube 影片重建工作. 該次案例讀取章節與繁體中文字幕, 每 20 秒取樣 67 張畫面, 將大量動畫狀態合併為 26 張投影片, 最後從同一份 JSON 產生 PPTX 與 PDF, 並驗證頁數和 16:9 尺寸.
