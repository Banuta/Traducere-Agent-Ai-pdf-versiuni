# Traduceri TED - instalare sau reinstalare pe Windows 10 / 11, fara drepturi de administrator.
#
# Se ruleaza in PowerShell (Start -> scrie PowerShell -> Enter), lipind comanda:
#   irm https://raw.githubusercontent.com/Banuta/Traducere-Agent-Ai-pdf-versiuni/main/instaleaza.ps1 | iex
#
# Nu se descarca niciun .exe nesemnat (care ar produce alerta SmartScreen "Don't run" sau alerte antivirus):
# programul ruleaza cu Python-ul oficial, semnat digital de Python Software Foundation.
# Instaleaza in %LOCALAPPDATA%\Programs\TraduceriTED (app = programul, python = Python inclus, data = documentele tale).
# Documentele si setarile existente se pastreaza la reinstalare.

& {
    $ErrorActionPreference = "Stop"
    $ProgressPreference = "SilentlyContinue"   # descarcarea e mult mai rapida fara bara de progres
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Repo = "https://raw.githubusercontent.com/Banuta/Traducere-Agent-Ai-pdf-versiuni/main"
    $Dir = Join-Path $env:LOCALAPPDATA "Programs\TraduceriTED"
    $AppDir = Join-Path $Dir "app"
    $Py = Join-Path $Dir "python\python.exe"
    $PyW = Join-Path $Dir "python\pythonw.exe"
    $AppPy = Join-Path $AppDir "app.py"

    function Step($m) { Write-Host ""; Write-Host "== $m" -ForegroundColor Cyan }
    function Ok($m) { Write-Host "   $m" -ForegroundColor Green }
    function Ask($question, $default) {
        if ($env:TRADUCERI_TED_SILENT) { return $default }
        $a = Read-Host "$question"
        if ([string]::IsNullOrWhiteSpace($a)) { return $default }
        return $a.Trim()
    }

    try {
        Write-Host ""
        Write-Host "  Traduceri TED - instalare" -ForegroundColor White
        Write-Host "  fise tehnice si manuale PDF traduse in mai multe limbi" -ForegroundColor Gray

        # ------------------------------------------------------------ 1. versiunea
        Step "1/5 Caut ultima versiune"
        # GitHub trimite fisierul ca text/plain: il citim ca text si il convertim explicit din JSON
        $txt = (Invoke-WebRequest -UseBasicParsing -Uri "$Repo/latest.json" -Headers @{ "Cache-Control" = "no-cache" }).Content
        if ($txt -is [byte[]]) { $txt = [Text.Encoding]::UTF8.GetString($txt) }
        $info = $txt | ConvertFrom-Json
        if (-not $info.bundle) { throw "Informatiile despre versiune sunt incomplete. Incearca din nou peste cateva minute." }
        Ok "Versiunea $($info.version)"

        # ------------------------------------------------------------ 2. descarcare
        Step "2/5 Descarc programul (~$([math]::Round($info.bundle_size / 1MB)) MB, 1-3 minute)"
        New-Item -ItemType Directory -Force -Path $Dir | Out-Null
        $zip = Join-Path $Dir "descarcare.zip"
        Invoke-WebRequest -UseBasicParsing -Uri "$Repo/$($info.bundle)" -OutFile $zip
        $hash = (Get-FileHash -Algorithm SHA256 -Path $zip).Hash.ToLower()
        if ($hash -ne $info.bundle_sha256) {
            Remove-Item -Force $zip
            throw "Fisierul descarcat este deteriorat (sha256 diferit). Ruleaza din nou comanda."
        }
        Ok "Descarcat si verificat (sha256)"

        # ------------------------------------------------------------ 3. instalare
        Step "3/5 Instalez in $Dir"
        try {   # daca aplicatia ruleaza, o oprim (altfel fisierele ei sunt blocate)
            Invoke-WebRequest -UseBasicParsing -Method Post -Uri "http://127.0.0.1:8765/api/shutdown" `
                -Headers @{ "X-Fise" = "1" } -ContentType "application/json" -Body '{"force": true}' -TimeoutSec 5 | Out-Null
            Start-Sleep -Seconds 3
        } catch { }
        $new = Join-Path $Dir "_nou"
        if (Test-Path $new) { Remove-Item -Recurse -Force $new }
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory($zip, $new)
        Remove-Item -Force $zip
        foreach ($d in @("app", "python")) {
            $target = Join-Path $Dir $d
            if (Test-Path $target) {
                try { Remove-Item -Recurse -Force $target }
                catch { throw "Nu pot inlocui folderul '$d': aplicatia Traduceri TED este inca deschisa. Inchide-o si ruleaza din nou comanda." }
            }
            Move-Item (Join-Path $new $d) $target
        }
        Copy-Item -Force (Join-Path $new "icon.ico") (Join-Path $Dir "icon.ico")
        Remove-Item -Recurse -Force $new
        New-Item -ItemType Directory -Force -Path (Join-Path $Dir "data") | Out-Null
        # versiunea veche cu .exe (instalator NSIS): fisierele acelea produceau alertele, le stergem
        foreach ($old in @("TraduceriTED.exe", "Dezinstaleaza.exe")) {
            $p = Join-Path $Dir $old
            if (Test-Path $p) { Remove-Item -Force $p -ErrorAction SilentlyContinue }
        }
        $ErrorActionPreference = "Continue"   # mesajele programelor externe nu sunt erori ale scriptului
        & $Py -s -c "import flask, pymupdf, PIL" 2>&1 | Out-Null
        $okImport = ($LASTEXITCODE -eq 0)
        $ErrorActionPreference = "Stop"
        if (-not $okImport) { throw "Programul nu porneste dupa instalare. Ruleaza din nou comanda." }
        Ok "Instalat"

        # ------------------------------------------------------------ 4. AI
        Step "4/5 Ce AI folosesti?"
        $settings = Join-Path $Dir "data\setari.json"
        $mode = ""
        if ((Test-Path $settings) -and -not $env:TRADUCERI_TED_AI) {
            Ok "Pastrez alegerea de la instalarea anterioara (se schimba din aplicatie: Conectare AI)."
        } else {
            $c = $env:TRADUCERI_TED_AI
            if (-not $c) {
                Write-Host "   1 = Doar Claude   (abonament Claude Pro / Max)"
                Write-Host "   2 = Doar ChatGPT  (abonament ChatGPT Plus / Pro, prin Codex)"
                Write-Host "   3 = Ambele        (Claude traduce, ChatGPT verifica) - recomandat"
                Write-Host "   4 = Aleg mai tarziu, din aplicatie"
                $c = Ask "   Scrie 1, 2, 3 sau 4 si apasa Enter [3]" "3"
            }
            $mode = @{ "1" = "claude"; "2" = "codex"; "3" = "ambele"; "claude" = "claude"; "codex" = "codex"; "ambele" = "ambele" }[$c]
            if ($mode) {
                $ErrorActionPreference = "Continue"
                & $Py -s $AppPy --ai $mode 2>&1 | Out-Null
                $ErrorActionPreference = "Stop"
                Ok "Ales: $mode"
            } else { Ok "Alegi din aplicatie." }
        }
        if ($mode) {
            $wantClaude = ($mode -ne "codex")
            $wantCodex = ($mode -ne "claude")
            $hasClaude = (Get-Command claude -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $HOME ".local\bin\claude.exe"))
            $hasCodex = (Get-Command codex -ErrorAction SilentlyContinue) -or `
                (Test-Path (Join-Path $env:LOCALAPPDATA "Programs\codex\codex.exe")) -or (Test-Path (Join-Path $env:APPDATA "npm\codex.cmd"))
            if (($wantClaude -and -not $hasClaude) -or ($wantCodex -and -not $hasCodex)) {
                $r = Ask "   Instalez acum si programul de conectare (Claude Code / Codex)? D/N [D]" "D"
                if ($r -match "^[DdYy]") {
                    if ($wantClaude -and -not $hasClaude) {
                        Write-Host "   Instalez Claude Code (programul oficial Anthropic)..." -ForegroundColor Gray
                        Start-Process powershell -Wait -NoNewWindow -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass",
                            "-Command", "irm https://claude.ai/install.ps1 | iex")
                    }
                    if ($wantCodex -and -not $hasCodex) {
                        Write-Host "   Instalez Codex (programul oficial OpenAI)..." -ForegroundColor Gray
                        Start-Process powershell -Wait -NoNewWindow -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass",
                            "-File", (Join-Path $AppDir "instalare\instaleaza-codex.ps1"))
                    }
                }
            } else { Ok "Programul de conectare este deja instalat." }
        }

        # ------------------------------------------------------------ 5. iconite
        Step "5/5 Iconite pe Desktop si in meniul Start"
        $ws = New-Object -ComObject WScript.Shell
        function Shortcut($path, $target, $arguments, $icon) {
            $s = $ws.CreateShortcut($path)
            $s.TargetPath = $target
            $s.Arguments = $arguments
            $s.WorkingDirectory = $AppDir
            $s.IconLocation = "$icon,0"
            $s.Description = "Traduceri TED"
            $s.Save()
        }
        $icon = Join-Path $Dir "icon.ico"
        $run = "-s `"$AppPy`""
        $uninstall = "-NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $AppDir 'instalare\dezinstaleaza.ps1')`""
        $menu = Join-Path ([Environment]::GetFolderPath("Programs")) "Traduceri TED"
        New-Item -ItemType Directory -Force -Path $menu | Out-Null
        Shortcut (Join-Path ([Environment]::GetFolderPath("Desktop")) "Traduceri TED.lnk") $PyW $run $icon
        Shortcut (Join-Path $menu "Traduceri TED.lnk") $PyW $run $icon
        Shortcut (Join-Path $menu "Dezinstaleaza Traduceri TED.lnk") "powershell.exe" $uninstall $icon
        $s = $ws.CreateShortcut((Join-Path $menu "Documentele mele (folder).lnk"))
        $s.TargetPath = (Join-Path $Dir "data"); $s.Save()

        $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\TraduceriTED"
        New-Item -Force -Path $key | Out-Null
        $props = @{ DisplayName = "Traduceri TED"; DisplayVersion = "$($info.version)"; Publisher = "TED Electric";
                    InstallLocation = $Dir; DisplayIcon = $icon; UninstallString = "powershell.exe $uninstall" }
        foreach ($k in $props.Keys) { Set-ItemProperty -Path $key -Name $k -Value $props[$k] }
        Set-ItemProperty -Path $key -Name NoModify -Value 1 -Type DWord
        Set-ItemProperty -Path $key -Name NoRepair -Value 1 -Type DWord
        Ok "Gata"

        Write-Host ""
        Write-Host "  Traduceri TED $($info.version) este instalat." -ForegroundColor Green
        Write-Host "  Se deschide acum in browser. Data viitoare il pornesti cu iconita 'Traduceri TED' de pe Desktop."
        Write-Host "  La prima pornire: 'Conectare AI' -> 'Conecteaza-te cu contul' -> te loghezi in browser -> 'Verifica'."
        Write-Host ""
        Start-Process -FilePath $PyW -ArgumentList $run -WorkingDirectory $AppDir
    }
    catch {
        Write-Host ""
        Write-Host "  EROARE: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Verifica internetul si ruleaza din nou comanda. Daca se repeta, trimite o captura a acestei ferestre." -ForegroundColor Yellow
    }
}
