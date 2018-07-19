@echo off

:: Ϊ����������ʾ�����Ϣ���������ļ���Ҫ�� gbk ����

:: �����������̨��� utf8 ���룬���Ǳ��� tex ʱ����Ŀ¼��������
:: chcp 65001 

rem http://stackoverflow.com/a/12408045/1334431
rem ������ :: ������ rem��ֻҪע���а��� ���� ��������� %%~ û����

set curdir=%cd%

%~d0
cd %~dp0
::echo %~dp0
cd ..
::echo %cd%

setlocal enabledelayedexpansion

::echo. & echo [1] �������ĵ� [2] ������ĵ� [3] ���벢����ĵ� & echo.
::set /p task=########## ����������Ҫִ�е������ţ�

::if "%task%"=="2" goto :makezip

:: for ѭ�����޷����������ļ������Ը��� forfiles�����Ƕ��Ѿ����ص��ļ��Ͳ�Ӧ�ô���
:: ʵ���ϣ��� forfiles Ҳ�����㣬��Ϊ��ÿ��ֻ��ƥ��һ���ļ�����

::forfiles -m *.aux -c "cmd /c attrib +S +H @file"
::forfiles -m *.bak -c "cmd /c attrib +S +H @file"
::forfiles -m *.log -c "cmd /c attrib +S +H @file"
::forfiles -m *.nav -c "cmd /c attrib +S +H @file"
::forfiles -m *.out -c "cmd /c attrib +S +H @file"
::forfiles -m *.sav -c "cmd /c attrib +S +H @file"
::forfiles -m *.snm -c "cmd /c attrib +S +H @file"
::forfiles -m *.synctex -c "cmd /c attrib +S +H @file"
::forfiles -m *.synctex.gz -c "cmd /c attrib +S +H @file"
::forfiles -m *.toc -c "cmd /c attrib +S +H @file"

::echo. & echo ---------- Hide all auxiliary files ----------

:: ���ص��ļ� xelatex �� pdflatex �޷�д�룬��˴˷���������
::for %%A in (*.aux,*.bak,*.log,*.nav,*.out,*.sav,*.snm,*.synctex,*.synctex.gz,*.toc) do (
::  echo ++++++++++ %%A
::  attrib +S +H %%A
::)

::goto :end

::set outdir=output

:: �� auxiliary �� output Ŀ¼�����ڣ���������

::if not exist auxiliary mkdir auxiliary
::if not exist %outdir% mkdir %outdir%

::set option=-aux-directory=auxiliary -output-directory=output -quiet
::set option=-aux-directory=auxiliary -output-directory=output
set option=-quiet -synctex=1

::pause

:: for �������ڿ���̨ʱ�� %i�����ڽű�ʱ�� %%i

:::: for ѭ�������±�����Ҫע�⣬�����������������������һ���ļ���
::for %%i in (gdsx*.tex) do (
::  set test=%%~ni
::  echo test=%test%
::)
:::: �� enabledelayedexpansion ѡ�Ȼ���� !test! �Ϳ��Խ�������⣬�� set /? �鿴����
::setlocal enabledelayedexpansion
::for %%i in (gdsx*.tex) do (
::  set test=%%~ni
::  echo test=!test!
::)
::endlocal

:: forfiles ��Ȼ������ʾ�ļ��޸�ʱ������������·�С��10ʱ��ʡ��ǰ����㣬������ gtr ���ñȽ�
:: ��ˣ�����Ӧ��һ��ʹ�ã����� %%~ti�������ȵĻ����� forfiles �Ƚ����� 

:: �� for ѭ���в����� goto����Ӧ�� call �ӳ���Ȼ���� exit /b �˻�

for /d %%I in (%~n0*) do (
  echo.
  set texbase=%%I
  set texfile=%%I.tex
  set pdffile=%%I.pdf
  call :findfile
  REM if exist %%I\%%I-note.tex (
    REM set texfile=%%I-note.tex
    REM set pdffile=%%I-note.pdf
    REM call :findfile
  REM )
  REM if exist %%I\%%I-slide.tex (
    REM set texfile=%%I-slide.tex
    REM set pdffile=%%I-slide.pdf
    REM call :findfile
  REM )
  if exist %%I\%%I-print.tex (
    set texfile=%%I-print.tex
    set pdffile=%%I-print.pdf
    call :findfile
  )
  if exist %%I\%%I-i.tex (
    set texfile=%%I-i.tex
    set pdffile=%%I-i.pdf
    call :findfile
  )
  if exist %%I\%%I-print-i.tex (
    set texfile=%%I-print-i.tex
    set pdffile=%%I-print-i.pdf
    call :findfile
  )
  if exist %%I\%%I-o.tex (
    set texfile=%%I-o.tex
    set pdffile=%%I-o.pdf
    call :findfile
  )
  if exist %%I\%%I-print-o.tex (
    set texfile=%%I-print-o.tex
    set pdffile=%%I-print-o.pdf
    call :findfile
  )
)

goto :makezip

:findfile
if not exist !texbase!\!pdffile! (
  :: echo not exist !texbase!\!pdffile!
  call :build
) else (
  for %%J in (!texbase!\!pdffile!) do (
    set pdftime=%%~tJ
    ::echo !pdftime! for %%J
    call :compare
  )
)
exit /b

:: 1��for /f %%i in (�ļ���) do (??)
:: 2��for /f %%i in ('�������') do (??)
:: 3��for /f %%i in ("�ַ���") do (??)
:: 4��for /f "usebackq" %%i in ("�ļ���") do (??)
:: 5��for /f "usebackq" %%i in (`�������`) do (??)
:: 6��for /f "usebackq" %%i in ('�ַ���') do (??)

