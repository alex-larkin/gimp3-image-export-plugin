#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (render-images image drawables resolutions all-images is-cropped)
  (let (
    (open-images (car (gimp-get-images)))
  )
    (cond 
      ((is-true all-images)
        (let loop ((i 0))
          (if (< i (vector-length open-images))
            (begin
              (if (not (equal? (car (gimp-image-get-file (vector-ref open-images i))) ""))
                (process-image (vector-ref open-images i) resolutions is-cropped)
              )
              (loop (+ i 1))
            )
          )
        )
      )
      (else
        (process-image image resolutions is-cropped)
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
  SF-TOGGLE "Render all open images"    1
  SF-TOGGLE "Crop images to new aspect ratio"   1
)

(script-fu-menu-register
  "render-images"
  "<Image>/Batch export"
)

(define (process-image image resolutions is-cropped)
  (let (
    (resolution-list (strbreakup resolutions ","))
    (image-width (car (gimp-image-get-width image)))
    (image-height (car (gimp-image-get-height image)))
    (name (remove-file-extension image))
  )
    (for-each (lambda (resolution)
      (let* (
        (image-copy (car (gimp-image-duplicate image)))
        (resolution-values (strbreakup resolution "x"))
        (new-width (string->number (car resolution-values)))
      )

        (cond
          ((= (length resolution-values) 1)
            
            (let (
              (new-height (* (/ new-width image-width) image-height))
            )
              (gimp-image-scale image-copy new-width new-height)
            )
          )
          ((= (length resolution-values) 2)
            (let* (
              (new-height (string->number (cadr resolution-values)))

            )
              (if (= is-cropped 1) 
                (let (
                  (original-ratio (/ image-width image-height))
                  (new-ratio (/ new-width new-height))
                )
                  (cond
                    ((> original-ratio new-ratio)
                      (let (
                        (crop-width (* (/ image-height new-height) new-width))
                      )
                        (gimp-image-crop image-copy crop-width image-height 0 0)
                      )
                    )
                    (else 
                      (let (
                        (crop-height (* (/ image-width new-width) new-height))
                      )
                        (gimp-image-crop image-copy image-width crop-height 0 0)
                      )
                    )
                  )
                  (gimp-message "crop image")
                )
              )
              (gimp-image-scale image-copy new-width new-height)
            )
          )
        )

        (gimp-message name)
        (export-image image-copy (string-append name "_" (number->string new-width) "x" (number->string new-height)) 80)
        
        (gimp-image-delete image-copy)
      )
    ) resolution-list)
  )
)

(define (export-image image name quality)
  (file-heif-av1-export RUN-NONINTERACTIVE image (string-append name "_" (number->string quality) ".avif") 0 quality FALSE 8 "rgb" "fast" FALSE FALSE)
)

(define (remove-last-item list)
  (reverse (cdr (reverse list)))
)

(define (string-join list separator)
  (let (
    (mergeCallback (lambda (element) (string-append separator element)))
  )
    (apply string-append (cons (car list) (map mergeCallback (cdr list))))
  )
)

(define (remove-file-extension image)
  (let* (
    (file-path (car (gimp-image-get-file image)))
    (path-parts (strbreakup file-path "."))
  )
    (string-join (remove-last-item path-parts) ".")
  )
)