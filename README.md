# custom-yacht-3ds
A customizable yacht dice game for the 3ds using lovepotion!
You can create your own dice sets and scoresheets with a yaml file, place it in the same directory as the game for PC, and in `sdmc:/3ds/custom-yacht-3ds`. See the [default.yaml](https://github.com/chalenged/custom-yacht-3ds/blob/main/default.yaml) file for an example with comments.

![image](https://raw.githubusercontent.com/chalenged/custom-yacht-3ds/refs/heads/main/screenshot1.png)

# Controls
The game is mostly self-explanatory with touch controls, however the following are physical button controls:
Start: Exit the game
Select: open the dialogue to choose a yaml file to load (Make sure you trust the source! These files allow for custom code!)
  In the yaml selection menu, use up and down on the dpad to select, then press a to confirm.

# Build
To run on computer, simply git clone the repository with <code>--recursive</code> and run the folder with love2d.
To build for the 3ds, either follow the instructions from https://lovebrew.org/getting-started/get-lovepotion, or do the following:

1. Install `git zip make` and [tex3ds](https://github.com/devkitPro/tex3ds)
2. Clone the repository with `git clone --recursive https://github.com/chalenged/custom-yacht-3ds.git` then enter it
3. Run `make` to create the zip (or make it yourself)
4. Add the `yachtgame.zip` file to the [bundler](https://bundle.lovebrew.org/) to create the game!
