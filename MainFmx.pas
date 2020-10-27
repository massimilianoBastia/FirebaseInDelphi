

unit MainFmx;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.JSON,System.StrUtils,System.Sensors,
  System.RTTI, REST.Types,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation, FMX.Edit, FMX.TabControl,
  FMX.MultiView, FMX.ScrollBox, FMX.Memo, FMX.Ani, FMX.Layouts,
  FB4D.Interfaces, FB4D.SelfRegistrationFra, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  FMX.ListBox,FB4D.RealTimeDB, FB4D.Storage,
  FMX.Menus,FMX.Platform.Win, System.Actions, FMX.ActnList;

type
  TfmxMain = class(TForm)
    TabControl: TTabControl;
    tabSignIn: TTabItem;
    tabClipboard: TTabItem;
    lblClipboardState: TLabel;
    btnSettings: TButton;
    btnSendToCloud: TButton;
    lblStatusRTDB: TLabel;
    lblSendStatusRTDB: TLabel;
    lblVersionInfo: TLabel;
    layToolbar: TLayout;
    layUserInfo: TLayout;
    btnSignOut: TButton;
    lblUserInfo: TLabel;
    tabServer: TTabItem;
    Label1: TLabel;
    ListView1: TListView;
    btnDeleteGroup: TButton;
    btnCreaServer: TButton;
    tabCreaServer: TTabItem;
    btnUploadServer: TButton;
    edtNomeServer: TEdit;
    lstDBNode: TListBox;
    tabContatti: TTabItem;
    btnUploadSynch: TButton;
    OpenDialog: TOpenDialog;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    btnBackGruppoList: TButton;
    ActionList1: TActionList;
    PreviousTabAction1: TChangeTabAction;
    btnBackContatti: TButton;
    btnBackCreaGruppo: TButton;
    TabControl1: TTabControl;
    tabLobby: TTabItem;
    memClipboardText: TMemo;
    memRTDB: TMemo;
    lblcurrentselection: TLabel;
    Memo1: TMemo;
    lblUpload: TLabel;
    SaveDialog1: TSaveDialog;
    edtStoragePath: TEdit;
    Layout1: TLayout;
    Rectangle1: TRectangle;
    Layout2: TLayout;
    Rectangle2: TRectangle;
    Layout3: TLayout;
    ListBox2: TListBox;
    StyleBook1: TStyleBook;
    Layout4: TLayout;
    Rectangle3: TRectangle;
    FraSelfRegistration1: TFraSelfRegistration;
    tabProjectSet: TTabItem;
    edtKey: TEdit;
    edtProjectID: TEdit;
    btnSet: TButton;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnSendToCloudClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSignOutClick(Sender: TObject);
    procedure OnItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure btnDeleteGroupClick(Sender: TObject);
    procedure btnCreaServerClick(Sender: TObject);
    procedure btnUploadServerClick(Sender: TObject);
    procedure btnUploadSynchClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBoxItem1Click(Sender: TObject);
    procedure ListBoxItem2Click(Sender: TObject);
    procedure ListBoxItem3Click(Sender: TObject);
    procedure btnBackGruppoListClick(Sender: TObject);
    procedure TabControlChange(Sender: TObject);
    procedure UploadServer;
    procedure ListBox2DblClick(Sender: TObject);
    function GetStorageFileName:string;
    procedure btnSetClick(Sender: TObject);

    private
    fConfig: IFirebaseConfiguration;
    fAuth: IFirebaseAuthentication;
    fRealTimeDB: IRealTimeDB;
    fFirebaseEvent: IFirebaseEvent;
    fReceivedUpdates, fErrorCount: Int64;
    fStressTestCounter: Int64;
    fStorage: IFirebaseStorage;
    fStorageObject: IStorageObject;
    fDatabase: IFirestoreDatabase;
    fTransaction: TTransaction;
    fDownloadStream: TFileStream;
    fUploadStream: TFileStream;
    function OnGetAuth: IFirebaseAuthentication;
    procedure OnUserLogin(const Info: string; User: IFirebaseUser);
    procedure OnPutResp(ResourceParams: TRequestResourceParam; Val: TJSONValue);
    procedure OnPutError(const RequestID, ErrMsg: string);
    procedure WipeToTab(ActiveTab: TTabItem);
    procedure StartClipboard;
    procedure OnRecData(const Event: string; Params: TRequestResourceParam;
      JSONObj: TJSONObject);
    procedure OnRecDataError(const Info, ErrMsg: string);
    procedure OnRecDataStop(Sender: TObject);
    procedure StartListener(selection: string);
    procedure StopListener;
    procedure SaveSettings;
    function GetSettingFilename: string;
    procedure ExceptionHandler(Sender: TObject; E: Exception);
    function CheckAndCreateRealTimeDBClass: boolean;
    function CheckSignedIn: boolean;
    procedure CreateAuthenticationClass;
    procedure ShowRTNode(ResourceParams: TRequestResourceParam;
    Val: TJSONValue);
    function GetRTDBPath: TStringDynArray;
    function GetPathFromResParams(
    ResParams: TRequestResourceParam): string;
    end;
