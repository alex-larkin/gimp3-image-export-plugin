#!/usr/bin/env gimp-script-fu-interpreter-3.0

;; Modified by Alex Larkin, 27 Jul 2026:
;;   - Added per-format checkboxes (JPEG/PNG/WebP/AVIF individually toggleable)
;;   - Added a destination-folder chooser (defaults to Pictures/GIMP3-Image-Exports),
;;     with the original "export beside the source image" behavior kept as a
;;     fallback when the chooser is left blank
;;   - Added a JPEG/WebP/AVIF quality slider (previously hardcoded at 80)
;;   - All of the above persist across GIMP restarts via GimpProcedureConfig --
;;     see the "ARGUMENT ORDER" note above the registration block below
;; Original script by Max Bronner: https://github.com/max-bronner/gimp3-image-export-plugin

;; --- path helpers ---------------------------------------------------------
;; These must be defined before default-destination-dir/the registration
;; block below, since that block calls (default-destination-dir) immediately
;; when the file loads (both at GIMP startup and at run time).

(define (path-basename path)
  (let* (
    (last-fwd-part (car (reverse (strbreakup path "/"))))
    (last-part (car (reverse (strbreakup last-fwd-part "\\"))))
  )
    last-part
  )
)

(define (path-dirname path)
  (let* (
    (base (path-basename path))
    (base-len (string-length base))
    (path-len (string-length path))
  )
    (if (= base-len path-len)
      ""
      (substring path 0 (- path-len base-len))
    )
  )
)

(define (strip-extension name)
  (let (
    (parts (strbreakup name "."))
  )
    (if (> (length parts) 1)
      (unbreakupstr (reverse (cdr (reverse parts))) ".")
      name
    )
  )
)

(define (path-join a b)
  (string-append a DIR-SEPARATOR b)
)

(define (dir? path)
  (and
    (string? path)
    (> (string-length path) 0)
    (file-exists? path)
    (= (file-type path) FILE-TYPE-DIR)
  )
)

;; --- default destination folder -------------------------------------------

(define EXPORT-FOLDER-NAME "GIMP3-Image-Exports")

(define (env-or-false name)
  (let (
    (value (getenv name))
  )
    (if (and (string? value) (> (string-length value) 0))
      value
      #f
    )
  )
)

(define (user-home-dir)
  (or (env-or-false "USERPROFILE") (env-or-false "HOME"))
)

;; Never throws -- this is evaluated as a registration default, and a throw
;; at load time would remove the plug-in from the menu with no visible error.
(define (default-destination-dir)
  (let (
    (home (user-home-dir))
  )
    (cond
      ((and home (dir? (path-join home "Pictures")))
        (path-join (path-join home "Pictures") EXPORT-FOLDER-NAME)
      )
      ((dir? home)
        (path-join home EXPORT-FOLDER-NAME)
      )
      (else
        (path-join gimp-directory EXPORT-FOLDER-NAME)
      )
    )
  )
)

(define (render-images image drawables resolutions all-images dest-dir
                        do-jpg do-png do-webp do-avif quality)
  (let* (
    (formats (collect-formats do-jpg do-png do-webp do-avif))
    (res-list (parse-resolutions resolutions))
    (dest (clean-destination dest-dir))
  )
    (cond
      ((null? formats)
        (gimp-message "Batch export: no file format selected. Tick at least one of JPEG / PNG / WebP / AVIF.")
      )
      ((null? res-list)
        (gimp-message "Batch export: no valid resolutions given. Use e.g. \"1920, 1920x1080\".")
      )
      ((and dest (not (ensure-directory dest)))
        (gimp-message (string-append "Batch export: could not create destination folder: " dest))
      )
      (else
        (set! *name-registry* '())
        (let (
          (open-images (car (gimp-get-images)))
        )
          (cond
            ((is-true all-images)
              (let loop ((i 0))
                (if (< i (vector-length open-images))
                  (begin
                    (if (not (equal? (car (gimp-image-get-file (vector-ref open-images i))) ""))
                      (process-image (vector-ref open-images i) res-list dest formats quality)
                    )
                    (loop (+ i 1))
                  )
                )
              )
            )
            (else
              (process-image image res-list dest formats quality)
            )
          )
        )
      )
    )
  )
)


;; ---------------------------------------------------------------------------
;; ARGUMENT ORDER IS PART OF THE PERSISTED-SETTINGS CONTRACT.
;; Script-Fu names each dialog value positionally per SF- type
;; (script_fu_arg_generate_name_and_nick in script-fu-arg.c), and
;; GimpProcedureConfig keys the saved-settings file on those generated names:
;;   Resolutions            -> "string"
;;   Render all open images -> "toggle"
;;   Destination folder     -> "dirname"
;;   Export JPEG            -> "toggle-2"
;;   Export PNG             -> "toggle-3"
;;   Export WebP            -> "toggle-4"
;;   Export AVIF            -> "toggle-5"
;;   Quality                -> "adjustment"
;; Saved at:
;;   <gimp-directory>/plug-in-settings/GimpProcedureConfigRun-render-images.last
;; NEVER insert a new argument before an existing one of the same type --
;; doing so silently re-maps a user's saved values onto the wrong widget.
;; Append new arguments after the existing ones instead. For the same reason,
;; don't rename the procedure "render-images" -- that orphans the .last file.
;; ---------------------------------------------------------------------------
(script-fu-register-filter
  "render-images"
  "Render Images"
  "Render Images for given resolutions as JPEG, PNG, WebP and/or AVIF"
  "Max Bronner"
  "Under GNU GENERAL PUBLIC LICENSE Version 3"
  "2025"
  "*"
  SF-ONE-OR-MORE-DRAWABLE
  SF-STRING     "Resolutions"               "1920, 1920x1080"
  SF-TOGGLE     "Render all open images"    1
  SF-DIRNAME    "Destination folder"        (default-destination-dir)
  SF-TOGGLE     "Export JPEG (.jpg)"        1
  SF-TOGGLE     "Export PNG (.png)"         1
  SF-TOGGLE     "Export WebP (.webp)"       1
  SF-TOGGLE     "Export AVIF (.avif)"       1
  SF-ADJUSTMENT "Quality (JPEG/WebP/AVIF)"  '(80 1 100 1 10 0 SF-SPINNER)
)

(script-fu-menu-register
  "render-images"
  "<Image>/Batch export"
)

;; Full path minus extension, used for the legacy "export beside the source"
;; case where no destination folder is set. Operates on the basename so a
;; dot in a directory name can't truncate the path (the original
;; remove-file-extension split the whole path on "." and had that bug).
(define (source-path-without-extension source-path)
  (string-append (path-dirname source-path) (strip-extension (path-basename source-path)))
)

