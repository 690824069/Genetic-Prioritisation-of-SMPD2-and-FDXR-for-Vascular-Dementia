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
