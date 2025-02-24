/**
Parametric filament spool desiccant container.

This container can be filled with loose desiccant pearls and placed in the center hole of a filament spool,
to keep it dry during storage.
It has a dense grid of square holes on all sides, which allows air to flow through the container and reach the desiccant pearls.

The lid can be put on the container and secured by a short twist.
*/


/* [container dimmensions] */
/*
The container is the main body of the design.
*/

// Overall diameter of the container. Use calipers to measure your spool. Substract 0.2 mm as a safety
// margin.
container_diameter = 52; // .1

// Length of the container. This should be the same as the height of your spool.
container_length = 67; // .1
// Thickness of the container walls. 2 mm is a good value for a sturdy container, 1 mm is too thin already.
wall_thickness = 2; //.1

/* [Air-flow grid dimmensions] */
/*
The air-flow grid is a dense grid of holes on all sides of the container.
This allows air to flow through the container and reach the desiccant pearls.
The holes are designed to be squares, but they could be any regular polygon by tweaking the
grid_fn parameter. Values other than 4 are not tested yet and will reuire some code
changes to look good and be printable.
*/

// Size of a square hole in the air-flow grid. This is from corner to corner.
grid_size = 2.5;
//TODO: Calculation is wrong in the code below.
// Sacing between the holes in the air-flow grid.
grid_spacing = 0.5; // 0.1
// Margin between the grid and walls or corners.
grid_margin = 2;

// Number of sides of the grid-holes. Only 4 (squares) look good at the moment.
grid_fn = 4; // 1

// Spacing for the grid holes on the side-wall of the container. This is the angle between the holes.
// The value of this parameter depends on the grid_size and the container_diameter, so whenever you
// change those, you should recalibrate this parameter.
grid_angular_spacing = 7; //TODO: Calculate this automatically

/* [Lid dimmensions] */
/*
The lid is a separate piece that can be put on the container and secured by a short twist.
If has two snaps on the side. These fit into guides on the container and allows the lid to be secured
by a short twist.
*/

lid_thickness = 5; // .1
// Makes the lid slightly smaller so that it can fit inside the container.
lid_tolerance = 0.4; // .1

/* [Snap Snaps] */
/*
The snap guides are small ... on the inside of the container. They guide the snaps of the lid and
allow it to be secured by a short twist.
Thers is a small nudge towards the end of the guide which holds the lid in place.
The nudge is designed a small cylinder.
*/

// must be odd to ensure the snap has equal width through all axis.
lid_snap_fn = 7; // 1

// There should be at last 3 lid-snaps.
lid_snap_count = 3; // 1

// Amount of degrees the lid needs to be twisted to be secured.
snap_guide_angle = 20;

// Diameter of the nudge cylinder.
snap_guide_nudge_diameter = 2;

// How much the nudge cylinder should stick out of the guide. Fine-tune this if the lid is too loose
// or too hard to snap into place.
snap_guide_nudge_width = 0.4;

/* [Features] */
// Whether to render the container or not.
render_container = true;
// Whether to render the lid or not.
render_lid = true;

// Rendering the whole design with small grid-holes is slow and makes the OpenSCAD editor laggy.
// This is temporarily enables to only render the first two lines of grid-holes on the container,
// so that the rendering performance is improved and you can calibrate grid_angular_spacing.
// Set this to false once you're done with that calibration.
calibrate_grid_angular_spacing = false;


/* [Other parameters] */

// The lid is rendered above the container to be able to be split into separate objects in the slicer.
// This parameter controls how much the lid is separated from the container.
explode_width = 6;
// Number of fragments to use for the circles. Higher values make the circles look rounder but
// exponentially increase rendering time and filesize.
$fn = $preview ? 20 : 64;

// used to prevent z-fighting
EPSILON = 0.01;

/* [Calculated values] */
outer_circumference = container_diameter * PI;
margin_top = lid_thickness + 1;
lid_snap_diameter = lid_thickness / 2;
snap_guide_rest_area_angle = lid_snap_diameter / outer_circumference * 360;

