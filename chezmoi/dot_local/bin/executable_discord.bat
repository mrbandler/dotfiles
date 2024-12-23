@echo off

%LocalAppData%/Discord/Update.exe
%Userprofile%/.local/bin/bdcli.exe install stable
%LocalAppData%/Discord/Update.exe --processStart Discord.exe
