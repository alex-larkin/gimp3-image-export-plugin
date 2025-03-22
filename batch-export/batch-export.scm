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
    (name (remove-file-extension image))
  )
    (for-each (lambda (resolution)
      (let* (
        (new-width (string->number resolution))
        (new-height (* (/ new-width (car (gimp-image-get-width image)))(car (gimp-image-get-height image))))
      )
        (gimp-message (number->string new-height))
        (gimp-message name)
      )
    ) resolution-list)
  )
  (export-image image name 80)
)

(define (string-join list separator)
  (let (
    (mergeCallback (lambda (element) (string-append separator element)))
  )
    (apply string-append (cons (car list) (map mergeCallback (cdr list))))
  )
)

(define (remove-last-item list)
  (reverse (cdr (reverse list)))
)

(define (export-image image name quality)
  (file-heif-av1-export RUN-NONINTERACTIVE image (string-append name "_" (number->string quality) ".avif") 0 quality FALSE 8 "rgb" "fast" FALSE FALSE)
)

(define (remove-file-extension image)
  (let* (
    (file-path (car (gimp-image-get-file image)))
    (path-parts (strbreakup file-path "."))
  )
    (string-join (remove-last-item path-parts) ".")
  )
)