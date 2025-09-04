if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed || !move.axes[3].homed
    M98 P"0:/sys/homeall.g" S1


M42 P4 S1                                                                                      ; Turn on relay
G4 P500

M558 K0 P8 C"1.io4.in" H5 F600 T18000
M98 P"0:/user/probeoffset.g"                                                                   ; load global variables

G90

var amplitude_Z = 1
var stepcourse_Z = 0.06
var stepprecise_Z = 0.02

var amplitude_XY = 1
var stepcourse_XY = 0.06
var stepprecise_XY = 0.02


var iter = 200

var axisposition = {move.axes[0].machinePosition, move.axes[1].machinePosition, move.axes[2].machinePosition, move.axes[3].machinePosition}



if exists(param.Z) ; Z- (T0 || T1)

    if abs(param.Z) < 5 ; T0 if less that 5
        
        while iterations < {var.iter}
    
            G38.4 K0 X{var.axisposition[0] - var.amplitude_Z/2} Z{move.axes[2].machinePosition - var.stepcourse_Z}
            if result == 0
                break
            G38.4 K0 X{var.axisposition[0] + var.amplitude_Z/2} Z{move.axes[2].machinePosition - var.stepcourse_Z}
            if result == 0
                break
    
        G91
        G1 Z{0.50}
        G90
    
        while iterations < {var.iter}
    
            G91
            G38.4 K0 X{var.axisposition[0] - var.amplitude_Z/2} Z{move.axes[2].machinePosition - var.stepprecise_Z}
            if result == 0
                break
            
            G91
            G38.4 K0 X{var.axisposition[0] + var.amplitude_Z/2} Z{move.axes[2].machinePosition - var.stepprecise_Z}
            if result == 0
                break

    if abs(param.Z) > 5 ; T1 if greater that 5

        while iterations < {var.iter}

            G38.4 K0 U{var.axisposition[3] - var.amplitude_Z/2} Z{move.axes[2].machinePosition - var.stepcourse_Z}
            if result == 0
                break
            G38.4 K0 U{var.axisposition[3] + var.amplitude_Z/2} Z{move.axes[2].machinePosition - var.stepcourse_Z}
            if result == 0
                break
    
        G91
        G1 Z{0.50}
        G90
    
        while iterations < {var.iter}
    
            G38.4 K0 U{var.axisposition[3] - var.amplitude_Z/2} Z{move.axes[2].machinePosition - var.stepprecise_Z}
            if result == 0
                break
            G38.4 K0 U{var.axisposition[3] + var.amplitude_Z/2} Z{move.axes[2].machinePosition - var.stepprecise_Z}
            if result == 0
                break

if exists(param.Y) ; Y +- (T0 || T1)

    if abs(param.Y) < 5 ; T0 if less that 5

        while iterations < {var.iter}

            G38.4 K0 X{var.axisposition[0] - var.amplitude_XY/2} Y{move.axes[1].machinePosition + param.Y * 1 / abs(param.Y) * var.stepcourse_XY}
            if result == 0
                break
            G38.4 K0 X{var.axisposition[0] + var.amplitude_XY/2} Y{move.axes[1].machinePosition + param.Y * 1 / abs(param.Y) * var.stepcourse_XY}
            if result == 0
                break

        G91
        G1 Y{-0.50 * param.Y * 1 / abs(param.Y)}
        G90

        while iterations < {var.iter}

            G91
            G38.4 K0 X{var.axisposition[0] - var.amplitude_XY/2} Y{move.axes[1].machinePosition + param.Y * 1 / abs(param.Y) * var.stepprecise_XY}
            if result == 0
                break
            
            G91
            G38.4 K0 X{var.axisposition[0] + var.amplitude_XY/2} Y{move.axes[1].machinePosition + param.Y * 1 / abs(param.Y) * var.stepprecise_XY}
            if result == 0
                break

    if abs(param.Y) > 5 ; T1 if greater that 5

        while iterations < {var.iter}

            G38.4 K0 U{var.axisposition[3] - var.amplitude_XY/2} Y{move.axes[1].machinePosition + param.Y * 1 / abs(param.Y) * var.stepcourse_XY}
            if result == 0
                break
            G38.4 K0 U{var.axisposition[3] + var.amplitude_XY/2} Y{move.axes[1].machinePosition + param.Y * 1 / abs(param.Y) * var.stepcourse_XY}
            if result == 0
                break

        G91
        G1 Y{-0.50 * param.Y * 1 / abs(param.Y)}
        G90

        while iterations < {var.iter}

            G91
            G38.4 K0 U{var.axisposition[3] - var.amplitude_XY/2} Y{move.axes[1].machinePosition + param.Y * 1 / abs(param.Y) * var.stepprecise_XY}
            if result == 0
                break
            
            G91
            G38.4 K0 U{var.axisposition[3] + var.amplitude_XY/2} Y{move.axes[1].machinePosition + param.Y * 1 / abs(param.Y) * var.stepprecise_XY}
            if result == 0
                break

if exists(param.X) ; X+- (T0 || T1)

    if abs(param.X) < 5 ; T0 if less that 5

       while iterations < {var.iter}       

           G38.4 K0 Y{var.axisposition[1] - var.amplitude_XY/2} X{move.axes[0].machinePosition + param.X * 1 / abs(param.X) * var.stepcourse_XY}
           if result == 0
               break
           G38.4 K0 Y{var.axisposition[1] + var.amplitude_XY/2} X{move.axes[0].machinePosition + param.X * 1 / abs(param.X) * var.stepcourse_XY}
           if result == 0
               break

       G91
       G1 X{-0.50 * param.X * 1 / abs(param.X)}
       G90

       while iterations < {var.iter}
           G91
           G38.4 K0 Y{var.axisposition[1] - var.amplitude_XY/2} X{move.axes[0].machinePosition + param.X * 1 / abs(param.X) * var.stepprecise_XY}
           if result == 0
               break
           
           G91
           G38.4 K0 Y{var.axisposition[1] + var.amplitude_XY/2} X{move.axes[0].machinePosition + param.X * 1 / abs(param.X) * var.stepprecise_XY}
           if result == 0
               break


    if abs(param.X) > 5 ; T1 if greater that 5

       while iterations < {var.iter}       

           G38.4 K0 Y{var.axisposition[1] - var.amplitude_XY/2} U{move.axes[3].machinePosition + param.X * 1 / abs(param.X) * var.stepcourse_XY}
           if result == 0
               break
           G38.4 K0 Y{var.axisposition[1] + var.amplitude_XY/2} U{move.axes[3].machinePosition + param.X * 1 / abs(param.X) * var.stepcourse_XY}
           if result == 0
               break

       G91
       G1 U{-0.50 * param.X * 1 / abs(param.X)}
       G90

       while iterations < {var.iter}

           G91
           G38.4 K0 Y{var.axisposition[1] - var.amplitude_XY/2} U{move.axes[3].machinePosition + param.X * 1 / abs(param.X) * var.stepprecise_XY}
           if result == 0
               break
           
           G91
           G38.4 K0 Y{var.axisposition[1] + var.amplitude_XY/2} U{move.axes[3].machinePosition + param.X * 1 / abs(param.X) * var.stepprecise_XY}
           if result == 0
               break



M400
G4 P400

echo "X"^{move.axes[0].machinePosition}^" Y"^{move.axes[1].machinePosition}^" Z"^{move.axes[2].machinePosition}^" U"^{move.axes[3].machinePosition}

G90
M558 K0 P8 C"1.io4.in" H5 F300 T18000
M98 P"0:/user/probeoffset.g"                       ; load global variablesif !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed || !move.axes[3].homed