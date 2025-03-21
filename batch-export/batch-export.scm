#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (render-images image drawables resolutions)
  (let (
    (open-images (car (gimp-get-images)))
  )
    (let loop ((i 0))
      (if (< i (vector-length open-images))
        (begin
          (if (not (equal? (car (gimp-image-get-file (vector-ref open-images i))) ""))
            (process-image (vector-ref open-images i) resolutions)
          )
          (loop (+ i 1))
        )
      )
    )
  )
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
    (for-each (lambda (resolution)
    
      (gimp-message resolution)
      (gimp-message (car (gimp-image-get-file image)))
      
    ) resolution-list)
  )
  (file-heif-av1-export RUN-NONINTERACTIVE image "test.avif" 0 50 FALSE 8 "rgb" "fast" FALSE FALSE)
)