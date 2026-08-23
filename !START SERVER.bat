@echo off
@title FIVEM SERVER
rd /s /q "%CD%\cache"
rd /s /q "%CD%\crashes"


fxserver\FXServer.exe +exec server.cfg +set onesync on +set onesync_enableInfinity 1

@pause