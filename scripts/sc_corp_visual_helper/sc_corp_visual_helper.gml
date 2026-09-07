/// @description Draws one clean Corporation engine flame.
function sc_enemy_corporation_thrust_draw(_x, _y, _radius, _angle, _visual, _alpha)
{
    var _p = _visual.palette;

    draw_set_alpha(_alpha * 0.24);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.24, 0.88,0, 0,0.24,_p.glow,false);

    draw_set_alpha(_alpha * 0.72);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.14, 0.68,0, 0,0.14,_p.energy,false);

    draw_set_alpha(_alpha);
    sc_visual_triangle(_x,_y,_radius,_angle, 0,-0.055, 0.46,0, 0,0.055,_p.core,false);

    draw_set_alpha(1);
}

/// @description Draws one recessed Corporation panel seam.
function sc_corp_visual_panel_seam(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,4,_p.recess);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,1,_p.trim);
}

/// @description Draws one flush Corporation armour plate with a bevel edge.
function sc_corp_visual_armour_plate(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_f3,_s3,_f4,_s4,_fill,_p)
{
    sc_visual_quad(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_f3,_s3,_f4,_s4,_p.recess);

    var _inset = 0.015;

    sc_visual_quad(_x,_y,_r,_a,
        lerp(_f1,0.5,_inset),lerp(_s1,0,_inset),
        lerp(_f2,0.5,_inset),lerp(_s2,0,_inset),
        lerp(_f3,0.5,_inset),lerp(_s3,0,_inset),
        lerp(_f4,0.5,_inset),lerp(_s4,0,_inset),
        _fill
    );

    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,2,_p.armour_light);
    sc_visual_line(_x,_y,_r,_a,_f2,_s2,_f3,_s3,2,_p.trim);
    sc_visual_line(_x,_y,_r,_a,_f3,_s3,_f4,_s4,1,_p.armour_dark);
    sc_visual_line(_x,_y,_r,_a,_f4,_s4,_f1,_s1,1,_p.armour_dark);
}

/// @description Draws one recessed blue Corporation energy strip.
function sc_corp_visual_energy_strip(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width + 6,_p.recess);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width + 3,_p.glow);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width,_p.energy);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,max(1,_width * 0.32),_p.core);
}

/// @description Draws one small embedded Corporation light slit.
function sc_corp_visual_light_slit(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,6,_p.recess);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,3,_p.energy);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,1,_p.core);
}

/// @description Draws one Corporation vent bank recessed into the hull.
function sc_corp_visual_vent_bank(_x,_y,_r,_a,_forward,_side,_length,_gap,_count,_p)
{
    var _half = (_count - 1) * _gap * 0.5;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _s = _side - _half + _i * _gap;

        sc_visual_line(
            _x,_y,_r,_a,
            _forward - _length * 0.5,_s,
            _forward + _length * 0.5,_s,
            5,_p.recess
        );

        sc_visual_line(
            _x,_y,_r,_a,
            _forward - _length * 0.5,_s,
            _forward + _length * 0.5,_s,
            2,_p.armour_dark
        );
    }
}

/// @description Draws one precision Corporation armour rib.
function sc_corp_visual_armour_rib(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width + 5,_p.recess);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width + 2,_p.armour_dark);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width,_p.armour_mid);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,1,_p.armour_light);
}

/// @description Draws one embedded Corporation sensor node.
function sc_corp_visual_sensor_node(_x,_y,_r,_a,_forward,_side,_radius,_p)
{
    sc_visual_circle(_x,_y,_r,_a,_forward,_side,_radius * 1.45,_p.recess,false);
    sc_visual_circle(_x,_y,_r,_a,_forward,_side,_radius,_p.sensor,false);
    sc_visual_circle(_x,_y,_r,_a,_forward,_side,_radius * 0.38,_p.core,false);
}

/// @description Draws one compact Corporation identification bar.
function sc_corp_visual_ident_bar(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,5,_p.recess);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,2,_p.decal);
}

/// @description Draws one elite flush panel with embedded energy lighting.
function sc_corp_visual_elite_panel(_x,_y,_r,_a,_forward,_side,_length,_height,_p)
{
    var _hf = _length * 0.5;
    var _hs = _height * 0.5;

    sc_visual_quad(_x,_y,_r,_a,
        _forward-_hf,_side-_hs,
        _forward+_hf,_side-_hs,
        _forward+_hf,_side+_hs,
        _forward-_hf,_side+_hs,
        _p.recess
    );

    var _pad_f = _length * 0.08;
    var _pad_s = _height * 0.14;

    sc_visual_quad(_x,_y,_r,_a,
        _forward-_hf+_pad_f,_side-_hs+_pad_s,
        _forward+_hf-_pad_f,_side-_hs+_pad_s,
        _forward+_hf-_pad_f,_side+_hs-_pad_s,
        _forward-_hf+_pad_f,_side+_hs-_pad_s,
        _p.armour_mid
    );

    sc_corp_visual_energy_strip(
        _x,_y,_r,_a,
        _forward-_length*0.25,_side,
        _forward+_length*0.25,_side,
        max(2,_height*_r*0.08),
        _p
    );
}

/// @description Draws one recessed Corporation weapon mount housing.
function sc_corp_visual_weapon_housing(_x,_y,_r,_a,_forward,_side,_length,_height,_p)
{
    var _hf = _length * 0.5;
    var _hs = _height * 0.5;

    sc_visual_quad(_x,_y,_r,_a,
        _forward-_hf,_side-_hs,
        _forward+_hf,_side-_hs*0.72,
        _forward+_hf,_side+_hs*0.72,
        _forward-_hf,_side+_hs,
        _p.recess
    );

    sc_visual_quad(_x,_y,_r,_a,
        _forward-_hf*0.82,_side-_hs*0.68,
        _forward+_hf*0.72,_side-_hs*0.48,
        _forward+_hf*0.72,_side+_hs*0.48,
        _forward-_hf*0.82,_side+_hs*0.68,
        _p.armour_dark
    );

    sc_visual_line(
        _x,_y,_r,_a,
        _forward-_hf*0.7,_side,
        _forward+_hf*0.62,_side,
        2,_p.trim
    );
}