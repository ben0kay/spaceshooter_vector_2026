/// @description Advances and expires the shield-break shell.
shield_break.remaining--;

if (shield_break.remaining <= 0)
    instance_destroy();