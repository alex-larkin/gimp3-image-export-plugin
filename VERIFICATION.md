# Manual verification checklist: batch-export.scm

Script-Fu has no automated test harness, so this is manual. Copy the file to
`%APPDATA%\GIMP\<version>\plug-ins\batch-export\` and restart GIMP between
steps where noted. Watch **Filters > Script-Fu > Console** and the GIMP error
console throughout — a throw at load time removes the plug-in from the menu
with no visible error.

1. **Fresh state.** Delete
   `%APPDATA%\GIMP\<version>\plug-in-settings\GimpProcedureConfigRun-render-images.last`,
   then restart GIMP. The dialog should show `...\Pictures\GIMP3-Image-Exports`
   as the destination even though that folder doesn't exist yet — and no
   folder should have been created on disk just from opening the dialog.

2. **Persistence (the core new requirement).** Run once → the folder gets
   created and files land in it. Change the ticked formats, the resolutions,
   and the destination, run again, then quit GIMP entirely and relaunch →
   the dialog should reopen with those changed values, not the defaults.

3. **Resolution collision.** Enter `800, 800x600` for one image → confirm the
   output files are `..._800.*` and `..._800x600.*` (distinct), not both
   `..._800.*`.

4. **Name collision.** Open two images both named `logo.*` from different
   source folders, tick "Render all open images" → confirm you get
   `logo_...` and `logo-2_...` in the destination folder, not one
   overwriting the other.

5. **No formats selected.** Untick all four format checkboxes and click OK →
   confirm you get a single message and no files are written, and that
   reopening the dialog still shows your (unticked) checkboxes as you left
   them.

6. **Legacy path (destination cleared).** Clear the destination folder
   chooser back to "(None)" and run → confirm files appear beside the source
   image(s), exactly as the original script did before this change.

7. **Nested folder creation.** Point the destination chooser at a path
   several levels deep that doesn't exist yet → confirm `ensure-directory`
   creates the whole chain and the run succeeds.

8. **Re-query sanity.** After first loading the edited script, confirm GIMP
   picked up the new argument signature: the `render-images` entry in
   `%APPDATA%\GIMP\<version>\pluginrc` should show eight `proc-arg` lines
   (up from three before this change).
