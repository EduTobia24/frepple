; FrePPLe Windows Installer Script
; Inno Setup 6.x required
; This script creates a complete Windows installer for FrePPLe APS
; Including PostgreSQL, Python environment, and web server

#define MyAppName "FrePPLe"
#define MyAppVersion "9.13.0"
#define MyAppPublisher "frePPLe bv"
#define MyAppURL "https://frepple.com"
#define MyAppExeName "frepple.exe"
#define PythonVersion "3.12"
#define PostgreSQLVersion "16"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
AppId={{8C5F3B7A-9E2D-4F1B-A6C8-3D9E7F2B4A1C}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\..\COPYING
InfoBeforeFile=README.txt
OutputDir=..\..\..\build\windows
OutputBaseFilename=frepple-{#MyAppVersion}-win64-setup
SetupIconFile=..\..\src\frepple.ico
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=admin
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\bin\frepple.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Types]
Name: "full"; Description: "Full installation (includes PostgreSQL)"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "core"; Description: "FrePPLe Core Engine and Web Application"; Types: full custom; Flags: fixed
Name: "postgresql"; Description: "PostgreSQL {#PostgreSQLVersion} Database Server"; Types: full
Name: "python"; Description: "Python {#PythonVersion} Runtime"; Types: full custom; Flags: fixed
Name: "shortcuts"; Description: "Desktop and Start Menu Shortcuts"; Types: full custom

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Components: shortcuts
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Components: shortcuts; Flags: unchecked
Name: "startservice"; Description: "Start FrePPLe service after installation"; GroupDescription: "Service Options:"; Flags: checkedonce
Name: "firewall"; Description: "Add Windows Firewall exception"; GroupDescription: "Security Options:"

[Files]
; Core application files (C++ binaries - optional, commented out for Python-only installation)
; Source: "..\..\bin\frepple.exe"; DestDir: "{app}\bin"; Flags: ignoreversion; Components: core
; Source: "..\..\bin\frepple.dll"; DestDir: "{app}\bin"; Flags: ignoreversion; Components: core
; Source: "..\..\bin\frepple.xsd"; DestDir: "{app}\share\frepple"; Flags: ignoreversion; Components: core
; Source: "..\..\bin\license.xml"; DestDir: "{app}\etc\frepple"; Flags: ignoreversion; Components: core

; Django application files
Source: "..\..\freppledb\*"; DestDir: "{app}\share\frepple\freppledb"; Flags: ignoreversion recursesubdirs; Components: core
Source: "..\..\frepplectl.py"; DestDir: "{app}\bin"; Flags: ignoreversion; Components: core
Source: "..\..\djangosettings.py"; DestDir: "{app}\etc\frepple"; Flags: ignoreversion; Components: core

; Configuration and requirements
Source: "..\..\requirements.txt"; DestDir: "{app}\share\frepple"; Flags: ignoreversion; Components: core
Source: "..\..\README.md"; DestDir: "{app}"; Flags: ignoreversion isreadme; Components: core
Source: "..\..\COPYING"; DestDir: "{app}"; Flags: ignoreversion; Components: core

; Static files (will be collected during post-install)
; Source: "..\..\static\*"; DestDir: "{app}\share\frepple\static"; Flags: ignoreversion recursesubdirs; Components: core

; PostgreSQL portable (must be prepared separately)
Source: "dependencies\postgresql\*"; DestDir: "{app}\pgsql"; Flags: ignoreversion recursesubdirs; Components: postgresql; Check: ShouldInstallPostgreSQL

; Python embeddable package (must be prepared separately)
Source: "dependencies\python\*"; DestDir: "{app}\python"; Flags: ignoreversion recursesubdirs; Components: python

; Xerces-C library
Source: "dependencies\xerces-c\bin\*.dll"; DestDir: "{app}\bin"; Flags: ignoreversion; Components: core

; PostgreSQL client library
Source: "dependencies\libpq\bin\*.dll"; DestDir: "{app}\bin"; Flags: ignoreversion; Components: core

; Scripts
Source: "scripts\*"; DestDir: "{app}\scripts"; Flags: ignoreversion; Components: core

[Dirs]
Name: "{app}\logs"; Permissions: users-full
Name: "{app}\data"; Permissions: users-full
Name: "{app}\pgsql\data"; Components: postgresql; Permissions: users-full
Name: "{app}\etc\frepple"; Permissions: users-full

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "http://localhost:8000"; IconFilename: "{app}\bin\frepple.exe"; Components: shortcuts
Name: "{group}\{#MyAppName} Documentation"; Filename: "{#MyAppURL}"; Components: shortcuts
Name: "{group}\Stop {#MyAppName}"; Filename: "{app}\scripts\stop-frepple.bat"; Components: shortcuts
Name: "{group}\Start {#MyAppName}"; Filename: "{app}\scripts\start-frepple.bat"; Components: shortcuts
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"; Components: shortcuts
Name: "{autodesktop}\{#MyAppName}"; Filename: "http://localhost:8000"; IconFilename: "{app}\bin\frepple.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "http://localhost:8000"; IconFilename: "{app}\bin\frepple.exe"; Tasks: quicklaunchicon

[Registry]
; Note: PATH modification removed to avoid admin/per-user conflicts
; Users can manually add to PATH if needed: {app}\bin;{app}\python;{app}\pgsql\bin

; Application settings
Root: HKLM; Subkey: "Software\{#MyAppName}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKLM; Subkey: "Software\{#MyAppName}"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"
Root: HKLM; Subkey: "Software\{#MyAppName}"; ValueType: string; ValueName: "PythonPath"; ValueData: "{app}\python"
Root: HKLM; Subkey: "Software\{#MyAppName}"; ValueType: string; ValueName: "PostgreSQLPath"; ValueData: "{app}\pgsql"; Components: postgresql

[Run]
; Install Visual C++ Redistributable if needed
Filename: "{app}\scripts\install-vcredist.bat"; Description: "Install Visual C++ Redistributable"; StatusMsg: "Installing Visual C++ Runtime..."; Flags: runhidden waituntilterminated

; Initialize PostgreSQL database
Filename: "{app}\scripts\init-postgresql.bat"; Parameters: """{app}"""; Description: "Initialize PostgreSQL database"; StatusMsg: "Initializing PostgreSQL..."; Flags: runhidden waituntilterminated; Components: postgresql

; Create Python virtual environment
Filename: "{app}\scripts\setup-python-env.bat"; Parameters: """{app}"""; Description: "Setup Python environment"; StatusMsg: "Installing Python dependencies..."; Flags: runhidden waituntilterminated; Components: python

; Initialize FrePPLe database
Filename: "{app}\scripts\init-frepple-db.bat"; Parameters: """{app}"""; Description: "Initialize FrePPLe database"; StatusMsg: "Creating FrePPLe database schema..."; Flags: runhidden waituntilterminated

; Configure Windows service
Filename: "{app}\scripts\install-service.bat"; Parameters: """{app}"""; Description: "Install FrePPLe as Windows service"; StatusMsg: "Installing service..."; Flags: runhidden waituntilterminated

; Add firewall exception
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""FrePPLe Web Server"" dir=in action=allow protocol=TCP localport=8000"; StatusMsg: "Adding firewall exception..."; Flags: runhidden waituntilterminated; Tasks: firewall

; Start service
Filename: "net"; Parameters: "start FrePPLeService"; Description: "Start FrePPLe service"; StatusMsg: "Starting FrePPLe..."; Flags: runhidden waituntilterminated; Tasks: startservice

; Open browser
Filename: "http://localhost:8000"; Description: "Open FrePPLe in browser"; Flags: shellexec postinstall skipifsilent; Components: shortcuts

[UninstallRun]
; Stop service
Filename: "net"; Parameters: "stop FrePPLeService"; Flags: runhidden; RunOnceId: "StopService"

; Uninstall service
Filename: "{app}\scripts\uninstall-service.bat"; Parameters: """{app}"""; Flags: runhidden waituntilterminated; RunOnceId: "UninstallService"

; Stop PostgreSQL
Filename: "{app}\scripts\stop-postgresql.bat"; Parameters: """{app}"""; Flags: runhidden; Components: postgresql; RunOnceId: "StopPostgreSQL"

; Remove firewall rule
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""FrePPLe Web Server"""; Flags: runhidden; Tasks: firewall; RunOnceId: "RemoveFirewall"

[UninstallDelete]
Type: filesandordirs; Name: "{app}\venv"
Type: filesandordirs; Name: "{app}\logs"
Type: files; Name: "{app}\etc\frepple\djangosettings.py"

[Code]
var
  PostgreSQLPage: TInputQueryWizardPage;
  DatabaseUserPage: TInputQueryWizardPage;
  WebServerPage: TInputQueryWizardPage;
  AdminUserPage: TInputQueryWizardPage;

// Custom string replace function
function StringReplaceAll(const S, OldPattern, NewPattern: string): string;
var
  Remaining: string;
  Offset: Integer;
begin
  Remaining := S;
  Result := '';
  while Pos(OldPattern, Remaining) > 0 do
  begin
    Offset := Pos(OldPattern, Remaining);
    Result := Result + Copy(Remaining, 1, Offset - 1) + NewPattern;
    Remaining := Copy(Remaining, Offset + Length(OldPattern), Length(Remaining));
  end;
  Result := Result + Remaining;
end;

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;

function ShouldInstallPostgreSQL: Boolean;
begin
  Result := WizardIsComponentSelected('postgresql');
end;

procedure InitializeWizard;
begin
  { PostgreSQL configuration page }
  PostgreSQLPage := CreateInputQueryPage(wpSelectComponents,
    'PostgreSQL Configuration', 'Configure PostgreSQL database settings',
    'Please enter the PostgreSQL configuration. Port 5433 is used by default to avoid conflicts with existing PostgreSQL installations.');
  PostgreSQLPage.Add('Database name:', False);
  PostgreSQLPage.Add('Port:', False);
  PostgreSQLPage.Values[0] := 'frepple';
  PostgreSQLPage.Values[1] := '5433';

  { Database user page }
  DatabaseUserPage := CreateInputQueryPage(PostgreSQLPage.ID,
    'Database User', 'Configure database user credentials',
    'Please enter the database user credentials for FrePPLe.');
  DatabaseUserPage.Add('Database username:', False);
  DatabaseUserPage.Add('Database password:', True);
  DatabaseUserPage.Values[0] := 'frepple';
  DatabaseUserPage.Values[1] := 'frepple';

  { Web server configuration page }
  WebServerPage := CreateInputQueryPage(DatabaseUserPage.ID,
    'Web Server Configuration', 'Configure FrePPLe web server',
    'Please enter the web server configuration.');
  WebServerPage.Add('Web server port:', False);
  WebServerPage.Add('Number of worker processes:', False);
  WebServerPage.Values[0] := '8000';
  WebServerPage.Values[1] := '4';

  { Admin user page }
  AdminUserPage := CreateInputQueryPage(WebServerPage.ID,
    'Administrator Account', 'Create FrePPLe administrator account',
    'Please enter the administrator credentials. Default is admin/admin (change after first login).');
  AdminUserPage.Add('Admin username:', False);
  AdminUserPage.Add('Admin password:', True);
  AdminUserPage.Values[0] := 'admin';
  AdminUserPage.Values[1] := 'admin';
end;

function GetDatabaseName(Param: String): String;
begin
  Result := PostgreSQLPage.Values[0];
end;

function GetDatabasePort(Param: String): String;
begin
  Result := PostgreSQLPage.Values[1];
end;

function GetDatabaseUser(Param: String): String;
begin
  Result := DatabaseUserPage.Values[0];
end;

function GetDatabasePassword(Param: String): String;
begin
  Result := DatabaseUserPage.Values[1];
end;

function GetWebServerPort(Param: String): String;
begin
  Result := WebServerPage.Values[0];
end;

function GetWorkerProcesses(Param: String): String;
begin
  Result := WebServerPage.Values[1];
end;

function GetAdminUsername(Param: String): String;
begin
  Result := AdminUserPage.Values[0];
end;

function GetAdminPassword(Param: String): String;
begin
  Result := AdminUserPage.Values[1];
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  SettingsFile: String;
  Content: TStringList;
  SecretKey: String;
  I: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    { Generate random secret key }
    SecretKey := '';
    for I := 1 to 50 do
      SecretKey := SecretKey + Chr(Random(26) + 65);

    { Update djangosettings.py with user's configuration }
    SettingsFile := ExpandConstant('{app}\etc\frepple\djangosettings.py');
    if FileExists(SettingsFile) then
    begin
      Content := TStringList.Create;
      try
        Content.LoadFromFile(SettingsFile);
        
        { Replace configuration values }
        for I := 0 to Content.Count - 1 do
        begin
          if Pos('SECRET_KEY = "%@mzit!i8b*$zc&6oev96=RANDOMSTRING"', Content[I]) > 0 then
            Content[I] := 'SECRET_KEY = "' + SecretKey + '"';
          
          if Pos('os.environ.get("POSTGRES_DBNAME","frepple")', Content[I]) > 0 then
            Content[I] := StringReplaceAll(Content[I], 'os.environ.get("POSTGRES_DBNAME","frepple")', '"' + GetDatabaseName('') + '"');
          
          if Pos('os.environ.get("POSTGRES_USER", "frepple")', Content[I]) > 0 then
            Content[I] := StringReplaceAll(Content[I], 'os.environ.get("POSTGRES_USER", "frepple")', '"' + GetDatabaseUser('') + '"');
          
          if Pos('os.environ.get("POSTGRES_PASSWORD", "frepple")', Content[I]) > 0 then
            Content[I] := StringReplaceAll(Content[I], 'os.environ.get("POSTGRES_PASSWORD", "frepple")', '"' + GetDatabasePassword('') + '"');
          
          if Pos('os.environ.get("POSTGRES_HOST", "")', Content[I]) > 0 then
            Content[I] := StringReplaceAll(Content[I], 'os.environ.get("POSTGRES_HOST", "")', '"localhost"');
          
          if Pos('os.environ.get("POSTGRES_PORT", "")', Content[I]) > 0 then
            Content[I] := StringReplaceAll(Content[I], 'os.environ.get("POSTGRES_PORT", "")', '"' + GetDatabasePort('') + '"');
        end;
        
        Content.SaveToFile(SettingsFile);
      finally
        Content.Free;
      end;
    end;

    { Save configuration to registry for scripts }
    RegWriteStringValue(HKLM, 'Software\FrePPLe', 'DatabaseName', GetDatabaseName(''));
    RegWriteStringValue(HKLM, 'Software\FrePPLe', 'DatabaseUser', GetDatabaseUser(''));
    RegWriteStringValue(HKLM, 'Software\FrePPLe', 'DatabasePassword', GetDatabasePassword(''));
    RegWriteStringValue(HKLM, 'Software\FrePPLe', 'DatabasePort', GetDatabasePort(''));
    RegWriteStringValue(HKLM, 'Software\FrePPLe', 'WebServerPort', GetWebServerPort(''));
    RegWriteStringValue(HKLM, 'Software\FrePPLe', 'WorkerProcesses', GetWorkerProcesses(''));
  end;
end;

function InitializeUninstall(): Boolean;
var
  Response: Integer;
begin
  Response := MsgBox('Do you want to keep your database and configuration files?' + #13#10 + 
                     'Choose No to completely remove FrePPLe including all data.',
                     mbConfirmation, MB_YESNO);
  
  if Response = IDYES then
  begin
    { Keep data - don't delete PostgreSQL data directory }
    RegWriteStringValue(HKLM, 'Software\FrePPLe', 'KeepData', '1');
  end
  else
  begin
    RegWriteStringValue(HKLM, 'Software\FrePPLe', 'KeepData', '0');
  end;
  
  Result := True;
end;
