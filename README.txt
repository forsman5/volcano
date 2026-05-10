VOLCANO
=======
Codename for an in-development top-down squad tactics game.

ENGINE
------
Built with Godot Engine 4.6.2 (stable)
https://godotengine.org

Godot is a free, open-source game engine. It uses GDScript (Python-like) as its
primary scripting language and supports 2D and 3D projects out of the box.

RUNNING THE EDITOR
------------------
From the gamedev folder, launch the editor by opening the project:

    Godot_v4.6.2-stable_win64.exe --editor volcano/project.godot

Or double-click Godot_v4.6.2-stable_win64.exe and import the project by pointing
it at volcano/project.godot.

RUNNING THE GAME
----------------
To run the game without the editor:

    Godot_v4.6.2-stable_win64.exe volcano/project.godot

Or press F5 inside the editor to launch from the main scene.

WEB EXPORT & LOCAL SERVER
--------------------------
export_and_serve.ps1 exports a release web build and immediately starts a local
HTTPS server so the game can be played in a browser, including from other devices
on the same LAN.

DEPENDENCIES
Run this once to install the Python package needed for HTTPS support:

    pip install cryptography

ALLOW POWERSHELL SCRIPTS
Run this once to allow local scripts to execute (Windows blocks them by default):

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

USAGE
From the project folder in PowerShell:

    .\export_and_serve.ps1

Once running, the script prints the URLs to use -- open the printed address in
a browser. On first visit, the browser will warn about a self-signed certificate;
click Advanced > Proceed to continue.