var
  fmxMain: TfmxMain;
  lItem: TListViewItem;
  currentSelection:string;
  Val: TJSONValue;
  fUID: string;
  fUSER: string;
  cAPIKey: string;
  cIDPrj: string;
  objectFileName:string;
  Obj: IStorageObject;
  ObjectName: string;
implementation

uses
  System.IniFiles, System.IOUtils,
  System.NetEncoding,
  System.Generics.Collections,
  FMX.Platform, FMX.Surfaces,
  FB4D.Configuration, FB4D.Authentication, FB4D.Helpers, FB4D.Response,
  FB4D.Request,Windows, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ImgList, Vcl.ExtCtrls,
  ShellAPI, System.ImageList;//Planner

const
 cTOKENS= 'chatclientserver-2aad8.appspot.com';
resourcestring
  rsEnterEMail = 'Enter your email address for login';
  rsWait = 'Please wait for Firebase';
  rsEnterPassword = 'Enter your password for login';
  rsSetupPassword = 'Setup a new password for future logins';
{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}
{$REGION 'Form and Tab Handling'}
procedure TfmxMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 StopListener;
 SaveSettings;
end;

procedure TfmxMain.FormCreate(Sender: TObject);
begin
  Application.OnException := ExceptionHandler;
end;

procedure TfmxMain.ExceptionHandler(Sender: TObject; E: Exception);
begin
  memClipboardText.Lines.Clear;
  memClipboardText.Lines.Add('Exception at: ' +
  FormatDateTime('dd/mm/yy hh:nn:ss:zzz', now));
  memClipboardText.Lines.Add(E.ClassName);
  memClipboardText.Lines.Add(E.Message);
  memClipboardText.Lines.Add(E.StackTrace);
end;
procedure TfmxMain.ListBoxItem1Click(Sender: TObject);
begin
   WipeToTab(tabServer);
   ListBox2.Clear;
   UploadServer;
end;

procedure TfmxMain.ListBoxItem2Click(Sender: TObject);
begin
   WipeToTab(tabCreaServer);
end;

procedure TfmxMain.ListBoxItem3Click(Sender: TObject);
begin
   WipeToTab(tabContatti);
end;

procedure TfmxMain.btnBackGruppoListClick(Sender: TObject);
begin
WipeToTab(tabClipboard);
end;
procedure TfmxMain.WipeToTab(ActiveTab: TTabItem);
var
  c: integer;
begin
  if TabControl.ActiveTab <> ActiveTab then
  begin
    ActiveTab.Visible := true;
{$IFDEF ANDROID}
    TabControl.ActiveTab := ActiveTab;
{$ELSE}
    TabControl.GotoVisibleTab(ActiveTab.Index, TTabTransition.Slide,
      TTabTransitionDirection.Normal);
{$ENDIF}
    for c := 0 to TabControl.TabCount - 1 do
      TabControl.Tabs[c].Visible := TabControl.Tabs[c] = ActiveTab;
  end;
end;
procedure TfmxMain.TabControlChange(Sender: TObject);
begin
btnBackGruppoList.Visible:=True;
btnBackContatti.Visible:= True;
btnBackCreaGruppo.Visible:=True;
end;
{$ENDREGION}
{$REGION 'Authentication'}
procedure TfmxMain.CreateAuthenticationClass;
begin
  if not assigned(fAuth) then
  begin
    fAuth := TFirebaseAuthentication.Create(cAPIKey);
  end;
