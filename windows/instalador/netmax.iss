; Instalador de NET_MAX para Windows (Inno Setup 6).
;
; Lo compila el flujo .github/workflows/release.yml:
;   iscc /DVersion=1.0.0 /DOrigen=<carpeta Release> /DSalida=<carpeta> windows\instalador\netmax.iss
;
; Se instala para el usuario actual (no pide permisos de administrador).
; La información (clientes, pagos…) NO está aquí: vive en Documentos\netmax.sqlite,
; así que desinstalar o actualizar no borra los datos.

#ifndef Version
  #define Version "1.0.0"
#endif
#ifndef Origen
  #define Origen "..\..\build\windows\x64\runner\Release"
#endif
#ifndef Salida
  #define Salida "..\..\build\instalador"
#endif

[Setup]
; No cambiar el AppId: con él Windows reconoce las actualizaciones.
AppId={{B260927D-15AC-4EBC-9DBB-D8700F573BF4}
AppName=NET_MAX
AppVersion={#Version}
AppVerName=NET_MAX {#Version}
AppPublisher=NET_MAX
AppContact=net_max@gmail.com
AppSupportPhone=771 196 3767
DefaultDirName={localappdata}\Programs\NET_MAX
DefaultGroupName=NET_MAX
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir={#Salida}
OutputBaseFilename=NET_MAX_Instalador_{#Version}
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\netmax_manager.exe
UninstallDisplayName=NET_MAX
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Cierra la app si está abierta antes de actualizarla.
CloseApplications=yes

[Languages]
Name: "es"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "escritorio"; Description: "Crear un acceso directo en el escritorio"; GroupDescription: "Accesos directos:"

[Files]
Source: "{#Origen}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\NET_MAX"; Filename: "{app}\netmax_manager.exe"
Name: "{group}\Desinstalar NET_MAX"; Filename: "{uninstallexe}"
Name: "{autodesktop}\NET_MAX"; Filename: "{app}\netmax_manager.exe"; Tasks: escritorio

[Run]
Filename: "{app}\netmax_manager.exe"; Description: "Abrir NET_MAX"; Flags: nowait postinstall skipifsilent
