/// @description Accelerates one visual transfer towards its HUD destination.
transfer.remaining--;
transfer.progress = clamp(
    1 - transfer.remaining / transfer.life,
    0,
    1
);

var _travel = power(
    transfer.progress,
    1.55
);

var _position = sc_hud_transfer_curve_position(
    transfer,
    _travel
);

transfer.x = _position.x;
transfer.y = _position.y;

if (transfer.remaining <= 0)
{
    sc_hud_transfer_arrive(transfer);
    instance_destroy();
}