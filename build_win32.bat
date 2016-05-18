@echo off

rem package options
set app=hacker-news-reader
set platform=win32
set arch=x64
set icon=app.ico
set copyright="Copyright (c) 2016, Jeffrey Massung"
set ignore="elm-stuff/|\.(elm|gitignore)$"
set electron=1.0.2

rem windows only settings
set CompanyName="Jeffrey Massung"
set ProductName="Hacker News | reader"

rem final output location
set out=".\out\%app%-%platform%-%arch%"

rem compile the app
elm-make Main.elm --output=elm.js

rem build the executable
call electron-packager . %app% --platform=%platform% --arch=%arch% --icon=%icon% --ignore=%ignore% --overwrite --out=out --version=%electron% -- app-copyright=%copyright% --version-string.CompanyName=%CompanyName% --version.string.ProductName=%ProductName%

rem rename the executable
ren "%out%\%app%.exe" "Hacker News reader.exe"

@echo on
