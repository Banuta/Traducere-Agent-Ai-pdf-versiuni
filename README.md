# Traduceri TED: versiuni și actualizări

Aici se publică versiunile aplicației **Traduceri TED**, care traduce fișe tehnice și manuale PDF în mai multe limbi, păstrând pozele, tabelele și aranjarea paginii.

## Descarcă

**[⬇ TraduceriTED-Setup.exe](https://github.com/Banuta/Traducere-Agent-Ai-pdf-versiuni/raw/main/instalare/TraduceriTED-Setup.exe)**: instalatorul pentru Windows 10 / 11 (~40 MB). Instalatorul nu are nevoie de drepturi de administrator și nu cere nimic instalat dinainte.

1. Dublu clic pe `TraduceriTED-Setup.exe`. Dacă apare „Windows a protejat PC-ul”, apasă **Mai multe informații → Rulează oricum**.
2. Alegi ce AI folosești: **doar Claude**, **doar ChatGPT** sau **ambele**.
3. La prima pornire apeși **„Conectează-te cu contul”** și te loghezi în browser. Gata.

## Actualizări

Aplicația instalată verifică singură această pagină la pornire. Când apare o versiune nouă, sus apare **„⟳ Versiune nouă”**: un clic pe **„Actualizează acum”** o instalează. Documentele și setările rămân neatinse.

## Ce conține acest depozit

| Fișier | Ce este |
|---|---|
| `latest.json` | ultima versiune: număr, noutăți, pachet, sha256 (citit de aplicație) |
| `actualizari/TraduceriTED-<versiune>.zip` | pachetul de actualizare (doar fișierele aplicației) |
| `instalare/TraduceriTED-Setup.exe` | instalatorul complet, ultima versiune |
| `versiuni.json` | istoricul tuturor versiunilor |

Codul complet al programului este în depozitul `Banuta/Traducere-automata-PDF-`.

## Istoric

### 1.0.0 (2026-11-05)
- Prima versiune cu instalator Windows: Python inclus, fără drepturi de administrator.
- La instalare alegi AI-ul (doar Claude, doar ChatGPT sau ambele); programul de conectare se poate instala direct.
- Actualizări automate cu un clic, direct din GitHub.
- Traduceri mai curate în toate limbile: liste uniforme, etichete din desene la locul lor.
