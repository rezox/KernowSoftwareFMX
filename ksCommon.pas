unit ksCommon;


interface

uses FMX.Controls, FMX.Graphics, System.UITypes, FMX.Types, Types, System.UIConsts, ksTypes;

{$I ksComponents.inc}

  function GetScreenScale: single;
  procedure ProcessMessages;

  procedure ReplaceOpaqueColor(ABmp: TBitmap; Color : TAlphaColor);
  function GetColorOrDefault(AColor, ADefaultIfNull: TAlphaColor): TAlphaColor;

  procedure SimulateClick(AControl: TControl; x, y: single);


  function IsBlankBitmap(ABmp: TBitmap; const ABlankColor: TAlphaColor = claNull): Boolean;

  procedure DrawAccessory(ACanvas: TCanvas; ARect: TRectF; AAccessory: TksAccessoryType;
    AStroke, AFill: TAlphaColor);

  function GetTextSizeHtml(AText: string; AFont: TFont;
    const AWidth: single = 0): TPointF;

  function CalculateTextWidth(AText: string; AFont: TFont; AWordWrap: Boolean;
    const AMaxWidth: single = 0; const APadding: single = 0): single;

  function CalculateTextHeight(AText: string; AFont: TFont; AWordWrap: Boolean; ATrimming: TTextTrimming;
    const AWidth: single = 0; const APadding: single = 0): single;

  procedure RenderText(ACanvas: TCanvas; x, y, AWidth, AHeight: single;
    AText: string; AFont: TFont; ATextColor: TAlphaColor; AWordWrap: Boolean;
    AHorzAlign: TTextAlign; AVertAlign: TTextAlign; ATrimming: TTextTrimming;
    const APadding: single = 0); overload;

  procedure RenderText(ACanvas: TCanvas; ARect: TRectF;
    AText: string; AFont: TFont; ATextColor: TAlphaColor; AWordWrap: Boolean;
    AHorzAlign: TTextAlign; AVertAlign: TTextAlign; ATrimming: TTextTrimming;
    const APadding: single = 0); overload;

  procedure RenderHhmlText(ACanvas: TCanvas; x, y, AWidth, AHeight: single;
    AText: string; AFont: TFont; ATextColor: TAlphaColor; AWordWrap: Boolean;
    AHorzAlign: TTextAlign; AVertAlign: TTextAlign; ATrimming: TTextTrimming);

  function GenerateBadge(AValue: integer; AColor, ABackgroundColor, ATextColor: TAlphaColor): TBitmap;

implementation

uses FMX.Platform, FMX.Forms,  SysUtils, FMX.TextLayout, Math, FMX.Utils
  {$IFDEF USE_TMS_HTML_ENGINE} , FMX.TMSHTMLEngine {$ENDIF}
  ;

var
  AScreenScale: single;
  ATextLayout: TTextLayout;


function GetScreenScale: single;
var
  Service: IFMXScreenService;
begin
  if AScreenScale > 0 then
  begin
    Result := AScreenScale;
    Exit;
  end;
  Service := IFMXScreenService(TPlatformServices.Current.GetPlatformService
    (IFMXScreenService));
  Result := Trunc(Service.GetScreenScale);
  {$IFDEF IOS}
  if Result < 2 then
   Result := 2;
  {$ENDIF}
  if Result > 3 then
    Result := 3;
  AScreenScale := Result;
end;


procedure ProcessMessages;
begin
  // FMX can occasionally raise an exception.
  try
    Application.ProcessMessages;
  except
    //
  end;
end;
function GetColorOrDefault(AColor, ADefaultIfNull: TAlphaColor): TAlphaColor;
begin
  Result := AColor;
  if Result = claNull then
    Result := ADefaultIfNull;
end;

function IsBlankBitmap(ABmp: TBitmap; const ABlankColor: TAlphaColor = claNull): Boolean;
var
  ABlank: TBitmap;
begin
  ABlank := TBitmap.Create(ABmp.Width, ABmp.Height);
  try
    ABlank.Clear(ABlankColor);
    Result := ABmp.EqualsBitmap(ABlank);
  finally
    FreeAndNil(ABlank);
  end;
end;

procedure RenderText(ACanvas: TCanvas; x, y, AWidth, AHeight: single;
  AText: string; AFont: TFont; ATextColor: TAlphaColor; AWordWrap: Boolean;
  AHorzAlign: TTextAlign; AVertAlign: TTextAlign; ATrimming: TTextTrimming;
  const APadding: single = 0); overload;
begin
  if AText = '' then
    Exit;
  ATextLayout.BeginUpdate;
  ATextLayout.Text := AText;
  ATextLayout.WordWrap := AWordWrap;
  ATextLayout.Font.Assign(AFont);
  ATextLayout.Color := ATextColor;
  ATextLayout.HorizontalAlign := AHorzAlign;
  ATextLayout.VerticalAlign := AVertAlign;
  ATextLayout.Padding.Rect := RectF(APadding, APadding, APadding, APadding);
  ATextLayout.Trimming := ATrimming;
  if AWordWrap  then
    ATextLayout.Trimming := TTextTrimming.None;
  ATextLayout.TopLeft := PointF(x, y);
  ATextLayout.MaxSize := PointF(AWidth, AHeight);
  ATextLayout.EndUpdate;
  ATextLayout.RenderLayout(ACanvas);
