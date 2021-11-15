program EditDePesquisa;



uses
  Vcl.Forms,
  uFrmMain in 'uFrmMain.pas' {Form1};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown :=  True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
