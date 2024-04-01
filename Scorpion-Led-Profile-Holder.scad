//TODO rename parameters

/* TODO handlEEE :) */
handlerHeight = 60;
handlerInternalDiameter = 14;
handlerWallThikness = 5;
handlerTieCaveOffset = 15;
handlerBallDiameter = 17.5;


/* led holder  */ 
ledHolderHeigh =  70;
ledHolderTieCaveOffset =  5;
ledHeatsinkHeigh = 7;
ledHeatsinkWidth = 17;

/* cable tie */
cableTieWidth = 4;

// calculated = 
handlerExternalDiameter = max(handlerInternalDiameter, sqrt(ledHeatsinkHeigh * ledHeatsinkHeigh +
ledHeatsinkWidth * ledHeatsinkWidth / 4) * 2) + handlerWallThikness;

delta = 0.01;//to hide artefacts

handler();
translate([0, (handlerHeight + handlerExternalDiameter) * 0.5, 0])
    rotate([0, 0, 90])
        led_holder();
        
module handler()
{
    translate([0, 0, handlerExternalDiameter * 0.5])
        rotate([90, 0, 0])
            difference()
            {
                workpiece_with_tie_cave(diameter = handlerExternalDiameter,
                height = handlerHeight,
                cave_offset = handlerTieCaveOffset);
                // канавка
                cylinder(h = handlerHeight + delta, d = handlerInternalDiameter, center=true, $fn=360);
                cutter();
                translate([0, 0, -(handlerHeight - handlerBallDiameter) * 0.5])
                sphere(d=handlerBallDiameter, $fn=360);
            }
}

module led_holder()
{
    translate([0, 0, handlerExternalDiameter * 0.5])
        rotate([90, 0, 0])
            difference()
            {
                union()
                {
                    workpiece_with_tie_cave(diameter = handlerExternalDiameter,
                    height = ledHolderHeigh,
                    cave_offset = ledHolderTieCaveOffset);
                    rotate([0, 90, 0])
                        translate([0, 0, -handlerExternalDiameter * 0.25 - delta])
                            workpiece(diameter = handlerExternalDiameter, height = handlerExternalDiameter * 0.5);
                }
                
                // канавка для ленты
                // Commented out To sink just in the half to the holder translate([0, -ledHeatsinkHeigh * 0.5, 0])
                cube([ledHeatsinkWidth, ledHeatsinkHeigh, ledHolderHeigh + delta], center=true);
                translate([handlerExternalDiameter * 0.5, 0, 0])
                    rotate([90, 0, 0])
                        scale([handlerExternalDiameter * 1.4, ledHolderHeigh - 3.5 * ledHolderTieCaveOffset, 1])
                        cylinder(h=handlerExternalDiameter + delta, d=1, center=true, $fn=8);
            }
}

module workpiece_with_tie_cave(diameter, height, cave_offset)
{
    difference()
    {
        workpiece(diameter, height);
        
        // для стяжки
        translate([0, 0, height * 0.5 - cave_offset])
            cutter();
        translate([0, 0, -height * 0.5 + cave_offset])
            cutter();
    }
}

module workpiece(diameter, height)
{
    //external figure 
    difference()
    {
        rotate([0, 0, 360 / 8 / 2])
            cylinder(h = height, d = diameter, center=true, $fn=8);
        // remove half of the figure
        translate([0, diameter * 0.5, 0])
            cube([diameter, diameter, height + delta], center=true);
    }
}

module cutter()
{
    difference()
    {
        cube([handlerExternalDiameter, handlerExternalDiameter, cableTieWidth], center = true);
        //translate([0, -sqrt(2 * handlerExternalDiameter * handlerExternalDiameter) * 0.5, 0])// too thick
        translate([0, - handlerExternalDiameter * 0.5, 0])
            rotate([0, 0, 45])
            cube([handlerExternalDiameter, handlerExternalDiameter, cableTieWidth + delta], center = true);
    }
}