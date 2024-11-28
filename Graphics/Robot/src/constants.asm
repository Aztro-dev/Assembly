%ifndef CONSTANTS
%define CONSTANTS

%define SYS_BRK 12

%define SCREEN_WIDTH 800
%define SCREEN_HEIGHT 800

%define KEY_SPACE 32
%define KEY_C 67
%define KEY_X 88
%define KEY_Z 90
%define KEY_ENTER 257
%define KEY_BACKSPACE 259
%define KEY_RIGHT 262
%define KEY_LEFT 263
%define KEY_DOWN 264
%define KEY_LEFT_SHIFT 340
%define MOUSE_BUTTON_LEFT 0

%define NO_COLOR 0xFF444444
%define BLACK 0xFF000000
%define WHITE 0xFFFFFFFF
%define BLUE 0xFFFFFF00
%define YELLOW 0xFF00FFFF
%define RED 0xFF0000FF
%define GREEN 0xFF00FF00

extern InitWindow
extern WindowShouldClose
extern CloseWindow
extern BeginDrawing
extern EndDrawing
extern ClearBackground
extern BeginMode3D
extern EndMode3D

extern LoadModel
extern UnloadModel


extern IsKeyPressed
extern IsKeyDown
extern IsMouseButtonPressed
extern IsMouseButtonDown
extern IsMouseButtonReleased
extern GetMouseX
extern GetMouseY

extern DrawFPS
extern SetTargetFPS
extern GetTime
extern SetRandomSeed
extern GetRandomValue

extern DrawRectangle
extern DrawRectangleLines
extern DrawRectangleLinesEx
extern DrawText
extern DrawModel

%endif