/*
    Module: circular_hole_grid

    Description:
        Creates a grid of square holes on a cylindrical surface. The holes are arranged in a
        staggered pattern.

    Parameters:
        - angular_spacing: The angular distance between holes in degrees.
        - diameter: The diameter of the cylindrical surface.
        - length: The length of the cylindrical surface.
        - hole_diameter: The diameter of each hole.
        - hole_fn: The number of facets used to approximate the circular holes.
        - grid_spacing: The distance between rows of holes.
        - calibrate_grid_angular_spacing: Boolean flag to adjust the grid angular spacing.

    Internal Variables:
        - true_angular_spacing: Adjusted angular spacing to ensure even distribution of holes.
        - z_step: The vertical distance between rows of holes.
        - grid_z: The number of rows of holes.

    Usage:
        This module can be used to create a pattern of holes on a cylindrical surface, which can be
        useful for designs requiring ventilation or weight reduction.
*/
module circular_hole_grid(angular_spacing, diameter, length, hole_diameter, hole_fn, grid_spacing, calibrate_grid_angular_spacing) {
  true_angular_spacing = 180 / (floor(180 / angular_spacing));
  z_step = (hole_diameter / 2) + (grid_spacing / sqrt(2));
  grid_z = ((calibrate_grid_angular_spacing) ? 2 : (length / z_step));

  for(z = [0:1:grid_z]) {
    angle_offset = (((z % 2) == 0) ? 0 : (true_angular_spacing / 2));
    for(angle = [0:true_angular_spacing:180]) {
      translate([0, 0, z * z_step])
        rotate([0, 90, angle + angle_offset])
          translate([0, 0, -(diameter + (2 * EPSILON)) / 2])
            cylinder(d = hole_diameter, h = diameter + (2 * EPSILON), $fn = hole_fn);
    }
  }
}

/*
    Module: rectangular_hole_grid

    Description:
        Creates a grid of square holes within a rectangular area. The holes are arranged in a
        staggered pattern.

    Parameters:
        x_size        - The width of the rectangular area.
        y_size        - The height of the rectangular area.
        height        - The height of the cylindrical holes.
        hole_diameter - The diameter of each cylindrical hole.
        hole_fn       - The number of facets used to approximate the cylindrical hole.
        hole_spacing  - The spacing between the edges of adjacent holes.

    Example Usage:
        rectangular_hole_grid(100, 50, 10, 5, 50, 10);
*/
module rectangular_hole_grid(x_size, y_size, height, hole_diameter, hole_fn, hole_spacing) {
  grid_x = x_size / (hole_spacing + hole_diameter);
  grid_y = y_size / (hole_spacing + hole_diameter);
  grid_x_dimmension = grid_x * (hole_spacing + hole_diameter);
  grid_y_dimmension = grid_y * (hole_spacing + hole_diameter);
  translate([(hole_diameter + hole_spacing) / 2, 0, 0])
    for(y = [0:1:grid_y * 2]) {
      x_offset = (((y % 2) == 0) ? 0 : (-(hole_spacing + hole_diameter) / 2));
      x_add = ((y % 2) == 0) ? 0 : 1;
      translate([x_offset, 0, 0])
        for(x = [0:1:grid_x + x_add]) {
          translate([x * (hole_spacing + hole_diameter), (y * (hole_spacing + hole_diameter)) / 2, 0])
            cylinder(d = hole_diameter, h = height, $fn = hole_fn);
        }
    }
}

/*
    Module: container_bottom

    Description:
        Creates the bottom part of a container with a grid pattern of holes.

    Parameters:
        - container_diameter: Diameter of the container.
        - height: Height of the container.
        - grid_margin: Margin for the grid pattern.
        - grid_size: Diameter of the holes in the grid pattern.
        - grid_fn: Number of facets used to approximate the holes.
        - grid_spacing: Spacing between the holes in the grid pattern.

    Usage:
        container_bottom(container_diameter, height, grid_margin, grid_size, grid_fn, grid_spacing);

    Example:
        container_bottom(50, 10, 2, 5, 16, 10);
*/
module container_bottom(container_diameter, height, grid_margin, grid_size, grid_fn, grid_spacing) {
  union() {
    difference() {
      cylinder(d = container_diameter, h = height);
      translate([0, 0, -EPSILON])
        cylinder(d = container_diameter - grid_margin, h = height + (2 * EPSILON));
    }
    difference() {
      cylinder(d = container_diameter, h = height);
      translate([-container_diameter / 2, -container_diameter / 2, -EPSILON])
        rectangular_hole_grid(x_size = container_diameter, y_size = container_diameter, height = height + (2 * EPSILON), hole_diameter = grid_size, hole_fn = grid_fn, hole_spacing = grid_spacing);
    }
  }
}

