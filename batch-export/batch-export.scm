#!/usr/bin/env gimp-script-fu-interpreter-3.0

(define (render-images image drawables resolutions all-images)
  (let (
    (open-images (car (gimp-get-images)))
  )
    (cond 
      ((is-true all-images)
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
      (else
        (process-image image resolutions)
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
)

(script-fu-menu-register
  "render-images"
  "<Image>/Batch export"
)

(define (process-image image resolutions)
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
              (crop-image image-copy new-width new-height image-width image-height)
              (gimp-image-scale image-copy new-width new-height)
            )
          )
        )

        (gimp-message name)
        (export-image image-copy (string-append name "-" (number->string new-width)) 80)
        
        (gimp-image-delete image-copy)
      )
    ) resolution-list)
  )
)

(define (crop-image image width height old-width old-height)
  (let* (
    (scale-x (/ old-width width))
    (scale-y (/ old-height height))
    (scale (cond
      ((< scale-x scale-y) scale-x)
      (else scale-y)
    ))
    (crop-width (* width scale))
    (crop-height (* height scale))
  )
    (gimp-image-crop image crop-width crop-height (* (- old-width crop-width) 0.5) (* (- old-height crop-height) 0.5))
  )
)

(define (export-image image name quality)
  (file-heif-av1-export
    #:run-mode RUN-NONINTERACTIVE
    #:image image
    #:file (string-append name ".avif")
    #:options -1
    #:quality quality
    #:lossless FALSE
    #:save-bit-depth 8
    #:pixel-format "rgb"
    #:encoder-speed "fast"
    #:include-exif FALSE
    #:include-xmp FALSE
    )
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

(define (is-true value)
  (not (= value 0))
)

(define (remove-file-extension image)
  (let* (
    (file-path (car (gimp-image-get-file image)))
    (path-parts (strbreakup file-path "."))
  )
    (string-join (remove-last-item path-parts) ".")
  )
)