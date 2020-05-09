(defpackage asdf-viz
  (:use :cl :cl-dot :trivia)
  (:export
   #:dependson
   #:visualize-asdf-hierarchy))

(in-package :asdf-viz)

(defvar *excluded* nil)
(defvar *license* nil)

(defmethod graph-object-node ((graph (eql 'dependson)) (object asdf:component))
  (make-instance 'node
                 :attributes (list :label (format nil "~a~:[~*~; (~a)~]"
                                                  (asdf:component-name object)
                                                  *license*
                                                  ;; For some reason asdf:system-license
                                                  ;; fails on some systems like :UIOP
                                                  ;; because asdf:primary-system-name returns NIL
                                                  ;; for them.
                                                  (when (asdf:primary-system-name object)
                                                    (asdf:system-license object)))
                                   :shape :octagon
                                   :style :filled
                                   :fillcolor "#eeeeff")))

(defmethod graph-object-node ((graph (eql 'dependson)) (object asdf:require-system))
  (make-instance 'node
                 :attributes (list :label (format nil "~a~:[~*~; (~a)~]"
                                                  (asdf:component-name object)
                                                  *license*
                                                  (asdf:system-license object))
                                   :shape :rect
                                   :style :filled
                                   :fillcolor "#eeffee")))


(defmethod graph-object-node ((graph (eql 'dependson)) (object cons))
  "If the object is something like (:feature :sbcl (:require :sb-introspect)) then
this method generates a reasonable label."
  (make-instance 'node
                 :attributes (list :label (format nil "~s" object)
                                   :shape :rect
                                   :style :filled
                                   :fillcolor "#ffeeee")))

(defun dependency-name (dependency-def)
  #|
  https://common-lisp.net/project/asdf/asdf.html#The-defsystem-grammar
  dependency-def := simple-component-name
  | ( :feature feature-expression dependency-def )
  | ( :version simple-component-name version-specifier )
  | ( :require module-name )
  |#
  (ematch dependency-def
    ((list :feature _ def) (dependency-name def))
    ((list :version name _) name)
    ((list :require module-name) module-name)
    (name name)))

(defmethod graph-object-points-to ((graph (eql 'dependson)) (object asdf:system))
  (remove nil
          (mapcar (lambda (dependency-def)
                    (let ((name (dependency-name dependency-def)))
                      (unless (find name *excluded* :test #'string-equal)
                        (handler-case (asdf:find-system name)
                          (asdf:missing-component ()
                            dependency-def)))))
                  (asdf:system-depends-on object))))


(defun visualize-asdf-hierarchy (target-png &optional (seed-systems (asdf:registered-systems)) (mode 'dependson))
  (dot-graph
   (generate-graph-from-roots mode seed-systems '(:rankdir "LR"))
   target-png :format :png))


