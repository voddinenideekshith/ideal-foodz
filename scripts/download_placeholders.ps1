<#
Download placeholder images referenced in index.html into images/.
Run this locally if you want to cache the current remote images.

Usage: Open PowerShell in the project root and run:
  .\scripts\download_placeholders.ps1

Note: Some remote image URLs may be protected or rate-limited and may fail.
#>

$outDir = Join-Path $PSScriptRoot "..\images"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$images = @(
  @{url='https://images.unsplash.com/photo-1604908177165-5f3b5fbf1c7d?q=80&w=1000&auto=format&fit=crop&s=1'; out='hero.jpg'},
  @{url='https://images.unsplash.com/photo-1543353071-087092ec393a?q=60&w=600&auto=format&fit=crop&s=3'; out='chicken_butter_masala.jpg'},
  @{url='https://images.unsplash.com/photo-1544025162-d76694265947?q=60&w=600&auto=format&fit=crop&s=5'; out='kadai_chicken.jpg'},
  @{url='https://images.unsplash.com/photo-1548943487-a2e4e1a5f2a9?q=60&w=600&auto=format&fit=crop&s=6'; out='chicken_curry.jpg'},
  @{url='https://images.unsplash.com/photo-1603133872877-9b3b0f9ebf25?q=60&w=600&auto=format&fit=crop&s=8'; out='chicken_roast_fry.jpg'},
  @{url='https://images.unsplash.com/photo-1600891964599-f61ba0e24092?q=60&w=600&auto=format&fit=crop&s=9'; out='veg_manchurian.jpg'},
  @{url='https://images.unsplash.com/photo-1604908177549-0f6ff3b9b0ef?q=60&w=600&auto=format&fit=crop&s=11'; out='chicken_biryani.jpg'},
  @{url='https://images.unsplash.com/photo-1586190848861-99aa4a171e90?q=60&w=600&auto=format&fit=crop&s=16'; out='roti.jpg'},
  @{url='https://images.unsplash.com/photo-1598514983663-9b4f5d1a1c7a?q=60&w=600&auto=format&fit=crop&s=21'; out='raita.jpg'},
  @{url='https://images.unsplash.com/photo-1585238342029-3d5c5a6af7c9?q=60&w=600&auto=format&fit=crop&s=22'; out='water_bottle.jpg'}
)

foreach ($i in $images) {
  $out = Join-Path $outDir $i.out
  try{
    Write-Host "Downloading $($i.url) -> $out"
    Invoke-WebRequest -Uri $i.url -OutFile $out -UseBasicParsing -ErrorAction Stop
  } catch {
    Write-Warning "Failed to download $($i.url): $_"
  }
}

Write-Host "Done. Check the images/ folder." -ForegroundColor Green
