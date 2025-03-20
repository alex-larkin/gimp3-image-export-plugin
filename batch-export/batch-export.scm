#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (render-images image drawables resolutions)
  (process-image image resolutions)

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
  SF-STRING "Resolutions" "1920, 1920x1080"
)

(script-fu-menu-register
  "render-images"
  "<Image>/Batch export"
)

(define (process-image image resolutions)
  (let (
    (resolution-list (strbreakup resolutions ","))
  )
    (gimp-message (list-ref resolution-list 0))
  )
)