end;
procedure TfmxMain.FormShow(Sender: TObject);
var
  IniFile: TIniFile;
  LastEMail: string;
  LastToken: string;
begin
IniFile := TIniFile.Create(GetSettingFilename);
  try
    edtKey.Text := IniFile.ReadString('FBProjectSettings', 'APIKey', '');
    edtProjectID.Text := IniFile.ReadString('FBProjectSettings', 'ProjectID', '');
    LastEMail := IniFile.ReadString('Authentication', 'User', '');
    LastToken := IniFile.ReadString('Authentication', 'Token', '');
  finally
    IniFile.Free;
  end;
  if edtKey.Text.IsEmpty or edtProjectID.Text.IsEmpty then
    TabControl.ActiveTab := tabProjectSet
  else
    TabControl.ActiveTab := tabSignIn;
    cApiKey:= edtKey.Text;
    cIDPrj:= edtProjectID.Text;
    FraSelfRegistration1.InitializeAuthOnDemand(OnGetAuth, OnUserLogin, LastToken,
    LastEMail);
    Caption := Caption + ' [' + TFirebaseHelpers.GetConfigAndPlatform + ']';
end;

procedure TfmxMain.SaveSettings;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create(GetSettingFilename);
  try
    IniFile.WriteString('FBProjectSettings', 'APIKey', edtKey.Text);
    IniFile.WriteString('FBProjectSettings', 'ProjectID', edtProjectID.Text);
    IniFile.WriteString('Authentication', 'User', FraSelfRegistration1.GetEMail);
    if assigned(fConfig) and fConfig.Auth.Authenticated then
      IniFile.WriteString('Authentication', 'Token',
      fConfig.Auth.GetRefreshToken)
    else
      IniFile.DeleteKey('Authentication', 'Token');
  finally
    IniFile.Free;
  end;
end;

procedure TfmxMain.btnSetClick(Sender: TObject);
begin
  if edtKey.Text.IsEmpty then
    edtKey.SetFocus
  else if edtProjectID.Text.IsEmpty then
    edtProjectID.SetFocus
  else begin
    SaveSettings;
    WipeToTab(tabSignIn);
    FraSelfRegistration1.StartEMailEntering;
  end;
end;

function TfmxMain.GetSettingFilename: string;
var
  FileName: string;
begin
  FileName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
  result := IncludeTrailingPathDelimiter(
{$IFDEF IOS}
    TPath.GetDocumentsPath
{$ELSE}
    TPath.GetHomePath
{$ENDIF}
    ) + FileName + TFirebaseHelpers.GetPlatform + '.ini';
end;

function TfmxMain.OnGetAuth: IFirebaseAuthentication;
begin
  if not assigned(fConfig) then
  begin
    fConfig := TFirebaseConfiguration.Create(cAPIKey, cIDPrj);
    fAuth:=fconfig.Auth;
    fFirebaseEvent := nil;
  end;
  result := fConfig.Auth;
end;

function TfmxMain.CheckSignedIn: boolean;
begin
  if fConfig.Auth.Authenticated then
    begin
    tabServer.Visible:=true;
    result := true
    end
  else begin
    result := false;
  end;
end;

procedure TfmxMain.btnSignOutClick(Sender: TObject);
begin
  fConfig.Auth.SignOut;
  fUID := '';
  WipeToTab(tabSignIn);
  FraSelfRegistration1.StartEMailEntering;
  ListBox2.Clear;
  StopListener;
  currentSelection:='';
end;

procedure TfmxMain.OnUserLogin(const Info: string; User: IFirebaseUser);
begin
  fUID := User.UID;
  if fConfig.Auth.Authenticated then
  begin
    CheckAndCreateRealTimeDBClass;
  end
  else
  begin
  end;
  if User.IsDisplayNameAvailable and not User.DisplayName.IsEmpty then
  begin
    lblUserInfo.Text := 'Logged in user name: ' + User.DisplayName;
    fUSER:= User.DisplayName
  end
  else
    lblUserInfo.Text := 'Logged in user eMail: ' + User.EMail;
    lblUserInfo.Text := lblUserInfo.Text + #13 + 'UserID: ' + fUID;
    StartClipboard;
