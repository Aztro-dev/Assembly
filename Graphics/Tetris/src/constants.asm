%ifndef CONSTANTS
%define CONSTANTS

%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 1000

%define KEY_SPACE 32
%define KEY_C 67
%define KEY_X 88
%define KEY_Z 90
%define KEY_ENTER 257
%define KEY_RIGHT 262
%define KEY_LEFT 263
%define KEY_DOWN 264
%define KEY_LEFT_SHIFT 340

%define NO_COLOR 0xFF444444
%define BLACK 0xFF000000
%define WHITE 0xFFFFFFFF
%define LIGHT_BLUE 0xFFFFFF00
%define YELLOW 0xFF00FFFF
%define PURPLE 0xFFC000C0
%define GREEN 0xFF00FF00
%define RED 0xFF0000FF
%define DARK_BLUE 0xFFFF0000
%define ORANGE 0xFF007FFF

extern InitWindow
extern WindowShouldClose
extern CloseWindow
extern BeginDrawing
extern EndDrawing
extern ClearBackground

extern IsKeyPressed
extern IsKeyDown

extern DrawFPS
extern SetTargetFPS
extern GetFrameTime

extern DrawRectangle
extern DrawRectangleLines
extern DrawRectangleLinesEx
extern DrawText

%endif
