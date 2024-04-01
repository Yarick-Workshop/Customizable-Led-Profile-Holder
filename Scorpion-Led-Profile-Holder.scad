//TODO rename parameters

// TODO GENERIC
wallThikness = 4;


/* TODO handlEEE :) */
handlerHeight = 60;
handlerInternalDiameter = 14;
handlerTieCaveOffset = 15;
handlerBallDiameter = 17.5;


/* led holder  */ 
ledHolderHeigh =  70;
ledHolderTieCaveOffset =  5;
ledHeatsinkHeigh = 7;
ledHeatsinkWidth = 18;

/* cable tie */
cableTieWidth = 4;

// calculated 

// SEE  undersized holes here: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/The_OpenSCAD_Language#cylinder

handlerExternalDiameter = (max(handlerInternalDiameter, handlerBallDiameter + wallThikness);
ledHolderExternalDiameter = (
    sqrt(ledHeatsinkHeigh * ledHeatsinkHeigh + 
            ledHeatsinkWidth * ledHeatsinkWidth / 4) * 2 
            + wallThikness);

handlerExternalDiameterFixed = handlerExternalDiameter / cos(180 / 8);
ledHolderExternalDiameterFixed = ledHolderExternalDiameter / cos(180 / 8);

delta = 0.01;//to hide artefacts

handler();

translate([0, (handlerHeight + ledHolderExternalDiameter) * 0.5, 0])
    rotate([0, 0, 90])
        led_holder();
        
module handler()
{
    translate([0, 0, handlerExternalDiameter * 0.5])
        rotate([90, 0, 0])
            difference()
            {
                workpiece_with_tie_cave(diameter = handlerExternalDiameter,
                    diameter_fixed = handlerExternalDiameterFixed,
                    height = handlerHeight,
                    cave_offset = handlerTieCaveOffset);
                
                // groove
                cylinder(h = handlerHeight + delta, d = handlerInternalDiameter, center=true, $fn=360);
                
                cutter(handlerExternalDiameter);

                translate([0, 0, -(handlerHeight - handlerBallDiameter) * 0.5])
                    sphere(d=handlerBallDiameter, $fn=360);
            }
}

module led_holder()
{
    translate([0, 0, ledHolderExternalDiameter * 0.5])
        rotate([90, 0, 0])
            difference()
            {
                union()
                {
                    workpiece_with_tie_cave(diameter = ledHolderExternalDiameter,
                        diameter_fixed = ledHolderExternalDiameterFixed,
                        height = ledHolderHeigh,
                        cave_offset = ledHolderTieCaveOffset);
                    rotate([0, 90, 0])
                        translate([0, (handlerExternalDiameter - ledHolderExternalDiameter) * 0.5, -ledHolderExternalDiameter * 0.25 - delta])
                            workpiece(diameter = handlerExternalDiameter,
                                diameter_fixed = handlerExternalDiameterFixed,
                                  height = ledHolderExternalDiameter * 0.5);
                }
                
                // a groove for sinking the heat from the LED profile
                // Commented out To sink just in the half to the holder translate([0, -ledHeatsinkHeigh * 0.5, 0])
                cube([ledHeatsinkWidth, ledHeatsinkHeigh, ledHolderHeigh + delta], center=true);
                translate([ledHolderExternalDiameterFixed * 0.5, 0, 0])
                    rotate([90, 0, 0])
                        scale([ledHolderExternalDiameterFixed * 1.4, ledHolderHeigh - 3.5 * ledHolderTieCaveOffset, 1])
                        cylinder(h=ledHolderExternalDiameterFixed + delta, d=1, center=true, $fn=8);
            }
}

module workpiece_with_tie_cave(diameter, diameter_fixed, height, cave_offset)
{
    difference()
    {
        workpiece(diameter, diameter_fixed, height);
        
        // для стяжки
        translate([0, 0, height * 0.5 - cave_offset])
            cutter(diameter);
        translate([0, 0, -height * 0.5 + cave_offset])
            cutter(diameter);
    }
}

module workpiece(diameter, diameter_fixed, height)
{
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
        cube([diameter + delta, diameter + delta, cableTieWidth], center = true);
        //translate([0, -sqrt(2 * diameter * diameter) * 0.5, 0])// too thick
        translate([0, - diameter * 0.5, 0])
            rotate([0, 0, 45])
            cube([diameter, diameter, cableTieWidth + delta], center = true);
    }
}