end;
procedure TfmxMain.StartListener(selection:string);
begin
  fFirebaseEvent := fConfig.RealTimeDB.ListenForValueEvents([selection],
  OnRecData, OnRecDataStop, OnRecDataError);
  fReceivedUpdates := 0;
  fErrorCount := 0;
end;

procedure TfmxMain.StopListener;
begin
  if assigned(fConfig) and assigned(fFirebaseEvent) then
    fFirebaseEvent.StopListening;
end;
{$ENDREGION}
{$REGION 'ChatTab'}
procedure TfmxMain.StartClipboard;
begin
  WipeToTab(tabClipboard);
  StartListener('Cloudy');
end;

procedure TfmxMain.btnDeleteGroupClick(Sender: TObject);
begin
    if not CheckAndCreateRealTimeDBClass then
    exit;
  memRTDB.Lines.Clear;
  try
    if fRealTimeDB.DeleteSynchronous(GetRTDBPath) then
      begin
        currentSelection:='';
        memRTDB.Lines.Add('Delete ' +
        GetPathFromResParams(GetRTDBPath) +
        ' passed')
      end
    else
        memRTDB.Lines.Add('Path ' +
        GetPathFromResParams(GetRTDBPath) +
        ' not found');
  except
      on e: exception do
      memRTDB.Lines.Add('Delete ' + GetPathFromResParams(GetRTDBPath) +
      ' failed: ' + e.Message);
  end;
end;

procedure TfmxMain.btnSendToCloudClick(Sender: TObject);
var
  Data: TJSONObject;
  User: IFirebaseUser;
  tNOW : TDateTime;
begin
  tNOW:=Time;
  lblSendStatusRTDB.Opacity := 1;
  lblSendStatusRTDB.Text := '';
  Data := TJSONObject.Create;
  try
    try
     Data.AddPair('type', 'text');
     Data.AddPair('text', string(UTF8Encode(memClipboardText.Lines.Text)));
     Data.AddPair('uid', string(fUID));
     Data.AddPair('userName', string(fUSER));
     Data.AddPair('time', TimeToStr(tNOW));
       if Length(currentSelection)>0 then
       begin
        fConfig.RealTimeDB.Put([currentSelection,fUID], Data, OnPutResp, OnPutError);
       end
       else
        fConfig.RealTimeDB.Put(['Cloudy',fUID], Data, OnPutResp, OnPutError);

    finally
      Data.Free;
    end;
  except
    on e: exception do
    begin
      memClipboardText.Lines.Clear;
      memClipboardText.Lines.Add('Exception in btnSendToCloudClick at: ' +
      FormatDateTime('dd/mm/yy hh:nn:ss:zzz', now));
      memClipboardText.Lines.Add(E.ClassName);
      memClipboardText.Lines.Add(E.Message);
      memClipboardText.Lines.Add(E.StackTrace);
    end;
  end;
end;

procedure TfmxMain.OnPutError(const RequestID, ErrMsg: string);
begin
  lblSendStatusRTDB.Opacity := 1;
  lblSendStatusRTDB.Text := 'Failure in ' + RequestID + ': ' + ErrMsg;
  if SameText(ErrMsg, 'Permission denied') then
    memClipboardText.Lines.Text := 'Check firebase setting'
end;

procedure TfmxMain.OnPutResp(ResourceParams: TRequestResourceParam;
  Val: TJSONValue);
begin
  lblSendStatusRTDB.Opacity := 1;
  lblSendStatusRTDB.Text := 'Clipboard updated';
end;

procedure TfmxMain.OnRecData(const Event: string; Params: TRequestResourceParam;
  JSONObj: TJSONObject);
var
  Path: string;
  Data: TJSONObject;
  lastLine:string;
  Val: TJSONValue;
  senderUID:string;
  senderUsername: string;
  li: Tlistboxitem;
  AMessage:string;
