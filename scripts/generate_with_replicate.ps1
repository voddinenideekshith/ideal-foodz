<#
Generates images via Replicate API for all menu items and hero/menu_grid.

Requirements:
- Set environment variable REPLICATE_API_TOKEN with your token before running.

Usage:
  Open PowerShell in project root and run:
    $env:REPLICATE_API_TOKEN = 'your_token_here'
    .\scripts\generate_with_replicate.ps1

This script will:
- Fetch the model default version
- Submit a prediction for each prompt
- Poll until completion and download the image into images/ as JPG

Note: This script performs many API calls and may consume credits.
#>

if (-not $env:REPLICATE_API_TOKEN) {
  Write-Error "REPLICATE_API_TOKEN is not set. Set it and re-run the script."; exit 1
}

$headers = @{ Authorization = "Token $env:REPLICATE_API_TOKEN"; "Content-Type" = "application/json" }

$candidateModels = @(
  'black-forest-labs/flux-schnell',
  'black-forest-labs/flux-dev'
)

$model = $null
$version = $null
foreach ($candidate in $candidateModels) {
  Write-Host "Fetching model info for $candidate"
  try {
    $modelInfo = Invoke-RestMethod -Uri "https://api.replicate.com/v1/models/$candidate" -Headers $headers -Method Get
    $resolvedVersion = $null
    if ($modelInfo.default_version -and $modelInfo.default_version.id) {
      $resolvedVersion = $modelInfo.default_version.id
    } elseif ($modelInfo.latest_version -and $modelInfo.latest_version.id) {
      $resolvedVersion = $modelInfo.latest_version.id
    }

    if ($resolvedVersion) {
      $model = $candidate
      $version = $resolvedVersion
      break
    }
  } catch {
    Write-Warning "Model unavailable: $candidate"
  }
}

if (-not $version) {
  Write-Error "Failed to fetch model info for all candidates."; exit 1
}

Write-Host "Using model: $model"
Write-Host "Using model version: $version"

if (-not (Test-Path images)) { New-Item -ItemType Directory -Path images | Out-Null }

# Define prompts for every required image
$premium = ", commercial food photography, Michelin star presentation, luxury restaurant branding, vibrant colors, hyper realistic, depth of field, natural shadows"

$items = @(
  @{name='hero'; prompt = "Ultra realistic food photography of Indian restaurant dishes on a wooden table, chicken biryani in a traditional handi, paneer butter masala in a copper bowl, butter naan with melted butter, chicken roast fry garnished with coriander, warm golden lighting, steam visible, professional DSLR photography, shallow depth of field, dark background, cinematic, 4K, hyper detailed, restaurant menu style, appetizing, high contrast, vibrant colors --ar 16:9"},
  @{name='menu_grid'; prompt = "Top view flat lay of Indian restaurant menu items: chicken biryani, veg biryani, paneer butter masala, butter naan, papad, raita, bagara rice, copper bowls and plates, rustic wooden background, professional food photography, bright warm lighting, ultra realistic, sharp focus, high detail, premium restaurant branding style --ar 16:9"},
  @{name='chicken_biryani'; prompt = "Authentic Hyderabadi chicken biryani served in copper handi, long basmati rice, juicy chicken pieces, saffron garnish, fried onions on top, mint leaves, steam rising, top angle photography, restaurant style plating, dark rustic background, ultra realistic, sharp focus, 8K food photography, warm lighting --ar 1:1"},
  @{name='paneer_butter_masala'; prompt = "Creamy paneer butter masala in traditional copper bowl, rich orange gravy, soft paneer cubes, butter naan beside it, fresh coriander garnish, Indian restaurant table setting, cinematic lighting, ultra realistic, professional food photography, depth of field, high detail, warm tones --ar 1:1"},
  @{name='chicken_butter_masala'; prompt = "Chicken butter masala in copper bowl, rich creamy gravy, aromatic spices, professional food photography, warm tones --ar 1:1"},
  @{name='paneer_masala'; prompt = "Paneer masala in restaurant bowl, rich masala, fresh coriander garnish, shallow depth of field --ar 1:1"},
  @{name='kadai_chicken'; prompt = "Kadai chicken served in iron wok, vibrant masala, fresh bell peppers, steam rising, rustic background --ar 1:1"},
  @{name='chicken_curry'; prompt = "Homestyle chicken curry in bowl, rich gravy, coriander garnish, warm lighting --ar 1:1"},
  @{name='chicken_soup'; prompt = "Hot chicken soup in white bowl, steam rising, fresh herbs garnish, close up macro photography, clean minimal restaurant style, soft lighting, shallow depth of field --ar 1:1"},
  @{name='chicken_roast_fry'; prompt = "Spicy Indian chicken roast fry, crispy texture, red masala coating, curry leaves and green chilies garnish, served on black plate, rustic wooden table, dramatic lighting, steam effect --ar 1:1"},
  @{name='veg_manchurian'; prompt = "Veg Manchurian in glossy sauce, restaurant plating, garnish, warm lighting --ar 1:1"},
  @{name='chicken_65'; prompt = "Chicken 65, crispy fried pieces, spicy red coating, lemon wedge and coriander garnish, restaurant style --ar 1:1"},
  @{name='veg_biryani'; prompt = "Veg biryani in bowl with saffron, mixed vegetables, fragrant rice, top view --ar 1:1"},
  @{name='paneer_biryani'; prompt = "Paneer biryani with paneer cubes, aromatic spices, saffron garnish --ar 1:1"},
  @{name='bagara_rice'; prompt = "Bagara rice served in bowl, fragrant, garnished with nuts and spices --ar 1:1"},
  @{name='jeera_rice'; prompt = "Jeera rice with cumin seeds, lightly garnished, restaurant side dish --ar 1:1"},
  @{name='curd_rice'; prompt = "Curd rice in bowl with tempered mustard seeds and curry leaves, simple homestyle presentation, garnish of pomegranate or coriander --ar 1:1"},
  @{name='roti'; prompt = "Roti stack on plate, soft texture, warm lighting --ar 1:1"},
  @{name='chapathi'; prompt = "Chapathi on plate, soft and fluffy, close-up, warm tones --ar 1:1"},
  @{name='plain_naan'; prompt = "Plain naan on wooden board, char marks, buttered edge --ar 1:1"},
  @{name='butter_naan'; prompt = "Butter naan with melted butter, glistening surface, restaurant serving --ar 1:1"},
  @{name='papad'; prompt = "Crispy papad on small plate, close up, textured, rustic background --ar 1:1"},
  @{name='raita'; prompt = "Raita in small bowl, creamy yogurt with herbs, cucumber bits, garnish --ar 1:1"},
  @{name='water_bottle'; prompt = "Water bottle on table, simple glass bottle or plastic bottle, minimal restaurant style --ar 1:1"}
)

