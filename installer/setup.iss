; OpenClaw Windows Installer
; 使用 Inno Setup 编译此脚本
; 版本: 1.0.0

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
; 输出设置
OutputDir=..\output
OutputBaseFilename=openclaw-setup-{#MyAppVersion}
SetupIconFile=..\assets\icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; 权限
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
chinesesimplified.WelcomeLabel2=这将安装 OpenClaw 到您的计算机。%n%nOpenClaw 是一个强大的 AI 助手框架。%n%n建议您在继续之前关闭所有其他应用程序。
chinesesimplified.FinishedHeadingLabel=OpenClaw 安装完成
chinesesimplified.FinishedLabel=安装已完成。您现在可以使用 OpenClaw 了。

[Pages]
Name: "apikeypage"; AfterPage: "wpSelectDir"

[Files]
; Node.js 便携版
Source: "..\bundled\nodejs\*"; DestDir: "{app}\nodejs"; Flags: ignoreversion recursesubdirs createallsubdirs
; OpenClaw 应用
Source: "..\bundled\openclaw\*"; DestDir: "{app}\openclaw"; Flags: ignoreversion recursesubdirs createallsubdirs
; 配置工具
Source: "..\config-tool\src-tauri\target\release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
; 启动脚本
Source: "..\bundled\start-openclaw.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\bundled\stop-openclaw.bat"; DestDir: "{app}"; Flags: ignoreversion
; 配置模板
Source: "..\bundled\openclaw-config.json"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\OpenClaw 网页"; Filename: "http://localhost:18789"; IconFilename: "{app}\icon-web.ico"
Name: "{group}\OpenClaw 配置"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon-config.ico"
Name: "{group}\启动 OpenClaw"; Filename: "{app}\start-openclaw.bat"; IconFilename: "{app}\icon-web.ico"
Name: "{group}\停止 OpenClaw"; Filename: "{app}\stop-openclaw.bat"; IconFilename: "{app}\icon-stop.ico"
Name: "{group}\卸载 OpenClaw"; Filename: "{uninstallexe}"
; 桌面快捷方式
Name: "{autodesktop}\OpenClaw 网页"; Filename: "http://localhost:18789"; IconFilename: "{app}\icon-web.ico"; Tasks: desktopicon
Name: "{autodesktop}\OpenClaw 配置"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\icon-config.ico"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: checkedonce
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode
Name: "autostart"; Description: "开机自动启动 OpenClaw"; GroupDescription: "启动选项:"; Flags: checkedonce

[Registry]
; 开机自启动
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "OpenClaw"; ValueData: """{app}\start-openclaw.bat"""; Flags: uninsdeletevalue; Tasks: autostart

[Run]
Filename: "{app}\start-openclaw.bat"; Description: "立即启动 OpenClaw"; Flags: nowait postinstall skipifsilent
Filename: "http://localhost:18789"; Description: "打开 OpenClaw 网页"; Flags: nowait postinstall skipifsilent shellexec

[UninstallRun]
Filename: "{app}\stop-openclaw.bat"; Flags: waituntilterminated

[UninstallDelete]
Type: filesandordirs; Name: "{app}\nodejs"
Type: filesandordirs; Name: "{app}\openclaw"
Type: filesandordirs; Name: "{app}\memory"
Type: filesandordirs; Name: "{app}\logs"
Type: files; Name: "{app}\openclaw-config.json"

[Code]
var
  ApiKeyPage: TInputQueryWizardPage;
  ZaiApiKeyEdit: TNewEdit;
  MinimaxApiKeyEdit: TNewEdit;
  UseZaiCheckBox: TNewCheckBox;
  UseMinimaxCheckBox: TNewCheckBox;

procedure InitializeWizard;
var
  Page: TWizardPage;
  Label1, Label2, Label3, Label4: TLabel;
begin
  // 创建 API Key 输入页面
  Page := CreateCustomPage(wpSelectDir, '配置 API 密钥', '请输入您的 AI 服务 API 密钥（可选，安装后可在配置工具中修改）');
  
  // GLM API Key
  Label1 := TLabel.Create(Page);
  Label1.Parent := Page.Surface;
  Label1.Caption := 'GLM (智谱) API Key:';
  Label1.Left := 0;
  Label1.Top := 10;
  
  ZaiApiKeyEdit := TNewEdit.Create(Page);
  ZaiApiKeyEdit.Parent := Page.Surface;
  ZaiApiKeyEdit.Left := 0;
  ZaiApiKeyEdit.Top := 30;
  ZaiApiKeyEdit.Width := Page.Surface.Width;
  ZaiApiKeyEdit.Height := 21;
  ZaiApiKeyEdit.PasswordChar := '*';
  
  // 获取链接
  Label2 := TLabel.Create(Page);
  Label2.Parent := Page.Surface;
  Label2.Caption := '获取密钥: https://open.bigmodel.cn';
  Label2.Left := 0;
  Label2.Top := 55;
  Label2.Font.Color := clBlue;
  Label2.Cursor := crHand;
  Label2.OnClick := @Label2.Click;  // 这里需要自定义点击事件
  
  // MiniMax API Key
  Label3 := TLabel.Create(Page);
  Label3.Parent := Page.Surface;
  Label3.Caption := 'MiniMax API Key:';
  Label3.Left := 0;
  Label3.Top := 85;
  
  MinimaxApiKeyEdit := TNewEdit.Create(Page);
  MinimaxApiKeyEdit.Parent := Page.Surface;
  MinimaxApiKeyEdit.Left := 0;
  MinimaxApiKeyEdit.Top := 105;
  MinimaxApiKeyEdit.Width := Page.Surface.Width;
  MinimaxApiKeyEdit.Height := 21;
  MinimaxApiKeyEdit.PasswordChar := '*';
  
  Label4 := TLabel.Create(Page);
  Label4.Parent := Page.Surface;
  Label4.Caption := '获取密钥: https://www.minimax.io';
  Label4.Left := 0;
  Label4.Top := 130;
  Label4.Font.Color := clBlue;
  Label4.Cursor := crHand;
end;

function UpdateConfigFile(const ConfigPath, ZaiKey, MinimaxKey: String): Boolean;
var
  ConfigContent: String;
begin
  Result := False;
  if FileExists(ConfigPath) then
  begin
    ConfigContent := GetFileContent(ConfigPath);
    // 替换占位符
    StringChangeEx(ConfigContent, '{{ZAI_API_KEY}}', ZaiKey, True);
    StringChangeEx(ConfigContent, '{{MINIMAX_API_KEY}}', MinimaxKey, True);
    // 保存配置
    if SaveStringToFile(ConfigPath, ConfigContent, False) then
      Result := True;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ConfigPath: String;
begin
  if CurStep = ssPostInstall then
  begin
    ConfigPath := ExpandConstant('{app}\openclaw-config.json');
    UpdateConfigFile(ConfigPath, ZaiApiKeyEdit.Text, MinimaxApiKeyEdit.Text);
  end;
end;
