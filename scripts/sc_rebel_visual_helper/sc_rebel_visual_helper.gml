/// @description Draws one outlined Rebel patch plate.
function sc_rebel_visual_patch_plate(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_f3,_s3,_f4,_s4,_fill,_p)
{
    sc_visual_quad(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_f3,_s3,_f4,_s4,_fill);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,2,_p.outline);
    sc_visual_line(_x,_y,_r,_a,_f2,_s2,_f3,_s3,2,_p.outline);
    sc_visual_line(_x,_y,_r,_a,_f3,_s3,_f4,_s4,2,_p.outline);
    sc_visual_line(_x,_y,_r,_a,_f4,_s4,_f1,_s1,2,_p.outline);
}

/// @description Draws one recessed Rebel panel seam.
function sc_rebel_visual_panel_seam(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,4,_p.void);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,1,_p.steel_mid);
}

/// @description Draws one Rebel pipe with recessed backing.
function sc_rebel_visual_pipe(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width + 3,_p.void);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width,_p.steel_mid);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,1,_p.steel_light);
}

/// @description Draws one heated Rebel pipe.
function sc_rebel_visual_pipe_hot(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width + 4,_p.void);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_width,_p.rust);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,max(1,_width * 0.35),_p.energy);
}

/// @description Draws one rectangular Rebel hazard panel.
function sc_rebel_visual_hazard_panel(_x,_y,_r,_a,_forward,_side,_length,_height,_p)
{
    var _hf = _length * 0.5;
    var _hs = _height * 0.5;

    sc_visual_quad(_x,_y,_r,_a,
        _forward-_hf,_side-_hs,
        _forward+_hf,_side-_hs,
        _forward+_hf,_side+_hs,
        _forward-_hf,_side+_hs,
        _p.warning
    );

    var _count = max(2,floor(_length / 0.09));
    var _step = _length / _count;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _f = _forward-_hf+_step*(_i+0.5);
        sc_visual_line(_x,_y,_r,_a,_f-_step*0.35,_side-_hs,_f+_step*0.35,_side+_hs,3,_p.void);
    }

    sc_visual_line(_x,_y,_r,_a,_forward-_hf,_side-_hs,_forward+_hf,_side-_hs,2,_p.outline);
    sc_visual_line(_x,_y,_r,_a,_forward-_hf,_side+_hs,_forward+_hf,_side+_hs,2,_p.outline);
}

/// @description Draws one Rebel slit vent.
function sc_rebel_visual_vent(_x,_y,_r,_a,_forward,_side,_length,_gap,_count,_p)
{
    var _half = (_count-1)*_gap*0.5;

    for (var _i = 0; _i < _count; ++_i)
    {
        var _s = _side-_half+_i*_gap;
        sc_visual_line(_x,_y,_r,_a,_forward-_length*0.5,_s,_forward+_length*0.5,_s,4,_p.void);
        sc_visual_line(_x,_y,_r,_a,_forward-_length*0.5,_s,_forward+_length*0.5,_s,1,_p.steel_mid);
    }
}

/// @description Draws one small Rebel slit light.
function sc_rebel_visual_slit_light(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,7,_p.void);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,3,_p.glow);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,1,_p.core);
}

/// @description Draws one crude Rebel rivet strip.
function sc_rebel_visual_rivet_strip(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_count,_p)
{
    if (_count <= 1)
    {
        sc_visual_circle(_x,_y,_r,_a,_f1,_s1,0.018,_p.steel_light,false);
        return;
    }

    for (var _i = 0; _i < _count; ++_i)
    {
        var _t = _i/(_count-1);
        var _f = lerp(_f1,_f2,_t);
        var _s = lerp(_s1,_s2,_t);
        sc_visual_circle(_x,_y,_r,_a,_f,_s,0.018,_p.steel_light,false);
        sc_visual_circle(_x,_y,_r,_a,_f,_s,0.008,_p.void,false);
    }
}

/// @description Draws one exposed Rebel brace.
function sc_rebel_visual_brace(_x,_y,_r,_a,_f1,_s1,_f2,_s2,_p)
{
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,7,_p.void);
    sc_visual_line(_x,_y,_r,_a,_f1,_s1,_f2,_s2,3,_p.steel_mid);
    sc_visual_circle(_x,_y,_r,_a,_f1,_s1,0.026,_p.steel_light,false);
    sc_visual_circle(_x,_y,_r,_a,_f2,_s2,0.026,_p.steel_light,false);
}

/// @description Draws one Rebel patch-repair X.
function sc_rebel_visual_patch_x(_x,_y,_r,_a,_forward,_side,_size,_p)
{
    sc_visual_line(_x,_y,_r,_a,_forward-_size,_side-_size,_forward+_size,_side+_size,4,_p.void);
    sc_visual_line(_x,_y,_r,_a,_forward-_size,_side+_size,_forward+_size,_side-_size,4,_p.void);
    sc_visual_line(_x,_y,_r,_a,_forward-_size,_side-_size,_forward+_size,_side+_size,2,_p.decal);
    sc_visual_line(_x,_y,_r,_a,_forward-_size,_side+_size,_forward+_size,_side-_size,2,_p.decal);
}

/// @description Draws one pair of crude Rebel identification chevrons.
function sc_rebel_visual_chevrons(_x,_y,_r,_a,_forward,_side,_size,_direction,_p)
{
    for (var _i = 0; _i < 2; ++_i)
    {
        var _f = _forward-_i*_size*1.35*_direction;
        sc_visual_line(_x,_y,_r,_a,_f-_size*_direction,_side-_size,_f,_side,3,_p.decal);
        sc_visual_line(_x,_y,_r,_a,_f,_side,_f-_size*_direction,_side+_size,3,_p.decal);
    }
}