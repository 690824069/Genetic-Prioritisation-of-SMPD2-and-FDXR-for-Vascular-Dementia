$ErrorActionPreference = "Stop"

$workspace = "C:\Users\Administrator\Documents\Codex\2026-05-04\files-mentioned-by-the-user-supplementary-2"
$sourceDocx = Join-Path $workspace "Manuscript_EBioMedicine_VaD_Integrated_6.6_figure_consistency.docx"
$outDocx = Join-Path $workspace "Manuscript_EBioMedicine_VaD_Integrated_6.7_single_snp_audit.docx"
$auditDir = Join-Path $workspace "single_snp_resolution_audit"
$s5Csv = Join-Path $workspace "Supplementary_Table_S5_Instrument_Resolution_Audit_6.7.csv"
$s5Xlsx = Join-Path $workspace "Supplementary_Table_S5_Instrument_Resolution_Audit_6.7.xlsx"

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

Copy-Item -LiteralPath $sourceDocx -Destination $outDocx -Force

function Set-ParagraphText {
  param($Paragraph, $NamespaceManager, [string]$Text)
  $textNodes = $Paragraph.SelectNodes(".//w:t", $NamespaceManager)
  if ($textNodes.Count -eq 0) { return }
  $textNodes[0].InnerText = $Text
  for ($i = 1; $i -lt $textNodes.Count; $i++) { $textNodes[$i].InnerText = "" }
}

