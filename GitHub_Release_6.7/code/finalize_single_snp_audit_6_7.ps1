$ErrorActionPreference = "Stop"

$workspace = "C:\Users\Administrator\Documents\Codex\2026-05-04\files-mentioned-by-the-user-supplementary-2"
$docx = Join-Path $workspace "Manuscript_EBioMedicine_VaD_Integrated_6.7_single_snp_audit.docx"
$s4Csv = Join-Path $workspace "Supplementary_Table_S4_Residual_Limitations_6.7.csv"
$s4Xlsx = Join-Path $workspace "Supplementary_Table_S4_Residual_Limitations_6.7.xlsx"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Set-ParagraphText {
  param($Paragraph, $NamespaceManager, [string]$Text)
  $textNodes = $Paragraph.SelectNodes(".//w:t", $NamespaceManager)
  if ($textNodes.Count -eq 0) { return }
  $textNodes[0].InnerText = $Text
  for ($i = 1; $i -lt $textNodes.Count; $i++) { $textNodes[$i].InnerText = "" }
}

$zip = [System.IO.Compression.ZipFile]::Open($docx, [System.IO.Compression.ZipArchiveMode]::Update)
try {
  $entry = $zip.GetEntry("word/document.xml")
  $reader = New-Object System.IO.StreamReader($entry.Open(), [System.Text.Encoding]::UTF8)
  [xml]$doc = $reader.ReadToEnd()
  $reader.Close()
  $ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
  $ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
  $replacements = 0
  foreach($p in @($doc.SelectNodes("//w:p", $ns))){
    $text = (($p.SelectNodes(".//w:t", $ns) | ForEach-Object { $_.InnerText }) -join "")
    if($text -like "Findings: Blood MR screened 16,845 genes and yielded 895 nominal candidates*Both final blood estimates were single-SNP Wald ratios*"){
      $new = "Findings: Blood MR screened 16,845 genes and yielded 895 nominal candidates; 44 showed nominal, directionally concordant evidence across blood and brain. These stages were hypothesis-generating, and neither final target met the experiment-wide blood MR threshold. SMPD2 showed the strongest colocalization evidence (PP4 = 0.685) and remained above PP4 > 0.50 under a more conservative shared-association prior (PP4 = 0.521). FDXR showed supportive but prior-sensitive colocalization (PP4 = 0.522; PP4 = 0.353 under the conservative prior). Both final primary blood estimates were single-SNP Wald ratios; a post hoc instrument-resolution audit identified a possible alternative two-instrument blood cis-eQTL configuration for SMPD2 but not FDXR. In GSE186798 astrocytes, higher SMPD2 expression in post-stroke dementia was supported by an exact permutation test (P = 0.00382), a bootstrap mean-difference interval excluding zero, and leave-one-out analyses. FDXR downregulation was consistent across GSE22255 and GSE58294, with a pooled Hedges' g of -0.78 (95% CI -1.17 to -0.40; I² = 0%)."
      Set-ParagraphText $p $ns $new
      $replacements++
    }
  }
  $entry.Delete()
  $newEntry = $zip.CreateEntry("word/document.xml")
  $stream = $newEntry.Open()
  $writer = New-Object System.IO.StreamWriter($stream, (New-Object System.Text.UTF8Encoding($false)))
  $doc.Save($writer)
  $writer.Close()
}
finally {
  $zip.Dispose()
}

