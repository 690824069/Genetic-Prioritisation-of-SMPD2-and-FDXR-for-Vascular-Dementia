param(
  [Parameter(Mandatory=$true)][string]$Path,
  [string]$Mode = "docx"
)

$ErrorActionPreference = "Stop"

function Expand-OfficeFile {
  param([string]$InputPath)
  $tmpRoot = Join-Path $env:TEMP ("codex_office_" + [guid]::NewGuid().ToString("N"))
  New-Item -ItemType Directory -Path $tmpRoot | Out-Null
  $zipPath = Join-Path $tmpRoot "file.zip"
  Copy-Item -LiteralPath $InputPath -Destination $zipPath
  Expand-Archive -LiteralPath $zipPath -DestinationPath $tmpRoot -Force
  return $tmpRoot
}

function Get-XText {
  param($Node)
  return (($Node.Descendants() | Where-Object { $_.Name.LocalName -eq "t" } | ForEach-Object { $_.Value }) -join "")
}

function Inspect-Docx {
  param([string]$InputPath)
  $tmpRoot = Expand-OfficeFile $InputPath
  try {
    [xml]$doc = Get-Content -LiteralPath (Join-Path $tmpRoot "word/document.xml") -Raw -Encoding UTF8
    $nsm = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
    $nsm.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
    $i = 0
    $doc.SelectNodes("//w:p", $nsm) | ForEach-Object {
      $i++
      $text = (($_.SelectNodes(".//w:t", $nsm) | ForEach-Object { $_.'#text' }) -join "")
      if ($text -match "SMPD2|FDXR|F-stat|Instrument selection|External transcriptomic validation|In conclusion|Interpretation|limma|linear models|Mann") {
        "{0}`t{1}" -f $i, $text
      }
    }
  }
  finally {
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force
  }
}

function Convert-ColumnNameToNumber {
  param([string]$ColumnName)
  $sum = 0
  foreach ($c in $ColumnName.ToUpperInvariant().ToCharArray()) {
    $sum = $sum * 26 + ([int][char]$c - [int][char]'A' + 1)
  }
  return $sum
}

function Get-SharedStrings {
  param([string]$Root)
  $path = Join-Path $Root "xl/sharedStrings.xml"
  if (!(Test-Path -LiteralPath $path)) { return @() }
  [xml]$ss = Get-Content -LiteralPath $path -Raw -Encoding UTF8
  $arr = @()
  foreach ($si in $ss.GetElementsByTagName("si")) {
    $arr += (($si.SelectNodes(".//*[local-name()='t']") | ForEach-Object { $_.'#text' }) -join "")
  }
  return $arr
}

function Get-XlsxSheets {
  param([string]$Root)
  [xml]$wb = Get-Content -LiteralPath (Join-Path $Root "xl/workbook.xml") -Raw -Encoding UTF8
  [xml]$rels = Get-Content -LiteralPath (Join-Path $Root "xl/_rels/workbook.xml.rels") -Raw -Encoding UTF8
  $relMap = @{}
  foreach ($rel in $rels.Relationships.Relationship) { $relMap[$rel.Id] = $rel.Target }
  $sheets = @()
  foreach ($sheet in $wb.workbook.sheets.sheet) {
    $rid = $sheet.GetAttribute("id", "http://schemas.openxmlformats.org/officeDocument/2006/relationships")
    $target = $relMap[$rid]
    $cleanTarget = [string]$target
    if ($cleanTarget.StartsWith("/")) {
      $cleanTarget = $cleanTarget.TrimStart("/")
    }
    elseif (!$cleanTarget.StartsWith("xl/")) {
      $cleanTarget = "xl/" + $cleanTarget
    }
    $sheets += [pscustomobject]@{ Name = $sheet.name; Target = $cleanTarget }
  }
  return $sheets
}

function Get-CellValue {
  param($Cell, $SharedStrings)
  $type = $Cell.t
  $vNode = $Cell.SelectSingleNode("./*[local-name()='v']")
  if ($Cell.is) {
    return (($Cell.is.SelectNodes(".//*[local-name()='t']") | ForEach-Object { $_.'#text' }) -join "")
  }
  if ($null -eq $vNode) { return "" }
  $raw = [string]$vNode.InnerText
  if ($type -eq "s") {
    return $SharedStrings[[int]$raw]
  }
  return $raw
}

function Inspect-Xlsx {
  param([string]$InputPath)
  $tmpRoot = Expand-OfficeFile $InputPath
  try {
    $shared = Get-SharedStrings $tmpRoot
    $sheets = Get-XlsxSheets $tmpRoot
    foreach ($sheet in $sheets) {
      "### Sheet: $($sheet.Name)"
      [xml]$ws = Get-Content -LiteralPath (Join-Path $tmpRoot $sheet.Target) -Raw -Encoding UTF8
      $rows = $ws.SelectNodes("//*[local-name()='row']")
      "rows: $($rows.Count)"
      foreach ($row in $rows) {
        $rowNum = [int]$row.GetAttribute("r")
        $cells = @{}
        foreach ($c in $row.c) {
          $ref = [string]$c.GetAttribute("r")
          $colLetters = ($ref -replace "\d", "")
          $cells[(Convert-ColumnNameToNumber $colLetters)] = Get-CellValue $c $shared
        }
        $line = ($cells.Keys | Sort-Object | ForEach-Object { $cells[$_] }) -join "`t"
        if ($rowNum -le 5 -or $line -match "SMPD2|FDXR|rs7372|205622_at|BA9|Table|F-stat|beta|allele") {
          "{0}`t{1}" -f $rowNum, $line
        }
      }
    }
  }
  finally {
    Remove-Item -LiteralPath $tmpRoot -Recurse -Force
  }
}

if ($Mode -eq "docx") {
  Inspect-Docx $Path
}
elseif ($Mode -eq "xlsx") {
  Inspect-Xlsx $Path
}
else {
  throw "Unknown mode: $Mode"
}
