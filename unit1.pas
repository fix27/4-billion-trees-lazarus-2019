unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,

  gl, glu, glut;
type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }


const
  AppWidth = 640;
  AppHeight = 480;

var
  objectXRot: Single = 0;
  objectYRot: Single = 0;
  objectZRot: Single = 0;
type
  Trnd = object
         constructor Create;
         function get:single;
         procedure resettop;
         procedure reset;
         destructor Destroy;
        private
         m:array [1..20000] of GLfloat;
         top:Word;
        end;
var
    Angle : Single;
    AutoAn: boolean;
    Pole:boolean;
      ScreenWidth, ScreenHeight: Integer;

constructor Trnd.Create;
var
 i:word;
begin
 randomize;
 for i:=1 to 20000 do m[i]:=random;
 top:=20000;
end;
function Trnd.get:single;
begin
 get:=m[top];
 if top>1 then top:=top-1
          else top:=20000;
end;
procedure Trnd.reset;
var
 i:word;
begin
 randomize;
 for i:=1 to 20000 do m[i]:=random;
 top:=20000;
end;

procedure Trnd.resettop;
begin
 top:=20000;
end;
destructor Trnd.Destroy;
begin
 top:=0;
end;
var
 rnd:Trnd;
procedure Branches(x,y,z,d,angleZ,angleX:GLfloat);
const
 maxx=7;
 dl=1;
var
 i:word;
 cx,cy:GLdouble;
 a:GLfloat;
 maxd:byte;
begin
  glPushMatrix;
  glTranslatef(x,y,z);
  glRotatef(AngleZ,0,0,1);
  glRotatef(AngleX,1,0,0);

  glBegin(GL_TRIANGLE_FAN); // draw a tetrahedron
  glColor3d(0.8,0.6,0.3);
{    glColor3f(0.8,0.8,0.81);}
  glVertex3f(0,0,d);
  glColor3f(0.6,0.5,0.2);
  for i:=0 to maxx do
   begin
    cx:=0.025*d*cos((2*pi/maxx)*i);
    cy:=0.025*d*sin((2*pi/maxx)*i);
{    glColor3f(0.8,0.8,0.81);}
    glVertex3d(cx,cy,0);
   end;
  glEnd;                    // finish triangle fan
  maxd:=5+round(7*rnd.get-0.5);
  if d>maxd then
  for i:=0 to 6+round(rnd.get*4) do
   begin
    a:=0.25+rnd.get*0.70;
    Branches(0,0,d*a,d*(1-a),360*rnd.get,25+20*rnd.get);
   end
  else
  for i:=0 to 7+round(rnd.get*7) do
   begin
    a:=0.3+rnd.get*0.7;
    glPushMatrix;
    glTranslatef(0,0,d*a);
    glRotatef(360*rnd.get,0,0,1);
    glRotatef(180*rnd.get,0,1,0);
    glRotatef(50+30*rnd.get,1,0,0);
    glBegin(GL_POLYGON);
    {  if rnd.get<0.5 then glColor3f(0.8,0.4,0.4)
                     else glColor3f(1,1,0.4);}
    glColor3f(0.3,0.7,0.2);
    glVertex3f(0,0,0);
    glVertex3f(0,-dl/3,dl/3);
    glVertex3f(0,0,dl);
    glVertex3f(0,dl/3,dl/3);
    glEnd;
    glpopmatrix;
   end;
  glPopMatrix;
end;
procedure lightinitr;
const
  Ambient : Array[0..3] of GLfloat = (0.9, 1, 0.9, 1);
  dif: Array[0..3] of GLfloat = (0.2, 0.2, 0.2, 1);
  em: Array[0..3] of GLfloat = (0, 0, 0, 1);
  spec: Array[0..3] of GLfloat = (0, 0, 0, 0);
  specl: Array[0..3] of GLfloat = (0, 0, 0, 0);

  pos:array[0..3]of glFloat=(10,30,30,1);
  dir:array[0..2]of glFloat=(-1,-1,-1);
var
   c_o:single;
   c:integer;
   s_e:glFloat;

begin
     s_e:=5;
     c_o:=90;
     c:=1;
     glEnable(gl_color_material);
     glLightModelFV(gl_light_model_local_viewer,@c);
     glLightFV(gl_light1,gl_spot_cutoff,@c_o);
     glLightFV(gl_light1,gl_position,@pos);
     glLightFV(gl_light1,gl_spot_direction,@dir);
     glLightFV(gl_light1,gl_ambient,@ambient);
     glLightFV(gl_light1,gl_specular,@specl);
     glLightFV(gl_light1,gl_spot_exponent,@s_e);

    glMaterialfv(GL_FRONT_and_back, GL_AMBIENT, @ambient);
    glMaterialfv(GL_FRONT_and_back, GL_DIFFUSE, @dif);
    glMaterialfv(GL_FRONT_and_back, GL_SPECULAR, @spec);
    glMaterialfv(GL_FRONT_and_back, GL_emission, @em);

end;


procedure InitializeGL;
const
  DiffuseLight: array[0..3] of GLfloat = (0.8, 0.8, 0.8, 1);
