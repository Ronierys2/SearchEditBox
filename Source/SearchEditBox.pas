{=======================================}
{             RSC SISTEMAS              }
{        SOLUÇÕES TECNOLÓGICAS          }
{         rscsistemas.com.br            }
{          +55 92 4141-2737             }
{      contato@rscsistemas.com.br       }
{                                       }
{ Desenvolvidor por:                    }
{   Roniery Santos Cardoso              }
{     ronierys2@hotmail.com             }
{     +55 92 984391279                  }
{                                       }
{                                       }
{ Versão Original RSC SISTEMAS          }
{ Versão: 1.0.0                         }
{                                       }
{                                       }
{=======================================}

unit SearchEditBox;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.Threading,

  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Dialogs,
  Vcl.ImgList,
  Vcl.DBGrids,
  Vcl.DBCtrls,
  Vcl.WinXCtrls,

  Data.DB,

  Winapi.Windows

  ;

type
  TSearchEditBox = class(TCustomEdit)
  strict private
    class constructor Create;
    class destructor Destroy;
  private
    { Private declarations }

    FrmPesquisa           : TForm;
    FDataLink     : TFieldDataLink;

    DBGridPes : TDBGrid;
    FDataSeparador: char;

    {============ TSearchEditBox ==========}
    procedure OnCreateShowFormPesquisa(Sender: TObject);

    {============ EDIT TSearchEditBox ==========}
    procedure OnKeyDownSearchEditBox(Sender: TObject; var Key: Word; Shift: TShiftState);

    {============ BOTÕES DE AÇÃO DO FORM DE PESQUISA ==========}
    procedure OnBtnOkClick(Sender: TObject);
    procedure OnBtnCancelarClick(Sender: TObject);
    procedure OnFecharTelaSharedClick(Sender: TObject);

    {============ FORM DE PESQUISA ==========}
    procedure onShowFrmShared(Sender: TObject);
    procedure OnKeyDownFrmPesquisa(Sender: TObject; var Key: Word; Shift: TShiftState);

    {============ EDIT DE PESQUISA==========}
    procedure OnKeyDownEditPesquisa(Sender: TObject; var Key: Word; Shift: TShiftState);

    {============ TSearchEditBox ==========}
    procedure SetDataSource(const Value: TDataSource);
    function GetDataSource: TDataSource;
    function GetDataField: string;
    procedure SetDataField(const Value: string);
    procedure SetDataSeparador(const Value: char);
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    { Published declarations }
    property DataField: string read GetDataField write SetDataField;
    property DataSource : TDataSource read GetDataSource write SetDataSource;
    property DataSeparador: char read FDataSeparador write SetDataSeparador;

    property Align;
    property Alignment;
    property Anchors;
    property AutoSelect;
    property AutoSize;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BevelWidth;
    property BiDiMode;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property Ctl3D;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property NumbersOnly;
    property OEMConvert;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Touch;
    property Visible;
    property StyleElements;
//    property OnChange;
//    property OnClick;
    property OnContextPopup;
//    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
//    property OnEnter;
//    property OnExit;
    property OnGesture;
//    property OnKeyDown;
//    property OnKeyPress;
//    property OnKeyUp;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;

  end;




procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Rsc', [TSearchEditBox]);
end;

/// procedure para o redimencionamento automatico do dbgrid
procedure FixDBGridColumnsWidth(const DBGrid: TDBGrid);
var
  i: integer;
  TotWidth: integer;
  VarWidth: integer;
  ResizableColumnCount: integer;
  AColumn: TColumn;
