; OpenClaw Windows Installer
; Version: 2026.3.7

#define MyAppName "OpenClaw"
#define MyAppVersion "2026.3.7"
#define MyAppPublisher "OpenClaw Community"
#define MyAppURL "https://github.com/openclaw/openclaw"
#define MyAppExeName "openclaw-config.exe"

[Setup]
AppId={{8F3B9A7C-5D2E-4F1A-9C8B-6E3D7F2A1B9C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=..\output
OutputBaseFilename=openclaw-setup-{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Node.js portable
Source: "..\bundled\nodejs\*"; DestDir: "{app}\nodejs"; Flags: ignoreversion recursesubdirs createallsubdirs
; OpenClaw app
Source: "..\bundled\openclaw\*"; DestDir: "{app}\openclaw"; Flags: ignoreversion recursesubdirs createallsubdirs
; Config tool exe
Source: "..\bundled\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; Start/stop scripts
Source: "..\bundled\start-openclaw.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bundled\stop-openclaw.bat"; DestDir: "{app}"; Flags: ignoreversion
; Config template
Source: "..\bundled\openclaw-config.json"; DestDir: "{app}"; Flags: ignoreversion; Check: FileExists(ExpandConstant('..\bundled\openclaw-config.json'))

[Icons]
Name: "{group}\OpenClaw Web UI"; Filename: "http://localhost:18789"
Name: "{group}\OpenClaw Config"; Filename: "{app}\{#MyAppExeName}"; Check: FileExists(ExpandConstant('{app}\{#MyAppExeName}'))
Name: "{group}\Start OpenClaw"; Filename: "{app}\start-openclaw.bat"
Name: "{group}\Stop OpenClaw"; Filename: "{app}\stop-openclaw.bat"
Name: "{group}\Uninstall OpenClaw"; Filename: "{uninstallexe}"
; Desktop shortcuts
Name: "{autodesktop}\OpenClaw Web UI"; Filename: "http://localhost:18789"; Tasks: desktopicon
Name: "{autodesktop}\OpenClaw Config"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; Check: FileExists(ExpandConstant('{app}\{#MyAppExeName}'))

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "autostart"; Description: "Start OpenClaw on boot"; GroupDescription: "Startup:"; Flags: checkedonce

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "OpenClaw"; ValueData: """{app}\start-openclaw.bat"""; Flags: uninsdeletevalue; Tasks: autostart

[Run]
Filename: "{app}\start-openclaw.bat"; Description: "Start OpenClaw now"; Flags: nowait postinstall skipifsilent
Filename: "http://localhost:18789"; Description: "Open OpenClaw Web UI"; Flags: nowait postinstall skipifsilent shellexec

[UninstallRun]
Filename: "{app}\stop-openclaw.bat"; Flags: waituntilterminated

[UninstallDelete]
Type: filesandordirs; Name: "{app}\nodejs"
Type: filesandordirs; Name: "{app}\openclaw"
Type: filesandordirs; Name: "{app}\memory"
Type: filesandordirs; Name: "{app}\logs"
