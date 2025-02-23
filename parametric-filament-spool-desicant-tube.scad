$fn=32;
grid_margin = 2;
tube_diameter = 52;
grid_size = 10.5; // 2.5
grid_spacing = 0.5;
grid_fn = 4;
tube_length = 67;
tube_wall_thickness = 2;
EPSILON = 0.01; // used to prevent z-fighting
grid_angular_spacing = 70;
outer_circumference = tube_diameter * PI;

lid_thickness = 5;
margin_top = lid_thickness + 1;
lid_snap_insert = 3;
lid_snap_protrusion = 0.5;
lid_snap_diameter = lid_thickness / 2;
lid_snap_fn = 7; // must be odd
lid_tolerance = 0.2;

snap_guide_angle = 20;
snap_guide_rest_area_angle = lid_snap_diameter / outer_circumference * 360;
snap_guide_nudge_diameter = 2;
snap_guide_nudge_width = 0.3;

draw_tube = true;
draw_lid = false;
calibrate_grid_angular_spacing = true;

explode_width = 10;

module circular_hole_grid(angular_spacing, diameter, length, hole_diameter, hole_fn, grid_spacing, calibrate_grid_angular_spacing) {
    true_angular_spacing = 180 / (floor(180 / angular_spacing));
    z_step = (hole_diameter / 2) + (grid_spacing / sqrt(2));
    grid_z = ((calibrate_grid_angular_spacing) ? 2 : (length / z_step));

    for(z = [0 : 1 : grid_z]) {
        angle_offset = (((z % 2) == 0) ? 0 : (true_angular_spacing / 2));
        for(angle=[0: true_angular_spacing : 180]) {
            translate([0, 0, z * z_step]) rotate([0, 90, angle + angle_offset]) translate([0, 0, -(diameter + (2 * EPSILON)) / 2]) cylinder(d=hole_diameter, h=diameter + (2 * EPSILON), $fn=hole_fn);
        }
    }
}

module rectangular_hole_grid(x_size, y_size, height, hole_diameter, hole_fn, hole_spacing) {
    grid_x = x_size / (hole_spacing + hole_diameter);
    grid_y = y_size / (hole_spacing + hole_diameter);
    grid_x_dimmension = grid_x * (hole_spacing + hole_diameter);
    grid_y_dimmension = grid_y * (hole_spacing + hole_diameter);
    translate([(hole_diameter + hole_spacing)/2, 0, 0]) for(y=[0: 1 : grid_y * 2]) {
        x_offset = (((y % 2) == 0) ? 0 : (-(hole_spacing + hole_diameter) / 2));
        x_add = ((y % 2) == 0) ? 0 : 1;
        translate([x_offset, 0, 0]) for(x=[0: 1 : grid_x + x_add]) {
            translate([x * (hole_spacing + hole_diameter), (y * (hole_spacing + hole_diameter)) / 2, 0]) cylinder(d=hole_diameter, h=height, $fn=hole_fn);
        }
    }
}


module tube_bottom(tube_diameter, height, grid_margin, grid_size, grid_fn, grid_spacing) {
    union() {
        difference() {
            cylinder(d=tube_diameter, h=height);
            translate([0, 0, -EPSILON]) cylinder(d=tube_diameter - grid_margin, h=height + (2 * EPSILON));
        }
        difference() {
            cylinder(d=tube_diameter, h=height);
            translate([-tube_diameter/2, -tube_diameter/2, -EPSILON]) rectangular_hole_grid(x_size=tube_diameter, y_size=tube_diameter, height=height + (2 * EPSILON), hole_diameter=grid_size, hole_fn=grid_fn, hole_spacing=grid_spacing);
        }
    }   
}


module hollow_tube(diameter, length, wall_thickness) {
    difference() {
        cylinder(d=diameter, h=length);
        translate([0, 0, -EPSILON]) cylinder(d=diameter - (2 * wall_thickness), h=length + 2 * EPSILON);
    }
}

module tube(diameter, length, wall_thickness, grid_angular_spacing, grid_spacing, hole_diameter, hole_fn, lid_snap_diameter, lid_snap_protrusion, calibrate_grid_angular_spacing) {
    union() {
        hollow_tube(diameter, wall_thickness, wall_thickness);
        difference() {
            translate([0, 0, wall_thickness]) hollow_tube(diameter, length - (2 * wall_thickness), wall_thickness);
            translate([0, 0, wall_thickness]) circular_hole_grid(angular_spacing=grid_angular_spacing, diameter=diameter, length=length, hole_diameter=hole_diameter, hole_fn=hole_fn, grid_spacing=grid_spacing, calibrate_grid_angular_spacing=calibrate_grid_angular_spacing);
        }
        translate([0, 0, length - margin_top]) hollow_tube(diameter, margin_top, wall_thickness);
    }
}

