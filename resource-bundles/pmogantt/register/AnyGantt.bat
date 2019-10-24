CLS

@ECHO OFF

ECHO Registering AnyChart SWF Folder in FlashPlayer Security Trust Folder...

MD "%APPDATA%\Macromedia\Flash Player\#Security\FlashPlayerTrust\"

ECHO %CD% > "%APPDATA%\Macromedia\Flash Player\#Security\FlashPlayerTrust\anychart%RANDOM%.cfg"

ECHO Done. Please restart your Browser if it launched.

PAUSE

EXIT


