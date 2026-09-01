if (!initialized || !GAMEPLAY_ACTIVE) exit;

var _stats = ship.stats.final;
var _radius = ship.collision.radius;

movement.input_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
movement.input_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

if (movement.input_x != 0 || movement.input_y != 0)
{
    var _input_length = point_distance(0, 0, movement.input_x, movement.input_y);
    movement.input_x /= _input_length;
    movement.input_y /= _input_length;
    movement.moving = true;
}
else movement.moving = false;

var _target_vx = movement.input_x * _stats.speed_max;
var _target_vy = movement.input_y * _stats.speed_max;
var _change = movement.moving ? _stats.acceleration : _stats.deceleration;

movement.velocity_x += clamp(_target_vx - movement.velocity_x, -_change, _change);
movement.velocity_y += clamp(_target_vy - movement.velocity_y, -_change, _change);

if (abs(movement.velocity_x) < 0.001) movement.velocity_x = 0;
if (abs(movement.velocity_y) < 0.001) movement.velocity_y = 0;

var _next_x = x + movement.velocity_x;
var _next_y = y + movement.velocity_y;

if (collision_circle(_next_x, y, _radius, o_solid, false, true) == noone)
    x = _next_x;
else movement.velocity_x = 0;

if (collision_circle(x, _next_y, _radius, o_solid, false, true) == noone)
    y = _next_y;
else movement.velocity_y = 0;

x = clamp(x, _radius, room_width - _radius);
y = clamp(y, _radius, room_height - _radius);

movement.speed = point_distance(0, 0, movement.velocity_x, movement.velocity_y);

aim.world_x = mouse_x;
aim.world_y = mouse_y;
aim.direction = point_direction(x, y, aim.world_x, aim.world_y);

var _turn = angle_difference(aim.direction, draw_angle);
draw_angle += clamp(_turn, -_stats.turn_speed, _stats.turn_speed);
draw_angle = draw_angle mod 360;

sc_player_visual_update(id);