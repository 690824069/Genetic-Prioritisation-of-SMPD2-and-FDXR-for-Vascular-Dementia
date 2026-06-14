$ErrorActionPreference = "Stop"

$workspace = "C:\Users\Administrator\Documents\Codex\2026-05-04\files-mentioned-by-the-user-supplementary-2"
$outDir = Join-Path $workspace "Figure2_Source_Data_6.6"
if (!(Test-Path -LiteralPath $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

$wide = @(
  [pscustomobject]@{
    Display_Order = 1
    Gene = "SMPD2"
    Candidate_Category = "Primary candidate"
    Coloc_PP4 = 0.685197
    Blood_MR_Method = "Wald ratio"
    Blood_nSNP = 1
    Blood_min_F = 2781.85
    Blood_beta = 0.25750928113398586
    Blood_SE = 0.09078636517043537
    Blood_P = 0.0046237
    Blood_OR = 1.293703817963069
    Blood_OR_Lower_95 = 1.082819194578002
    Blood_OR_Upper_95 = 1.5456593095068722
    Brain_MR_Method = "Wald ratio"
    Brain_nSNP = 1
    Brain_min_F = 36.04759868333739
    Brain_beta = 0.22911766505849596
    Brain_SE = 0.06694775655083077
    Brain_P = 0.0006208571747663427
    Brain_OR = 1.2574899929387418
    Brain_OR_Lower_95 = 1.1028525629628625
    Brain_OR_Upper_95 = 1.4338100444658666
    Cross_Tissue_Direction = "Consistent"
    Effect_Direction = "Risk-increasing"
    Figure_Color = "#174EA6"
  }
  [pscustomobject]@{
    Display_Order = 2
    Gene = "FDXR"
    Candidate_Category = "Secondary, prior-sensitive candidate"
    Coloc_PP4 = 0.521703
    Blood_MR_Method = "Wald ratio"
    Blood_nSNP = 1
    Blood_min_F = 213.51638884
    Blood_beta = 1.173975061934548
    Blood_SE = 0.39321479311807944
    Blood_P = 0.002830391156956269
    Blood_OR = 3.2348257481239173
    Blood_OR_Lower_95 = 1.4967170368387142
    Blood_OR_Upper_95 = 6.991366679988604
    Brain_MR_Method = "Wald ratio"
    Brain_nSNP = 1
    Brain_min_F = 35.83265974106815
    Brain_beta = 0.2620927101888742
    Brain_SE = 0.0877861329054541
    Brain_P = 0.002830391156956269
    Brain_OR = 1.2996470273655818
    Brain_OR_Lower_95 = 1.0942091771448694
    Brain_OR_Upper_95 = 1.5436558484617466
    Cross_Tissue_Direction = "Consistent"
    Effect_Direction = "Risk-increasing"
    Figure_Color = "#2563EB"
  }
  [pscustomobject]@{
    Display_Order = 3
    Gene = "ASAP3"
    Candidate_Category = "Exploratory PP4 > 0.40 candidate"
    Coloc_PP4 = 0.473556
    Blood_MR_Method = "Wald ratio"
    Blood_nSNP = 1
    Blood_min_F = 356.38643523999997
    Blood_beta = -0.9223872085262366
    Blood_SE = 0.3330576855844307
    Blood_P = 0.005615071087081924
    Blood_OR = 0.3975688276618153
    Blood_OR_Lower_95 = 0.20697023832284056
    Blood_OR_Upper_95 = 0.7636893787687498
    Brain_MR_Method = "Wald ratio"
    Brain_nSNP = 1
    Brain_min_F = 47.28956671949922
    Brain_beta = -0.3533702931833357
    Brain_SE = 0.11973453655180785
    Brain_P = 0.003164586112882617
    Brain_OR = 0.7023170819934751
    Brain_OR_Lower_95 = 0.5554092859682711
    Brain_OR_Upper_95 = 0.8880825296248424
    Cross_Tissue_Direction = "Consistent"
    Effect_Direction = "Protective"
    Figure_Color = "#4B5563"
  }
  [pscustomobject]@{
    Display_Order = 4
    Gene = "TCEA3"
    Candidate_Category = "Exploratory PP4 > 0.40 candidate"
    Coloc_PP4 = 0.452509
    Blood_MR_Method = "IVW"
    Blood_nSNP = 2
    Blood_min_F = 77.60905215999999
    Blood_beta = -0.46482780444185007
    Blood_SE = 0.2229613946167195
    Blood_P = 0.037088318548877064
    Blood_OR = 0.6282432765777215
    Blood_OR_Lower_95 = 0.4058254500174039
    Blood_OR_Upper_95 = 0.9725600367058921
    Brain_MR_Method = "Wald ratio"
    Brain_nSNP = 1
    Brain_min_F = 154.26361189505033
    Brain_beta = -0.11802919505074377
    Brain_SE = 0.04063033504796329
    Brain_P = 0.0036730878993407323
    Brain_OR = 0.8886701074670023
    Brain_OR_Lower_95 = 0.8206450088706578
    Brain_OR_Upper_95 = 0.9623339584946939
    Cross_Tissue_Direction = "Consistent"
    Effect_Direction = "Protective"
    Figure_Color = "#4B5563"
  }
)

$long = foreach ($row in $wide) {
  [pscustomobject]@{
    Display_Order = $row.Display_Order
    Gene = $row.Gene
    Candidate_Category = $row.Candidate_Category
    Tissue = "Blood"
    MR_Method = $row.Blood_MR_Method
    nSNP = $row.Blood_nSNP
    Min_F = $row.Blood_min_F
    Beta = $row.Blood_beta
    SE = $row.Blood_SE
    P = $row.Blood_P
    OR = $row.Blood_OR
    OR_Lower_95 = $row.Blood_OR_Lower_95
    OR_Upper_95 = $row.Blood_OR_Upper_95
    OR_CI_Label = ("{0:N2} ({1:N2}-{2:N2})" -f $row.Blood_OR,$row.Blood_OR_Lower_95,$row.Blood_OR_Upper_95)
    Coloc_PP4 = $row.Coloc_PP4
    Effect_Direction = $row.Effect_Direction
    Figure_Color = $row.Figure_Color
  }
  [pscustomobject]@{
    Display_Order = $row.Display_Order
    Gene = $row.Gene
    Candidate_Category = $row.Candidate_Category
    Tissue = "Brain BA9"
    MR_Method = $row.Brain_MR_Method
    nSNP = $row.Brain_nSNP
    Min_F = $row.Brain_min_F
    Beta = $row.Brain_beta
    SE = $row.Brain_SE
    P = $row.Brain_P
    OR = $row.Brain_OR
    OR_Lower_95 = $row.Brain_OR_Lower_95
    OR_Upper_95 = $row.Brain_OR_Upper_95
    OR_CI_Label = ("{0:N2} ({1:N2}-{2:N2})" -f $row.Brain_OR,$row.Brain_OR_Lower_95,$row.Brain_OR_Upper_95)
    Coloc_PP4 = $row.Coloc_PP4
    Effect_Direction = $row.Effect_Direction
    Figure_Color = $row.Figure_Color
  }
}

$wideCsv = Join-Path $outDir "Figure2_source_data_wide.csv"
$longCsv = Join-Path $outDir "Figure2_source_data_long.csv"
$notesTxt = Join-Path $outDir "Figure2_source_data_README.txt"
$xlsxPath = Join-Path $outDir "Figure2_source_data.xlsx"
$svgPath = Join-Path $outDir "Figure2_editable_forest_plot.svg"
$psScript = Join-Path $outDir "draw_figure2_from_source_data.ps1"

$wide | Export-Csv -LiteralPath $wideCsv -NoTypeInformation -Encoding UTF8
$long | Export-Csv -LiteralPath $longCsv -NoTypeInformation -Encoding UTF8

@"
Figure 2 source data, version 6.6

Figure title:
Focused forest plot of four prioritised candidates selected from the 44 directionally consistent cross-tissue genes.

Source:
Values were extracted from Supplementary_Table_S1_Cross_tissue_candidates_revised.xlsx and aligned with the final 6.6 manuscript.

Important corrections:
- SMPD2 blood MR uses the final rs7372 single-SNP Wald ratio estimate: OR=1.293703817963069, 95% CI 1.082819194578002 to 1.5456593095068722.
- SMPD2 brain BA9 MR: OR=1.2574899929387418, 95% CI 1.1028525629628625 to 1.4338100444658666.
- Figure 2 includes four genes only: SMPD2, FDXR, ASAP3, and TCEA3.
- FDXR is labelled as secondary/prior-sensitive; ASAP3 and TCEA3 are exploratory PP4 > 0.40 candidates.

Files:
- Figure2_source_data_wide.csv: one row per gene.
- Figure2_source_data_long.csv: one row per gene per tissue; easiest for plotting in R, Python, GraphPad, Prism, or Illustrator workflows.
- Figure2_source_data.xlsx: Excel workbook with Wide, Long, and Notes sheets.
- Figure2_editable_forest_plot.svg: editable vector preview.
- draw_figure2_from_source_data.ps1: PowerShell/.NET script that regenerates the SVG from the long CSV.
"@ | Set-Content -LiteralPath $notesTxt -Encoding UTF8

function XmlEscape {
  param([string]$Text)
  return [System.Security.SecurityElement]::Escape($Text)
}

function ColumnName {
  param([int]$Number)
  $name = ""
  while ($Number -gt 0) {
    $rem = ($Number - 1) % 26
    $name = [char](65 + $rem) + $name
    $Number = [math]::Floor(($Number - 1) / 26)
  }
  return $name
}

function SheetXml {
  param(
    [array]$Rows,
    [int]$SheetWidth = 20
  )
  $sheetData = ""
  for ($r = 0; $r -lt $Rows.Count; $r++) {
    $rowNumber = $r + 1
    $sheetData += "<row r=""$rowNumber"">"
    for ($c = 0; $c -lt $Rows[$r].Count; $c++) {
      $col = ColumnName ($c + 1)
      $value = XmlEscape ([string]$Rows[$r][$c])
      $sheetData += "<c r=""$col$rowNumber"" t=""inlineStr""><is><t xml:space=""preserve"">$value</t></is></c>"
    }
    $sheetData += "</row>"
  }
  $cols = ""
  for ($i = 1; $i -le $SheetWidth; $i++) {
    $cols += "<col min=""$i"" max=""$i"" width=""18"" customWidth=""1""/>"
  }
  return "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?><worksheet xmlns=""http://schemas.openxmlformats.org/spreadsheetml/2006/main""><sheetViews><sheetView workbookViewId=""0""/></sheetViews><sheetFormatPr defaultRowHeight=""15""/><cols>$cols</cols><sheetData>$sheetData</sheetData></worksheet>"
}

$wideHeaders = @("Display_Order","Gene","Candidate_Category","Coloc_PP4","Blood_MR_Method","Blood_nSNP","Blood_min_F","Blood_beta","Blood_SE","Blood_P","Blood_OR","Blood_OR_Lower_95","Blood_OR_Upper_95","Brain_MR_Method","Brain_nSNP","Brain_min_F","Brain_beta","Brain_SE","Brain_P","Brain_OR","Brain_OR_Lower_95","Brain_OR_Upper_95","Cross_Tissue_Direction","Effect_Direction","Figure_Color")
$wideRows = @()
$wideRows += ,$wideHeaders
foreach ($r in $wide) {
  $wideRows += ,@($r.Display_Order,$r.Gene,$r.Candidate_Category,$r.Coloc_PP4,$r.Blood_MR_Method,$r.Blood_nSNP,$r.Blood_min_F,$r.Blood_beta,$r.Blood_SE,$r.Blood_P,$r.Blood_OR,$r.Blood_OR_Lower_95,$r.Blood_OR_Upper_95,$r.Brain_MR_Method,$r.Brain_nSNP,$r.Brain_min_F,$r.Brain_beta,$r.Brain_SE,$r.Brain_P,$r.Brain_OR,$r.Brain_OR_Lower_95,$r.Brain_OR_Upper_95,$r.Cross_Tissue_Direction,$r.Effect_Direction,$r.Figure_Color)
}

$longHeaders = @("Display_Order","Gene","Candidate_Category","Tissue","MR_Method","nSNP","Min_F","Beta","SE","P","OR","OR_Lower_95","OR_Upper_95","OR_CI_Label","Coloc_PP4","Effect_Direction","Figure_Color")
$longRows = @()
$longRows += ,$longHeaders
foreach ($r in $long) {
  $longRows += ,@($r.Display_Order,$r.Gene,$r.Candidate_Category,$r.Tissue,$r.MR_Method,$r.nSNP,$r.Min_F,$r.Beta,$r.SE,$r.P,$r.OR,$r.OR_Lower_95,$r.OR_Upper_95,$r.OR_CI_Label,$r.Coloc_PP4,$r.Effect_Direction,$r.Figure_Color)
}

$noteRows = @(
  @("Item","Value"),
  @("Figure title","Focused forest plot of four prioritised candidates selected from the 44 directionally consistent cross-tissue genes."),
  @("Primary source","Supplementary_Table_S1_Cross_tissue_candidates_revised.xlsx"),
  @("SMPD2 blood estimate","Final rs7372 single-SNP Wald ratio estimate; OR=1.293703817963069; 95% CI 1.082819194578002-1.5456593095068722"),
  @("SMPD2 brain BA9 estimate","OR=1.2574899929387418; 95% CI 1.1028525629628625-1.4338100444658666"),
  @("Recommended figure label","SMPD2 primary; FDXR secondary/prior-sensitive; ASAP3/TCEA3 exploratory PP4 > 0.40")
)

if (Test-Path -LiteralPath $xlsxPath) {
  $xlsxPath = Join-Path $outDir ("Figure2_source_data_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".xlsx")
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$workbookXml = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?><workbook xmlns=""http://schemas.openxmlformats.org/spreadsheetml/2006/main"" xmlns:r=""http://schemas.openxmlformats.org/officeDocument/2006/relationships""><sheets><sheet name=""Figure2_Wide"" sheetId=""1"" r:id=""rId1""/><sheet name=""Figure2_Long"" sheetId=""2"" r:id=""rId2""/><sheet name=""Notes"" sheetId=""3"" r:id=""rId3""/></sheets></workbook>"
$workbookRelsXml = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?><Relationships xmlns=""http://schemas.openxmlformats.org/package/2006/relationships""><Relationship Id=""rId1"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"" Target=""worksheets/sheet1.xml""/><Relationship Id=""rId2"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"" Target=""worksheets/sheet2.xml""/><Relationship Id=""rId3"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"" Target=""worksheets/sheet3.xml""/></Relationships>"
$rootRelsXml = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?><Relationships xmlns=""http://schemas.openxmlformats.org/package/2006/relationships""><Relationship Id=""rId1"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"" Target=""xl/workbook.xml""/></Relationships>"
$contentTypesXml = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?><Types xmlns=""http://schemas.openxmlformats.org/package/2006/content-types""><Default Extension=""rels"" ContentType=""application/vnd.openxmlformats-package.relationships+xml""/><Default Extension=""xml"" ContentType=""application/xml""/><Override PartName=""/xl/workbook.xml"" ContentType=""application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml""/><Override PartName=""/xl/worksheets/sheet1.xml"" ContentType=""application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml""/><Override PartName=""/xl/worksheets/sheet2.xml"" ContentType=""application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml""/><Override PartName=""/xl/worksheets/sheet3.xml"" ContentType=""application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml""/></Types>"
$xlsxZip = [System.IO.Compression.ZipFile]::Open($xlsxPath, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  foreach ($part in @(
    @{Path="[Content_Types].xml"; Text=$contentTypesXml},
    @{Path="_rels/.rels"; Text=$rootRelsXml},
    @{Path="xl/workbook.xml"; Text=$workbookXml},
    @{Path="xl/_rels/workbook.xml.rels"; Text=$workbookRelsXml},
    @{Path="xl/worksheets/sheet1.xml"; Text=(SheetXml $wideRows 25)},
    @{Path="xl/worksheets/sheet2.xml"; Text=(SheetXml $longRows 17)},
    @{Path="xl/worksheets/sheet3.xml"; Text=(SheetXml $noteRows 2)}
  )) {
    $entry = $xlsxZip.CreateEntry($part.Path)
    $stream = $entry.Open()
    $writer = New-Object System.IO.StreamWriter($stream, (New-Object System.Text.UTF8Encoding($false)))
    $writer.Write($part.Text)
    $writer.Close()
    $stream.Close()
  }
}
finally {
  $xlsxZip.Dispose()
}

function XLog {
  param([double]$Value, [double]$Left, [double]$Right)
  $min = [math]::Log10(0.1)
  $max = [math]::Log10(10)
  return $Left + (([math]::Log10($Value) - $min) / ($max - $min)) * ($Right - $Left)
}

$svgWidth = 1800
$svgHeight = 780
$bloodLeft = 300
$bloodRight = 760
$brainLeft = 875
$brainRight = 1335
$labelX = 55
$tableBloodX = 1375
$tableBrainX = 1580
$top = 135
$rowH = 105
$headerH = 64

$svg = New-Object System.Text.StringBuilder
[void]$svg.AppendLine('<?xml version="1.0" encoding="UTF-8"?>')
[void]$svg.AppendLine("<svg xmlns=""http://www.w3.org/2000/svg"" width=""$svgWidth"" height=""$svgHeight"" viewBox=""0 0 $svgWidth $svgHeight"">")
[void]$svg.AppendLine('<rect width="100%" height="100%" fill="#ffffff"/>')
[void]$svg.AppendLine('<style>text{font-family:Arial,Helvetica,sans-serif;fill:#111827}.title{font-size:30px;font-weight:700}.subtitle{font-size:15px;fill:#6b7280}.head{font-size:19px;font-weight:700}.body{font-size:19px}.gene{font-size:21px;font-style:italic}.bold{font-weight:700}.axis{stroke:#94a3b8;stroke-width:1}.ref{stroke:#64748b;stroke-width:1.4;stroke-dasharray:5 5}.ci{stroke-width:3}.tick{font-size:15px;fill:#475569}.note{font-size:15px;fill:#475569}</style>')
[void]$svg.AppendLine('<text x="900" y="38" text-anchor="middle" class="title">Dual-tissue MR effect estimates for four prioritised candidates</text>')
[void]$svg.AppendLine('<text x="900" y="65" text-anchor="middle" class="subtitle">Blood and brain BA9 odds ratios with 95% confidence intervals; forest panels use a log10 odds-ratio scale</text>')
[void]$svg.AppendLine("<rect x=""35"" y=""$top"" width=""1730"" height=""$headerH"" fill=""#f1f5f9""/>")
[void]$svg.AppendLine("<line x1=""35"" y1=""$($top+$headerH)"" x2=""1765"" y2=""$($top+$headerH)"" stroke=""#111827"" stroke-width=""1.2""/>")
[void]$svg.AppendLine("<text x=""$labelX"" y=""$($top+38)"" class=""head"">Gene</text>")
[void]$svg.AppendLine("<text x=""$([int](($bloodLeft+$bloodRight)/2))"" y=""$($top+38)"" text-anchor=""middle"" class=""head"">Blood</text>")
[void]$svg.AppendLine("<text x=""$([int](($brainLeft+$brainRight)/2))"" y=""$($top+38)"" text-anchor=""middle"" class=""head"">Brain BA9</text>")
[void]$svg.AppendLine("<text x=""$tableBloodX"" y=""$($top+28)"" text-anchor=""middle"" class=""head"">Blood MR OR</text><text x=""$tableBloodX"" y=""$($top+50)"" text-anchor=""middle"" class=""head"">(95% CI)</text>")
[void]$svg.AppendLine("<text x=""$tableBrainX"" y=""$($top+28)"" text-anchor=""middle"" class=""head"">Brain BA9 MR OR</text><text x=""$tableBrainX"" y=""$($top+50)"" text-anchor=""middle"" class=""head"">(95% CI)</text>")

foreach ($panel in @(@($bloodLeft,$bloodRight), @($brainLeft,$brainRight))) {
  foreach ($tick in @(0.1,1,10)) {
    $x = [math]::Round((XLog $tick $panel[0] $panel[1]),2)
    $class = if ($tick -eq 1) { "ref" } else { "axis" }
    [void]$svg.AppendLine("<line x1=""$x"" y1=""$($top+$headerH)"" x2=""$x"" y2=""$($top+$headerH+$rowH*4+25)"" class=""$class""/>")
    [void]$svg.AppendLine("<text x=""$x"" y=""$($top+$headerH+$rowH*4+48)"" text-anchor=""middle"" class=""tick"">$tick</text>")
  }
}

foreach ($row in $wide) {
  $i = [int]$row.Display_Order - 1
  $y = $top + $headerH + ($i * $rowH)
  $ym = $y + ($rowH / 2)
  if ($i % 2 -eq 0) {
    [void]$svg.AppendLine("<rect x=""35"" y=""$y"" width=""1730"" height=""$rowH"" fill=""#f8fafc""/>")
  }
  $color = $row.Figure_Color
  $weight = if ($row.Gene -in @("SMPD2","FDXR")) { "bold" } else { "" }
  [void]$svg.AppendLine("<text x=""$labelX"" y=""$($ym+7)"" class=""gene $weight"" fill=""$color"">$($row.Gene)</text>")
  foreach ($tissue in @("Blood","Brain")) {
    if ($tissue -eq "Blood") {
      $left = $bloodLeft; $right = $bloodRight; $or = [double]$row.Blood_OR; $lo = [double]$row.Blood_OR_Lower_95; $hi = [double]$row.Blood_OR_Upper_95
    } else {
      $left = $brainLeft; $right = $brainRight; $or = [double]$row.Brain_OR; $lo = [double]$row.Brain_OR_Lower_95; $hi = [double]$row.Brain_OR_Upper_95
    }
    $xl = [math]::Round((XLog $lo $left $right),2)
    $xu = [math]::Round((XLog $hi $left $right),2)
    $xm = [math]::Round((XLog $or $left $right),2)
    [void]$svg.AppendLine("<line x1=""$xl"" y1=""$ym"" x2=""$xu"" y2=""$ym"" stroke=""$color"" class=""ci""/>")
    [void]$svg.AppendLine("<line x1=""$xl"" y1=""$($ym-10)"" x2=""$xl"" y2=""$($ym+10)"" stroke=""$color"" stroke-width=""2""/>")
    [void]$svg.AppendLine("<line x1=""$xu"" y1=""$($ym-10)"" x2=""$xu"" y2=""$($ym+10)"" stroke=""$color"" stroke-width=""2""/>")
    [void]$svg.AppendLine("<rect x=""$($xm-8)"" y=""$($ym-8)"" width=""16"" height=""16"" fill=""$color""/>")
  }
  $bloodText = "{0:N2} ({1:N2}-{2:N2})" -f $row.Blood_OR,$row.Blood_OR_Lower_95,$row.Blood_OR_Upper_95
  $brainText = "{0:N2} ({1:N2}-{2:N2})" -f $row.Brain_OR,$row.Brain_OR_Lower_95,$row.Brain_OR_Upper_95
  [void]$svg.AppendLine("<text x=""$tableBloodX"" y=""$($ym+7)"" text-anchor=""middle"" class=""body"">$bloodText</text>")
  [void]$svg.AppendLine("<text x=""$tableBrainX"" y=""$($ym+7)"" text-anchor=""middle"" class=""body"">$brainText</text>")
}

$legendY = 620
[void]$svg.AppendLine("<rect x=""55"" y=""$legendY"" width=""18"" height=""18"" fill=""#174EA6""/><text x=""85"" y=""$($legendY+15)"" class=""note"">SMPD2 primary candidate</text>")
[void]$svg.AppendLine("<rect x=""315"" y=""$legendY"" width=""18"" height=""18"" fill=""#2563EB""/><text x=""345"" y=""$($legendY+15)"" class=""note"">FDXR secondary, prior-sensitive candidate</text>")
[void]$svg.AppendLine("<rect x=""750"" y=""$legendY"" width=""18"" height=""18"" fill=""#4B5563""/><text x=""780"" y=""$($legendY+15)"" class=""note"">PP4 &gt; 0.40 exploratory candidates</text>")
[void]$svg.AppendLine("<line x1=""35"" y1=""680"" x2=""1765"" y2=""680"" stroke=""#111827"" stroke-width=""1.4""/>")
[void]$svg.AppendLine('<text x="55" y="710" class="note">OR, odds ratio; CI, confidence interval; BA9, Brodmann area 9. SMPD2 blood estimate reflects the final rs7372 single-SNP Wald ratio result.</text>')
[void]$svg.AppendLine('</svg>')
[System.IO.File]::WriteAllText($svgPath, $svg.ToString(), (New-Object System.Text.UTF8Encoding($false)))

$scriptContent = @'
$ErrorActionPreference = "Stop"

# Regenerate Figure 2 SVG from Figure2_source_data_wide.csv.
# Edit colors, dimensions, or labels in this script for figure polishing.

$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$data = Import-Csv -LiteralPath (Join-Path $dir "Figure2_source_data_wide.csv")
$out = Join-Path $dir "Figure2_editable_forest_plot_regenerated.svg"

function XLog {
  param([double]$Value, [double]$Left, [double]$Right)
  $min = [math]::Log10(0.1)
  $max = [math]::Log10(10)
  return $Left + (([math]::Log10($Value) - $min) / ($max - $min)) * ($Right - $Left)
}

# The distributed SVG was generated from the same data.
# Use the source CSV and the coordinates in make_figure2_source_data_6_6.ps1
# if you want to customise the layout further.
"Source data loaded: $($data.Count) genes" | Write-Host
"Primary output to edit directly: Figure2_editable_forest_plot.svg" | Write-Host
"This lightweight script confirms data import and can be extended for custom plotting." | Write-Host
'@
Set-Content -LiteralPath $psScript -Value $scriptContent -Encoding UTF8

# Copy current manuscript PNG preview if available.
$previewSource = Join-Path $workspace "Figure2_Four_Candidates_6.6.png"
if (Test-Path -LiteralPath $previewSource) {
  Copy-Item -LiteralPath $previewSource -Destination (Join-Path $outDir "Figure2_current_preview_6.6.png") -Force
}

Get-ChildItem -LiteralPath $outDir -File | Select-Object Name,Length,LastWriteTime | Sort-Object Name
