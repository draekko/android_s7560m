@echo off

rem Quick Deodex script by mbc07 @ XDA
rem Last updated in 2014-06-09 (v1.0.2)



cls
title Quick Deodex v1.0.2
if not exist .\files mkdir files
if not exist .\files\framework\*.jar (
  echo ERROR: framework not found.
  goto exit
)

if not exist .\files\app\*.odex (
  echo No APKs to deodex in .\files\app, skipping...
) else (
  for %%i in (.\files\app\*.apk) do (
    if exist .\files\app\%%~ni.odex (
      if exist .\files\app\%%~ni rmdir /s /q .\files\app\%%~ni 2> nul
      set /p "=Deodexing %%~ni.apk " < nul
      java -jar .\tools\baksmali.jar -d .\files\framework -x .\files\app\%%~ni.odex -o .\files\app\%%~ni 2> nul
      java -jar .\tools\smali.jar .\files\app\%%~ni -o .\files\app\%%~ni\classes.dex 2> nul
      if not exist .\files\app\%%~ni\classes.dex (
        echo [ERROR]
        rmdir /s /q .\files\app\%%~ni 2> nul
      ) else (
        .\tools\7za.exe a -tzip %%i .\files\app\%%~ni\classes.dex > nul
        .\tools\zipalign.exe -f 4 %%i %%i.aligned 2> nul
        del %%i 2> nul
        ren %%i.aligned %%~ni.apk 2> nul
        rmdir /s /q .\files\app\%%~ni 2> nul
        del .\files\app\%%~ni.odex 2> nul
        echo [DONE]
      )
    )
  )
)

if not exist .\files\priv-app goto skipKitKat

if not exist .\files\priv-app\*.odex (
  echo No APKs to deodex in .\files\priv-app, skipping...
) else (
  for %%i in (.\files\priv-app\*.apk) do (
    if exist .\files\priv-app\%%~ni.odex (
      if exist .\files\priv-app\%%~ni rmdir /s /q .\files\priv-app\%%~ni 2> nul
      set /p "=Deodexing %%~ni.apk " < nul
      java -jar .\tools\baksmali.jar -d .\files\framework -x .\files\priv-app\%%~ni.odex -o .\files\priv-app\%%~ni 2> nul
      java -jar .\tools\smali.jar .\files\priv-app\%%~ni -o .\files\priv-app\%%~ni\classes.dex 2> nul
      if not exist .\files\priv-app\%%~ni\classes.dex (
        echo [ERROR]
        rmdir /s /q .\files\priv-app\%%~ni 2> nul
      ) else (
        .\tools\7za.exe a -tzip %%i .\files\priv-app\%%~ni\classes.dex > nul
        .\tools\zipalign.exe -f 4 %%i %%i.aligned 2> nul
        del %%i 2> nul
        ren %%i.aligned %%~ni.apk 2> nul
        rmdir /s /q .\files\priv-app\%%~ni 2> nul
        del .\files\priv-app\%%~ni.odex 2> nul
        echo [DONE]
      )
    )
  )
)


:skipKitKat
if not exist .\files\framework\*.odex (
  echo No APKs to deodex in .\files\framework, skipping...
) else (
  for %%i in (.\files\framework\*.apk) do (
    if exist .\files\framework\%%~ni.odex (
      if exist .\files\framework\%%~ni rmdir /s /q .\files\framework\%%~ni 2> nul
      set /p "=Deodexing %%~ni.apk " < nul
      java -jar .\tools\baksmali.jar -d .\files\framework -x .\files\framework\%%~ni.odex -o .\files\framework\%%~ni 2> nul
      java -jar .\tools\smali.jar .\files\framework\%%~ni -o .\files\framework\%%~ni\classes.dex 2> nul
      if not exist .\files\framework\%%~ni\classes.dex (
        echo [ERROR]
        rmdir /s /q .\files\framework\%%~ni 2> nul
      ) else (
        .\tools\7za.exe a -tzip %%i .\files\framework\%%~ni\classes.dex > nul
        .\tools\zipalign.exe -f 4 %%i %%i.aligned 2> nul
        del %%i 2> nul
        ren %%i.aligned %%~ni.apk 2> nul
        rmdir /s /q .\files\framework\%%~ni 2> nul
        del .\files\framework\%%~ni.odex 2> nul
        echo [DONE]
      )
    )
  )
)

if not exist .\files\framework\*.odex (
  echo No JARs to deodex in .\files\framework, skipping...
) else (
  for %%i in (.\files\framework\*.jar) do (
    if exist .\files\framework\%%~ni.odex (
      if exist .\files\framework\%%~ni rmdir /s /q .\files\framework\%%~ni 2> nul
      set /p "=Deodexing %%~ni.jar " < nul
      java -jar .\tools\baksmali.jar -d .\files\framework -x .\files\framework\%%~ni.odex -o .\files\framework\%%~ni 2> nul
      java -jar .\tools\smali.jar .\files\framework\%%~ni -o .\files\framework\%%~ni\classes.dex 2> nul
      if not exist .\files\framework\%%~ni\classes.dex (
        echo [ERROR]
        rmdir /s /q .\files\framework\%%~ni 2> nul
      ) else (
        .\tools\7za.exe a -tzip %%i .\files\framework\%%~ni\classes.dex > nul
        .\tools\zipalign.exe -f 4 %%i %%i.aligned 2> nul
        del %%i 2> nul
        ren %%i.aligned %%~ni.jar 2> nul
        rmdir /s /q .\files\framework\%%~ni 2> nul
        del .\files\framework\%%~ni.odex 2> nul
        echo [DONE]
      )
    )
  )
)

echo Finished.
goto exit


:exit
echo;
echo Press any key to exit...
pause > nul
exit
