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
  "Render Images for given resolutions as JPEG, PNG, WebP, AVIF"
  "Max Bronner"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2025"
  "*"
  SF-ONE-OR-MORE-DRAWABLE
  SF-STRING "Resolutions"               "1920, 1920x1080"
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
    (file-name (remove-file-extension image))
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
        (export-image image-copy (string-append file-name "_" (number->string new-width)))
        (gimp-image-delete image-copy)
      )
    ) resolution-list)
  )
)


(define (export-image image name)
  (let ((quality 80))
    (export-jpeg image name quality)
    (export-png image name quality)
    (export-webp image name quality)
    (export-avif image name quality)
  )
)

(define (export-jpeg image name quality)
  (file-jpeg-export
    #:run-mode RUN-NONINTERACTIVE
    #:image image
    #:file (string-append name ".jpg")
    #:options -1
    #:quality (* 0.01 quality)
    #:smoothing 0.0
    #:optimize TRUE
    #:progressive FALSE
    #:cmyk FALSE
    #:sub-sampling "sub-sampling-1x1"
    #:baseline TRUE
    #:restart 0
    #:dct "integer"
    #:include-exif FALSE
    #:include-iptc FALSE
    #:include-xmp FALSE
    #:include-color-profile FALSE
    #:include-thumbnail FALSE
    #:include-comment FALSE
  )
)

(define (export-png image name quality)
  (file-png-export
    #:run-mode RUN-NONINTERACTIVE
    #:image image
    #:file (string-append name ".png")
    #:options -1
    #:interlaced FALSE
    #:compression 9
    #:bkgd TRUE
    #:offs FALSE
    #:phys TRUE
    #:time TRUE
    #:save-transparent TRUE
    #:optimize-palette FALSE
    #:format "auto"
    #:include-exif FALSE
    #:include-iptc FALSE
    #:include-xmp FALSE
    #:include-color-profile FALSE
    #:include-thumbnail FALSE
    #:include-comment FALSE
  )
)

(define (export-webp image name quality)
  (file-webp-export
    #:run-mode RUN-NONINTERACTIVE
    #:image image
    #:file (string-append name ".webp")
    #:options -1
    #:preset "default"
    #:lossless FALSE
    #:quality quality
    #:alpha-quality 100
    #:use-sharp-yuv FALSE
    #:animation-loop TRUE
    #:minimize-size TRUE
    #:keyframe-distance 50
    #:default-delay 200
    #:force-delay FALSE
    #:animation FALSE
    #:include-exif FALSE
    #:include-iptc FALSE
    #:include-xmp FALSE
    #:include-color-profile FALSE
    #:include-thumbnail FALSE
  )
)

(define (export-avif image name quality)
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

(define (is-true value)
  (not (= value 0))
)