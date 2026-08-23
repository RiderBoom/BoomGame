@echo off
@title DELETE CACHE
rd /s /q "%CD%\cache"
rd /s /q "%CD%\crashes"

timeout /T 2
exit