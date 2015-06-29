unit untMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, ksSlideMenu, FMX.Layouts, FMX.Objects,
  FMX.TabControl, FMX.ListBox;

type
  TForm6 = class(TForm)
    ToolBar1: TToolBar;
    btnLeftMenu: TButton;
    btnRightMenu: TButton;
    Label1: TLabel;
    imgHome: TImage;
    imgSearch: TImage;
    imgCalendar: TImage;
    imgMenu: TImage;
    imgContact: TImage;
    layoutImages: TLayout;
    SlideMenu1: TksSlideMenu;
    SlideMenu2: TksSlideMenu;
    imgAbout: TImage;
    TabControl1: TTabControl;
    tabAbout: TTabItem;
    tabReserve: TTabItem;
    tabMyBookings: TTabItem;
    tabMenu: TTabItem;
    tabContact: TTabItem;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnRightMenuClick(Sender: TObject);
    procedure btnLeftMenuClick(Sender: TObject);
    procedure SlideMenu1SelectMenuItemEvent(Sender: TObject; AId: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.fmx}

procedure TForm6.btnLeftMenuClick(Sender: TObject);
begin
  SlideMenu1.ToggleMenu;
end;

procedure TForm6.btnRightMenuClick(Sender: TObject);
begin
  SlideMenu2.ToggleMenu;
end;

procedure TForm6.FormCreate(Sender: TObject);
begin
  TabControl1.TabPosition := TTabPosition.None;

  SlideMenu1.AddMenuItem('ABOUT', 'About Us', imgHome.Bitmap);
  SlideMenu1.AddMenuItem('RESERVE', 'Make a Booking', imgSearch.Bitmap);
  SlideMenu1.AddMenuItem('MY BOOKINGS', 'My Bookings', imgCalendar.Bitmap);
  SlideMenu1.AddMenuItem('MENU', 'View Menus', imgMenu.Bitmap);
  SlideMenu1.AddMenuItem('CONTACT', 'Contact Us', imgContact.Bitmap);
  SlideMenu1.ItemIndex := 0;

  SlideMenu2.AddMenuItem('ANOTHER', 'Another Menu', imgHome.Bitmap);
  SlideMenu2.AddMenuItem('ABOUT', 'About', imgSearch.Bitmap);

  SlideMenu2.ItemIndex := 0;
  layoutImages.Visible := False;
end;

procedure TForm6.SlideMenu1SelectMenuItemEvent(Sender: TObject; AId: string);
begin
  if AId = 'ABOUT' then TabControl1.ActiveTab := tabAbout;
  if AId = 'RESERVE' then TabControl1.ActiveTab := tabReserve;
  if AId = 'MY BOOKINGS' then TabControl1.ActiveTab := tabMyBookings;
  if AId = 'MENU' then TabControl1.ActiveTab := tabMenu;
  if AId = 'CONTACT' then TabControl1.ActiveTab := tabContact;

end;

end.