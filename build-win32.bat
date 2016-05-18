@echo off

rem package options
set app=hacker-news-reader
set platform=win32
set arch=x64
set icon=app.ico
set ignore='\.elm$'
set electron=1.1.0

rem final output location
set out=".\out\%app%-%platform%-%arch%"

rem compile the app
elm-make Main.elm --output=elm.js

rem build the executable
call electron-packager . %app% --platform=%platform% --arch=%arch% --icon=%icon% --ignore=%ignore% --overwrite --out=out --version=%electron%

rem rename the executable
ren "%out%\%app%.exe" "Hacker News reader.exe"

@echo on
