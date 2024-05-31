/* [Generic] */
min_Wall_Thikness = 4;
cable_Tie_Cave_Width = 4;

/* [Handle] */
handler_Length = 60;
handler_Internal_Diameter = 14;
handler_Tie_Cave_Offset = 15;
handler_Ball_Diameter = 17.5;

/* [Profile holder]  */ 
led_Holder_Length = 70;
led_Holder_Tie_Cave_Offset = 5;
led_Profile_Heigh = 7;
led_Profile_Width = 18;

/* [Hidden] */
//to hide artefacts
delta = 0.01;

handler_External_Diameter = max(handler_Internal_Diameter, handler_Ball_Diameter) + 2 * min_Wall_Thikness;
led_Holder_External_Diameter = sqrt(led_Profile_Heigh * led_Profile_Heigh + 
            led_Profile_Width * led_Profile_Width / 4) * 2 
            + 2 * min_Wall_Thikness;

// SEE  undersized holes here: 
// https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#cylinder
// to understan why
handler_External_Diameter_Fixed = handler_External_Diameter / cos(180 / 8);
led_Holder_External_Diameter_Fixed = led_Holder_External_Diameter / cos(180 / 8);

translate([0,0,20]) 
rotate([180,0,0])
    holder();

color("Black", 0.4)
    translate([0, 0, 7]) 
    rotate([-90, 0, 0]) 
        cylinder(h = 200, d = handler_Internal_Diameter);

module holder()
{
    handler();

    translate([0, (handler_Length + led_Holder_External_Diameter) * 0.5, 0])
        rotate([0, 0, 90])
            led_holder();
}
        
module handler()
{
    translate([0, 0, handler_External_Diameter * 0.5])
        rotate([90, 0, 0])
            difference()
            {
                workpiece_with_tie_cave(diameter = handler_External_Diameter,
                    diameter_fixed = handler_External_Diameter_Fixed,
                    height = handler_Length,
                    cave_offset = handler_Tie_Cave_Offset);
                
                // groove
                cylinder(h = handler_Length + delta, d = handler_Internal_Diameter, center=true, $fn=360);
                
                cutter(handler_External_Diameter);

                translate([0, 0, -(handler_Length - handler_Ball_Diameter) * 0.5])
                    sphere(d=handler_Ball_Diameter, $fn=360);
            }
}

module led_holder()
{
    translate([0, 0, led_Holder_External_Diameter * 0.5])
        rotate([90, 0, 0])
        {
            difference()
            {
                union()
                {
                    workpiece_with_tie_cave(diameter = led_Holder_External_Diameter,
                        diameter_fixed = led_Holder_External_Diameter_Fixed,
                        height =led_Holder_Length,
                        cave_offset =led_Holder_Tie_Cave_Offset);
                    rotate([0, 90, 0])
                        translate([0, (handler_External_Diameter - led_Holder_External_Diameter) * 0.5, -led_Holder_External_Diameter * 0.25 - delta])
                            workpiece(diameter = handler_External_Diameter,
                                diameter_fixed = handler_External_Diameter_Fixed,
                                  height = led_Holder_External_Diameter * 0.5);
                }
                
                // a groove for sinking the heat from the LED profile
                // To sink just in the half to the holder translate([0, -led_Profile_Heigh * 0.5, 0])
                cube([led_Profile_Width, led_Profile_Heigh, led_Holder_Length + delta], center=true);
                translate([led_Holder_External_Diameter_Fixed * 0.5, 0, 0])
                    rotate([90, 0, 0])
                        scale([led_Holder_External_Diameter_Fixed * 1.4, led_Holder_Length - 3.5 * led_Holder_Tie_Cave_Offset, ])
                            cylinder(h=led_Holder_External_Diameter_Fixed + delta, d=1, center=true, $fn=8);
            }
            color([0.69,0.69,0.69], 0.25)
                cube([led_Profile_Width, led_Profile_Heigh, 500], center=true);
        }
}
module workpiece_with_tie_cave(diameter, diameter_fixed, height, cave_offset)
{
    difference()
    {
        workpiece(diameter, diameter_fixed, height);
        
        // tie cave
        translate([0, 0, height * 0.5 - cave_offset])
            cutter(diameter);
        translate([0, 0, -height * 0.5 + cave_offset])
            cutter(diameter);
    }
}

module workpiece(diameter, diameter_fixed, height)
{
    //color("Brown")
    //external figure 
    difference()
    {
        rotate([0, 0, 360 / 8 / 2])
            cylinder(h = height, d = diameter_fixed, center=true, $fn=8);
        
        // remove half of the figure
        translate([0, diameter * 0.5, 0])
            cube([diameter + delta, diameter, height + delta], center=true);
    }
}

module cutter(diameter)
{
    difference()
    {
        cube([diameter + delta, diameter + delta, cable_Tie_Cave_Width], center = true);
        translate([0, - diameter * 0.5, 0])
            rotate([0, 0, 45])
            cube([diameter, diameter, cable_Tie_Cave_Width + delta], center = true);
    }
}