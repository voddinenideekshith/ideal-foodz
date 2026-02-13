<#
PowerShell template to generate images using OpenAI Images API or an alternative.

USAGE:
1. Set your API key as an environment variable: $env:OPENAI_API_KEY = 'sk-...'
2. Edit the $prompts array or point to prompts/image-prompts.md
3. Run: .\scripts\generate_images_template.ps1

This script is a template — adapt the POST endpoint and payload to the provider you use.
#>

$outDir = Join-Path $PSScriptRoot "..\images"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$prompts = @(
    @{name='hero'; prompt = Get-Content -Raw "$(Resolve-Path ..\prompts\image-prompts.md)" -ErrorAction SilentlyContinue | Select-String -Pattern "1\) Hero Banner Image" -Context 0,10},
    @{name='chicken_biryani'; prompt = 'REPLACE_WITH_PROMPT_2'},
    @{name='paneer_butter_masala'; prompt = 'REPLACE_WITH_PROMPT_3'},
    @{name='chicken_roast_fry'; prompt = 'REPLACE_WITH_PROMPT_4'},
    @{name='chicken_soup'; prompt = 'REPLACE_WITH_PROMPT_5'},
    @{name='menu_grid'; prompt = 'REPLACE_WITH_PROMPT_6'}
)

# --- Example: OpenAI Images API template (adjust to your provider) ---
foreach ($p in $prompts) {
    $name = $p.name
    $outfile = Join-Path $outDir ("$name.jpg")
    Write-Host "Prepare generation for: $name -> $outfile"
    # Replace the prompt text below with the detailed prompt from prompts/image-prompts.md
    $promptText = Read-Host "Enter prompt for $name (or press Enter to use default text)"
    if ([string]::IsNullOrWhiteSpace($promptText)) { $promptText = $p.prompt }

    # Example curl-style payload for OpenAI Images endpoint (change URL/payload per provider):
    $curl = @"
curl -s -X POST https://api.openai.com/v1/images/generations \
  -H "Authorization: Bearer $env:OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"prompt":"$($promptText -replace '"','\"')","n":1,"size":"1024x1024"}' \
  | jq -r '.data[0].b64_json' | base64 --decode > "$outfile"
"@

    Write-Host "Generated command (example). Run this in a compatible shell after setting your API key:" -ForegroundColor Yellow
    Write-Host $curl
    Write-Host "---"
}

Write-Host "Template generation script finished. Replace the example payload with your provider's API call and run the generated commands to create images." -ForegroundColor Green
