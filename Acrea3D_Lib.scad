// Acrea 3D_Lib

/** pinhole builds a pinhole given a height diameter and axis The origin of the pinhole is the center of one side of the pinhole, which would be the side on the edge of the design, and the cylinder going positively into the design.
    @param A3_height is the length of the cylinder
    @param A3_Diameter is the diameter of the cylinder
    @param A3_Axis an integer (0 or 1) that points the cylinder into the x or y axis respectively*/
module A3_pinhole(A3_Height, A3_Diameter, A3_Axis){
    yRotate = A3_Axis == 1 ? 1 : 0;
    xRotate = A3_Axis == 1 ? 0 : 1;
    yTranslate = A3_Axis == 0 ? A3_Height : 0;
    translate([0,yTranslate, 0])
    rotate([90*xRotate, 90*yRotate, 0])
    cylinder(h = A3_Height, d=A3_Diameter);
}
// End Module

/** pinholeChain builds a chain of pinholes into either the y axis or the x axis
    @param A3_NumPins is the number of pinholes in the chain
    @param A3_Period is the period distance between the pinholes
    @param A3_Height is the length of the pinhole
    @param A3_Diameter is the diameter of the pinholes
    @param A3_Axis an integer (0 or 1) that points the cylinder into the x or y axis respectively*/
module A3_pinholeChain(A3_NumPins, A3_Period, A3_Height, A3_Diameter, A3_Axis){
    chainLength = (A3_NumPins - 1)*A3_Period + A3_Diameter;
    xTrans = A3_Axis == 0 ? A3_Period : 0;
    yTrans = A3_Axis == 1 ? A3_Period : 0;
    for(i = [0:A3_NumPins - 1]){
        translate([i*xTrans, i*yTrans, 0])
        A3_pinhole(A3_Height, A3_Diameter, A3_Axis);
    }
}
//End Module

/** pinholeChain builds a chain of pinholes into either the y axis or the x axis. It centers the chain along the axis that it is built on
    @param A3_NumPins is the number of pinholes in the chain
    @param A3_Period is the period distance between the pinholes
    @param A3_Height is the length of the pinhole
    @param A3_Diameter is the diameter of the pinholes
    @param A3_Axis an integer (0 or 1) that points the cylinder into the x or y axis respectively
    @param A3_LBulk is the length of the material that */
module A3_pinholeChain(A3_NumPins, A3_Period, A3_Height, A3_Diameter, A3_Axis, A3_LBulk){
    chainLength = (A3_NumPins - 1)*A3_Period + A3_Diameter;
    lDiff = A3_LBulk - chainLength;
    cTrans = lDiff/2 + A3_Diameter/2;
    xTrans = A3_Axis == 0 ? cTrans : 0;
    yTrans = A3_Axis == 1 ? cTrans : 0;
    xStep = A3_Axis == 0 ? A3_Period : 0;
    yStep = A3_Axis == 1 ? A3_Period : 0;
    for(i = [0:A3_NumPins - 1]){
        translate([xTrans + i*xStep, yTrans + i*yStep, 0])
        A3_pinhole(A3_Height, A3_Diameter, A3_Axis);
    }
}
//End Module

/** buildPinIO builds a standard set of inputs and outputs opposite each other. */
module A3_buildPinIO(A3_NumInputs, A3_NumOutputs, A3_Axis, A3_Period, A3_Diameter, A3_Height, A3_LChainBulk, A3_DistOut, A3_HBulk){
    xTrue = A3_Axis == 1 ? 0 : 1;
    yTrue = A3_Axis == 0 ? 0 : 1;
    
    
    translate([0,0,A3_HBulk/2])
    A3_pinholeChain(A3_NumInputs, A3_Period, A3_Height, A3_Diameter, A3_Axis, A3_LChainBulk);
    
    translate([yTrue*A3_DistOut,xTrue*A3_DistOut,A3_HBulk/2])
    mirror([yTrue,xTrue,0])
    A3_pinholeChain(A3_NumOutputs, A3_Period, A3_Height, A3_Diameter, A3_Axis, A3_LChainBulk);
}
//End Module

