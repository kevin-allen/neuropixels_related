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
                  screwYSpacing=7,
                  screwZSpacing=15,
                  screwWidth=3.5
){
                 
   difference(){
    // square shape
    translate([-plateS[0]/2,-plateS[1]/2,shankHeight])cube(plateS);
    // remove the probe
    translate([0,0.6,0])probe(boxS=[probeBoxS[0]+tol,probeBoxS[1],probeBoxS[2]],
                            pcbS=[probePcbS[0]+tol,probePcbS[1],probePcbS[2]+2]);
   }
   
   // add 3 attachment/hole for screws that will secure the probePlate to the probePlateCasing
   difference(){
   union(){
    translate([-screwYSpacing/2,-screwWidth/2-plateS[1]/2,shankHeight])rotate([0,0,90])nut(height=4.5,width = screwWidth,hole_diameter=1.3);
    translate([screwYSpacing/2,-screwWidth/2-plateS[1]/2,shankHeight])rotate([0,0,90])nut(height=4.5,width = screwWidth,hole_diameter=1.3);
    translate([0,-screwWidth/2-plateS[1]/2,shankHeight+screwZSpacing])rotate([0,0,90])nut(height=4.5,width = screwWidth,hole_diameter=1.3);
   }
   // remove some materials from the nuts (could be implement in nut module)
   translate([-(screwWidth+1)/2,-5,shankHeight-0.1])cube([screwWidth+1,10,10]);
   translate([screwWidth/2-0.25,-5,shankHeight+screwZSpacing-0.1])cube([screwWidth+1,10,10]);
   translate([-(screwWidth+1)-screwWidth/2+0.25,-5,shankHeight+screwZSpacing-0.1])cube([screwWidth+1,10,10]);
   
   
   }
   
   
   
}


probePlate();
color("blue")translate([0,0.7,0])probe();
