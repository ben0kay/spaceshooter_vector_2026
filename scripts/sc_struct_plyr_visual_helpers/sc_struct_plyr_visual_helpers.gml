/// @description Draws one player-structure chamfered armour module.
function sc_struct_plyr_chamfer_box(_x,_y,_cx,_cy,_w,_h,_cut,_fill,_p)
{
    var _l=_x+_cx-_w*0.5;
    var _r=_x+_cx+_w*0.5;
    var _t=_y+_cy-_h*0.5;
    var _b=_y+_cy+_h*0.5;

    var _pts=[
        [_l+_cut,_t],[_r-_cut,_t],[_r,_t+_cut],[_r,_b-_cut],
        [_r-_cut,_b],[_l+_cut,_b],[_l,_b-_cut],[_l,_t+_cut]
    ];

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_x+_cx,_y+_cy,_fill,1);
    for (var _i=0;_i<=8;++_i)
    {
        var _pt=_pts[_i mod 8];
        draw_vertex_colour(_pt[0],_pt[1],_fill,1);
    }
    draw_primitive_end();

    draw_set_colour(_p.outline);
    for (var _i=0;_i<8;++_i)
    {
        var _a=_pts[_i];
        var _bpt=_pts[(_i+1) mod 8];
        draw_line_width(_a[0],_a[1],_bpt[0],_bpt[1],5);
    }

    draw_set_colour(c_white);
}


/// @description Draws one inset armour panel inside a player structure.
function sc_struct_plyr_panel(_x,_y,_cx,_cy,_w,_h,_fill,_p)
{
    sc_struct_plyr_chamfer_box(_x,_y,_cx,_cy,_w,_h,10,_p.void,_p);
    sc_struct_plyr_chamfer_box(_x,_y,_cx,_cy,_w-12,_h-12,7,_fill,_p);
}


/// @description Draws one recessed player-structure panel seam.
function sc_struct_plyr_seam(_x,_y,_x1,_y1,_x2,_y2,_p)
{
    draw_set_colour(_p.void);
    draw_line_width(_x+_x1,_y+_y1,_x+_x2,_y+_y2,5);

    draw_set_colour(_p.outline);
    draw_line_width(_x+_x1,_y+_y1,_x+_x2,_y+_y2,2);

    draw_set_colour(c_white);
}


/// @description Draws one recessed aqua player-structure light strip.
function sc_struct_plyr_light_strip(_x,_y,_x1,_y1,_x2,_y2,_width,_p)
{
    draw_set_colour(_p.void);
    draw_line_width(_x+_x1,_y+_y1,_x+_x2,_y+_y2,_width+8);

    draw_set_colour(_p.glow);
    draw_line_width(_x+_x1,_y+_y1,_x+_x2,_y+_y2,_width+4);

    draw_set_colour(_p.energy);
    draw_line_width(_x+_x1,_y+_y1,_x+_x2,_y+_y2,_width);

    draw_set_colour(_p.core);
    draw_line_width(_x+_x1,_y+_y1,_x+_x2,_y+_y2,max(1,_width*0.28));

    draw_set_colour(c_white);
}


/// @description Draws one bank of recessed machinery vents.
function sc_struct_plyr_vent_bank(_x,_y,_cx,_cy,_w,_h,_count,_vertical,_p)
{
    sc_struct_plyr_panel(_x,_y,_cx,_cy,_w,_h,_p.hull_dark,_p);

    if (_vertical)
    {
        var _spacing=(_w-20)/max(1,_count);
        for (var _i=0;_i<_count;++_i)
        {
            var _px=_cx-_w*0.5+10+_spacing*(_i+0.5);
            draw_set_colour(_p.void);
            draw_line_width(_x+_px,_y+_cy-_h*0.32,_x+_px,_y+_cy+_h*0.32,5);
            draw_set_colour(_p.hull_light);
            draw_line_width(_x+_px,_y+_cy-_h*0.32,_x+_px,_y+_cy+_h*0.32,1);
        }
    }
    else
    {
        var _spacing=(_h-20)/max(1,_count);
        for (var _i=0;_i<_count;++_i)
        {
            var _py=_cy-_h*0.5+10+_spacing*(_i+0.5);
            draw_set_colour(_p.void);
            draw_line_width(_x+_cx-_w*0.32,_y+_py,_x+_cx+_w*0.32,_y+_py,5);
            draw_set_colour(_p.hull_light);
            draw_line_width(_x+_cx-_w*0.32,_y+_py,_x+_cx+_w*0.32,_y+_py,1);
        }
    }

    draw_set_colour(c_white);
}


