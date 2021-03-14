$fs=0.1;
$fn=20;

/*

plastic parts for neuropixels1.0 probe implantation


*/

module screw_M1(length=6.5, head_length=0.65, head_diameter=2.0, thread_diameter=0.95){
    cylinder(h=length,d=thread_diameter);
    cylinder(h=head_length,d=head_diameter);
}



module plus(diameter=0.5, length=3){
    translate([-length/2,0,0])rotate([0,90,0])cylinder(d=diameter,h=length);
    translate([0,length/2,0])rotate([90,0,0])cylinder(d=diameter,h=length);
    translate([0,0,-length/2])rotate([0,0,0])cylinder(d=diameter,h=length);
}

module grid(diameter=0.4, unit_space = 2, unit_length= 2, xn = 10, yn= 10, zn = 3)
{
    for ( x = [0 : xn-1] ){
        for( y = [0 : yn-1]){
            for ( z = [0 : zn-1]){
        translate([x*unit_space,y*unit_space,z*unit_space])plus(diameter=diameter,length=unit_length);            
        }
    }
   }
}


// hexagone shape for nuts 
function cot(x)=1/tan(x);
module hexagone (height=0.95,width=3){
    angle = 360/6;		// 6 pans
	cote = width * cot(angle);
	translate([0,0,height/2])
    union()
	{
		rotate([0,0,0])
			cube([width,cote,height],center=true);
		rotate([0,0,angle])
			cube([width,cote,height],center=true);
		rotate([0,0,2*angle])
			cube([width,cote,height],center=true);
	}
}
module nut(width=3,height=0.95,hole_diameter=1.1){
    difference(){
        hexagone(height=height,width=width);
        translate([0,0,-0.5])cylinder(d=hole_diameter,h=height+1);
    }
}


module narrowNut(width=3,height=0.95,hole_diameter=1.1){
    difference(){
    nut(width,height,hole_diameter);
        translate([-width/2,width/2,-0.1])cube([width,width,height+0.2]);
        translate([-width/2,-width-width/2,-0.1])cube([width,width,height+0.2]);
    }
}


// to attache 2 parts
module captive_nut(width = 3.6, nut_width = 3.1, height_nut = 1, height_below=1.1, height_above=0.6,screw_diameter = 1.3,positive=true){
    if(positive){ // we want the structure
    difference(){
    // body
    hexagone(height=height_nut+height_below+height_above,width=width);
    // entry point for nut
    hull(){
        translate([-0.2,0,height_below])hexagone(height=height_nut,width=nut_width);
        translate([width,0,height_below])hexagone(height=height_nut,width=nut_width);
    }
    // hole for the screw
    translate([0,0,height_below])cylinder(h=height_nut+height_above+1,d=screw_diameter);
    }}
    else{ // just get the space for the screw
     hull(){
        translate([-0.2,0,height_below])hexagone(height=height_nut,width=nut_width);
        translate([width,0,height_below])hexagone(height=height_nut,width=nut_width);
    }
    }
    
}

// size of the Neuropixels1.0 probe
probeBoxS=[6.2, 1.8,10.4];
probeTransitionZ = 1.0;
probePcbS=[8,1.4,11.4];
probeShankS = [0.3,0.3,11.9];


// this is a Neuropixels1.0 probe
module probe(boxS=[6.2, 1.8,10.4],
             transitionZ = 1.0,
             pcbS=[8,1.4,11.4],
             shankS = [0.3,0.3,11.9])
{
    // shank
    translate([-shankS[0]/2,-shankS[1]/2,0])cube(shankS);
    
    // box above shank
    translate([-boxS[0]/2,-boxS[1]/2,shankS[2]])cube(boxS);
    
    // transition
    hull(){
    translate([-boxS[0]/2,-boxS[1]/2,shankS[2]+boxS[2]-0.1])cube([boxS[0],boxS[1],0.1]);
    translate([-pcbS[0]/2,-pcbS[1]/2,shankS[2]+boxS[2]+transitionZ+0.1])cube([pcbS[0],pcbS[1],0.1]);  
            
    }
    
    // pcb
    translate([-pcbS[0]/2,-pcbS[1]/2,shankS[2]+boxS[2]+transitionZ])cube(pcbS);
}


