unit uFrmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Data.DB, Vcl.Grids, Vcl.DBGrids,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, Vcl.DBCtrls,
  Vcl.Imaging.pngimage, Vcl.WinXCtrls, SearchEditBox;



type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    DataSource1: TDataSource;
    FDMemTable1: TFDMemTable;
    FDMemTable1id: TIntegerField;
    FDMemTable1nome: TStringField;
    FDMemTable1descri: TStringField;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    SearchEditBox1: TSearchEditBox;
    Edit1: TEdit;
    DBGrid1: TDBGrid;

    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  TConsoantes:  array of char = [ 'B', 'C', 'D', 'F',
                                  'G', 'H', 'J', 'L', 'M',
                                  'N', 'P', 'Q', 'R', 'S',
                                  'T', 'V', 'X', 'Z', 'W', 'Y', 'K'];

  TVogais:    array of  char  = ['A', 'E', 'I', 'O', 'U'];


implementation

{$R *.dfm}

function GetNewName: string;
var
  TamNome, t : integer;
  Indice  : integer;
  I       : Integer;
  NewName : string;
begin
  NewName :=  EmptyStr;
  Result  :=  EmptyStr;

  Randomize;
  repeat
    TamNome :=  Random(10);
  until (TamNome > 3);

  for I := Pred(TamNome) DownTo  1 do
    begin
      If Odd(i) then //impar
        begin
          indice := Random(length(TConsoantes));
          NewName  :=  NewName  +  TConsoantes[indice];
        end
      else
        begin
          indice := Random(length(TVogais));
          NewName  :=  NewName  +  TVogais[indice];
        end;
    end;

  if NewName = EmptyStr then
    NewName :=  GetNewName;

  Result  :=  NewName;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  FDMemTable1.Open;
  for I := 1 to 30 do
    begin
      FDMemTable1.Append;
      FDMemTable1id.Value :=  I;
      FDMemTable1nome.Value :=  GetNewName;
      FDMemTable1descri.Value :=  GetNewName;
      FDMemTable1.Post;
    end;
  FDMemTable1.Open;
  FDMemTable1.First;
end;

end.
