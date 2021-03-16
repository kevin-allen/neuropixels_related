/*
part used to hold the neuropixels probe

*/

$fs=0.1;
$fn=20;
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

module stereotaxic_c_clamp_simple (){
base_length=24; // length in the middle of the drive
base_width=15; // width in the middle of the drive
base_height=10; //
base_shift=2;
post_length=11.3;
post_width=10.3;
rounding_radius=1.0; // radius of circles that rounds the corners 
fs=0.1;

screw_diameter=4.8;
screw_length=25;

 difference(){
    union(){
     hull(){    
            // place 4 circles in the corners, with the given radius
      translate([(base_length/2)-(rounding_radius)+base_shift, (-base_width/2)+(rounding_radius),0])
      cylinder(r=rounding_radius,h=base_height,$fs=fs);
      translate([(-base_length/2)+(rounding_radius)+base_shift, (-base_width/2)+(rounding_radius),0])
      cylinder(r=rounding_radius,h=base_height,$fs=fs);
      translate([(-base_length/2)+(rounding_radius)+base_shift, (base_width/2)-(rounding_radius),0])
      cylinder(r=rounding_radius,h=base_height,$fs=fs);
      translate([(base_length/2)-(rounding_radius)+base_shift, (base_width/2)-(rounding_radius),0])
      cylinder(r=rounding_radius,h=base_height,$fs=fs);
        }     
    
    }  
    translate([0,0,base_height/2]) rotate([0,90,0]) cylinder(h=screw_length,r=screw_diameter/2,$fs=fs);
    translate([-(post_length+1)/2,-(post_width+1)/2,-0.5]) cube([post_length+1,post_width+1,base_height+1]);
    
    translate([-base_length/2+base_shift-0.5,-base_width-3,base_height*2/3]) rotate([-20,0,0])  cube([base_length+1,10,base_height]);
    translate([-base_length/2+base_shift-0.5,base_width/2+1,base_height*1/3]) rotate([20,0,0])  cube([base_length+1,10,base_height]);
    translate([-base_length/2+base_shift-6,-base_width/2-1,base_height*2/3]) rotate([0,30,0])  cube([5+1,base_width+2,base_height]);
}
}

module stereotaxic_holder_microdrive(height=4.5, width = 7.5, length = 20, holderScrewXSpacing=10.2){
    difference(){
        union(){
    cube([length,width,height]);
    translate([28,4,4.5])rotate([180,0,0])stereotaxic_c_clamp_simple();
        }
    //holes for the microdrive screws
    translate([length/2-holderScrewXSpacing/2-2,width/2,-0.1])cylinder(d=1.3,h=4.7);
    translate([length/2+holderScrewXSpacing/2-2,width/2,-0.1])cylinder(d=1.3,h=4.7);
    
    // make sure the screw holes are not blocked
    translate([length/2-holderScrewXSpacing/2-2,width/2,height-0.5])cylinder(d1=1.3,d2=2.5,h=1.1);
    translate([length/2+holderScrewXSpacing/2-2,width/2,height-0.5])cylinder(d1=1.3,d2=2.5,h=1.1);
        
    }
}

stereotaxic_holder_microdrive();