begin
  if not assigned(DBGrid.DataSource) then
    exit;
  if DBGrid.DataSource.DataSet.IsEmpty then
    Exit;
  // largura total de todas as colunas antes de redimensionar
  TotWidth := 0;
  // como dividir qualquer espaço extra na grade
  VarWidth := 0;
  // quantas colunas precisam ser redimensionadas automaticamente
  ResizableColumnCount := 0;
  for i := 0 to -1 + DBGrid.Columns.Count do
  begin
    TotWidth := TotWidth + DBGrid.Columns[i].Width;
    if DBGrid.Columns[i].Field.Tag = 0 then
      Inc(ResizableColumnCount);
  end;
  // adiciona 1px para a linha separadora de coluna
  if dgColLines in DBGrid.Options then
  TotWidth := TotWidth + DBGrid.Columns.Count;
  // adiciona a largura da coluna do indicador
  if dgIndicator in DBGrid.Options then
  TotWidth := TotWidth + IndicatorWidth;
  // largura vale "esquerda"
  VarWidth := DBGrid.ClientWidth - TotWidth;
  // Distribui VarWidth
  // igualmente para todas as colunas auto-redimensionáveis
  if ResizableColumnCount > 0 then
  VarWidth := VarWidth div ResizableColumnCount;

  TTask.Run(
  procedure
  begin
    TThread.Queue(TThread.CurrentThread, procedure
    var
      i: integer;
    begin
      for i := 0 to -1 + DBGrid.Columns.Count do
      begin
        AColumn := DBGrid.Columns[i];
        if AColumn.Field.Tag = 0 then
        begin
          AColumn.Width := AColumn.Width + VarWidth;
          if AColumn.Width = 0 then
            AColumn.Width := AColumn.Field.Tag;
        end;
      end;
    end);
  end);
end;



{ TSharedEdit }

constructor TSearchEditBox.Create(AOwner: TComponent);
begin
  inherited;

  DataSeparador :=  ',';

  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  try
    OnClick   :=  OnCreateShowFormPesquisa;
    OnKeyDown :=  OnKeyDownSearchEditBox;
  Except on E: Exception do
    begin
      ShowMessage(e.Message);
    end;
  end;
end;


class constructor TSearchEditBox.Create;
begin
  TCustomStyleEngine.RegisterStyleHook(TSearchEditBox, TEditStyleHook);
end;

destructor TSearchEditBox.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;

  inherited;
end;


class destructor TSearchEditBox.Destroy;
begin
  TCustomStyleEngine.UnRegisterStyleHook(TSearchEditBox, TEditStyleHook);
end;

function TSearchEditBox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TSearchEditBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TSearchEditBox.OnBtnCancelarClick(Sender: TObject);
begin
  DataSource.DataSet.Filtered := False;
  FrmPesquisa.Close;
end;

procedure TSearchEditBox.OnBtnOkClick(Sender: TObject);
var
  Selecionado:  string;
  I:  integer;
begin
  Selecionado :=  EmptyStr;

  if DBGridPes.SelectedRows.Count > 0 then
    begin
      for I := 0 to DBGridPes.SelectedRows.Count - 1 do
        begin
          TDataSource(DBGridPes.DataSource).DataSet.GotoBookmark(DBGridPes.SelectedRows.Items[I]);
          Selecionado :=  Selecionado + TDataSource(DBGridPes.DataSource).DataSet.FieldByName(FDataLink.Field.FieldName).AsString + FDataSeparador;
        end;
    end
  else
    begin
      Selecionado :=  Selecionado + TDataSource(DBGridPes.DataSource).DataSet.FieldByName(FDataLink.Field.FieldName).AsString + FDataSeparador;
    end;


  Self.Text :=  Copy(Selecionado, 1, length(Selecionado) - 1);

  FrmPesquisa.Close;
end;

procedure TSearchEditBox.OnCreateShowFormPesquisa(Sender: TObject);
var
  pnlButtom   : TPanel;
  pnlTop      : TPanel;
  pnlClient   : TPanel;
  btnCancelar : TButton;
  btnOk       : TButton;
  EdtPesquisa : TEdit;
  MyClass: TComponent;
