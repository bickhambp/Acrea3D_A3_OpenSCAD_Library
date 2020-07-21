// Acrea 3D_Lib

/** pinhole builds a pinhole given a height diameter and axis The origin of the pinhole is the center of one side of the pinhole, which would be the side on the edge of the design, and the cylinder going positively into the design.
    @param A3_height is the length of the cylinder
    @param A3_Diameter is the diameter of the cylinder
    @param A3_Direction a string ("UP", "DOWN", "N", "E", "S", "W") that points the cylinder one of the six cardinal directions respectively*/
module A3_pinhole(A3_Height, A3_Diameter, A3_Direction, A3_NumberSides = 50){
    $fn = A3_NumberSides;
    AF_xRotate = A3_Direction == "UP" ? 0 
        : A3_Direction == "DOWN" ? 180 
        : A3_Direction == "N" ? -90 
        : A3_Direction == "E" ? 0 
        : A3_Direction == "S" ? 90 
        : 0;
    AF_yRotate = A3_Direction == "UP" ? 0 
        : A3_Direction == "DOWN" ? 0 
        : A3_Direction == "N" ? 0 
        : A3_Direction == "E" ? 90 
        : A3_Direction == "S" ? 0 
        : -90;
    rotate([AF_xRotate, AF_yRotate, 0])
    cylinder(h = A3_Height, d=A3_Diameter);
}
// End Module


/**line creates a connection channels between two points given the width and the height
@param p1 and p2 are the first points given as lists [x,y,z]
@param width is the width of the channel
@param height is the height of the channel
@param centralize is a bool that determines of the channels are built with the origin on the corner, or the center
*/
module A3_channel(A3_P1,A3_P2, A3_Width, A3_Height, A3_Centralize = true) {
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
module A3_polyChannel(A3_Points, A3_Width, A3_Height, A3_Centralize = true) {
    module AF_polyChannel_inner(A3_Points, AF_index) {
        if(AF_index < len(A3_Points)) {               //This if statement with the recursion below will cycle through the list of points
            A3_channel(A3_Points[AF_index - 1], A3_Points[AF_index], A3_Width, A3_Height, A3_Centralize);
            AF_polyChannel_inner(A3_Points, AF_index + 1);
        }
    }
    AF_polyChannel_inner(A3_Points, 1);
}
//End Module

/*
serpentin2D creates a serpentinge across a single plane. 
@A3_chanCrossSection [int,int] the width and the height of the channels in mm
@A3_globalSize [int,int] The length and width of the entire serpentine structure viewed from above in mm
@A3_serpentineLength gives the total length of the channel. If A3_serpentineLength is not 0 either the number of channels needs to be given with the A3_period or the global size needs to be given but not both
@A3_numChans is the number of lengths of the serpentine there are 
@A3_period is the A3_period length between lengths of the serpentine
*/
module A3_serpentine2D(A3_chanCrossSection, A3_globalSize = [0,0], A3_serpentineLength = 0, A3_numChans = 0, A3_period = 0, A3_center = true){
    if(A3_serpentineLength != 0){
         if(A3_numChans != 0 && A3_period != 0){
             A3_globalLength = A3_numChans * A3_period;
             A3_globalWidth = (A3_serpentineLength - A3_globalLength) / (A3_numChans);
             A3_xTrans = A3_center == true ? -A3_globalLength / 2 : 0;
             for(i = [0:A3_numChans]){
                 if(i == 0){
                     A3_p1 = [i * A3_period,0,0];
                     A3_p2 = [i * A3_period,pow(-1, i+1) * A3_globalWidth/2,0];
                     A3_p3 = [(i+1) * A3_period,pow(-1,i+1) * A3_globalWidth/2,0];
                     translate([A3_xTrans,0,0])
                     A3_polyChannel([A3_p1,A3_p2,A3_p3],A3_chanCrossSection[0],A3_chanCrossSection[1]);
                 }
                 else if(i == A3_numChans){
                     A3_p1 = [i * A3_period,pow(-1,i) * A3_globalWidth/2,0];
                     A3_p2 = [i * A3_period,0,0];
                     translate([A3_xTrans,0,0])
                     A3_polyChannel([A3_p1,A3_p2],A3_chanCrossSection[0],A3_chanCrossSection[1]); 
                 }
                 else{
                     A3_p1 = [i * A3_period,pow(-1,i) * A3_globalWidth/2,0];
                     A3_p2 = [i * A3_period,pow(-1, i+1) * A3_globalWidth/2,0];
                     A3_p3 = [(i+1) * A3_period,pow(-1,i+1) * A3_globalWidth/2,0];
                     translate([A3_xTrans,0,0])
                     A3_polyChannel([A3_p1,A3_p2,A3_p3],A3_chanCrossSection[0],A3_chanCrossSection[1]);
                 }
             }
         }
         else if(A3_globalSize != [0,0]){
             A3_xTrans = A3_center == true ? -A3_globalSize[0]/2 : 0;
             A3_numChans = (A3_serpentineLength - A3_globalSize[0])/A3_globalSize[1];
             A3_period = A3_globalSize[0]/A3_numChans;
             A3_globalWidth = A3_globalSize[1];
             A3_globalLength = A3_globalSize[0];
             for(i = [0:A3_numChans]){
                 if(i == 0){
                     A3_p1 = [i * A3_period,0,0];
                     A3_p2 = [i * A3_period,pow(-1, i+1) * A3_globalWidth/2,0];
                     A3_p3 = [(i+1) * A3_period,pow(-1,i+1) * A3_globalWidth/2,0];
                     translate([A3_xTrans,0,0])
                     A3_polyChannel([A3_p1,A3_p2,A3_p3],A3_chanCrossSection[0],A3_chanCrossSection[1]);
                 }
                 else if(i >= A3_numChans - 1){
                     A3_p1 = [i * A3_period,pow(-1,i) * A3_globalWidth/2,0];
                     A3_p2 = [i * A3_period,0,0];
                     translate([A3_xTrans,0,0])
                     A3_polyChannel([A3_p1,A3_p2],A3_chanCrossSection[0],A3_chanCrossSection[1]); 
                 }
                 else{
                     A3_p1 = [i * A3_period,pow(-1,i) * A3_globalWidth/2,0];
                     A3_p2 = [i * A3_period,pow(-1, i+1) * A3_globalWidth/2,0];
                     A3_p3 = [(i+1) * A3_period,pow(-1,i+1) * A3_globalWidth/2,0];
                     translate([A3_xTrans,0,0])
                     A3_polyChannel([A3_p1,A3_p2,A3_p3],A3_chanCrossSection[0],A3_chanCrossSection[1]);
                 }
             }             
         }
         else{echo("Serpentine after Length not sufficiently defined");}
    }
    else if (A3_globalSize != [0,0]){
        
    }
    else{
        echo("Serpentine not sufficiently defined");
    }
}