(defpackage :asdf-viz.class-hierarchy
  (:use :cl :cl-dot :trivia)
  (:export
   #:visualize-class-hierarchy))

(in-package :asdf-viz.class-hierarchy)

(defmethod graph-object-node ((graph (eql 'class-hierarchy)) (object class))
  (make-instance 'node
                 :attributes (list :label (class-name object)
                                   :shape :octagon
                                   :style :filled
                                   :fillcolor "#ffeeee")))

(defmethod graph-object-points-to ((graph (eql 'class-hierarchy)) (object class))
  (c2mop:class-direct-subclasses object))

(defun visualize-class-hierarchy (target-png &optional (base-classes '(T)))
  (dot-graph
   (generate-graph-from-roots 'class-hierarchy
                              (mapcar #'find-class base-classes) '(:rankdir "TB"))
   target-png :format :png))



