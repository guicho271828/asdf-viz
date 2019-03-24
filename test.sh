#!/bin/bash

ros install asdf-viz

asdf-viz -l asdf-viz.png asdf-viz
asdf-viz -l weblocks.png weblocks
asdf-viz -l spinneret.png spinneret



call-graph-viz -s alexandria -p alexandria -f alexandria:symbolicate symbolicate.png
call-graph-viz -i -s alexandria -f alexandria:symbolicate symbolicate2.png
call-graph-viz -s alexandria -p alexandria alexandria.png


class-viz asdf.png asdf:component
class-viz -s plump plump.png plump:node
