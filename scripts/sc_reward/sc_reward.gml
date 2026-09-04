/*
REWARDS

Registered enemy rewards enter here.
The real credit total belongs to the active profile.
Visual feedback remains separate from the stored currency.
*/

/// @description Grants one registered reward to the player.
function sc_player_reward_grant(_reward, _x, _y, _layer)
{
    var _credits = max(0, round(_reward.credits));
    if (_credits <= 0) return false;

    global.profile.credits += _credits;

    sc_world_feedback_create(_x, _y, _layer, "+" + string(_credits) + " CR", make_colour_rgb(70, 245, 255), 1);

    if (instance_exists(global.level.hud))
        sc_hud_level_credit_gain(global.level.hud.hud, _credits);

    return true;
}