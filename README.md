# Hardsub Konzole
Jednoduchý program pro tvorbu mkv hardsubů. Stačí vybrat původní video (mkv formát), vložit titulky (ass nebo 
srt formát), zvolit složku pro uložení videa, název videa a bitrate (doplní se automaticky z původního videa) a 
kliknout na tlačítko Vytvořit hardsub. Pro stažení klikněte 
[sem](https://github.com/RikudouSage/hardsub-konzole/releases).
## Kompilace
### Potřebné nástroje
1. [Qt Framework](https://www.qt.io/download/) 2. [Inno Setup](http://www.jrsoftware.org/isdl.php#stable)
### Postup kompilace
1. Ve složce `source/hardsub` spuste příkaz `qmake` z Qt Frameworku (výchozí složka: `C:\Qt\5.9\mingw53_32\bin`) 
2. Ve stejné složce spuste příkaz `mingw32-make` z Qt Frameworku (výchozí složka: `C:\Qt\Tools\mingw530_32\bin`) 
3. Zkopírujte soubor `hardsub.exe` ze složky `source/hardsub/release/` do složky `bin/` 4. Ve složce `bin/` 
spuste příkaz `windeployqt --qmldir source/hardsub bin/hardsub.exe` - nástroj `windeployqt` se standardně 
nachází v `C:\Qt\5.9\mingw53_32\bin` složku `source/hardsub` nahrate celou cestou k této složce, stejně tak 
cestu k souboru `bin/hardsub.exe` 5. Z Qt Frameworku zkopírujte soubory `libstdc++-6.dll`, `libwinpthread-1.dll` 
a `libgcc_s_dw2-1.dll` (standardně se nachází ve složce `C:\Qt\Tools\mingw530_32\bin`) 6. Otevřete soubor 
`hs.iss` pomocí programu Inno Setup, v něm klikněte na `Build -> Compile` (případně stiskněte `CTRL+F9`) a 
počkejte, než se zkompiluje instalátor
7. Nainstalujte zkompilovaný soubor `HardsubKonzole.exe`