begin
//  glClearColor(0.18, 0.20, 0.66, 0);
  glClearColor(0,0,0.5,1);

  glShadeModel(GL_SMOOTH);
  glEnable(GL_DEPTH_TEST);

  glEnable(GL_LIGHTING);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, DiffuseLight);

  glEnable(GL_LIGHT0);

//  glEnable(GL_COLOR_MATERIAL);
  lightinitr;
  glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
end;

procedure GLKeyboard(Key: Byte; X, Y: Longint); cdecl;
begin
  if Key = 27 then
    Halt(0);
  if UpCase(char(Key)) = 'D' then Angle:=Angle+1;
  if UpCase(char(Key)) = 'A' then Angle:=Angle-1;
  if UpCase(char(Key)) = 'S' then AutoAn:=not AutoAn;
  if UpCase(char(Key)) = 'X' then Pole:=not Pole;
  if UpCase(char(Key)) = ' ' then rnd.reset;
end;


procedure DrawGLScene; cdecl;
var
  DeltaTime: Single;
  i,j:integer;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  //DeltaTime := GetDeltaTime;

 { glLoadIdentity;
  glTranslatef(0, 0, -5);
  glRotatef(objectXRot, 1, 0, 0);
  glRotatef(objectYRot, 0, 1, 0);
  glRotatef(objectZRot, 0, 0, 1);

  glColor3f(1, 1, 1);
  glutSolidCube(2);

  objectXRot := objectXRot + 50 * DeltaTime;
  objectYRot := objectYRot + 100 * DeltaTime;
  objectZRot := objectZRot + 50 * DeltaTime;
  }

  glMatrixMode(GL_MODELVIEW); // activate the transformation matrix
  glLoadIdentity;             // set it to initial state
{  gluLookAt(0,0,-6,-2,-2,10,-10,-10,0); // set up a viewer position and view point }
  if pole then gluLookAt(-100,0,10,0,0,15,0,0,1)
  else gluLookAt(-50,0,10,0,0,15,0,0,1); // set up a viewer position and view point }
  //glTranslatef(0,0,0);
{  if not pole then}
 // do rotation around axis (x:0;y:1;z:0)}
//  glRotatef(30,1,0,0);      // do another rotation for better view (accumulates to first rot.)
//  glScalef(1,sin(Angle*pi/90),1); // simulate bumping
  glEnable(GL_DEPTH_TEST); // enable depth testing
  glRotatef(-Angle,0,0,1);
  lightinitr;
  glEnable(GL_LIGHT1);
  glEnable(GL_LIGHTING);
  glRotatef(2*Angle,0,0,1);
  rnd.resettop;
  if pole then for i:=-3 to 3  do for j:=-3 to 3  do Branches(j*10,i*10,0,10+(7*rnd.get),0,0)
          else Branches(0,0,0,20+(7*rnd.get),0,0);
{  Branches(0,-10,0,27,0,0,1);}
  if AutoAn then Angle:=Angle+0.1;
  if Angle >= 360 then Angle:=0;
 // Repaint;



  glutSwapBuffers;

  //FrameRendered;
end;

procedure ReSizeGLScene(Width, Height: Integer); cdecl;
begin
  if Height = 0 then
    Height := 1;

  glViewport(0, 0, Width, Height);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45, Width / Height, 0.1, 1000);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
end;

{procedure GLFPSTimer(Value: Integer); cdecl;
var
  FPS: Single;
  FPSText: String;
begin
  //FPS := GetFPS;
  //FPSText := Format('OpenGL Tutorial :: Light - %.2f FPS', [FPS]);
 // glutSetWindowTitle(PChar(FPSText));
 // glutTimerFunc(1000, @GLFPSTimer, 0);
end;   }

procedure glutInitPascal(ParseCmdLine: Boolean);
var
  Cmd: array of PChar;
  CmdCount, I: Integer;
begin

  if ParseCmdLine then
    CmdCount := ParamCount + 1
  else
    CmdCount := 1;
  SetLength(Cmd, CmdCount);
  for I := 0 to CmdCount - 1 do
    Cmd[I] := PChar(ParamStr(I));
  glutInit(@CmdCount, @Cmd);
end;


procedure TForm1.Button1Click(Sender: TObject);
begin

end;

procedure TForm1.FormPaint(Sender: TObject);
begin
    glutInitPascal(True);
  glutInitDisplayMode(GLUT_DOUBLE or GLUT_RGB or GLUT_DEPTH);
  glutInitWindowSize(AppWidth, AppHeight);
  ScreenWidth := glutGet(GLUT_SCREEN_WIDTH);
  ScreenHeight := glutGet(GLUT_SCREEN_HEIGHT);
  glutInitWindowPosition((ScreenWidth - AppWidth) div 2, (ScreenHeight - AppHeight) div 2);
  glutCreateWindow('OpenGL Tutorial :: Light');
  rnd.reset;
  AutoAn:=true;
  InitializeGL;

  glutDisplayFunc(@DrawGLScene);
  glutReshapeFunc(@ReSizeGLScene);
  glutKeyboardFunc(@GLKeyboard);
  glutIdleFunc(@DrawGLScene);
 // glutTimerFunc(1000, @GLFPSTimer, 0);

  glutMainLoop;
end;

end.