begin
  if not Assigned(DataSource) then
    Exit;

  if Assigned(FrmPesquisa) then
    begin
      FrmPesquisa.ShowModal;
      Exit
    end;

  {$Region 'Form de pesquisa'}
  Application.CreateForm(TForm, FrmPesquisa);
  FrmPesquisa.Name        :=  'RscFrmPesquisa'  + IntToStr(Random(9999));
  FrmPesquisa.Height      :=  250;
  FrmPesquisa.Width       :=  400;
  FrmPesquisa.BorderStyle :=  TFormBorderStyle.bsNone;
  FrmPesquisa.KeyPreview  :=  True;
  FrmPesquisa.OnShow      :=  onShowFrmshared;
  FrmPesquisa.OnKeyDown   :=  OnKeyDownFrmPesquisa;
  FrmPesquisa.Color       :=  clWhite;  //  clGrayText;
  {$EndRegion}

  {$Region 'Panel Buttom Botões de ação'}
  pnlButtom                   :=  TPanel.Create(FrmPesquisa);
  pnlButtom.Name              :=  'pnlButtom' + IntToStr(Random(9999));
  pnlButtom.Caption           :=  EmptyStr;
  pnlButtom.Parent            :=  FrmPesquisa;
  pnlButtom.ParentBackground  :=  False;
  pnlButtom.ParentColor       :=  False;
  pnlButtom.BevelOuter        :=  TBevelCut.bvNone;
  pnlButtom.Color             :=  clHotLight;
  pnlButtom.Align             :=  TAlign.alBottom;
  pnlButtom.Height            :=  40;
  {$EndRegion}

  {$Region 'Panel Top Pesquisa'}
  pnlTop                   :=  TPanel.Create(FrmPesquisa);
  pnlTop.Name              :=  'pnlTop' + IntToStr(Random(9999));
  pnlTop.Caption           :=  EmptyStr;
  pnlTop.Parent            :=  FrmPesquisa;
  pnlTop.ParentBackground  :=  False;
  pnlTop.ParentColor       :=  False;
  pnlTop.BevelOuter        :=  TBevelCut.bvNone;
  pnlTop.Color             :=  clHotLight;
  pnlTop.Align             :=  TAlign.alTop;
  pnlTop.Height            :=  50;
//  pnlTop.AlignWithMargins  :=  True;
//  pnlTop.Margins.SetBounds(0, 0, 0, 0);
  {$EndRegion}

  {$Region 'Panel Client Tools'}
  pnlClient                   :=  TPanel.Create(FrmPesquisa);
  pnlClient.Name              :=  'pnlClient' + IntToStr(Random(9999));
  pnlClient.Caption           :=  EmptyStr;
  pnlClient.Parent            :=  FrmPesquisa;
  pnlClient.ParentBackground  :=  False;
  pnlClient.ParentColor       :=  False;
  pnlClient.BevelOuter        :=  TBevelCut.bvNone;
  pnlClient.Color             :=  $00FF9615;
  pnlClient.Align             :=  TAlign.alClient;
  pnlClient.AlignWithMargins  :=  True;
  pnlClient.Margins.SetBounds(10, 5, 10, 5);
  {$EndRegion}

  {$Region 'DBGrid'}
  DBGridPes             :=  TDBGrid.Create(FrmPesquisa);
  DBGridPes.Name        :=  'DBGridPes' + IntToStr(Random(9999));
  DBGridPes.Parent      :=  pnlClient;
  DBGridPes.Align       :=  alClient;
  DBGridPes.BorderStyle :=  bsNone;
  DBGridPes.DataSource  :=  DataSource;
  DBGridPes.Options     :=  DBGridPes.Options + [ dgTitles, dgIndicator, dgColumnResize, dgColLines,
                                                  dgRowLines, dgTabs, dgRowSelect, dgCancelOnExit,
                                                  dgMultiSelect, dgTitleClick, dgTitleHotTrack];
  {$EndRegion}

  {$Region 'Botão Ok'}
  btnOk                   :=  TButton.Create(FrmPesquisa);
  btnOk.Name              :=  'btnOk' + IntToStr(Random(9999));
  btnOk.Parent            :=  pnlButtom;
  btnOk.Width             :=  80;
  btnOk.Align             :=  TAlign.alLeft;
  btnOk.Caption           :=  'Ok';
  btnOk.OnClick           :=  OnBtnOkClick;
  btnOk.AlignWithMargins  :=  True;
  btnOk.Margins.SetBounds(10, 3, 0, 3);
  {$EndRegion}

  {$Region 'Botão Cancelar'}
  btnCancelar                   :=  TButton.Create(FrmPesquisa);
  btnCancelar.Name              :=  'btnCancelar' + IntToStr(Random(9999));
  btnCancelar.Parent            :=  pnlButtom;
  btnCancelar.Width             :=  80;
  btnCancelar.Align             :=  TAlign.alRight;
  btnCancelar.AlignWithMargins  :=  True;
  btnCancelar.Caption           :=  'Fechar';
  btnCancelar.OnClick           :=  OnBtnCancelarClick;
  btnCancelar.Margins.SetBounds(0, 3, 10, 3);
  {$EndRegion}

  {$Region 'Edit Pesquisa'}
  EdtPesquisa                   :=  TEdit.Create(FrmPesquisa);
  EdtPesquisa.Name              :=  'EdtPesquisa' + IntToStr(Random(9999));
  EdtPesquisa.Parent            :=  pnlTop;
  EdtPesquisa.Width             :=  80;
  EdtPesquisa.Align             :=  TAlign.alClient;
  EdtPesquisa.Text              :=  EmptyStr;
  EdtPesquisa.Font.Size         :=  12;
  EdtPesquisa.Font.Color        :=  clHotLight;
  EdtPesquisa.AlignWithMargins  :=  True;
  EdtPesquisa.OnKeyUp           :=  OnKeyDownEditPesquisa;
  EdtPesquisa.BorderStyle       :=  bsNone;
  EdtPesquisa.CharCase          :=  ecUpperCase;
  EdtPesquisa.Margins.SetBounds(10, 10, 10, 10);


  EdtPesquisa.TextHint := 'Digite aqui para filtrar por:  ' + FDataLink.Field.DisplayLabel;
  EdtPesquisa.Clear;
  {$EndRegion}


  try
    FrmPesquisa.ShowModal;
  finally
    FreeAndNil(FrmPesquisa);
  end;