begin
  Assert(assigned(JSONObj), 'JSON object expected');
  Assert(JSONObj.Count = 2, 'Invalid JSON object received');
  Path := JSONObj.Pairs[0].JsonValue.Value;
  if JSONObj.Pairs[1].JsonValue is TJSONObject then
  begin
    inc(fReceivedUpdates);
    Data := JSONObj.Pairs[1].JsonValue as TJSONObject;
    if Data.GetValue('type').Value = 'text' then
    begin
     li := Tlistboxitem.Create(Self);
     lastLine:= RawByteString(Data.GetValue('text').Value);
     senderUID:= RawByteString(Data.GetValue('uid').Value);
     senderUsername:= RawByteString(Data.GetValue('userName').Value);
     li.Text :=senderUsername + ':' + lastLine;
     listbox2.AddObject(li);
    end
    else if
       Data.GetValue('type').Value = 'file' then
    begin
       ObjectName:=RawByteString(Data.getValue('filepath').Value);
       Listbox2.Items.Add(ObjectName.substring(objectName.lastIndexOf('\')));
       edtStoragePath.Text:=ObjectName;
       lblUpload.text:='uploaded';
    end
  else
    lblStatusRTDB.Text := 'Clipboard is empty';
    lblStatusRTDB.Text := Format('New clipboard content #%d at %s',
    [fReceivedUpdates, TimeToStr(now)]);
  end;
end;

procedure TfmxMain.OnRecDataError(const Info, ErrMsg: string);
begin
  inc(fErrorCount);
  lblStatusRTDB.Text := 'Clipboard error: ' + ErrMsg;
end;

procedure TfmxMain.OnRecDataStop(Sender: TObject);
begin
  lblStatusRTDB.Text := Format('Clipboard stopped at %s %d',
  [TimeToStr(now), fReceivedUpdates]);
  fFirebaseEvent := nil;
end;

function TfmxMain.GetStorageFileName: string;
begin
  result := edtStoragePath.Text;
end;

procedure TfmxMain.btnUploadSynchClick(Sender: TObject);
var
  Storage: TFirebaseStorage;
  fs: TFileStream;
  ExtType: string;
  ContentType: TRESTContentType;
  Data: TJSONObject;
begin
  if not CheckSignedIn then
    exit;
  if OpenDialog.Execute then
  begin
  Data := TJSONObject.Create;
    ExtType := LowerCase(ExtractFileExt(OpenDialog.FileName).Substring(1));
    if (ExtType = 'jpg') or (ExtType = 'jpeg') then
      ContentType := TRESTContentType.ctIMAGE_JPEG
    else if ExtType = 'png' then
      ContentType := TRESTContentType.ctIMAGE_PNG
    else if ExtType = 'gif' then
      ContentType := TRESTContentType.ctIMAGE_GIF
    else if ExtType = 'mp4' then
      ContentType := TRESTContentType.ctVIDEO_MP4
    else
      ContentType := TRESTContentType.ctNone;
      ObjectName:= OpenDialog.FileName;
      Storage := TFirebaseStorage.Create(cTOKENS,OnGetAuth);
    try
      fs := TFileStream.Create(OpenDialog.FileName, fmOpenRead);
      try
        edtStoragePath.Text:=OpenDialog.FileName;
        Obj := Storage.UploadSynchronousFromStream(fs,edtStoragePath.Text, ContentType);
        Data.AddPair('type', 'file');
        Data.AddPair('filepath',edtStoragePath.Text );
       if Length(currentSelection)>0 then
       begin
         fConfig.RealTimeDB.Put([currentSelection,fUID], Data, OnPutResp, OnPutError);
       end
       else
         fConfig.RealTimeDB.Put(['Cloudy',fUID], Data, OnPutResp, OnPutError);
         objectFileName:=objectName;
         lblUpload.Text:= 'uploaded';
      finally
        fs.Free;
      end;
    finally
      Storage.Free;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'ServerTab'}
function TfmxMain.CheckAndCreateRealTimeDBClass: boolean;
begin
    if not CheckSignedIn then
    exit(false);
  if not assigned(fRealTimeDB) then
  begin
    fRealTimeDB := TRealTimeDB.Create(cIDPrj, fConfig.Auth);
    fFirebaseEvent := nil;
  end;
  result := true;
end;

function TfmxMain.GetRTDBPath: TStringDynArray;
begin
  if currentSelection.Length>0  then
  begin
       result := SplitString(currentSelection.Replace('\', '/'), '/');
  end
  else
       result:=SplitString('Cloudy'.Replace('\', '/'), '/');
end;

function TfmxMain.GetPathFromResParams(ResParams: TRequestResourceParam): string;
var
  i: integer;
begin
  result := '';
  for i := low(ResParams) to high(ResParams) do
    if i = low(ResParams) then
      result := ResParams[i]
    else
      result := result + '/' + ResParams[i];
end;

procedure TfmxMain.UploadServer;
var
Val: TJSONValue;
begin
 if not CheckAndCreateRealTimeDBClass then
    exit;
 ListView1.items.Clear;
  try
    Val := fRealTimeDB.GetSynchronous(['']);
    try
      ShowRTNode(GetRTDBPath, Val);
    finally
      Val.Free;
    end;
  except
      on e: exception do
      memRTDB.Lines.Add('Get ' + GetPathFromResParams(GetRTDBPath) +
      ' failed: ' + e.Message);
    end;
end;

procedure TfmxMain.ShowRTNode(ResourceParams: TRequestResourceParam; Val: TJSONValue);
var
  Obj: TJSONObject;
  c: integer;
begin
  try
    if Val is TJSONObject then
    begin
      ListView1.BeginUpdate;
      Obj := Val as TJSONObject;
      for c := 0 to Obj.Count - 1 do
      begin
          if Obj.Pairs[c].JsonValue is TJSONString then
          begin
           lItem:= Listview1.Items.Add;

           LItem.Text:=Obj.Pairs[c].JsonString.Value;

          end
          else
           lItem:= Listview1.Items.Add;
           LItem.Text:=Obj.Pairs[c].JsonString.Value;
      end;
    end
    else if not(Val is TJSONNull) then
    else
      memRTDB.Lines.Add(Format('Path %s not found',[GetPathFromResParams(ResourceParams)]));
  except
    on e: exception do
      memRTDB.Lines.Add('Show RT Node failed: ' + e.Message);
  end;
  ListView1.EndUpdate;
end;

procedure TfmxMain.OnItemClick(const Sender: TObject;
const AItem: TListViewItem);
begin
    if not currentSelection.Equals(AItem.Text)then
    begin
     StopListener;
     currentSelection:= Aitem.Text;
     fFirebaseEvent := fConfig.RealTimeDB.ListenForValueEvents([currentSelection],
     OnRecData, OnRecDataStop, OnRecDataError);
     StartListener(currentSelection);
     WipeToTab(TabClipboard);
    end
    else
     WipeToTab(TabClipboard);
end;

procedure TfmxMain.ListBox2DblClick(Sender: TObject);
 var Storage: TFirebaseStorage;
 Stream: TFileStream;
 begin
  if not CheckSignedIn then
   exit;
  if lblUpload.text.Contains('uploaded') then
  begin
    Storage := TFirebaseStorage.Create('chatclientserver-2aad8.appspot.com', OnGetAuth);
    fStorageObject := Storage.GetSynchronous(GetStorageFileName);
    SaveDialog1 := SaveDialog1.Create(self);
    SaveDialog1.FileName := fStorageObject.ObjectName(false);
    if SaveDialog1.Execute then
    begin
      SaveDialog1.InitialDir:= objectFileName;
      try
       Stream := TFileStream.Create(SaveDialog1.FileName, fmCreate);
       fStorageObject.DownloadToStreamSynchronous(Stream);
       lblUpload.Text:=fStorageObject.ObjectName(true) + ' downloaded to ' +
       SaveDialog1.FileName;
       finally
       Stream.Free;
      end;
    end;
  end;
end;

procedure TfmxMain.btnCreaServerClick(Sender: TObject);
begin
    WipeToTab(tabCreaServer);
end;
{$ENDREGION}
{$REGION 'CreaServer'}
procedure TfmxMain.btnUploadServerClick(Sender: TObject);
var
  Data: TJSONObject;
  Val: TJSONValue;
begin
  if not CheckAndCreateRealTimeDBClass then
    exit;
  StopListener;
  currentSelection:= edtNomeServer.Text;
  StartListener(currentSelection);
  WipeToTab(tabClipboard);
end;
{$ENDREGION}
end.
