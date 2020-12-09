#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: cp

requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000

inputs:
  input_file:
    type: File
    inputBinding:
      position: 1
  output_filename:
    type: string
    default: "output.txt"
    inputBinding:
      position: 2
outputs:
  output_file:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
