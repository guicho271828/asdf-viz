#|

This example contains convenient functions `visualize-ql-hierarchy'.

Try this (assume quicklisp is already loaded):

 (ql-hierarchy:visualize-ql-hierarchy
   (merge-pathnames \"ql-classes.png\" (user-homedir-pathname)))

Note: it doesn't work for local projects.

|#


(defpackage :cl-dot.ql-example
  (:use :cl :cl-dot
        #+sbcl :sb-mop
        #-sbcl :closer-mop)
  (:export
   #:requiredby
   #:dependson
   #:visualize-ql-hierarchy))

(in-package :cl-dot.ql-example)

(defmethod graph-object-node ((graph (eql 'requiredby)) (object QL-DIST:SYSTEM))
  (make-instance 'node
                 :attributes (list :label (ql-dist:name object)
                                   :shape :octagon
                                   :style :filled
                                   :fillcolor "#eeeeff")))

(defmethod graph-object-points-to ((graph (eql 'requiredby)) (object QL-DIST:SYSTEM))
  (remove nil
          (mapcar #'ql-dist:find-system
                  (ql-dist:required-systems object))))

(defmethod graph-object-node ((graph (eql 'dependson)) (object QL-DIST:SYSTEM))
  (make-instance 'node
                 :attributes (list :label (ql-dist:name object)
                                   :shape :octagon
                                   :style :filled
                                   :fillcolor "#eeeeff")))

(defmethod graph-object-points-to ((graph (eql 'dependson)) (object QL-DIST:SYSTEM))
  (remove nil
          (mapcar #'ql-dist:find-system
                  (ql:who-depends-on (ql-dist:name object)))))


(defun visualize-ql-hierarchy (target-png &optional (seed-systems (ql:system-list)) (mode 'requiredby))
  (dot-graph
   (generate-graph-from-roots mode seed-systems '(:rankdir "LR"))
   target-png :format :png))