// plate to mount the probe on
module probePlate(plateS=[8,2.5,23.8],
                  tol = 0.5,
                  shankHeight=12,
                  screwXSpacing=7,
                  screwZSpacing=15,
                  screwWidth=3.0,
                  screwBackFrontSpacing=8.3,
                  nutHeight = 1, 
                  belowNutHeight=1.1, 
                  aboveNutHeight=0.6,
                  wingS=[0.65,2,3]
){
                 
   difference(){
    union(){
    // square shape, where the probe body seats
    translate([-plateS[0]/2,-plateS[1]/2,shankHeight])cube(plateS);
    // add connection point to connect to front screw
    difference(){
        scaleF=0.8;
        h=4.5;
        translate([0,plateS[1]/2,shankHeight]) scale([1,scaleF,1]) cylinder(d=plateS[0],h=h);
        translate([0,plateS[1]/2,shankHeight-0.1]) scale([1,scaleF,1])cylinder(d=plateS[0]-1.2,h=h+0.2);
        translate([-50,plateS[1]/2-100.1,shankHeight-0.1])cube([100,100,100]);
    }
    }
    // remove the probe
    translate([0,0.6,0])probe(boxS=[probeBoxS[0]+tol,probeBoxS[1],probeBoxS[2]],
                            pcbS=[probePcbS[0]+tol,probePcbS[1],probePcbS[2]+2]);
   }
   
   
   
   // add 3 attachment/hole for screws that will secure the probePlate to the probePlateCasing
    yBack=-screwWidth/2-plateS[1]/2;
    yFront=yBack+screwBackFrontSpacing;
    translate([-screwXSpacing/2,yBack,shankHeight])rotate([0,0,90])narrowNut(height=4.5,width = screwWidth,hole_diameter=1.3);
    translate([screwXSpacing/2,yBack,shankHeight])rotate([0,0,90])narrowNut(height=4.5,width = screwWidth,hole_diameter=1.3);
   translate([0,yFront,shankHeight])rotate([0,0,90])narrowNut(height=4.5,width = screwWidth,hole_diameter=1.3); 
 
   
   
   
   // add 2 captive nuts to connect to the stereotaxic arm
   extraBelow=1.5;
   translate([-screwXSpacing/2, -screwWidth/2-plateS[1]/2,
               plateS[2]+shankHeight-nutHeight -belowNutHeight - aboveNutHeight-extraBelow]) rotate([0,0,270])captive_nut(height_nut=nutHeight, height_below=belowNutHeight+extraBelow, height_above=aboveNutHeight);
   translate([screwXSpacing/2, -screwWidth/2-plateS[1]/2,
               plateS[2]+shankHeight-nutHeight -belowNutHeight - aboveNutHeight-extraBelow]) rotate([0,0,270])captive_nut(height_nut=nutHeight, height_below=belowNutHeight+extraBelow, height_above=aboveNutHeight);
   
   
   
}

// part to which you screw the probe plate to
// the probePlateCasing will be cemented to skull and is not recoverable
module probePlateCasing(lowerOutDia=4.5,
                 lowerInDia=3.5,
                 coneHeight=4,
                 higherOutDia=7,
                 higherInDia=5,
                 coneYOffset=0.5,
                 screwYOffset=-2.8,
                 screwBackFrontSpacing=8.3,
                 screwXSpacing=7,
                 screwZSpacing=15,
                 nutHeight = 1, 
                 belowNutHeight=1.1, 
                 aboveNutHeight=0.6,

)
{
    // for the y coordinates of nuts
    backY=screwYOffset;
    frontY = screwYOffset+screwBackFrontSpacing;
    
    difference(){
    // cone at base
    union(){
    hull(){
    translate([0,coneYOffset,0])cylinder(d=lowerOutDia,h=1);
    translate([0,coneYOffset,coneHeight])cylinder(d=higherOutDia,h=1);
    }       
    // 
    // captive nuts
    translate([screwXSpacing/2,
               backY,
               coneHeight+1-nutHeight-aboveNutHeight-belowNutHeight]) rotate([0,0,0])captive_nut(height_nut=nutHeight, height_below=belowNutHeight, height_above=aboveNutHeight);
    
    translate([-screwXSpacing/2,
               backY,
               coneHeight+1-nutHeight-aboveNutHeight-belowNutHeight]) rotate([0,0,180])captive_nut(height_nut=nutHeight, height_below=belowNutHeight, height_above=aboveNutHeight);
    
    translate([0,
               frontY,
               coneHeight+1-nutHeight-aboveNutHeight-belowNutHeight]) rotate([0,0,90])captive_nut(height_nut=nutHeight, height_below=belowNutHeight, height_above=aboveNutHeight);
    }
    
    //empty the inside of the cone
    translate([0,coneYOffset,-0.01])hull(){
    cylinder(d=lowerInDia,h=1.2);
    translate([0,0,coneHeight])cylinder(d=higherInDia,h=1.2);
    }    
        
    // empty the hole of the captive nuts
     translate([screwXSpacing/2,
               backY,
               coneHeight+1-nutHeight-aboveNutHeight-belowNutHeight]) rotate([0,0,0])captive_nut(height_nut=nutHeight, height_below=belowNutHeight, height_above=aboveNutHeight,positive=false);
    translate([-screwXSpacing/2,
               backY,
               coneHeight+1-nutHeight-aboveNutHeight-belowNutHeight]) rotate([0,0,180])captive_nut(height_nut=nutHeight, height_below=belowNutHeight, height_above=aboveNutHeight,positive=false);
    translate([0,
               frontY,
               coneHeight+1-nutHeight-aboveNutHeight-belowNutHeight]) rotate([0,0,90])captive_nut(height_nut=nutHeight, height_below=belowNutHeight, height_above=aboveNutHeight,positive=false);
}

    
    
    
}



probePlate();
//color("blue")translate([0,0.7,0])probe();
translate([0,0,6.5])probePlateCasing();