@echo off

if "%JAVA_OPTS%" == "" goto DEFAULT_JAVA_OPTS

:INVOKE
echo JAVA_HOME=%JAVA_HOME%
echo JAVA_OPTS=%JAVA_OPTS%
echo CAPSID_HOME=%CAPSID_HOME%

if "%CAPSID_HOME%" == "" goto CAPSID_HOME_NOT_SET

setlocal ENABLEDELAYEDEXPANSION

set CAPSID_DIST=%~dp0..
echo CAPSID_DIST=%CAPSID_DIST%

rem Java 6 supports wildcard classpaths
rem http://download.oracle.com/javase/6/docs/technotes/tools/windows/classpath.html
set CLASSPATH=%CAPSID_HOME%\conf;%CAPSID_DIST%\lib\*

set JAVA_DEBUG=-agentlib:jdwp=transport=dt_socket,server=y,address=8000,suspend=n

IF NOT EXIST "%CAPSID_HOME%\logs" mkdir "%CAPSID_HOME%\logs"
  rem Add %JAVA_DEBUG% to this line to enable remote JVM debugging (for developers)
  java %JAVA_OPTS% -cp "%CLASSPATH%" -DCAPSID_HOME="%CAPSID_HOME%" -DCAPSID_DIST=%CAPSID_DIST% ca.on.oicr.capsid.server.httpd.CapsidJettyServer %*
goto :END

:DEFAULT_JAVA_OPTS
set JAVA_OPTS=-Xmx2G -XX:MaxPermSize=128M
goto :INVOKE

:JAVA_HOME_NOT_SET
echo JAVA_HOME not set
goto :END

:CAPSID_HOME_NOT_SET
echo CAPSID_HOME not set
goto :END

:END