/// @description Draws one reinforced horizontal player-structure corridor.
function sc_struct_plyr_corridor(_x,_y,_cx,_cy,_w,_h,_p)
{
    sc_struct_plyr_chamfer_box(_x,_y,_cx,_cy,_w,_h,16,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,_cx,_cy,_w-18,_h-18,11,_p.hull_mid,_p);

    sc_struct_plyr_light_strip(
        _x,_y,
        _cx-_w*0.34,_cy,
        _cx+_w*0.34,_cy,
        4,_p
    );

    var _amount=max(2,floor(_w/80));

    for (var _i=1;_i<_amount;++_i)
    {
        var _px=_cx-_w*0.5+(_w/_amount)*_i;

        draw_set_colour(_p.void);
        draw_line_width(
            _x+_px,_y+_cy-_h*0.42,
            _x+_px,_y+_cy+_h*0.42,
            5
        );

        draw_set_colour(_p.hull_light);
        draw_line_width(
            _x+_px,_y+_cy-_h*0.34,
            _x+_px,_y+_cy+_h*0.34,
            1
        );
    }

    draw_set_colour(c_white);
}


/// @description Draws one exposed player-structure truss.
function sc_struct_plyr_truss(_x,_y,_x1,_y1,_x2,_y2,_width,_p)
{
    draw_set_colour(_p.void);
    draw_line_width(_x+_x1,_y+_y1,_x+_x2,_y+_y2,_width+6);

    draw_set_colour(_p.hull_mid);
    draw_line_width(_x+_x1,_y+_y1,_x+_x2,_y+_y2,_width);

    var _dx=_x2-_x1;
    var _dy=_y2-_y1;
    var _len=point_distance(_x1,_y1,_x2,_y2);
    var _amount=max(2,floor(_len/55));

    for (var _i=0;_i<_amount;++_i)
    {
        var _t1=_i/_amount;
        var _t2=min(1,(_i+0.5)/_amount);

        var _ax=_x1+_dx*_t1;
        var _ay=_y1+_dy*_t1;
        var _bx=_x1+_dx*_t2;
        var _by=_y1+_dy*_t2;

        draw_set_colour(_p.hull_light);
        draw_circle(_x+_ax,_y+_ay,4,false);
        draw_line_width(_x+_ax,_y+_ay,_x+_bx,_y+_by,1);
    }

    draw_set_colour(c_white);
}


/// @description Draws one small player cargo/storage crate.
function sc_struct_plyr_crate(_x,_y,_cx,_cy,_w,_h,_p)
{
    sc_struct_plyr_chamfer_box(_x,_y,_cx,_cy,_w,_h,6,_p.hull_mid,_p);

    draw_set_colour(_p.hull_light);
    draw_rectangle(
        _x+_cx-_w*0.32,_y+_cy-_h*0.26,
        _x+_cx+_w*0.32,_y+_cy+_h*0.26,
        true
    );

    sc_struct_plyr_seam(
        _x,_y,
        _cx,_cy-_h*0.34,
        _cx,_cy+_h*0.34,
        _p
    );

    draw_set_colour(_p.warning);
    draw_rectangle(
        _x+_cx-_w*0.38,_y+_cy-_h*0.38,
        _x+_cx-_w*0.26,_y+_cy-_h*0.25,
        false
    );

    draw_set_colour(c_white);
}