# Append premium suffix to each prompt
foreach ($it in $items) { $it.prompt = $it.prompt + $premium }

function Generate-And-Download($prompt, $outfile, $aspectRatio) {
  $body = @{ 
    version = $version
    input = @{ 
      prompt = $prompt
      aspect_ratio = $aspectRatio
      output_format = 'jpg'
      output_quality = 95
    }
  } | ConvertTo-Json -Depth 10
  Write-Host "Submitting prediction for $outfile"
  $resp = $null
  $submitted = $false
  $attempt = 0
  while (-not $submitted -and $attempt -lt 12) {
    $attempt++
    try {
      $resp = Invoke-RestMethod -Uri 'https://api.replicate.com/v1/predictions' -Headers $headers -Method Post -Body $body
      $submitted = $true
    } catch {
      $errText = $null
      if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $errText = $_.ErrorDetails.Message }
      if (-not $errText) { $errText = $_.Exception.Message }

      $wait = [Math]::Min(20, 2 * $attempt)
      if ($errText -match '"retry_after"\s*:\s*(\d+)') {
        $wait = [int]$matches[1] + 1
      }

      if ($errText -match '"status"\s*:\s*402' -or $errText -match 'Insufficient credit') {
        Write-Error "Generation blocked by insufficient Replicate credit. Add billing credit and re-run."
        return $false
      }

      Write-Warning "Prediction submit attempt $attempt failed. Waiting $wait seconds. Error: $errText"
      Start-Sleep -Seconds $wait
    }
  }

  if (-not $submitted) {
    Write-Error "Failed to submit prediction after retries."
    return $false
  }

  $pred_url = "https://api.replicate.com/v1/predictions/$($resp.id)"
  while ($true) {
    Start-Sleep -Seconds 2
    $status = Invoke-RestMethod -Uri $pred_url -Headers $headers -Method Get
    if ($status.status -eq 'succeeded') { break }
    if ($status.status -eq 'failed') { Write-Warning "Prediction failed: $($status)"; return $false }
    Write-Host "Status: $($status.status) - waiting..."
  }

  # prediction output usually contains URLs
  $outUrls = $status.output
  if ($outUrls) {
    if ($outUrls -is [System.Array]) {
      $imgUrl = $outUrls[0]
    } else {
      $imgUrl = $outUrls
    }
    Write-Host "Downloading result to $outfile from $imgUrl"
    try{ Invoke-WebRequest -Uri $imgUrl -OutFile $outfile -UseBasicParsing -ErrorAction Stop } catch { Write-Warning "Failed to download image: $_"; return $false }
    return $true
  } else { Write-Warning "No output URL for prediction."; return $false }
}

# Generate images
foreach ($it in $items) {
  $name = $it.name
  $filename = Join-Path (Join-Path $PSScriptRoot '..\images') ("$name.jpg")
  if ($name -in @('hero','menu_grid')) {
    $aspectRatio='16:9'
  } else {
    $aspectRatio='1:1'
  }
  $ok = Generate-And-Download $it.prompt $filename $aspectRatio
  if (-not $ok) { Write-Warning "Generation failed for $name" }
  Start-Sleep -Seconds 2
}

Write-Host "All generation attempts finished." -ForegroundColor Green
