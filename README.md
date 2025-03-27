# GIMP 3 Export Plugin

A plugin for GIMP 3 to batch export images, optimized for web development. This plugin allows you to quickly render images in multiple resolutions and formats.

## Features

- Batch export images in **JPEG, PNG, WebP, and AVIF** formats
- Supports resizing into different aspect ratios with cropping
- Process multiple images at once

## Installation

Place the script in your GIMP plug-ins folder:

**Windows:**  
`C:/Users/AppData/Roaming/GIMP/3.0/plug-ins/batch-export/batch-export.scm`

**MacOS/Linux:**  
`~/Library/Application Support/GIMP/3.0/plug-ins/batch-export/batch-export.scm`

Restart GIMP afterwards.

## Usage

1. Open the image/s in GIMP you want to export.
2. Go to **Batch Export > Render Images** in the menu bar.
3. Enter desired resolutions:
   - **Width only** (e.g., `500`) keeps the aspect ratio.
   - **Width x Height** (e.g., `800x600`) crops the image before resizing.
   - Separate multiple resolutions with a comma (e.g., `500,800x600`).
4. Toggle **Select All Open Images** if needed.
5. Click **OK**, and images will be saved in the same folder as the original, with new widths appended to the filename (e.g., `image_500.jpg`).

## Customization

You can modify the script by simply opening it in an IDE or text editor. Especially the export options for the formats can be easily tweaked.

For more details, check **GIMP > Help > Procedure Browser** and [Funky](https://script-fu.github.io/funky/).

## License

This plugin is released under the **GNU General Public License v3**.

## Contributing

Feel free to fork, modify, or submit pull requests to improve the script!
