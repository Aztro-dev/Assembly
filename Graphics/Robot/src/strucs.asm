struc Vector3
  .x resd 1
  .y resd 1
  .z resd 1
  .padding resd 1
endstruc

struc Camera3d
  .position:    resb Vector3_size ; Vector3
  .target:      resb Vector3_size ; Vector3
  .up:          resb Vector3_size ; Vector3
  .fovy:        resd 1 ; Float
  .projection:  resd 1 ; int
endstruc

struc robot_struc
  .model: resq 1 ; Model type
  .position: resb Vector3_size ; Vector3 (3 floats)
  .heading: resd 1 ; float
endstruc

