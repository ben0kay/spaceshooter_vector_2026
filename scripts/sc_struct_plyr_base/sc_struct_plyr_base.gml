/// @description Registers the colossal player starting base.
function sc_world_structure_register_player_base()
{
    return sc_world_structure_register({
        identity:{
            key: "player_starting_base",
            name: "Frontier Haven"
        },

        visual:{
            canvas_width:2304,
            canvas_height:1280,
            palette: sc_faction_palette_get(Faction.PLAYER),
            draw_script: sc_world_structure_player_base_draw
        },

        collision:{
            broad_radius:1080,

            parts:[
                {
                    key:"reactor",
                    shape: StructureCollisionShape.CIRCLE,
                    forward:-720,
                    side:0,
                    radius:285,
                    angle:0
                },
                {
                    key:"central_spine",
                    shape: StructureCollisionShape.RECTANGLE,
                    forward:0,
                    side:0,
                    width:1120,
                    height:170,
                    angle:0
                },
                {
                    key:"upper_hangar",
                    shape:StructureCollisionShape.RECTANGLE,
                    forward:-170,
                    side:-300,
                    width:620,
                    height:250,
                    angle:0
                },
                {
                    key:"lower_hangar",
                    shape: StructureCollisionShape.RECTANGLE,
                    forward:-110,
                    side:315,
                    width:500,
                    height:245,
                    angle:0
                },
                {
                    key:"command_hub",
                    shape: StructureCollisionShape.CIRCLE,
                    forward:540,
                    side:0,
                    radius:205,
                    angle:0
                },
                {
                    key:"east_module",
                    shape: StructureCollisionShape.RECTANGLE,
                    forward:830,
                    side:0,
                    width:310,
                    height:210,
                    angle:0
                }
            ]
        }
    });
}

