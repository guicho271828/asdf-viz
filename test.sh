#!/bin/bash

ros install asdf-viz
call-graph-viz -s alexandria -p alexandria -f alexandria:symbolicate symbolicate.png
call-graph-viz -i -s alexandria -f alexandria:symbolicate symbolicate2.png
call-graph-viz -s alexandria -p alexandria alexandria.png
