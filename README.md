# Controller Viewer
Simple controller viewer overlay for streaming, controller testing, and input recording. This is a hobby project and will have limited support. The application runs on incredibly low CPU usage and 4MB - 8MB of RAM usage, great to stay

The intent is to have a light weight controller representation for use in OBS or screenshare. The always on top nature will allow you to open the application and share your screen, no need to run OBS and create custom layouts! If you do want to use it in OBS, you can disable the always on top and add it as a source (see [OBS Use](#obs-use)).

## Supported Hardware
Currently this is a standalone 64-bit application that runs on Windows 10 and 11. It will support controllers that report as an xinput device. Other controller devices may be supported in the future.

## Usage
The usage is pretty basic and is currently set up for showing ONLY the first player controller, run the `Overlay.bat` file to start the application. A controller view should appear (red if the system cannot detect a controller, or a functioning overlay). To change basic options, there will be a controller icon in your task bar, right clicking this will give you options like: Always on Top, Scale, Reset position to center, and toggle the overlay view (also default keyboard shortcut of `Alt + Shift + 1`).

Basic overlay use should allow it to render over most games. It *WILL NOT* be captured by Xbox Gamebar recordings, but may be captured in other recording software (Zoom, OBS, or similar where you share a **screen** - not a window).

If the application hangs or acts erratically, you can kill the process `wlua5.1.exe` - as that is the Lua runtime that powers the app.

### OBS Use
If you want to add this as an overlay to your OBS layout, run the application and in OBS add a new `Window Capture` source. If the source is black or blank, you need to right click the source and choose `Properties`. In that dialogue, set the `Capture Method` to `Windows 10` - at this point, there may be a yellow outline around the controller application that indicates window capture (don't worry if this doesn't show up - it may be tied to a Windows setting). I would also suggest unticking the `Capture Cursor` option. Finally, if you don't want the application to stay on top of all windows, you can right click the application icon in the system tray and turn off `Always On Top`.

## Advanced Customization
Toggle overlay shortcut is a Yue keyboard bind, known as an [accelerator](https://libyue.com/docs/latest/lua/api/accelerator.html); it is stored in `settings.ini` and can be changed there (see [accelerator](https://libyue.com/docs/latest/lua/api/accelerator.html) documentation). To modify the deadzone of your thumbsticks, at this moment, it is in `theme.ini` under `rightThumb` and `leftThumb` - these are a float value of `0.0` (No DZ) to `1.0` (All DZ. Why?!). Deadzone will control if the stick draws as "moving" or "stationary" at a certain value.

You may also set custom render scaling in `settings.ini`, if the options of 100%, 75%, or 50% don't meet needs.

## Theming
Currently, the overlay supports a single theme. All files are in the `assets` directory and the specifications of use are defined in the `theme.ini` file. If you are doing a 1-to-1 graphical update, feel free to make edits to the images directly. If you want to change asset sizes or layout, you will need to edit the ini to include new `offsetx` and `offsety` values of each asset (these are the top corner position of the render, using the `base.png` as a reference). On the thumbsticks, you can also set the `motionx` and `motiony` values for how much movement the hats will show when the associated stick is moved to the maximum point in any direction.

YMMV with changing asset sizes - larger assets may incur a RAM penalty (albieit, not much), and different sizes may expose any bugs where there may be hardcode values or calculations based on the original 512x512 controller layout. The system currently support PNGs with alpha transparency for the file type.

## Development
The core scripts are all in [Lua 5.1.5](https://www.lua.org/manual/5.1/), using [Yue 0.15.3 Lua Scripting](https://libyue.com/docs/latest/lua/), and xinput from https://github.com/ThomasR95/BHDS_Controller/. You are welcome to modify and change the scripts, menu oiptions, and usage. I would appreciate pull requests of improvements or features!

## Roadmap
In no specific order, these are features I would love to support
- [ ] Move deadzone definitions from `theme.ini` to `settings.ini`
- [ ] Swapping controller view via context menu (temporary multi-controller support)
- [ ] Proper support for single application showing multiple controllers
- [ ] Render FPS options (currently runs at about 60fps - minimally adding 75/90/120/144)
- [ ] Multi-theme support (be able to have multiple defined themes and change them)
- [ ] Script patching (Minimally update the core Lua scripts, eventually patching themes)