/**pCLen get the length of the pinhole chain from the start of the first channel to the far edge of the last pinhole.
    @param A3_NumPins is the number of pins in the chain
    @param A3_Period is the period distance between the pinholes
    @param A3_Diameter is the diameter of the pinholes in the chain*/
function A3_pinholeCLen(A3_NumPins, A3_Period, A3_Diameter) = (A3_NumPins - 1)*A3_Period + A3_Diameter;
// End Function

/**line creates a connection channels between two points given the widtha nd the height
@param p1 and p2 are the first points given as lists [x,y,z]
@param width is the width of the channel
@param height is the height of the channel
@param centralize is a bool that determines of the channels are built with the origin on the corner, or the center
*/
module A3_line(A3_P1,A3_P2, A3_Width, A3_Height, A3_Centralize) {
    hull() {
        translate(A3_P1) cube([A3_Width,A3_Width,A3_Height], center = A3_Centralize);
        translate(A3_P2) cube([A3_Width,A3_Width,A3_Height], center = A3_Centralize);
    }
}
//End Module

/** polyline creates connection channels between a list of points 
    @param points is a list of points [[x1,y1,z1], [x2,y2,z2],... [xn, yn, zn]] that the line will go through sequentially
    @param width is the width of the channel
    @param height is the height of the channel
    @param centralize is a bool that determines of the channels are built with the origin on the corner, or the center*/
module A3_polyline(A3_Points, A3_Width, A3_Height, A3_Centralize) {
    module polyline_inner(A3_Points, index) {
        if(index < len(A3_Points)) {               //This if statement with the recursion below will cycle through the list of points
            A3_line(A3_Points[index - 1], A3_Points[index], A3_Width, A3_Height, A3_Centralize);
            polyline_inner(A3_Points, index + 1);
        }
    }

    polyline_inner(A3_Points, 1);
}
//End Module

/** biforcate builds the fork of a channel. The origin of the peices is the center of the base (the flat portion of the fork)
    @param A3_Period is the distance between the center of the channels being created
    @param A3_WChan is the width of the channels, along x and y axis
    @param A3_HChan is the height of the channels along the z axis
    @param A3_Buffer is the length of the fork from the relative origin
    @param A3_Face  1-6 fork faces: up, front, left, right, back, down
    @param A3_Rotation from face (0 or 1) beingeither rotated 90 not changing the fork face*/
module A3_bifork(A3_Period, A3_WChan, A3_HChan, A3_Buffer, A3_Face, A3_Rotation){
    module AF_fork(){
        BFF_TempTrans = 
            A3_Face == 1 && A3_Rotation == 0 ? [[A3_WChan,A3_WChan,A3_HChan],[A3_WChan, A3_WChan, A3_Buffer]] : 
            A3_Face == 1 && A3_Rotation == 1 ? [[A3_WChan,A3_WChan,A3_HChan],[A3_WChan, A3_WChan, A3_Buffer]] :
            A3_Face == 2 && A3_Rotation == 0 ? [[A3_WChan,A3_HChan,A3_WChan],[A3_WChan, A3_HChan, A3_Buffer]] :
            A3_Face == 2 && A3_Rotation == 1 ? [[A3_HChan,A3_WChan,A3_WChan],[A3_HChan, A3_WChan, A3_Buffer]] :
            A3_Face == 3 && A3_Rotation == 0 ? [[A3_WChan,A3_HChan,A3_WChan],[A3_WChan, A3_HChan, A3_Buffer]] :
            A3_Face == 3 && A3_Rotation == 1 ? [[A3_HChan,A3_WChan,A3_WChan],[A3_HChan, A3_WChan, A3_Buffer]] :
            A3_Face == 4 && A3_Rotation == 0 ? [[A3_WChan,A3_HChan,A3_WChan],[A3_WChan, A3_HChan, A3_Buffer]] :
            A3_Face == 4 && A3_Rotation == 1 ? [[A3_HChan,A3_WChan,A3_WChan],[A3_HChan, A3_WChan, A3_Buffer]] :
            A3_Face == 5 && A3_Rotation == 0 ? [[A3_WChan,A3_HChan,A3_WChan],[A3_WChan, A3_HChan, A3_Buffer]] :
            A3_Face == 5 && A3_Rotation == 1 ? [[A3_HChan,A3_WChan,A3_WChan],[A3_HChan, A3_WChan, A3_Buffer]] :
            A3_Face == 6 && A3_Rotation == 0 ? [[A3_WChan,A3_WChan,A3_HChan],[A3_WChan, A3_WChan, A3_Buffer]] : [[A3_WChan,A3_WChan,A3_HChan],[A3_WChan, A3_WChan, A3_Buffer]]; 
        