end;

procedure TSearchEditBox.OnFecharTelaSharedClick(Sender: TObject);
begin

end;

procedure TSearchEditBox.OnKeyDownEditPesquisa(Sender: TObject; var Key: Word; Shift: TShiftState);  //(Sender: TObject; var Key: Char);
var
  Filter: String;
begin
  if Key = VK_ESCAPE then
    OnBtnCancelarClick(Sender)
  else
    if Key = VK_RETURN then
      OnBtnOkClick(Sender)
    else
      begin
        if TEdit(Sender).Text <>  EmptyStr then
          begin
            if Assigned(FDataLink.Field)  and (not FDataLink.Field.DataSet.Fields[0].IsNull ) then
              begin
                if FDataLink.Field.FieldKind = fkData then
                begin
                  case FDataLink.Field.DataType of
                    ftUnknown:;
                    ftBoolean:;

                    ftString, ftFixedChar,
                    ftWideString, ftFixedWideChar,
                    ftWideMemo,ftMemo:  Filter := 'Upper('  + FDataLink.Field.FieldName + ') like ' + AnsiUpperCase(QuotedStr('%' + Trim(TEdit(Sender).Text) + '%'));

                    ftSmallint, ftInteger,
                    ftWord, ftLargeint,
                    ftLongWord, ftShortint,
                    ftBytes, ftByte:  Filter := FDataLink.Field.FieldName + ' = ' + TEdit(Sender).Text;

                    ftFloat, ftCurrency, ftBCD,
                    ftFMTBcd, ftExtended, ftSingle: Filter := 'Upper('  + FDataLink.Field.FieldName + ') = ' + QuotedStr(UpperCase(Trim(TEdit(Sender).Text)));

                    ftDate, ftTime, ftDateTime: Filter := 'Upper('  + FDataLink.Field.FieldName + ') = ' + QuotedStr(UpperCase(Trim(TEdit(Sender).Text)));
                  end;

                  try
                    DataSource.DataSet.Filtered := False;
                    DataSource.DataSet.Filter   := Filter;
                    DataSource.DataSet.Filtered := true;
                  except on E: Exception do
                  end;
                end;
              end;
          end
        else
          begin
            DataSource.DataSet.Filtered := False;
          end;
      end;
end;

procedure TSearchEditBox.OnKeyDownFrmPesquisa(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OnBtnOkClick(Sender)
  else
    if Key = VK_ESCAPE then
      OnBtnCancelarClick(Sender);
end;

procedure TSearchEditBox.OnKeyDownSearchEditBox(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    OnCreateShowFormPesquisa(Sender);
end;

procedure TSearchEditBox.onShowFrmshared(Sender: TObject);
var
  pRect:  TRect;
begin
  GetWindowRect(TWinControl(Self).Handle, pRect);

  if (pRect.Left + FrmPesquisa.Width) > (Screen.ActiveForm.Width) then
    begin
      FrmPesquisa.Left  :=  (pRect.Left - (FrmPesquisa.Width - Self.Width));
    end
  else
    begin
      FrmPesquisa.Left  :=  pRect.Left;
    end;

  FrmPesquisa.Top   :=  pRect.Top  + Self.Height + 3;

  FixDBGridColumnsWidth(DBGridPes);

end;

procedure TSearchEditBox.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

procedure TSearchEditBox.SetDataSeparador(const Value: char);
begin
  FDataSeparador := Value;
end;

procedure TSearchEditBox.SetDataSource(const Value: TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
    FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;



end.
