# 위키(docs/kb/)를 읽어 지식 그래프 사이트의 데이터(site/data/*.json)를 다시 만들어요.
# 넣기나 온톨로지를 고친 뒤에 돌려요. Windows PowerShell 5.1 기본 기능만 써요.
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-site-data.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$kb = Join-Path $root 'docs\kb'
$out = Join-Path $root 'site\data'
$utf8 = New-Object Text.UTF8Encoding $false
$read = { param($p) [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8) }
$write = { param($name, $obj) [IO.File]::WriteAllText((Join-Path $out $name), (ConvertTo-Json @($obj) -Depth 4), $utf8) }

# 권고: timeline.md의 표 한 줄이 권고 하나예요
# | 날짜 | 시각 | 제목 | 종류 | [제품](products/x.md) · 분야 | `:줄` | `A-YYYYMMDD-HHMM` |
$adv = @()
foreach ($l in (& $read (Join-Path $kb 'timeline.md')) -split "`r?`n") {
  if ($l -notmatch '^\| \d\d-\d\d .*`(A-(\d{4})(\d\d)(\d\d)-\d{4})` \|$') { continue }
  $c = $l.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
  if ($c.Count -ne 7) { throw "칸이 7개가 아니에요: $l" }
  $pc = $c[4] -split ' · ', 2
  $prod = $pc[0] -replace '^\[(.+)\]\((.+)\)$', '$1'
  $adv += [ordered]@{
    id = $matches[1]; date = "$($matches[2])-$($matches[3])-$($matches[4])"; time = $c[1]; title = $c[2]
    product = $prod; category = $pc[1]; kind = $c[3]; source_line = [int]($c[5] -replace '[`:]', '')
    has_page = $pc[0] -match '^\[.+\]\(products/.+\.md\)$'
  }
}
if (-not $adv.Count) { throw 'timeline.md에서 권고를 찾지 못했어요' }
$adv = @($adv | Sort-Object { $_.id })
$dup = $adv | Group-Object { $_.id } | Where-Object Count -gt 1
if ($dup) { throw "권고 ID가 겹쳐요: $($dup.Name -join ', ')" }

# 제품: 권고에서 세요
$prods = foreach ($g in ($adv | Group-Object { $_.product })) {
  $cats = @($g.Group | ForEach-Object { $_.category } | Select-Object -Unique)
  if ($cats.Count -ne 1) { throw "$($g.Name)의 분야가 여러 개예요: $($cats -join ', ')" }
  $d = @($g.Group | ForEach-Object { $_.date } | Sort-Object)
  [ordered]@{ product = $g.Name; category = $cats[0]; advisories = $g.Count; first = $d[0]; last = $d[-1]; has_page = [bool]$g.Group[0].has_page }
}
foreach ($a in $adv) { $a.Remove('has_page') }

# 이어진 권고: ontology.md 2절 "이어짐" 표의 앞·뒤 칸에 나온 ID를 차례로 이어요
$onto = & $read (Join-Path $kb 'ontology.md')
$follows = @()
$inTable = $false
foreach ($l in $onto -split "`r?`n") {
  if ($l -match '^\| 앞 \| 뒤 \| 근거 \|') { $inTable = $true; continue }
  if ($inTable -and $l -notmatch '^\|') { break }
  if (-not $inTable -or $l -match '^\| ---') { continue }
  $c = $l.Trim('|').Split('|') | ForEach-Object { $_.Trim() }
  $ids = @([regex]::Matches($c[0] + ' ' + $c[1], 'A-\d{8}-\d{4}') | ForEach-Object { $_.Value })
  for ($i = 1; $i -lt $ids.Count; $i++) { $follows += [ordered]@{ from_id = $ids[$i - 1]; to_id = $ids[$i]; reason = $c[2] } }
}
$known = @{}; $adv | ForEach-Object { $known[$_.id] = 1 }
foreach ($f in $follows) { foreach ($id in $f.from_id, $f.to_id) { if (-not $known.ContainsKey($id)) { throw "이어짐 표에 없는 권고 ID가 있어요: $id" } } }

# 온톨로지 개념의 "지금 개수"를 위키에서 다시 세요
$pages = @(Get-ChildItem $kb -Recurse -Filter *.md)
$count = @{
  '알림' = $adv.Count; '권고문' = $adv.Count; '제품' = @($prods).Count
  '분야' = @($adv | ForEach-Object { $_.category } | Select-Object -Unique).Count
  '종류' = @($adv | ForEach-Object { $_.kind } | Select-Object -Unique).Count
  'CVE' = @($adv | Where-Object { $_.title -match 'CVE-' }).Count
  '원본 파일' = @(Get-ChildItem (Join-Path $root 'raw') -Filter *.txt).Count
  '확인 사항' = @($pages | ForEach-Object { [regex]::Matches((& $read $_.FullName), '(?m)^- \d{4}-\d\d-\d\d 확인 \(') } ).Count
  '기록' = @((& $read (Join-Path $kb 'log.md')) -split "`r?`n" | Where-Object { $_ -match '^- \d{4}-\d\d-\d\d ' }).Count
  '쪽' = $pages.Count
}
$conceptsPath = Join-Path $out 'ontology_concepts.json'
$concepts = @((& $read $conceptsPath) | ConvertFrom-Json | ForEach-Object { $_ })
foreach ($c in $concepts) { if ($count.ContainsKey($c.concept)) { $c.count = $count[$c.concept] } }

& $write 'advisories.json' $adv
& $write 'products.json' $prods
& $write 'follows.json' $follows
& $write 'ontology_concepts.json' $concepts
"권고 $($adv.Count), 제품 $(@($prods).Count), 이어진 쌍 $($follows.Count), 개념 개수: " + (($concepts | ForEach-Object { "$($_.concept) $($_.count)" }) -join ', ')