        cube([A3_Period + BFF_TempTrans[0][0], BFF_TempTrans[0][1], BFF_TempTrans[0][2]],center = true);
        
        translate([-A3_Period/2,  0,  BFF_TempTrans[0][2]])
        cube([BFF_TempTrans[1][0], BFF_TempTrans[1][1], BFF_TempTrans[1][2]], center = true);
        translate([A3_Period/2,  0,  BFF_TempTrans[0][2]])
        cube([BFF_TempTrans[1][0], BFF_TempTrans[1][1], A3_Buffer], center = true);
    }
    AF_Rotate = 
        A3_Face == 1 && A3_Rotation == 0 ? [0,0,0] : 
        A3_Face == 1 && A3_Rotation == 1 ? [0,0,90] :
        A3_Face == 2 && A3_Rotation == 0 ? [90,0,0] :
        A3_Face == 2 && A3_Rotation == 1 ? [90,90,0] :
        A3_Face == 3 && A3_Rotation == 0 ? [90,0,-90] :
        A3_Face == 3 && A3_Rotation == 1 ? [90,90,-90] :
        A3_Face == 4 && A3_Rotation == 0 ? [90,0,90] :
        A3_Face == 4 && A3_Rotation == 1 ? [90,90,90] :
        A3_Face == 5 && A3_Rotation == 0 ? [-90,0,0] :
        A3_Face == 5 && A3_Rotation == 1 ? [-90,90,0] :
        A3_Face == 6 && A3_Rotation == 0 ? [180,0,0] : [180,0,90];     
    AF_Translate =  
        A3_Face == 1 ? [0,0,A3_HChan/2] :
        A3_Face == 2 ? [0,-A3_WChan/2,0] :
        A3_Face == 3 ? [-A3_WChan/2,0,0] :
        A3_Face == 4 ? [A3_WChan/2,0,0] :
        A3_Face == 5 ? [0,A3_WChan/2,0] : [0,0,-A3_HChan/2];
    translate(AF_Translate)
    rotate(AF_Rotate)
    AF_fork();
}
//End Module

/** biforkChain builds a chain of biforks in the positive direction
    @param A3_NumForks is the numbetr of forks
    @param A3_Period is the distance between forks
    @param A3_ForkPeriod is the distance between fork prongs
    @param A3_WChan is the width of the channels, along x and y axis
    @param A3_HChan is the height of the channels along the z axis
    @param A3_Buffer is the length of the fork from the relative origin
    @param A3_Face  1-6 fork faces: up, front, left, right, back, down
    @param A3_Rotation from face (0 or 1) beingeither rotated 90 not changing*/
module A3_biforkChain(A3_NumForks, A3_Period, A3_ForkPeriod, A3_WChan, A3_HChan, A3_Buffer, A3_Face, A3_Rotation){
    AF_FRSum = [A3_Face, A3_Rotation];
    AF_XTrans = 
        (A3_Face == 1 || A3_Face == 2 || A3_Face == 5 || A3_Face == 6) && A3_Rotation == 1 ? 1 : 0;         //Determines if it will make a chain along the x axis
    
    AF_YTrans = 
        AF_FRSum == [1,0] || AF_FRSum == [3,1] || AF_FRSum == [6,0] || AF_FRSum == [4,1] ? 1 : 0;         // Determines if it will make a chain along the y axis
    
    AF_ZTrans = AF_XTrans == 1 || AF_YTrans == 1 ? 0 : 1; //Determines if it will make a chain along the z axis
    AF_Trans = [AF_XTrans*A3_Period, AF_YTrans*A3_Period, AF_ZTrans * A3_Period];
    
    for(i=[0:A3_NumForks - 1]){
        translate(i*AF_Trans){
            A3_bifork(A3_ForkPeriod, A3_WChan, A3_HChan, A3_Buffer, A3_Face, A3_Rotation);
        }
    }
}