end;

procedure RenderText(ACanvas: TCanvas; ARect: TRectF;
  AText: string; AFont: TFont; ATextColor: TAlphaColor; AWordWrap: Boolean;
  AHorzAlign: TTextAlign; AVertAlign: TTextAlign; ATrimming: TTextTrimming;
  const APadding: single = 0); overload;
begin
  RenderText(ACanvas, ARect.Left, ARect.Top, ARect.Width, ARect.Height, AText, AFont, ATextColor, AWordWrap, AHorzAlign, AVertAlign, ATrimming, APadding);
end;

function GetTextSizeHtml(AText: string; AFont: TFont;
  const AWidth: single = 0): TPointF;
{$IFDEF USE_TMS_HTML_ENGINE}
var
  AnchorVal, StripVal, FocusAnchor: string;
  XSize, YSize: single;
  HyperLinks, MouseLink: integer;
  HoverRect: TRectF;
  ABmp: TBitmap;
{$ENDIF}
begin
  Result := PointF(0, 0);
{$IFDEF USE_TMS_HTML_ENGINE}
  XSize := AWidth;

  if XSize <= 0 then
    XSize := MaxSingle;

  ABmp := TBitmap.Create(10, 10);
  try
    ABmp.BitmapScale := GetScreenScale;
    ABmp.Canvas.Assign(AFont);
{$IFDEF USE_TMS_HTML_ENGINE}
    HTMLDrawEx(ABmp.Canvas, AText, RectF(0, 0, XSize, MaxSingle), 0, 0, 0, 0, 0,
      False, False, False, False, False, False, False, 1, claNull, claNull,
      claNull, claNull, AnchorVal, StripVal, FocusAnchor, XSize, YSize,
      HyperLinks, MouseLink, HoverRect, 1, nil, 1);
    Result := PointF(XSize, YSize);
{$ELSE}
    Result := PointF(0, 0);
{$ENDIF}
  finally
    FreeAndNil(ABmp);
  end;
{$ENDIF}
end;

function CalculateTextWidth(AText: string; AFont: TFont; AWordWrap: Boolean;
  const AMaxWidth: single = 0; const APadding: single = 0): single;
var
  APoint: TPointF;
begin
  ATextLayout.BeginUpdate;
  // Setting the layout MaxSize
  if AMaxWidth > 0 then
    APoint.X := AMaxWidth
  else
    APoint.x := MaxSingle;
  APoint.y := 100;
  ATextLayout.MaxSize := APoint;
  ATextLayout.Text := AText;
  ATextLayout.WordWrap := AWordWrap;
  ATextLayout.Padding.Rect := RectF(APadding, APadding, APadding, APadding);
  ATextLayout.Font.Assign(AFont);
  ATextLayout.HorizontalAlign := TTextAlign.Leading;
  ATextLayout.VerticalAlign := TTextAlign.Leading;
  ATextLayout.EndUpdate;
  //ATextLayout.RenderLayout(ATextLayout.LayoutCanvas);
  Result := ATextLayout.Width;
end;

function CalculateTextHeight(AText: string; AFont: TFont; AWordWrap: Boolean; ATrimming: TTextTrimming;
  const AWidth: single = 0; const APadding: single = 0): single;
var
  APoint: TPointF;
begin
  Result := 0;
  if AText = '' then
    Exit;
  ATextLayout.BeginUpdate;
  // Setting the layout MaxSize
  APoint.x := MaxSingle;
  if AWidth > 0 then
    APoint.x := AWidth;
  APoint.y := MaxSingle;
  ATextLayout.Font.Assign(AFont);
  ATextLayout.MaxSize := APoint;
  ATextLayout.Text := AText;
  ATextLayout.WordWrap := AWordWrap;
  ATextLayout.Padding.Rect := RectF(APadding, APadding, APadding, APadding);
  ATextLayout.HorizontalAlign := TTextAlign.Leading;
  ATextLayout.VerticalAlign := TTextAlign.Leading;
  ATextLayout.EndUpdate;
  Result := ATextLayout.TextHeight;
end;

