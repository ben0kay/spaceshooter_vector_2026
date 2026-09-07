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