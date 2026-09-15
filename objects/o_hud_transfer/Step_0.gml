/// @description Delays activation, then travels and emits a residual trail.
if (!GAMEPLAY_ACTIVE) exit;

if (!transfer.spawned)
{
    transfer.spawn_delay--;

    if (transfer.spawn_delay > 0)
        exit;

    transfer.spawned = true;
    sc_particles_hud_transfer_burst_emit(transfer);
}

transfer.age++;
transfer.remaining--;

var _travel_time = transfer.life - transfer.launch_delay;

transfer.progress = clamp(
    (transfer.age - transfer.launch_delay) / _travel_time,
    0,1
);

transfer.travel = power(transfer.progress,1.35);

var _position = sc_hud_transfer_curve_position(
    transfer,
    transfer.travel
);

transfer.x = _position.x;
transfer.y = _position.y;

if (transfer.age > transfer.launch_delay
&& transfer.remaining > 1)
{
    sc_particles_hud_transfer_trail_emit(transfer);
}

if (transfer.remaining <= 0)
{
    sc_hud_transfer_arrive(transfer);
    instance_destroy();
}