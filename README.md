# GIMP 3 Export Plugin

A plugin for GIMP 3 to batch export images, optimized for web development. This plugin allows you to quickly render images in multiple resolutions and formats.

## Features

- Batch export images in **JPEG, PNG, WebP, and AVIF** formats, individually toggleable
- Supports resizing into different aspect ratios with cropping
- Process multiple images at once
- Choose a destination folder, or leave it blank to export beside each source image
- Adjustable export quality
- Remembers your dialog settings between runs, including after restarting GIMP

## Installation

Place the script in your GIMP plug-ins folder:

**Windows:**  
`%APPDATA%\GIMP\<version>\plug-ins\batch-export\batch-export.scm`  
(e.g. `C:\Users\<you>\AppData\Roaming\GIMP\3.2\plug-ins\batch-export\batch-export.scm` — the version folder matches your installed GIMP)

**MacOS/Linux:**  
`~/Library/Application Support/GIMP/<version>/plug-ins/batch-export/batch-export.scm`

Restart GIMP afterwards.

## Usage

1. Open the image/s in GIMP you want to export.
2. Go to **Batch Export > Render Images** in the menu bar.
3. Enter desired resolutions:
   - **Width only** (e.g., `500`) keeps the aspect ratio.
   - **Width x Height** (e.g., `800x600`) crops the image before resizing.
   - Separate multiple resolutions with a comma (e.g., `500,800x600`).
4. Toggle **Select All Open Images** if needed.
5. Tick the file formats you want to export (**JPEG / PNG / WebP / AVIF**). At least one must be ticked.
6. Choose a **Destination folder** (defaults to `Pictures/GIMP3-Image-Exports`). Leave it blank to export beside each source image instead.
7. Adjust **Quality** if needed. This applies to JPEG, WebP, and AVIF only — PNG is always lossless.
8. Click **OK**. Files are named `<image>_<resolution>.<ext>`, e.g. `image_500.jpg` or `image_800x600.png`. If a destination folder is set and two source images share a basename, the second one gets a `-2` suffix (`image-2_500.jpg`) so nothing is overwritten.

Your choices for all of the above are saved automatically and restored the next time you open the dialog, even after restarting GIMP. To reset everything back to the defaults, close GIMP and delete:  
`%APPDATA%\GIMP\<version>\plug-in-settings\GimpProcedureConfigRun-render-images.last` (Windows), or the equivalent `plug-in-settings` folder on MacOS/Linux.

## Customization

You can modify the script by simply opening it in an IDE or text editor. Especially the export options for the formats can be easily tweaked.

For more details, check **GIMP > Help > Procedure Browser** and [Funky](https://script-fu.github.io/funky/).

## License

This plugin is released under the **GNU General Public License v3**.

## Contributing

Feel free to fork, modify, or submit pull requests to improve the script!
