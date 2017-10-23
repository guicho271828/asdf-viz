(defpackage :asdf-viz.call-graph
  (:use :cl :cl-dot :trivia)
  (:export
   #:visualize-callgraph))

(in-package :asdf-viz.call-graph)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defclass call-graph ()
    ((packages :initarg :packages
               :initform nil
               :documentation "list of packages to limit the visualization of the call graph")
     (include-outside-calls :initarg :include-outside-calls
                            :initform nil
                            :documentation "If the leaf node contains symbols outside PACKAGES"))))

(defmethod graph-object-node ((graph call-graph) (object package))
  (make-instance 'node
                 :attributes (list :label (package-name object)
                                   :shape :octagon
                                   :style :filled
                                   :fillcolor "#ffeeee")))

(defmethod graph-object-points-to ((graph call-graph) (object package))
  (let (acc)
    (do-external-symbols (s object acc)
      (when (fboundp s)
        (push s acc)))))

(defmethod graph-object-node ((graph call-graph) (object symbol))
  (make-instance 'node
                 :attributes (list :label (princ-to-string object)
                                   :shape :octagon
                                   :style :filled
                                   :fillcolor "#eeeeff")))

(defun callees (symbol)
  (handler-case
      (mapcar #'first (funcall (GET 'SWANK/BACKEND::list-callees 'SWANK/BACKEND::IMPLEMENTATION) symbol))
    (error ()
      (warn "Error while listing the callees of symbol ~a" symbol))))

(defun belongs-to-packages (packages fname)
  (match fname
    ((or (list 'setf symbol)
         (and symbol (symbol)))
     (some (lambda (package)
             (multiple-value-bind (s2 status) (find-symbol (symbol-name symbol) package)
               (and (not (eq :inherited status))
                    (eq symbol s2))))
           packages))
    (_
     (warn "unknown/nonstandard type of function name: ~a" fname))))

(defmethod graph-object-points-to ((graph call-graph) (object symbol))
  (ematch graph
    ((call-graph packages include-outside-calls)
     (when (belongs-to-packages packages object)
       (if include-outside-calls
           (callees object)
           (remove-if-not (lambda (s) (belongs-to-packages packages s))
                          (callees object)))))))

(defmethod graph-object-node ((graph call-graph) (object list))
  (make-instance 'node
                 :attributes (list :label (princ-to-string object)
                                   :shape :octagon
                                   :style :filled
                                   :fillcolor "#eeeeff")))

(defmethod graph-object-points-to ((graph call-graph) (object list))
  (ematch* (graph object)
    (((call-graph packages include-outside-calls)
      (list 'setf object))
     (when (belongs-to-packages packages object)
       (if include-outside-calls
           (callees object)
           (remove-if-not (lambda (s) (belongs-to-packages packages s))
                          (callees object)))))))

(defun visualize-callgraph (target-png pkg-designators &key seeds include-outside-calls)
  (let* ((packages (mapcar #'find-package pkg-designators))
         (seeds (or seeds packages)))
    (dot-graph
     (generate-graph-from-roots (make-instance 'call-graph
                                               :packages packages
                                               :include-outside-calls include-outside-calls)
                                seeds '(:rankdir "LR"))
     target-png :format :png)))



