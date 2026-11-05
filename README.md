# Traduceri TED: versiuni și actualizări

Aici se publică versiunile aplicației **Traduceri TED**, care traduce fișe tehnice și manuale PDF în mai multe limbi, păstrând pozele, tabelele și aranjarea paginii.

## Instalare (Windows 10 / 11)

1. Apasă **Start**, scrie **PowerShell** și apasă **Enter**.
2. Copiază rândul de mai jos, lipește-l în fereastra albastră (clic dreapta) și apasă **Enter**:

```powershell
irm https://raw.githubusercontent.com/Banuta/Traducere-Agent-Ai-pdf-versiuni/main/instaleaza.ps1 | iex
```

3. Răspunzi la două întrebări: **ce AI folosești** (1 = doar Claude, 2 = doar ChatGPT, 3 = ambele) și dacă să instaleze acum programul de conectare.
4. Aplicația se deschide în browser. La prima pornire apeși **„Conectează-te cu contul”** și te loghezi. Gata.

Nu sunt necesare drepturi de administrator și nu trebuie instalat nimic înainte.

**Fără alerte „Don't run” sau antivirus:** nu se descarcă niciun `.exe` nesemnat. Programul rulează cu Python-ul oficial, semnat digital de Python Software Foundation, la fel cum se instalează Claude Code. Aceeași comandă reinstalează sau repară programul, păstrând documentele.

## Actualizări

Aplicația instalată verifică singură această pagină la pornire. Când apare o versiune nouă, sus apare **„⟳ Versiune nouă”**: un clic pe **„Actualizează acum”** o instalează. Documentele și setările rămân neatinse.

## Ce conține acest depozit

| Fișier | Ce este |
|---|---|
| `instaleaza.ps1` | scriptul de instalare (comanda de mai sus) |
| `latest.json` | ultima versiune: număr, noutăți, pachete, sha256 (citit de aplicație și de instalator) |
| `instalare/TraduceriTED-windows.zip` | programul complet, cu Python inclus (pentru prima instalare) |
| `actualizari/TraduceriTED-<versiune>.zip` | pachetul de actualizare (doar fișierele aplicației) |
| `versiuni.json` | istoricul tuturor versiunilor |

Codul complet al programului este în depozitul `Banuta/Traducere-automata-PDF-`.

## Istoric

### 1.0.1 (2026-11-05)
- Fără alerte la instalare: s-a renunțat la fișierele `.exe` nesemnate, care produceau alerta SmartScreen „Don't run” și alertele antivirus false.
- Instalarea se face cu o singură comandă în PowerShell. Iconița pornește Python-ul oficial, semnat digital.
- Dacă aveai versiunea cu `.exe`, comanda o înlocuiește și șterge fișierele `.exe` vechi. Documentele rămân.

### 1.0.0 (2026-11-05)
- Prima versiune cu instalator Windows.
- La instalare alegi AI-ul (doar Claude, doar ChatGPT sau ambele).
- Actualizări automate cu un clic, direct din GitHub.
- Traduceri mai curate în toate limbile.