/*
    Module: hollow_container
    Description: Creates a hollow cylindrical container with specified outer diameter, length, and
    wall thickness.
    
    Parameters:
        - diameter: The outer diameter of the container.
        - length: The length (height) of the container.
        - wall_thickness: The thickness of the container's wall.
    
    Usage:
        hollow_container(diameter, length, wall_thickness);
    
    Example:
        hollow_container(20, 50, 2);
        // This creates a hollow container with an outer diameter of 20 mm, a length of 50 mm, and a
        // wall thickness of 2 mm.
*/
module hollow_container(diameter, length, wall_thickness) {
  difference() {
    cylinder(d = diameter, h = length);
    translate([0, 0, -EPSILON])
      cylinder(d = diameter - (2 * wall_thickness), h = length + 2 * EPSILON);
  }
}

/*
    Module: container

    Description:
        Creates a parametric container with a grid of circular holes. The container is hollow and has a
        specified wall thickness. 
        The grid of holes can be calibrated.

    Parameters:
        - diameter: The outer diameter of the container.
        - length: The total length of the container.
        - wall_thickness: The thickness of the container walls.
        - grid_angular_spacing: The angular spacing between the holes in the grid.
        - grid_spacing: The spacing between the holes in the grid along the length of the container.
        - hole_diameter: The diameter of the holes in the grid.
        - hole_fn: The number of facets used to approximate the circular holes.
        - lid_snap_diameter: The diameter for the lid snap feature.
        - calibrate_grid_angular_spacing: Temporarily set this to true while calibrating the
                                          grid_angular_spacing to reduce render-time.

    Usage:
        container(diameter, length, wall_thickness, grid_angular_spacing, grid_spacing, hole_diameter,
        hole_fn, lid_snap_diameter, calibrate_grid_angular_spacing);
*/
module container(diameter, length, wall_thickness, grid_angular_spacing, grid_spacing, hole_diameter, hole_fn, lid_snap_diameter, calibrate_grid_angular_spacing) {
  union() {
    hollow_container(diameter, wall_thickness, wall_thickness);
    difference() {
      translate([0, 0, wall_thickness])
        hollow_container(diameter, length - (2 * wall_thickness), wall_thickness);
      translate([0, 0, wall_thickness])
        circular_hole_grid(angular_spacing = grid_angular_spacing, diameter = diameter, length = length, hole_diameter = hole_diameter, hole_fn = hole_fn, grid_spacing = grid_spacing, calibrate_grid_angular_spacing = calibrate_grid_angular_spacing);
    }
    translate([0, 0, length - margin_top])
      hollow_container(diameter, margin_top, wall_thickness);
  }
}

/*
    Module: lid_snap

    Description:
        This module adds snaps to the lid, so it can be secured to the container with a short twist. 

    Parameters:
        - diameter: The outer diameter of the lid.
        - lid_snap_diameter: The diameter of the snap-fit feature.
        - lid_snap_fn: The number of facets to use for the snap-fit feature.
        - wall_thickness: The thickness of the wall of the lid.
        - lid_thickness: The thickness of the lid itself.

    Usage:
        lid_snap(diameter, lid_snap_diameter, lid_snap_fn, wall_thickness, lid_thickness);
*/
module lid_snap(diameter, lid_snap_diameter, lid_snap_fn, wall_thickness, lid_thickness, lid_tolerance) {
  inner_circle_radius = lid_snap_diameter * cos(180 / lid_snap_fn);
  difference() {
    translate([0, 0, (inner_circle_radius / 2) + EPSILON])
      rotate([0, 270, 0])
        color("Tomato") cylinder(d = lid_snap_diameter, h = diameter / 2, $fn = lid_snap_fn);
    color("LimeGreen") difference() {
      cylinder(d = diameter * 1.1, h = lid_thickness);
      translate([0, 0, -EPSILON])
        cylinder(d = diameter - wall_thickness - lid_tolerance, h = lid_thickness + (2 * EPSILON));
    }
    cylinder(d = diameter - (2 * wall_thickness) - lid_tolerance, h = lid_thickness);
  }
}

