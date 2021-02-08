:: Example of how I set up pyZ80 to compile on a Windows environment.  You'll need to correct the paths for your system

chdir "F:\Program Files (x86)\pyz80"
xcopy "F:\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source" "F:\Program Files (x86)\pyz80\test" /E /C /Q /R /Y

::Use -D switch for DEBUG assembler directives in development.  Output mapfile to have SimCoupe use label names in its monitor
pyz80.py -I test/samdos2 -D DEBUG --exportfile=test/symbol.txt --mapfile=test/auto.map test/auto.asm

move /Y "F:\Program Files (x86)\pyz80\test\auto.dsk" "F:\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source\auto.dsk"
move /Y "F:\Program Files (x86)\pyz80\test\symbol.txt" "F:\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source\symbol.txt"
move /Y "F:\Program Files (x86)\pyz80\test\auto.map" "F:\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source\auto.map"
del /Q "F:\Program Files (x86)\pyz80\test\*.*"

:: Run disk immediately, progam auto-runs 
"F:\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source\auto.dsk"