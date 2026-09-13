/// @description Bursts briefly before accelerating towards the HUD.
transfer.age++;
transfer.remaining--;

var _travel_time = transfer.life
    - transfer.launch_delay;

transfer.progress = clamp(
    (transfer.age - transfer.launch_delay)
    / _travel_time,
    0,
    1
);

transfer.travel = power(
    transfer.progress,
    1.35
);

var _position = sc_hud_transfer_curve_position(
    transfer,
    transfer.travel
);

transfer.x = _position.x;
transfer.y = _position.y;

if (transfer.remaining <= 0)
{
    sc_hud_transfer_arrive(transfer);
    instance_destroy();
}