#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (render-images image drawables)
  (gimp-message-set-handler 2)
  (gimp-message (car (gimp-image-get-file image)))
)


(script-fu-register-filter
  "render-images"
  "Render Images"
  "Render Images for given resolutions into different formats"
  "Max Bronner"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2025"
  "*"
  SF-ONE-OR-MORE-DRAWABLE
)

(script-fu-menu-register
  "render-images"
  "<Image>/File/"
)