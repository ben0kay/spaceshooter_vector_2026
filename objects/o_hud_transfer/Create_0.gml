/// @description Initializes one configurable delayed HUD transfer.
transfer = {
    type: transfer_create.type,
    amount: transfer_create.amount,

    start: transfer_create.start,
    control: transfer_create.control,
    target: transfer_create.target,

    colour: transfer_create.colour,
    core_colour: transfer_create.core_colour,
    glow_colour: transfer_create.glow_colour,

    spawn_delay: transfer_create.spawn_delay,
    spawned: transfer_create.spawn_delay <= 0,
    body_scale: transfer_create.body_scale,

    life: transfer_create.life,
    launch_delay: transfer_create.launch_delay,
    remaining: transfer_create.life,
    age: 0,
    progress: 0,
    travel: 0,

    x: transfer_create.start.x,
    y: transfer_create.start.y,

    fragment_amount: transfer_create.fragment_amount,
    fragment_spread: transfer_create.fragment_spread,
    curve_variation: transfer_create.curve_variation
};

depth = -15000;

if (transfer.spawned)
    sc_particles_hud_transfer_burst_emit(transfer);