/// @description Draws one player docking or landing pad.
function sc_struct_plyr_docking_pad(_x,_y,_cx,_cy,_w,_h,_p)
{
    sc_struct_plyr_chamfer_box(_x,_y,_cx,_cy,_w,_h,28,_p.hull_dark,_p);
    sc_struct_plyr_chamfer_box(_x,_y,_cx,_cy,_w-26,_h-26,20,_p.hull_mid,_p);

    draw_set_colour(_p.outline);
    draw_circle(_x+_cx,_y+_cy,min(_w,_h)*0.28,true);

    draw_set_colour(_p.warning);
    draw_circle(_x+_cx,_y+_cy,min(_w,_h)*0.26,true);

    draw_set_colour(_p.energy);
    draw_line_width(_x+_cx,_y+_cy-min(_w,_h)*0.18,_x+_cx,_y+_cy+min(_w,_h)*0.18,3);
    draw_line_width(_x+_cx-min(_w,_h)*0.18,_y+_cy,_x+_cx+min(_w,_h)*0.18,_y+_cy,3);

    var _sx=_w*0.38;
    var _sy=_h*0.38;

    for (var _side=-1;_side<=1;_side+=2)
    {
        draw_set_colour(_p.warning);

        draw_line_width(
            _x+_cx-_sx,
            _y+_cy+_sy*_side,
            _x+_cx-_sx+24,
            _y+_cy+_sy*_side,
            5
        );

        draw_line_width(
            _x+_cx+_sx-24,
            _y+_cy+_sy*_side,
            _x+_cx+_sx,
            _y+_cy+_sy*_side,
            5
        );
    }

    draw_set_colour(c_white);
}


/// @description Draws one large player reactor hub with radial machinery.
function sc_struct_plyr_reactor_hub(_x,_y,_cx,_cy,_radius,_spokes,_p)
{
    draw_set_colour(_p.outline);
    draw_circle(_x+_cx,_y+_cy,_radius,false);

    draw_set_colour(_p.hull_dark);
    draw_circle(_x+_cx,_y+_cy,_radius-14,false);

    draw_set_colour(_p.hull_mid);
    draw_circle(_x+_cx,_y+_cy,_radius*0.76,false);

    draw_set_colour(_p.hull_light);
    draw_circle(_x+_cx,_y+_cy,_radius*0.63,true);

    draw_set_colour(_p.void);
    draw_circle(_x+_cx,_y+_cy,_radius*0.51,false);

    draw_set_colour(_p.energy);
    draw_circle(_x+_cx,_y+_cy,_radius*0.41,true);

    draw_set_colour(_p.glow);
    draw_circle(_x+_cx,_y+_cy,_radius*0.34,false);

    draw_set_colour(_p.core);
    draw_circle(_x+_cx,_y+_cy,_radius*0.2,false);

    for (var _i=0;_i<_spokes;++_i)
    {
        var _a=(_i/_spokes)*360;
        var _ix=_cx+lengthdir_x(_radius*0.55,_a);
        var _iy=_cy+lengthdir_y(_radius*0.55,_a);
        var _ox=_cx+lengthdir_x(_radius*0.9,_a);
        var _oy=_cy+lengthdir_y(_radius*0.9,_a);

        draw_set_colour(_p.void);
        draw_line_width(_x+_ix,_y+_iy,_x+_ox,_y+_oy,24);

        draw_set_colour(_p.hull_light);
        draw_line_width(_x+_ix,_y+_iy,_x+_ox,_y+_oy,12);

        draw_set_colour(_p.energy);
        draw_line_width(_x+_ix,_y+_iy,_x+_ox,_y+_oy,3);

        var _mx=_cx+lengthdir_x(_radius*0.82,_a);
        var _my=_cy+lengthdir_y(_radius*0.82,_a);

        draw_set_colour(_p.outline);
        draw_circle(_x+_mx,_y+_my,17,false);

        draw_set_colour(_p.hull_mid);
        draw_circle(_x+_mx,_y+_my,12,false);
    }

    draw_set_colour(c_white);
}


/// @description Draws one smaller circular player command/sensor hub.
function sc_struct_plyr_command_hub(_x,_y,_cx,_cy,_radius,_p)
{
    draw_set_colour(_p.outline);
    draw_circle(_x+_cx,_y+_cy,_radius,false);

    draw_set_colour(_p.hull_dark);
    draw_circle(_x+_cx,_y+_cy,_radius-12,false);

    draw_set_colour(_p.hull_mid);
    draw_circle(_x+_cx,_y+_cy,_radius*0.72,false);

    draw_set_colour(_p.hull_light);
    draw_circle(_x+_cx,_y+_cy,_radius*0.53,false);

    draw_set_colour(_p.void);
    draw_circle(_x+_cx,_y+_cy,_radius*0.34,false);

    sc_struct_plyr_light_strip(
        _x,_y,
        _cx-_radius*0.34,_cy,
        _cx+_radius*0.34,_cy,
        5,_p
    );

    draw_set_colour(c_white);
}