/// @description Draws the colossal modular player starting base.
function sc_world_structure_player_base_draw(_x,_y,_visual)
{
    var _p=_visual.palette;

    //==================================================
    // EXPOSED STRUCTURAL TRUSSES - draw underneath hull
    //==================================================

    sc_struct_plyr_truss(_x,_y,-120,-235,390,-90,12,_p);
    sc_struct_plyr_truss(_x,_y,-35,240,365,90,12,_p);
    sc_struct_plyr_truss(_x,_y,250,245,480,135,10,_p);


    //==================================================
    // CENTRAL SPINE
    //==================================================

    sc_struct_plyr_corridor(_x,_y,-135,0,1010,156,_p);

    // Heavy connector collars.
    sc_struct_plyr_chamfer_box(_x,_y,-420,0,82,190,13,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,-420,0,55,158,8,_p.hull_light,_p);

    sc_struct_plyr_chamfer_box(_x,_y,145,0,82,190,13,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,145,0,55,158,8,_p.hull_light,_p);

    sc_struct_plyr_chamfer_box(_x,_y,370,0,76,185,13,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,370,0,49,150,8,_p.hull_light,_p);

    // Spine machinery panels.
    for (var _i=0;_i<5;++_i)
    {
        var _px=-275+_i*116;

        sc_struct_plyr_panel(
            _x,_y,
            _px,-43,
            78,38,
            _p.hull_dark,_p
        );

        sc_struct_plyr_light_strip(
            _x,_y,
            _px-23,-43,
            _px+23,-43,
            3,_p
        );
    }


    //==================================================
    // LEFT REACTOR / POWER HUB
    //==================================================

    sc_struct_plyr_reactor_hub(_x,_y,-720,0,290,8,_p);

    // Reactor cardinal machinery blocks.
    sc_struct_plyr_chamfer_box(_x,_y,-720,-315,118,118,16,_p.hull_mid,_p);
    sc_struct_plyr_chamfer_box(_x,_y,-720,315,118,118,16,_p.hull_mid,_p);
    sc_struct_plyr_chamfer_box(_x,_y,-1035,0,120,118,16,_p.hull_mid,_p);
    sc_struct_plyr_chamfer_box(_x,_y,-405,0,120,118,16,_p.hull_mid,_p);

    sc_struct_plyr_light_strip(_x,_y,-720,-350,-720,-282,8,_p);
    sc_struct_plyr_light_strip(_x,_y,-720,282,-720,350,8,_p);
    sc_struct_plyr_light_strip(_x,_y,-1065,0,-1005,0,8,_p);
    sc_struct_plyr_light_strip(_x,_y,-435,0,-375,0,8,_p);

    // Reactor panel divisions.
    for (var _i=0;_i<12;++_i)
    {
        var _a=_i*30;
        var _x1=-720+lengthdir_x(220,_a);
        var _y1=lengthdir_y(220,_a);
        var _x2=-720+lengthdir_x(269,_a);
        var _y2=lengthdir_y(269,_a);

        draw_set_colour(_p.outline);
        draw_line_width(
            _x+_x1,_y+_y1,
            _x+_x2,_y+_y2,
            3
        );
    }

    // Four potential defence sockets around reactor.
    sc_struct_plyr_hardpoint_socket(_x,_y,-965,-210,27,_p);
    sc_struct_plyr_hardpoint_socket(_x,_y,-965,210,27,_p);
    sc_struct_plyr_hardpoint_socket(_x,_y,-520,-235,27,_p);
    sc_struct_plyr_hardpoint_socket(_x,_y,-520,235,27,_p);


    //==================================================
    // UPPER HANGAR / FLIGHT DECK
    //==================================================

    sc_struct_plyr_chamfer_box(_x,_y,-180,-315,640,258,30,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,-180,-315,612,230,24,_p.hull_mid,_p);

    // Large landing rectangle.
    sc_struct_plyr_docking_pad(_x,_y,-120,-315,350,196,_p);

    // Hangar machinery section on left.
    sc_struct_plyr_panel(_x,_y,-416,-315,112,200,_p.hull_dark,_p);
    sc_struct_plyr_vent_bank(_x,_y,-416,-343,72,70,5,false,_p);

    // Hangar utility section on right.
    sc_struct_plyr_panel(_x,_y,115,-315,115,195,_p.hull_dark,_p);
    sc_struct_plyr_vent_bank(_x,_y,115,-350,70,58,5,true,_p);

    // Cargo racks beside the pad.
    for (var _row=0;_row<3;++_row)
    for (var _col=0;_col<2;++_col)
    {
        sc_struct_plyr_crate(
            _x,_y,
            84+_col*49,
            -286+_row*53,
            42,39,_p
        );
    }

    sc_struct_plyr_warning_stripe(_x,_y,-301,-420,60,13,_p);
    sc_struct_plyr_warning_stripe(_x,_y,18,-420,60,13,_p);

    sc_struct_plyr_antenna(_x,_y,-443,-414,70,true,_p);
    sc_struct_plyr_antenna(_x,_y,139,-414,55,true,_p);


    //==================================================
    // LOWER SERVICE / DOCKING PLATFORM
    //==================================================

    sc_struct_plyr_chamfer_box(_x,_y,-135,325,520,250,30,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,-135,325,492,222,23,_p.hull_mid,_p);

    sc_struct_plyr_docking_pad(_x,_y,-210,325,300,190,_p);

    // Utility crates / storage.
    for (var _i=0;_i<3;++_i)
    {
        sc_struct_plyr_crate(
            _x,_y,
            22,
            270+_i*56,
            62,44,_p
        );
    }

    // Suspended cargo cluster.
    for (var _row=0;_row<2;++_row)
    for (var _col=0;_col<3;++_col)
    {
        sc_struct_plyr_crate(
            _x,_y,
            215+_col*43,
            285+_row*44,
            36,34,_p
        );
    }

    sc_struct_plyr_warning_stripe(_x,_y,-338,222,58,13,_p);
    sc_struct_plyr_warning_stripe(_x,_y,-82,428,58,13,_p);


    //==================================================
    // RIGHT COMMAND / OPERATIONS HUB
    //==================================================

    // Broad octagonal housing.
    sc_struct_plyr_chamfer_box(_x,_y,545,0,370,330,52,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,545,0,340,300,42,_p.hull_mid,_p);

    // Armour ribs around hub.
    for (var _side=-1;_side<=1;_side+=2)
    {
        sc_struct_plyr_panel(_x,_y,460,_side*108,94,58,_p.hull_light,_p);
        sc_struct_plyr_panel(_x,_y,630,_side*108,94,58,_p.hull_light,_p);
    }

    sc_struct_plyr_command_hub(_x,_y,545,0,112,_p);

    // Vertical energy windows.
    sc_struct_plyr_light_strip(_x,_y,430,-58,430,58,7,_p);
    sc_struct_plyr_light_strip(_x,_y,660,-58,660,58,7,_p);

    // Orange service warning blocks.
    sc_struct_plyr_warning_stripe(_x,_y,455,-132,48,12,_p);
    sc_struct_plyr_warning_stripe(_x,_y,635,132,48,12,_p);

    // Upper sensor tower + dish.
    sc_struct_plyr_chamfer_box(_x,_y,545,-196,112,82,18,_p.hull_dark,_p);
    sc_struct_plyr_command_hub(_x,_y,545,-198,46,_p);
    sc_struct_plyr_sensor_dish(_x,_y,545,-270,82,_p);

    sc_struct_plyr_antenna(_x,_y,690,-146,85,true,_p);
    sc_struct_plyr_antenna(_x,_y,738,-115,52,true,_p);

    // Lower defence hardpoint.
    sc_struct_plyr_hardpoint_socket(_x,_y,660,128,30,_p);


    //==================================================
    // FAR EAST MODULE
    //==================================================

    sc_struct_plyr_corridor(_x,_y,755,0,145,92,_p);

    sc_struct_plyr_chamfer_box(_x,_y,875,0,300,220,35,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,875,0,274,192,27,_p.hull_mid,_p);

    sc_struct_plyr_panel(_x,_y,875,-50,178,54,_p.hull_dark,_p);
    sc_struct_plyr_panel(_x,_y,875,50,178,54,_p.hull_dark,_p);

    sc_struct_plyr_light_strip(_x,_y,818,-50,932,-50,8,_p);
    sc_struct_plyr_light_strip(_x,_y,818,50,932,50,8,_p);

    sc_struct_plyr_warning_stripe(_x,_y,1015,0,18,88,_p);

    sc_struct_plyr_antenna(_x,_y,960,-112,72,true,_p);
    sc_struct_plyr_antenna(_x,_y,808,112,55,false,_p);


    //==================================================
    // EXTRA MICRO DETAIL
    //==================================================

    // Small maintenance panels along central structure.
    for (var _i=0;_i<7;++_i)
    {
        var _px=-315+_i*101;

        sc_struct_plyr_seam(
            _x,_y,
            _px,-66,
            _px,66,
            _p
        );
    }

    // Tiny status lights.
    for (var _i=0;_i<6;++_i)
    {
        draw_set_colour(_i mod 3==0?_p.core:_p.energy);
        draw_circle(
            _x-320+_i*74,
            _y+31,
            3,
            false
        );
    }

    draw_set_alpha(1);
    draw_set_colour(c_white);
}