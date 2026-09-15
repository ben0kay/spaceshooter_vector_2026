/// @description Advances and expires the shield-break shell.
if (!GAMEPLAY_ACTIVE) exit;
shield_break.remaining--;

if (shield_break.remaining <= 0)
    instance_destroy();