(define (process-image image resolutions dest-dir formats quality)
  (let* (
    (image-width (car (gimp-image-get-width image)))
    (image-height (car (gimp-image-get-height image)))
    (source-path (car (gimp-image-get-file image)))
    (base-token (if dest-dir
                  (unique-token-for source-path)
                  (source-path-without-extension source-path)
                ))
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
        (export-image image-copy (export-prefix dest-dir base-token resolution) formats quality)
        (gimp-image-delete image-copy)
      )
    ) resolutions)
  )
)

;; Final path (minus extension) for one resolution's rendered image.
(define (export-prefix dest-dir base-token resolution)
  (let (
    (file-token (string-append base-token "_" resolution))
  )
    (if dest-dir
      (path-join dest-dir file-token)
      file-token
    )
  )
)

(define (export-image image prefix formats quality)
  (for-each
    (lambda (fmt-pair) ((cdr fmt-pair) image prefix quality))
    formats
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

;; --- destination-folder handling -------------------------------------------

;; SF-DIRNAME reports an unset/cleared chooser as "". Treat that as "no
;; destination folder chosen" -> caller falls back to legacy behavior.
(define (clean-destination dest-dir)
  (if (and (string? dest-dir) (> (string-length dest-dir) 0))
    dest-dir
    #f
  )
)

;; dir-make (ftx) wraps g_mkdir: non-recursive, and returns #f if the path
;; already exists. Walk the path component by component so nested
;; destinations (e.g. a folder several levels deep that doesn't exist yet)
;; still get created; ignore dir-make's return value and check the final
;; result with dir?, since "already exists" and "just created" both count
;; as success here.
(define (ensure-directory path)
  (if (dir? path)
    #t
    (let loop ((parts (strbreakup path DIR-SEPARATOR)) (prefix ""))
      (if (null? parts)
        (dir? path)
        (let (
          (next (if (string=? prefix "") (car parts) (path-join prefix (car parts))))
        )
          (if (> (string-length next) 0)
            (dir-make next)
          )
          (loop (cdr parts) next)
        )
      )
    )
  )
)

;; --- output-name collision guard --------------------------------------------
;; When multiple source images share a destination folder, basename
;; collisions become possible (two different "logo.png" files, or the same
;; image exported to two different resolutions). Assign each source path a
;; stable token for the run, appending -2, -3, ... only on genuine clashes.
;; Reset at the start of every run (see render-images above).

(define *name-registry* '())

(define (registry-token-taken? token)
  (let loop ((entries *name-registry*))
    (cond
      ((null? entries) #f)
      ((equal? (cdr (car entries)) token) #t)
      (else (loop (cdr entries)))
    )
  )
)

(define (unique-token-for source-path)
  (let (
    (hit (assoc source-path *name-registry*))
  )
    (if hit
      (cdr hit)
      (let (
        (base (strip-extension (path-basename source-path)))
      )
        (let loop ((n 1))
          (let (
            (candidate (if (= n 1) base (string-append base "-" (number->string n))))
          )
            (if (registry-token-taken? candidate)
              (loop (+ n 1))
              (begin
                (set! *name-registry* (cons (cons source-path candidate) *name-registry*))
                candidate
              )
            )
          )
        )
      )
    )
  )
)

;; --- resolution parsing ------------------------------------------------------

(define (string-nonempty? s)
  (> (string-length s) 0)
)

(define (valid-resolution? token)
  (and
    (string-nonempty? token)
    (let (
      (parts (strbreakup token "x"))
    )
      (and
        (number? (string->number (car parts)))
        (or
          (= (length parts) 1)
          (and (= (length parts) 2) (number? (string->number (cadr parts))))
        )
      )
    )
  )
)

;; Splits on "," and trims/validates each token, so stray whitespace or a
;; malformed entry (e.g. "1920,,junk, 800x600") degrades gracefully instead
;; of crashing later on (string->number "").
(define (parse-resolutions resolutions)
  (let loop ((tokens (strbreakup resolutions ",")) (result '()))
    (if (null? tokens)
      (reverse result)
      (let (
        (trimmed (string-trim (car tokens)))
      )
        (if (valid-resolution? trimmed)
          (loop (cdr tokens) (cons trimmed result))
          (loop (cdr tokens) result)
        )
      )
    )
  )
)

;; --- format selection ---------------------------------------------------------

(define (collect-formats do-jpg do-png do-webp do-avif)
  (append
    (if (is-true do-jpg)  (list (cons "jpg"  export-jpeg))  '())
    (if (is-true do-png)  (list (cons "png"  export-png))   '())
    (if (is-true do-webp) (list (cons "webp" export-webp))  '())
    (if (is-true do-avif) (list (cons "avif" export-avif))  '())
  )
)

(define (is-true value)
  (not (= value 0))
)