:compare
:: http://stackoverflow.com/a/16727927
for %%K in (!texbase!\*.tex) do (
  ::echo %%~tK for %%K
  if "!pdftime!" lss "%%~tK" (
    :: !pdffile! file is old
    call :build
    exit /b
  ) else if "!pdftime!" equ "%%~tK" (
    ::echo compare file time with second
    rem �� | �ܵ���ֱ���ض������̨������ַ����ǲ��ɹ��ģ�
    rem echo hello > set /p myvar=
    rem ���������� for /f �ķ���
    rem http://stackoverflow.com/a/14965458/1334431
    for /f "tokens=*" %%L in ('forfiles /p !texbase! /m %%~nxK /c "cmd /c echo @fdate @ftime"') do (
      set texsec=%%L
    )
    for /f "tokens=*" %%L in ('forfiles /p !texbase! /m !pdffile! /c "cmd /c echo @fdate @ftime"') do (
      set pdfsec=%%L
    )
    rem �������е� :: ʵ�ʲ��Ǳ�׼������
    rem �����������и�Ϊ :: �ᵼ�´���"ϵͳ�Ҳ���ָ����������"
    rem �� :: ע�͸�Ϊ rem ע�;��ܽ��������
    rem ʵ��ԭʼ�� ( ) �е��������� :: ע�;ͻᵼ������
    rem http://stackoverflow.com/q/12407800/1334431
    rem http://stackoverflow.com/a/4006006/1334431
    rem echo !pdfsec:~-8! for !pdffile!
    rem echo !texsec:~-8! for %%~nxK
    if "!texsec:~-2!" gtr "!pdfsec:~-2!" (
      echo. need build 
      call :build
      exit /b
    )
  )
)
echo ---------- No changes in !texfile! ----------
exit /b

:build
echo ---------- Compiling new !texfile! ----------
:: xelatex -job-name=!texbase!-slide %option% !texfile!
:: xelatex -job-name=!texbase!-slide %option% !texfile!
:: xelatex -job-name=!texbase!-print %option% "\def\handout{}\input{!texfile!}"
:: xelatex -job-name=!texbase!-print %option% "\def\handout{}\input{!texfile!}"
cd !texbase!
echo ++++++++++ compile !texfile! once
:: http://stackoverflow.com/a/6817833/1334431
:: �� && �� || ���� %errorlevel% ������
:: xelatex 1>nul %option% !texfile! && (echo success) || (echo error!)
:: �Ժܶ����ִ�гɹ� %errorlevel% ���� 0��ʧ������� 1
:: echo %errorlevel%
xelatex 1>nul %option% !texfile! || (
  echo ++++++++++ some errors in !texfile!
  set error=true
  exit /b
)
echo ++++++++++ compile !texfile! twice
xelatex 1>nul %option% !texfile!
cd ..
exit /b

:makezip

::if "%task%"=="1" goto :end
if "%error%"=="true" goto :end

if not exist backup mkdir backup

echo. & echo ---------- Make all files into zips ----------

:: ��������ĸ�ʽ���������ϵͳ�������й�
set curdate=%date:~2,2%%date:~5,2%%date:~8,2%

set filelist=binary\* common\*
for /d %%I in (%~n0*) do (
  for %%K in (%%I\*.tex,%%I\%%I.pdf,%%I\%%I-*.pdf,%%I\*.jpg,%%I\*.png,,%%I\*.gif) do (
    set filelist=!filelist! %%K
  )
)
::echo !filelist!

:: �� EnableDelayedExpansion �У�! �������ַ�����Ҫ�� ^^! ת��
:: �� http://www.robvanderwoude.com/escapechars.php

echo ++++++++++ packaging %~n0-%curdate%.zip
if exist backup\%~n0-%curdate%.zip del /q backup\%~n0-%curdate%.zip
binary\7z.exe 1>nul a -tzip -xr^^!*.bak backup\%~n0-%curdate%.zip !filelist!

echo ++++++++++ packaging %~n0-%curdate%-tex.zip
if exist backup\%~n0-%curdate%-tex.zip del /q backup\%~n0-%curdate%-tex.zip
binary\7z.exe 1>nul a -tzip -xr^^!*.bak -xr^^!*.pdf backup\%~n0-%curdate%-tex.zip !filelist!

:: �Ե㿪ͷ���ļ���ѹ��ʱ�������ָ�Ŀ¼
set filelist=
for /d %%I in (%~n0*) do (
  set filelist=!filelist! .\%%I\%%I.pdf .\%%I\%%I-*.pdf
)
::echo !filelist!

echo ++++++++++ packaging %~n0-%curdate%-pdf.zip
if exist backup\%~n0-%curdate%-pdf.zip del /q backup\%~n0-%curdate%-pdf.zip
binary\7z.exe 1>nul a -tzip backup\%~n0-%curdate%-pdf.zip !filelist!

::for /d %%I in (%~n0*) do (
::  copy 1>nul /y %%I\%%I.pdf %outdir%
::  copy 1>nul /y %%I\%%I-print.pdf %outdir%
::)
::cd !outdir!
::%~dp0common\7z.exe 1>nul a -tzip %~dp0backup\%~n0-%curdate%-pdf.zip *
::cd ..

:end

if "%error%"=="true" (
  echo. & echo ========== ����ִ�г��ִ�������ֹ ==========
) else (
  echo. & echo ========== ���е������Ѿ�ִ����� ==========
)
set /p p=

::pause

endlocal

cd %curdir%

:: -synctex=1 �ƺ���Ч������ -synctex=-1 ��Ч

:: -aux-directory=DIR              Use DIR as the directory to write auxiliary files to.
:: -include-directory=DIR          Prefix DIR to the input search path.
:: -job-name=NAME
:: -output-directory=DIR