/*
    Module: lid

    Description:
        Creates the lid.

    Parameters:
        - diameter: The overall diameter of the lid.
        - wall_thickness: The thickness of the wall of the lid.
        - lid_thickness: The thickness of the lid itself.
        - lid_snap_diameter: The diameter of the snap feature on the lid.
        - lid_snap_fn: The number of facets used to approximate the snap feature.
        - grid_margin: The margin around the grid pattern on the container bottom.
        - grid_size: The size of the grid pattern on the container bottom.
        - grid_fn: The number of facets used to approximate the grid pattern.
        - grid_spacing: The spacing between elements of the grid pattern.

    Usage:
        lid(diameter, wall_thickness, lid_thickness, lid_snap_diameter, lid_snap_fn, grid_margin, grid_size, grid_fn, grid_spacing);
*/
module lid(diameter, wall_thickness, lid_thickness, lid_snap_diameter, lid_snap_fn, grid_margin, grid_size, grid_fn, grid_spacing, lid_tolerance) {
  container_bottom(container_diameter = diameter - (2 * wall_thickness) - lid_tolerance, height = lid_thickness, grid_margin = grid_margin, grid_size = grid_size, grid_fn = grid_fn, grid_spacing = grid_spacing);
  // lid_snaps
  for (i = [0:1:lid_snap_count - 1]) {
    rotate([0, 0, (360 / lid_snap_count) * i]) lid_snap(diameter = diameter, lid_snap_diameter = lid_snap_diameter, lid_snap_fn = lid_snap_fn, wall_thickness = wall_thickness, lid_thickness = lid_thickness, lid_tolerance);
  }
}

/*
    Module: lid_snap_guide

    Description:
        This module adds a snap guide for the lid to the container.
        The lid's snaps slide into this guide and the lid can be secured with a short twist.

    Parameters:
        - container_diameter: The outer diameter of the container.
        - container_length: The length of the container.
        - wall_thickness: The thickness of the container wall.
        - snap_guide_rest_area_angle: The angle of the rest area for the snap guide.
        - lid_snap_diameter: The diameter of the snap feature on the lid.
        - snap_guide_angle: The angle of the snap guide.
        - snap_guide_nudge_diameter: The diameter of the nudge feature on the snap guide.
        - snap_guide_nudge_width: The width of the nudge feature on the snap guide.

    Usage:
        This module can be used to create a snap guide for a lid that fits onto a container with
        specified dimensions and angles. The snap guide helps ensure that the lid snaps securely
        onto the container.
*/
module lid_snap_guide(container_diameter, container_length, wall_thickness, snap_guide_rest_area_angle, lid_snap_diameter, snap_guide_angle, snap_guide_nudge_diameter, snap_guide_nudge_width) {
  rotate([0, 0, -snap_guide_rest_area_angle / 2])
    translate([0, 0, container_length - (lid_snap_diameter * 2) + EPSILON]) {
      difference() {
        union() {
          rotate_extrude(angle = snap_guide_rest_area_angle)
            square([(container_diameter - wall_thickness) / 2, lid_snap_diameter * 2]);
          rotate_extrude(angle = snap_guide_angle)
            square([(container_diameter - wall_thickness) / 2, lid_snap_diameter]);
        }
        rotate([0, 0, snap_guide_angle - snap_guide_rest_area_angle - 1])
          translate([((container_diameter - wall_thickness) / 2) + (snap_guide_nudge_diameter / 2) - snap_guide_nudge_width, 0, -EPSILON])
            cylinder(d = snap_guide_nudge_diameter, h = lid_snap_diameter + (2 * EPSILON));
      }
    }
}

/*
    Main

    Contstructs the container and lid.
*/
if (render_container) {
  // bottom of the container
container_bottom(container_diameter = container_diameter, height = wall_thickness, grid_margin = grid_margin, grid_size = grid_size, grid_fn = grid_fn, grid_spacing = grid_spacing);

  difference() {
    // container
    container(diameter = container_diameter, length = container_length, wall_thickness = wall_thickness, grid_angular_spacing = grid_angular_spacing, grid_spacing = grid_spacing, hole_diameter = grid_size, hole_fn = grid_fn, lid_snap_diameter = lid_snap_diameter, calibrate_grid_angular_spacing = calibrate_grid_angular_spacing);
    for (i = [0:1:lid_snap_count - 1]) {
      rotate([0, 0, (360 / lid_snap_count) * i]) lid_snap_guide(container_diameter = container_diameter, container_length = container_length, wall_thickness = wall_thickness, snap_guide_rest_area_angle = snap_guide_rest_area_angle, lid_snap_diameter = lid_snap_diameter, snap_guide_angle = snap_guide_angle, snap_guide_nudge_diameter = snap_guide_nudge_diameter, snap_guide_nudge_width = snap_guide_nudge_width);
    }
  }
}

// lid
if (render_lid) {
  // lid
  translate([0, 0, container_length - lid_thickness + explode_width])
    lid(container_diameter, wall_thickness, lid_thickness, lid_snap_diameter, lid_snap_fn = lid_snap_fn, grid_margin = grid_margin, grid_size = grid_size, grid_fn = grid_fn, grid_spacing = grid_spacing, lid_tolerance = lid_tolerance);
}