$s4Rows = @(
  [pscustomobject]@{
    Limitation = "Final primary blood MR estimates were single-SNP Wald ratios"
    Current_mitigation = "Reported SNP identity, alleles, beta/SE, F-statistics, harmonized audit data, and directionally consistent brain BA9 estimates; sensitivity methods marked not applicable rather than omitted; added post hoc instrument-resolution audit showing a possible alternative two-instrument SMPD2 blood cis-eQTL configuration but no additional strict LD-independent FDXR or GTEx BA9 instruments"
    Remaining_inference_boundary = "The final primary estimates remain single-instrument; the SMPD2 alternative configuration requires separate harmonisation and cannot yet support full MR-Egger, weighted median/mode, or Cochran's Q inference"
    Manuscript_position = "Hypothesis-generating genetic prioritisation, not stand-alone causal proof"
    Highest_value_next_step = "Fully harmonise the SMPD2 rs13220304 + rs1113666 configuration against the exact VaD outcome; search additional QTL resources for FDXR; run conditional/fine-mapping-based instrument selection"
  },
  [pscustomobject]@{
    Limitation = "Neither SMPD2 nor FDXR met the experiment-wide blood MR threshold"
    Current_mitigation = "Explicitly separated eQTL instrument-selection Bonferroni threshold from gene-outcome MR multiplicity; reported Bonferroni reference status in S3"
    Remaining_inference_boundary = "Nominal MR screening can generate false-positive candidates and is not FDR-controlled discovery"
    Manuscript_position = "Sequential prioritisation based on convergence across tissues and colocalization"
    Highest_value_next_step = "Report gene-level FDR/q-values for all MR stages and test candidates in independent VaD or VCI GWAS resources"
  },
  [pscustomobject]@{
    Limitation = "No independent VaD or VCI GWAS replication"
    Current_mitigation = "Clearly labelled FinnGen R11 as the discovery outcome and avoided claiming independent genetic replication"
    Remaining_inference_boundary = "Between-cohort robustness, endpoint stability, and ancestry generalisability remain untested"
    Manuscript_position = "Target-prioritisation evidence requiring independent genetic replication"
    Highest_value_next_step = "Apply for or obtain MEGAVCID/CHARGE-UKBB-EADB or comparable independent VaD/VCI summary statistics"
  },
  [pscustomobject]@{
    Limitation = "No conditional or multi-signal colocalization"
    Current_mitigation = "Reported primary coloc PP4 and prior-odds sensitivity; classified FDXR as secondary and prior-sensitive"
    Remaining_inference_boundary = "Multiple independent eQTL/GWAS signals or LD structure could affect PP4 interpretation"
    Manuscript_position = "Supportive shared-variant evidence, not definitive colocalization"
    Highest_value_next_step = "Run coloc.susie, conditional colocalization, fine-mapping, and credible-set overlap using full locus-level summary statistics"
  },
  [pscustomobject]@{
    Limitation = "GSE186798 was not reprocessed from the complete raw expression matrix"
    Current_mitigation = "Used targeted sample-level values, exact permutation, bootstrap, leave-one-out deletion, Welch test, and standardized effect sizes; avoided transcriptome-wide limma claims"
    Remaining_inference_boundary = "Batch effects, probe-level preprocessing, and transcriptome-wide model context cannot be fully assessed"
    Manuscript_position = "External transcriptomic contextualisation, not independent molecular replication"
    Highest_value_next_step = "Reprocess complete GSE186798 or comparable cell-type-resolved data from raw files with matrix-level differential-expression modelling"
  },
  [pscustomobject]@{
    Limitation = "No functional perturbation experiment"
    Current_mitigation = "Separated target prioritisation from therapeutic tractability and avoided causal/druggable-target claims"
    Remaining_inference_boundary = "Mechanism, direction of intervention, safety, and druggability remain unresolved"
    Manuscript_position = "Mechanistically interpretable target hypotheses"
    Highest_value_next_step = "Perturb SMPD2 in astrocyte-endothelial models and FDXR in ischemia/redox models; assess vascular, mitochondrial, and safety phenotypes"
  }
)
$s4Rows | Export-Csv -LiteralPath $s4Csv -NoTypeInformation -Encoding UTF8

function XmlEscape([string]$s) { return [System.Security.SecurityElement]::Escape($s) }

function SheetXml {
  param([array]$Rows)
  $cols = @("Limitation","Current_mitigation","Remaining_inference_boundary","Manuscript_position","Highest_value_next_step")
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')
  $r = 1
  [void]$sb.Append("<row r=""$r"">")
  for($c=0; $c -lt $cols.Count; $c++){ $cell=[char](65+$c)+[string]$r; [void]$sb.Append("<c r=""$cell"" t=""inlineStr""><is><t>$(XmlEscape $cols[$c])</t></is></c>") }
  [void]$sb.Append("</row>")
  foreach($row in $Rows){
    $r++
    [void]$sb.Append("<row r=""$r"">")
    for($c=0; $c -lt $cols.Count; $c++){ $cell=[char](65+$c)+[string]$r; $v=[string]$row.($cols[$c]); [void]$sb.Append("<c r=""$cell"" t=""inlineStr""><is><t>$(XmlEscape $v)</t></is></c>") }
    [void]$sb.Append("</row>")
  }
  [void]$sb.Append('</sheetData></worksheet>')
  return $sb.ToString()
}

if(Test-Path -LiteralPath $s4Xlsx){ Remove-Item -LiteralPath $s4Xlsx -Force }
$contentTypesXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>'
$rootRelsXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'
$workbookXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Residual_limitations" sheetId="1" r:id="rId1"/></sheets></workbook>'
$workbookRelsXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>'

$xlsxZip = [System.IO.Compression.ZipFile]::Open($s4Xlsx, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  foreach($part in @(
    @{Path="[Content_Types].xml"; Text=$contentTypesXml},
    @{Path="_rels/.rels"; Text=$rootRelsXml},
    @{Path="xl/workbook.xml"; Text=$workbookXml},
    @{Path="xl/_rels/workbook.xml.rels"; Text=$workbookRelsXml},
    @{Path="xl/worksheets/sheet1.xml"; Text=(SheetXml $s4Rows)}
  )){
    $e=$xlsxZip.CreateEntry($part.Path)
    $s=$e.Open()
    $w=New-Object System.IO.StreamWriter($s,(New-Object System.Text.UTF8Encoding($false)))
    $w.Write($part.Text)
    $w.Close()
  }
}
finally { $xlsxZip.Dispose() }

"Abstract replacements: $replacements"
"Updated S4 CSV: $s4Csv"
"Updated S4 XLSX: $s4Xlsx"