module lid_snap(diameter, lid_snap_diameter, lid_snap_protrusion, lid_snap_insert, lid_snap_fn, wall_thickness, lid_thickness) {
    inner_circle_radius = lid_snap_diameter * cos(180/lid_snap_fn);
    difference() {
        translate([0, 0, (inner_circle_radius/2) + EPSILON]) rotate([0, 270, 0]) cylinder(d=lid_snap_diameter, h=diameter/2, $fn=lid_snap_fn);
        difference () {
            cylinder(d=diameter * 1.1, h=lid_thickness);
            translate([0, 0, -EPSILON]) cylinder(d=diameter - (wall_thickness / 2), h=lid_thickness + (2 * EPSILON));
        }
        cylinder(d=diameter - (2 * wall_thickness), h=lid_thickness);
    }
}

module lid(diameter, wall_thickness, lid_thickness, lid_snap_diameter, lid_snap_protrusion, lid_snap_insert, lid_snap_fn,/***/ grid_margin, grid_size, grid_fn, grid_spacing) {
    tube_bottom(tube_diameter=diameter - (2 * wall_thickness), height=lid_thickness, grid_margin=grid_margin, grid_size=grid_size, grid_fn=grid_fn, grid_spacing=grid_spacing);
    // lid_snaps
    lid_snap(diameter=diameter, lid_snap_diameter=lid_snap_diameter, lid_snap_protrusion=lid_snap_protrusion, lid_snap_insert=lid_snap_insert, lid_snap_fn=lid_snap_fn, wall_thickness=wall_thickness, lid_thickness=lid_thickness);

    rotate([0, 0, 180]) lid_snap(diameter=diameter, lid_snap_diameter=lid_snap_diameter, lid_snap_protrusion=lid_snap_protrusion, lid_snap_insert=lid_snap_insert, lid_snap_fn=lid_snap_fn, wall_thickness=wall_thickness, lid_thickness=lid_thickness);

}

module lid_snap_guide() {
    rotate([0, 0, -snap_guide_rest_area_angle/2])
    translate([0, 0, tube_length - (lid_snap_diameter * 2) + EPSILON]) {
        difference() {
            union() {
                rotate_extrude(angle=snap_guide_rest_area_angle) square([(tube_diameter - tube_wall_thickness) / 2, lid_snap_diameter * 2]);
                rotate_extrude(angle=snap_guide_angle) square([(tube_diameter - tube_wall_thickness) / 2, lid_snap_diameter]);
            }
            rotate([0, 0, snap_guide_angle - snap_guide_rest_area_angle - 1]) translate([((tube_diameter - tube_wall_thickness) / 2) + (snap_guide_nudge_diameter / 2) - snap_guide_nudge_width, 0, -EPSILON]) cylinder(d=snap_guide_nudge_diameter, h=lid_snap_diameter + (2 * EPSILON));
        }
    }
}

if (draw_tube) {
   // bottom of the tube
    if (!calibrate_grid_angular_spacing) {
        tube_bottom(tube_diameter, tube_wall_thickness);
    }

    difference() {
        // tube
        tube(diameter=tube_diameter, length=tube_length, wall_thickness=tube_wall_thickness, grid_angular_spacing=grid_angular_spacing, grid_spacing=grid_spacing, hole_diameter=grid_size, hole_fn=grid_fn, lid_snap_diameter=lid_snap_diameter, lid_snap_protrusion=lid_snap_protrusion, calibrate_grid_angular_spacing=calibrate_grid_angular_spacing);
        lid_snap_guide();
        rotate([0, 0, 180]) lid_snap_guide();
    }
}

// lid
if (draw_lid) {
    // lid
    translate([0, 0, tube_length - lid_thickness + explode_width]) lid(tube_diameter - lid_tolerance, tube_wall_thickness, lid_thickness, lid_snap_diameter, lid_snap_protrusion, lid_snap_insert, lid_snap_fn=lid_snap_fn, grid_margin=grid_margin, grid_size=grid_size, grid_fn=grid_fn, grid_spacing=grid_spacing);
}
