program FirebaseInDelphi;

uses
  System.StartUpCopy,
  FMX.Forms,
  MainFmx in 'MainFmx.pas' {fmxMain},
  FB4D.SelfRegistrationFra in 'GUIPatterns\FB4D.SelfRegistrationFra.pas' {FraSelfRegistration: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfmxMain, fmxMain);
  Application.Run;
end.
