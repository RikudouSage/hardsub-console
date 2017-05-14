#define MyAppName "Hardsub Console"
#define MyAppVersion "2.2.0"
#define MyAppPublisher "Hokage.cz"
#define MyAppURL "http://hokage.cz"
#define MyAppExeName "hardsub.exe"
#define SourceDir "C:\Users\domin\Documents\hardsub"

[Setup]
AppId={{6ACD3487-B867-4E32-BCE4-8AAF6CD3A525}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppPublisher}\{#MyAppName}
UninstallDisplayIcon={app}\icon.ico
DisableProgramGroupPage=yes
OutputDir={#SourceDir}
OutputBaseFilename=HardsubConsole_{#MyAppVersion}
Compression=lzma
SolidCompression=yes
AllowNoIcons=yes
SetupMutex=HardsubKonzoleSetupMutex

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]                                                                                                                     
Source: "{#SourceDir}\bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceDir}\licenses\*"; DestDir: "{app}\licenses"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#SourceDir}\icon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{commonprograms}\{#MyAppName}"; Filename: "{app}\bin\{#MyAppExeName}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\bin\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\bin\{#MyAppExeName}"; Tasks: quicklaunchicon
Name: "{app}\Hardsub Konzole"; Filename: "{app}\bin\{#MyAppExeName}";

[Run]
Filename: "{app}\bin\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: dirifempty; Name: "{app}\.."
Type: filesandordirs; Name: "{localappdata}\hardsub"