procedure RenderHhmlText(ACanvas: TCanvas; x, y, AWidth, AHeight: single;
  AText: string; AFont: TFont; ATextColor: TAlphaColor; AWordWrap: Boolean;
  AHorzAlign: TTextAlign; AVertAlign: TTextAlign; ATrimming: TTextTrimming);
{$IFDEF USE_TMS_HTML_ENGINE}
var
  AnchorVal, StripVal, FocusAnchor: string;
  XSize, YSize: single;
  HyperLinks, MouseLink: integer;
  HoverRect: TRectF;
{$ENDIF}
begin
{$IFDEF USE_TMS_HTML_ENGINE}
  ACanvas.Fill.Color := ATextColor;
  ACanvas.Font.Assign(AFont);
  HTMLDrawEx(ACanvas, AText, RectF(x, y, x + AWidth, y + AHeight), 0, 0, 0, 0,
    0, False, False, True, False, False, False, AWordWrap, 1, claNull, claNull,
    claNull, claNull, AnchorVal, StripVal, FocusAnchor, XSize, YSize,
    HyperLinks, MouseLink, HoverRect, 1, nil, 1);
{$ELSE}
  AFont.Size := 10;
  RenderText(ACanvas, x, y, AWidth, AHeight, 'Requires TMS FMX', AFont,
    ATextColor, AWordWrap, AHorzAlign, AVertAlign, ATrimming);
{$ENDIF}
end;

procedure DrawAccessory(ACanvas: TCanvas; ARect: TRectF; AAccessory: TksAccessoryType;
  AStroke, AFill: TAlphaColor);
var
  AState: TCanvasSaveState;
begin
  AState := ACanvas.SaveState;
  try
    ACanvas.IntersectClipRect(ARect);
    ACanvas.Fill.Color := AFill;
    ACanvas.Fill.Kind := TBrushKind.Solid;
    ACanvas.FillRect(ARect, 0, 0, AllCorners, 1);
    AccessoryImages.GetAccessoryImage(AAccessory).DrawToCanvas(ACanvas, ARect, False);
    ACanvas.Stroke.Color := AStroke;
    ACanvas.DrawRect(ARect, 0, 0, AllCorners, 1);
  finally
    ACanvas.RestoreState(AState);
  end;
end;

procedure ReplaceOpaqueColor(ABmp: TBitmap; Color : TAlphaColor);
var
  x,y: Integer;
  AMap: TBitmapData;
  PixelColor: TAlphaColor;
  PixelWhiteColor: TAlphaColor;
  C: PAlphaColorRec;
begin
  if ABmp.Map(TMapAccess.ReadWrite, AMap) then
  try
    AlphaColorToPixel(Color   , @PixelColor, AMap.PixelFormat);
    AlphaColorToPixel(claWhite, @PixelWhiteColor, AMap.PixelFormat);
    for y := 0 to ABmp.Height - 1 do
    begin
      for x := 0 to ABmp.Width - 1 do
      begin
        C := @PAlphaColorArray(AMap.Data)[y * (AMap.Pitch div 4) + x];
        if (C^.Color<>claWhite) and (C^.A>0) then
          C^.Color := PremultiplyAlpha(MakeColor(PixelColor, C^.A / $FF));
      end;
    end;
  finally
    ABmp.Unmap(AMap);
  end;
end;

procedure SimulateClick(AControl: TControl; x, y: single);
var
  AForm     : TCommonCustomForm;
  AFormPoint: TPointF;
begin
  AForm := nil;
  if (AControl.Root is TCustomForm) then
    AForm := (AControl.Root as TCustomForm);
  if AForm <> nil then
  begin
    AFormPoint := AControl.LocalToAbsolute(PointF(X,Y));
    AForm.MouseDown(TMouseButton.mbLeft, [], AFormPoint.X, AFormPoint.Y);
    AForm.MouseUp(TMouseButton.mbLeft, [], AFormPoint.X, AFormPoint.Y);
  end;
end;

function GenerateBadge(AValue: integer; AColor, ABackgroundColor, ATextColor: TAlphaColor): TBitmap;
var
  ABadgeScale: single;
begin
  {$IFNDEF MSWINDOWS}
  ABadgeScale := (GetScreenScale * 2);
  {$ELSE}
   ABadgeScale := (GetScreenScale * 1);
  {$ENDIF}
  Result := TBitmap.Create(Round(12 * ABadgeScale), Round(12 * ABadgeScale));
  Result.Clear(claNull);
  Result.Canvas.BeginScene;
  Result.Canvas.Fill.Color := AColor;
  Result.Canvas.FillEllipse(RectF(0, 0, Result.Width, Result.Height), 1);
  Result.Canvas.Stroke.Color := ABackgroundColor;
  Result.Canvas.StrokeThickness := 1*ABadgeScale;
  Result.Canvas.DrawEllipse(RectF(1, 1, Result.Width-1, Result.Height-1), 1);
  Result.Canvas.Fill.Color := ATextColor;
  Result.Canvas.Font.Size := 9*ABadgeScale;
  Result.Canvas.FillText(RectF(0, 0, Result.Width, Result.Height), IntToStr(AValue), False, 1, [], TTextAlign.Center);
  Result.Canvas.EndScene;
end;

initialization

  AScreenScale := 0;
  ATextLayout := TTextLayoutManager.DefaultTextLayout.Create;

finalization

  FreeAndNil(ATextLayout);


end.

