/// @description Draws one generic mine.
if (!initialized) exit;

var _radius = max(
    mine.visual.radius,
    mine.pulse.radius_max
);

if (!sc_optimization_circle_visible(
    x,
    y,
    _radius,
    32
))
    exit;

sc_mine_draw(id);