$zip = [System.IO.Compression.ZipFile]::Open($outDocx, [System.IO.Compression.ZipArchiveMode]::Update)
try {
  $entry = $zip.GetEntry("word/document.xml")
  $reader = New-Object System.IO.StreamReader($entry.Open(), [System.Text.Encoding]::UTF8)
  [xml]$doc = $reader.ReadToEnd()
  $reader.Close()

  $ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
  $ns.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

  $replacements = 0
  $paras = @($doc.SelectNodes("//w:p", $ns))
  foreach ($p in $paras) {
    $text = (($p.SelectNodes(".//w:t", $ns) | ForEach-Object { $_.InnerText }) -join "")
    $new = $null

    if ($text -like "For genes with sufficient numbers of independent instruments, sensitivity analyses were planned*For genes with only two instruments, sensitivity analyses were considered limited*") {
      $new = "For genes with sufficient numbers of independent instruments, sensitivity analyses were planned to evaluate heterogeneity and directional pleiotropy. Cochran's Q test was used to assess heterogeneity, and the MR-Egger intercept test was used to assess directional pleiotropy when the number of instruments was adequate. Weighted median and weighted mode estimates were considered supplementary estimators for multi-instrument genes. For genes instrumented by one valid SNP, including the final blood instruments for SMPD2 and FDXR after harmonized pruning, these sensitivity analyses were not applicable. For genes with only two instruments, sensitivity analyses were considered limited and interpreted cautiously because MR-Egger and mode-based estimators are unstable with very small instrument numbers. As a post hoc instrument-resolution audit, eQTLGen whole-blood cis-eQTLs for SMPD2 and FDXR passing P < 5 x 10^-8 were re-clumped using the 1000 Genomes European reference panel, a 1000-kb window, and r2 < 0.001; r2 < 0.01 was examined only as a sensitivity screen. GTEx v8 BA9 reported independent eQTL outputs were also queried for both genes. This audit was used to evaluate whether the final single-instrument limitation could be mitigated, not to redefine the primary discovery pipeline. [25-28]"
    }
    elseif ($text -like "Genetically predicted higher expression of SMPD2 and FDXR was directionally associated*stand-alone causal proof.") {
      $new = "Genetically predicted higher expression of SMPD2 and FDXR was directionally associated with increased vascular dementia risk in both blood and brain eQTL-based MR analyses. These primary estimates were nominal and based on the final harmonized instrument set; after final pruning both genes were represented by single blood SNPs. A post hoc instrument-resolution audit was therefore conducted to determine whether additional LD-independent cis-eQTL signals could mitigate this limitation."
    }
    elseif ($text -like "For SMPD2, after final harmonization and instrument pruning, one valid blood cis-eQTL instrument was retained*OR 1.26*") {
      $new = "For SMPD2, after final harmonization and instrument pruning, one valid blood cis-eQTL instrument was retained: rs7372 (effect/other allele G/A; eQTL beta = 0.2963; GWAS beta = 0.0763; F = 2781.85; Supplementary Table S2). The final blood-based Wald ratio estimate indicated that genetically predicted higher SMPD2 expression was associated with increased VaD risk (OR 1.29, 95% CI 1.08-1.55; P = 0.00462). This direction was consistent with the brain BA9 assessment estimate (Wald ratio; nSNP = 1; F = 36.05; OR 1.26, 95% CI 1.10-1.43; P = 6.21 x 10^-4). In the post hoc audit, strict eQTLGen clumping identified two candidate LD-independent whole-blood cis-eQTL signals for SMPD2 (rs13220304 and rs1113666; pairwise r2 = 0.000274 in 1000 Genomes EUR). Because the final primary SNP rs7372 was in the same primary eQTL clump as rs13220304 (r2 = 0.686), this finding was treated as a possible alternative two-instrument configuration rather than as a direct replacement of the final rs7372 Wald ratio."
    }
    elseif ($text -like "For FDXR, one harmonized blood cis-eQTL instrument was retained*The wide blood confidence interval reflects single-SNP imprecision.") {
      $new = "For FDXR, one harmonized blood cis-eQTL instrument was retained: rs492095. The blood Wald ratio was OR 3.23 (95% CI 1.50-7.00; P = 2.83 x 10^-3), and the direction was consistent in brain BA9 (Wald ratio; nSNP = 1; F = 35.83; OR 1.30, 95% CI 1.09-1.54; P = 2.830391 x 10^-3). The available blood and brain outputs yielded identical Wald z statistics and P values despite different effect-size scales. Corresponding values were blood beta = 1.174, SE = 0.393 and brain beta = 0.2621, SE = 0.0878. Full audit data are provided in Supplementary Table S2. The wide blood confidence interval reflects single-SNP imprecision. The instrument-resolution audit identified only one strict LD-independent blood cis-eQTL clump for FDXR (rs492095), and GTEx BA9 independent eQTL outputs contained one independent signal each for SMPD2 and FDXR; therefore, the brain BA9 estimates and the FDXR blood estimate remained single-instrument analyses."
    }
    elseif ($text -like "The convergence of cross-tissue genetic prioritisation, colocalization, and transcriptomic context positions SMPD2 as the primary candidate*") {
      $new = "The convergence of cross-tissue genetic prioritisation, colocalization, and transcriptomic context positions SMPD2 as the primary candidate and FDXR as a secondary, prior-sensitive candidate warranting experimental follow-up. This hierarchy is important: neither target achieved experiment-wide significance in the blood MR screen, both final primary blood estimates were single-SNP Wald ratios, and the external cohorts provided disease-state context rather than direct vascular dementia replication. A post hoc instrument-resolution audit partially mitigated the single-instrument concern for SMPD2 by identifying a possible alternative two-instrument blood cis-eQTL configuration, but did not identify an additional independent instrument for FDXR or for either gene in GTEx BA9. The principal contribution is therefore an auditable prioritisation framework and two mechanistically interpretable hypotheses, rather than definitive causal target validation."
    }
    elseif ($text -like "This study has several limitations, which are summarised with corresponding mitigation steps in Supplementary Table S4*") {
      $new = "This study has several limitations, which are summarised with corresponding mitigation steps in Supplementary Table S4. First, the final primary blood MR estimates for both SMPD2 and FDXR were single-SNP Wald ratios. This precluded MR-Egger regression, weighted median, weighted mode, Cochran's Q, and formal multi-instrument pleiotropy assessment for the primary estimates. A post hoc instrument-resolution audit identified a possible alternative two-instrument SMPD2 blood cis-eQTL configuration (rs13220304 and rs1113666; pairwise r2 = 0.000274), but this was not used to replace the final primary estimate because it requires a separately harmonized instrument set and table-level reporting. No additional strict LD-independent FDXR blood instrument was identified, and GTEx BA9 independent eQTL outputs contained one independent signal for each target. We therefore treated the MR results as prioritisation evidence rather than stand-alone causal estimates, reported instrument strength and allele-level audit data, required directional consistency in blood and brain, and interpreted effect sizes cautiously. Second, the gene-vascular dementia MR stages used nominal P < 0.05 for candidate generation, and neither final target met the conservative experiment-wide blood MR threshold. The retained set should therefore be viewed as a hypothesis-generating prioritisation set, not an FDR-controlled discovery set. Third, no independent vascular dementia or vascular cognitive impairment GWAS replication dataset was available within the current analysis. This limits assessment of between-cohort genetic robustness, ancestry generalisability, and endpoint-definition stability. Fourth, the primary colocalization analysis used a single-causal-variant model. Prior-odds sensitivity supported a more robust interpretation for SMPD2 than for FDXR, but conditional or multi-signal colocalization was not performed; residual confounding by multiple independent signals or linkage disequilibrium cannot be excluded. Fifth, GSE186798 provided cell-type-resolved post-stroke dementia context but was not reprocessed from the complete raw expression matrix. Exact permutation, bootstrap, leave-one-out, Welch, and standardized-effect analyses strengthened internal stability of the targeted astrocyte comparison, but they do not replace full matrix-level preprocessing, batch assessment, and transcriptome-wide modelling. Sixth, no functional perturbation experiments were performed. Consequently, neither SMPD2 nor FDXR should be interpreted as a validated causal or therapeutic target, and the findings should guide experimental prioritisation rather than immediate drug-development decisions."
    }
    elseif ($text -like "Future work should address these limitations in a staged manner*") {
      $new = "Future work should address these limitations in a staged manner. The highest-priority next step is replication in independent vascular dementia or vascular cognitive impairment GWAS resources, followed by full harmonisation of the alternative SMPD2 two-instrument blood cis-eQTL configuration, conditional and multi-signal colocalization in disease-relevant brain, vascular, and immune eQTL datasets, and formal pleiotropy audits of the retained instruments. Complete reprocessing of GSE186798 or comparable cell-type-resolved datasets should be used to compare targeted sample-level results with matrix-level differential-expression models. Finally, SMPD2 should be tested in astrocyte-endothelial co-cultures, vascular organoids, and cell-type-specific perturbation models to define whether sphingomyelin metabolism alters gliovascular function, whereas FDXR requires experiments separating chronic genetically influenced redox biology from acute compensatory responses after ischemia. These steps are necessary before either candidate can be considered therapeutically tractable."
    }
    elseif ($text -like "Note: This table reports the analytical criteria used in the final analysis for instrument selection*") {
      $new = "Note: This table reports the analytical criteria used in the final analysis for instrument selection, harmonization, Mendelian randomization, colocalization, single-cell mapping, and external transcriptomic contextualisation. Blood cis-eQTL instruments were selected using a Bonferroni-corrected threshold of P < 2.96 x 10^-6, weak instruments were excluded using F-statistic > 10, and LD clumping was performed using r2 < 0.001 within a 10,000 kb window. The same F-statistic > 10 threshold was applied to frontal cortex BA9 eQTL instruments whenever SNP-level effect estimates and standard errors were available. For single-SNP genes, Wald ratio estimates were used; for multi-SNP genes, IVW with multiplicative random effects was used. PP4 > 0.50 was defined as supportive evidence for colocalization. External transcriptomic robustness analyses included exact permutation, stratified bootstrap, leave-one-out deletion, standardized effect sizes, and a two-cohort pooled standardized-effect analysis. A post hoc instrument-resolution audit was added to assess whether the single-instrument limitation could be mitigated; it did not redefine the primary discovery pipeline."
    }
    elseif ($text -like "Note: PP4 > 0.50 was used as supportive rather than definitive colocalization evidence*Exact instrument information is provided in Supplementary Table S2 and robustness calculations in Supplementary Table S3.") {
      $new = "Note: PP4 > 0.50 was used as supportive rather than definitive colocalization evidence. Gene-outcome MR screening was nominal and hypothesis-generating; neither SMPD2 nor FDXR met the blood-stage experiment-wide threshold of P < 2.97 x 10^-6. Under p12 = 5 x 10^-6, PP4 was 0.521 for SMPD2 and 0.353 for FDXR; under p12 = 2 x 10^-5, PP4 was 0.813 and 0.686, respectively. Exact primary instrument information is provided in Supplementary Table S2, robustness calculations in Supplementary Table S3, and the post hoc instrument-resolution audit in Supplementary Table S5."
    }
    elseif ($text -like "The plot shows nominal blood discovery and frontal cortex BA9 MR estimates for SMPD2, FDXR, ASAP3, and TCEA3*The complete 44-gene forest plot is provided in Supplementary Figure S1.") {
      $new = "The plot shows nominal blood discovery and frontal cortex BA9 MR estimates for SMPD2, FDXR, ASAP3, and TCEA3. Odds ratios and 95% confidence intervals are displayed for each tissue. SMPD2 blood MR uses the final rs7372 single-SNP Wald ratio estimate, OR 1.29 (95% CI 1.08-1.55), and its brain BA9 estimate is OR 1.26 (95% CI 1.10-1.43). SMPD2 and FDXR exceeded PP4 > 0.50 in the primary colocalization analysis, whereas ASAP3 and TCEA3 were exploratory at PP4 > 0.40. These MR screening results were hypothesis-generating and not experiment-wide significant. The post hoc instrument-resolution audit is reported separately in Supplementary Table S5 and does not alter the primary estimates displayed here. The complete 44-gene forest plot is provided in Supplementary Figure S1."
    }
    elseif ($text -like "Supplementary Table S3. Robustness analyses for the prioritised targets*definitive causal or therapeutic validation.") {
      $new = "Supplementary Table S3. Robustness analyses for the prioritised targets, including experiment-wide Bonferroni reference status, colocalization prior-odds sensitivity, exact permutation, bootstrap and leave-one-out analyses of GSE186798 astrocytes, two-cohort pooled standardized-effect analysis of FDXR across GSE22255 and GSE58294, descriptive SMPD2 context-specific effects, and data-provenance notes. Supplementary Table S4. Residual limitations and mitigation strategy. This table maps the six principal unresolved limitations to the mitigation steps already included in the present manuscript, the residual inference boundary, and the analyses or experiments required to resolve each limitation. Supplementary Table S5. Post hoc instrument-resolution audit for SMPD2 and FDXR, including GTEx BA9 independent eQTL records, eQTLGen blood cis-eQTL LD-clumping results, and pairwise LD checks for the candidate SMPD2 alternative two-instrument configuration. These supplementary materials clarify that the study provides an auditable genetic prioritisation framework and target hypotheses rather than definitive causal or therapeutic validation."
    }

    if ($new -ne $null) {
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

$summary = Import-Csv -LiteralPath (Join-Path $auditDir "single_snp_resolution_summary.csv")
$extra = @(
  [pscustomobject]@{
    Resource = "Pairwise LD, 1000 Genomes EUR"
    Gene = "SMPD2"
    Criterion = "rs13220304 vs rs1113666"
    IndependentSignals = "NA"
    IndexSNPs = "rs13220304; rs1113666"
    Interpretation = "Pairwise r2 = 0.000274; supports low LD between the two strict clump index SNPs"
  },
  [pscustomobject]@{
    Resource = "Pairwise LD, 1000 Genomes EUR"
    Gene = "SMPD2"
    Criterion = "rs7372 vs rs13220304"
    IndependentSignals = "NA"
    IndexSNPs = "rs7372; rs13220304"
    Interpretation = "Pairwise r2 = 0.686; current primary SNP rs7372 belongs to the same primary clump as rs13220304"
  },
  [pscustomobject]@{
    Resource = "Pairwise LD, 1000 Genomes EUR"
    Gene = "SMPD2"
    Criterion = "rs7372 vs rs1113666"
    IndependentSignals = "NA"
    IndexSNPs = "rs7372; rs1113666"
    Interpretation = "Pairwise r2 = 0.0139; not sufficiently independent under the strict r2 < 0.001 rule"
  }
)
$allRows = @($summary) + @($extra)
$allRows | Export-Csv -LiteralPath $s5Csv -NoTypeInformation -Encoding UTF8

function XmlEscape([string]$s) {
  return [System.Security.SecurityElement]::Escape($s)
}

function SheetXml {
  param([array]$Rows)
  $cols = @("Resource","Gene","Criterion","IndependentSignals","IndexSNPs","Interpretation")
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')
  $r = 1
  [void]$sb.Append("<row r=""$r"">")
  for($c=0; $c -lt $cols.Count; $c++){
    $cell = [char](65+$c) + [string]$r
    [void]$sb.Append("<c r=""$cell"" t=""inlineStr""><is><t>$(XmlEscape $cols[$c])</t></is></c>")
  }
  [void]$sb.Append("</row>")
  foreach($row in $Rows){
    $r++
    [void]$sb.Append("<row r=""$r"">")
    for($c=0; $c -lt $cols.Count; $c++){
      $cell = [char](65+$c) + [string]$r
      $v = [string]$row.($cols[$c])
      [void]$sb.Append("<c r=""$cell"" t=""inlineStr""><is><t>$(XmlEscape $v)</t></is></c>")
    }
    [void]$sb.Append("</row>")
  }
  [void]$sb.Append('</sheetData></worksheet>')
  return $sb.ToString()
}

function NotesXml {
  $rows = @(
    @("Item","Note"),
    @("Purpose","Post hoc audit to assess whether the final single-instrument limitation could be mitigated for SMPD2 or FDXR."),
    @("Primary manuscript status","The final primary blood MR estimates remain SMPD2 rs7372 Wald ratio and FDXR rs492095 Wald ratio."),
    @("Key SMPD2 finding","Strict eQTLGen LD clumping identified rs13220304 and rs1113666 as a possible alternative two-instrument blood cis-eQTL configuration."),
    @("Key caution","rs7372 and rs13220304 are in the same primary eQTL clump; the alternative SMPD2 configuration requires separate harmonisation before it can be used as a sensitivity MR."),
    @("FDXR finding","No additional strict LD-independent blood cis-eQTL or GTEx BA9 independent eQTL was identified for FDXR.")
  )
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')
  for($r=1; $r -le $rows.Count; $r++){
    [void]$sb.Append("<row r=""$r"">")
    for($c=0; $c -lt 2; $c++){
      $cell = [char](65+$c) + [string]$r
      [void]$sb.Append("<c r=""$cell"" t=""inlineStr""><is><t>$(XmlEscape $rows[$r-1][$c])</t></is></c>")
    }
    [void]$sb.Append("</row>")
  }
  [void]$sb.Append('</sheetData></worksheet>')
  return $sb.ToString()
}

if(Test-Path -LiteralPath $s5Xlsx){ Remove-Item -LiteralPath $s5Xlsx -Force }
$contentTypesXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/><Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>'
$rootRelsXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'
$workbookXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Audit_summary" sheetId="1" r:id="rId1"/><sheet name="Notes" sheetId="2" r:id="rId2"/></sheets></workbook>'
$workbookRelsXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/><Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/></Relationships>'

$xlsxZip = [System.IO.Compression.ZipFile]::Open($s5Xlsx, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  foreach($part in @(
    @{Path="[Content_Types].xml"; Text=$contentTypesXml},
    @{Path="_rels/.rels"; Text=$rootRelsXml},
    @{Path="xl/workbook.xml"; Text=$workbookXml},
    @{Path="xl/_rels/workbook.xml.rels"; Text=$workbookRelsXml},
    @{Path="xl/worksheets/sheet1.xml"; Text=(SheetXml $allRows)},
    @{Path="xl/worksheets/sheet2.xml"; Text=(NotesXml)}
  )){
    $e = $xlsxZip.CreateEntry($part.Path)
    $s = $e.Open()
    $w = New-Object System.IO.StreamWriter($s, (New-Object System.Text.UTF8Encoding($false)))
    $w.Write($part.Text)
    $w.Close()
  }
}
finally {
  $xlsxZip.Dispose()
}

"Updated manuscript: $outDocx"
"Paragraph replacements: $replacements"
"Supplementary S5 CSV: $s5Csv"
"Supplementary S5 XLSX: $s5Xlsx"