/// @description Draws one circular player turret or utility hardpoint socket.
function sc_struct_plyr_hardpoint_socket(_x,_y,_cx,_cy,_radius,_p)
{
    draw_set_colour(_p.outline);
    draw_circle(_x+_cx,_y+_cy,_radius,false);

    draw_set_colour(_p.hull_light);
    draw_circle(_x+_cx,_y+_cy,_radius-5,false);

    draw_set_colour(_p.void);
    draw_circle(_x+_cx,_y+_cy,_radius*0.55,false);

    draw_set_colour(_p.energy);
    draw_circle(_x+_cx,_y+_cy,_radius*0.25,false);

    draw_set_colour(c_white);
}


/// @description Draws one slim player communications antenna mast.
function sc_struct_plyr_antenna(_x,_y,_cx,_cy,_length,_vertical,_p)
{
    if (_vertical)
    {
        draw_set_colour(_p.void);
        draw_line_width(_x+_cx,_y+_cy,_x+_cx,_y+_cy-_length,7);

        draw_set_colour(_p.hull_light);
        draw_line_width(_x+_cx,_y+_cy,_x+_cx,_y+_cy-_length,3);

        draw_set_colour(_p.energy);
        draw_circle(_x+_cx,_y+_cy-_length,5,false);
    }
    else
    {
        draw_set_colour(_p.void);
        draw_line_width(_x+_cx,_y+_cy,_x+_cx+_length,_y+_cy,7);

        draw_set_colour(_p.hull_light);
        draw_line_width(_x+_cx,_y+_cy,_x+_cx+_length,_y+_cy,3);

        draw_set_colour(_p.energy);
        draw_circle(_x+_cx+_length,_y+_cy,5,false);
    }

    draw_set_colour(c_white);
}


/// @description Draws one top-down player sensor dish assembly.
function sc_struct_plyr_sensor_dish(_x,_y,_cx,_cy,_radius,_p)
{
    draw_set_colour(_p.outline);
    draw_circle(_x+_cx,_y+_cy,_radius*0.58,false);

    draw_set_colour(_p.hull_dark);
    draw_circle(_x+_cx,_y+_cy,_radius*0.5,false);

    draw_set_colour(_p.hull_light);
    draw_circle(_x+_cx,_y+_cy,_radius*0.34,false);

    draw_set_colour(_p.void);
    draw_circle(_x+_cx,_y+_cy,_radius*0.22,false);

    draw_set_colour(_p.metal);
    draw_circle(_x+_cx+_radius*0.15,_y+_cy-_radius*0.2,_radius*0.52,true);

    draw_set_colour(_p.outline);
    draw_line_width(
        _x+_cx-radius*0.1,_y+_cy+radius*0.12,
        _x+_cx+radius*0.42,_y+_cy-radius*0.46,
        6
    );

    draw_set_colour(_p.energy);
    draw_circle(
        _x+_cx+radius*0.42,
        _y+_cy-radius*0.46,
        6,false
    );

    draw_set_colour(c_white);
}


/// @description Draws one compact orange player hazard marking.
function sc_struct_plyr_warning_stripe(_x,_y,_cx,_cy,_w,_h,_p)
{
    draw_set_colour(_p.warning);
    draw_rectangle(
        _x+_cx-_w*0.5,
        _y+_cy-_h*0.5,
        _x+_cx+_w*0.5,
        _y+_cy+_h*0.5,
        false
    );

    var _amount=max(2,floor(_w/12));

    draw_set_colour(_p.void);

    for (var _i=0;_i<_amount;++_i)
    {
        var _px=_cx-_w*0.5+(_i+0.5)*(_w/_amount);

        draw_line_width(
            _x+_px-4,_y+_cy-_h*0.5,
            _x+_px+4,_y+_cy+_h*0.5,
            3
        );
    }

    draw_set_colour(c_white);
}