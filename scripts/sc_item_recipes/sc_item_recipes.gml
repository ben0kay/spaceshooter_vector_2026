/*
MANUFACTURING RECIPES

Recipes contain only data.
Facilities decide which service types they provide.
*/

/// @description Registers one manufacturing recipe.
function sc_recipe_register(_data)
{
    var _key = _data.identity.key;

    if (variable_struct_exists(global.data.recipes, _key))
    {
        show_debug_message("RECIPE REGISTRATION ERROR - duplicate key: " + _key);
        return false;
    }

    variable_struct_set(global.data.recipes, _key, _data);
    return true;
}

/// @description Returns one registered recipe.
function sc_recipe_get(_key)
{
    if (!variable_struct_exists(global.data.recipes, _key))
    {
        show_debug_message("RECIPE ERROR - unknown key: " + _key);
        return undefined;
    }

    return variable_struct_get(global.data.recipes, _key);
}

/// @description Registers the initial industrial production tree.
function sc_recipe_register_all()
{
    return sc_recipe_register({ identity: { key: "recipe_refined_iron", name: "Refined Iron" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_iron",4]], outputs: [["item_refined_iron",1]] })
    && sc_recipe_register({ identity: { key: "recipe_refined_copper", name: "Refined Copper" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_copper",4]], outputs: [["item_refined_copper",1]] })
    && sc_recipe_register({ identity: { key: "recipe_silicon_wafer", name: "Silicon Wafer" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_silicon",3]], outputs: [["item_silicon_wafer",1]] })
    && sc_recipe_register({ identity: { key: "recipe_industrial_carbon", name: "Industrial Carbon" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_carbon",4]], outputs: [["item_industrial_carbon",1]] })
    && sc_recipe_register({ identity: { key: "recipe_industrial_sulfur", name: "Industrial Sulfur" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_sulfur",4]], outputs: [["item_industrial_sulfur",1]] })
    && sc_recipe_register({ identity: { key: "recipe_refined_titanium", name: "Refined Titanium" }, service: FacilityService.REFINERY, duration: 270, inputs: [["item_titanium",5]], outputs: [["item_refined_titanium",1]] })
    && sc_recipe_register({ identity: { key: "recipe_resonant_crystal", name: "Resonant Crystal" }, service: FacilityService.REFINERY, duration: 300, inputs: [["item_crystal",4]], outputs: [["item_resonant_crystal",1]] })
	    && sc_recipe_register({ identity: { key: "recipe_industrial_ceramic", name: "Industrial Ceramic" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_rock",4]], outputs: [["item_industrial_ceramic",1]] })
    && sc_recipe_register({ identity: { key: "recipe_optical_quartz", name: "Optical Quartz" }, service: FacilityService.REFINERY, duration: 210, inputs: [["item_quartz",4]], outputs: [["item_optical_quartz",1]] })
    && sc_recipe_register({ identity: { key: "recipe_separated_volatiles", name: "Separated Volatiles" }, service: FacilityService.REFINERY, duration: 180, inputs: [["item_ice",4]], outputs: [["item_separated_volatiles",1]] })
    && sc_recipe_register({ identity: { key: "recipe_lithium_compound", name: "Lithium Compound" }, service: FacilityService.REFINERY, duration: 210, inputs: [["item_lithium",4]], outputs: [["item_lithium_compound",1]] })
    && sc_recipe_register({ identity: { key: "recipe_refined_nickel", name: "Refined Nickel" }, service: FacilityService.REFINERY, duration: 210, inputs: [["item_nickel",4]], outputs: [["item_refined_nickel",1]] })
    && sc_recipe_register({ identity: { key: "recipe_refined_cobalt", name: "Refined Cobalt" }, service: FacilityService.REFINERY, duration: 240, inputs: [["item_cobalt",4]], outputs: [["item_refined_cobalt",1]] })
    && sc_recipe_register({ identity: { key: "recipe_refined_tungsten", name: "Refined Tungsten" }, service: FacilityService.REFINERY, duration: 300, inputs: [["item_tungsten",5]], outputs: [["item_refined_tungsten",1]] })
    && sc_recipe_register({ identity: { key: "recipe_refined_platinum", name: "Refined Platinum" }, service: FacilityService.REFINERY, duration: 300, inputs: [["item_platinum",5]], outputs: [["item_refined_platinum",1]] })
    && sc_recipe_register({ identity: { key: "recipe_enriched_uranium", name: "Enriched Uranium" }, service: FacilityService.REFINERY, duration: 360, inputs: [["item_uranium",5]], outputs: [["item_enriched_uranium",1]] })
    && sc_recipe_register({ identity: { key: "recipe_iridium_matrix", name: "Iridium Matrix" }, service: FacilityService.REFINERY, duration: 420, inputs: [["item_iridium",6]], outputs: [["item_iridium_matrix",1]] })
    && sc_recipe_register({ identity: { key: "recipe_carbon_composite", name: "Carbon Composite" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_industrial_carbon",2]], outputs: [["item_carbon_composite",1]] })
    && sc_recipe_register({ identity: { key: "recipe_steel_alloy", name: "Steel Alloy" }, service: FacilityService.FABRICATOR, duration: 300, inputs: [["item_refined_iron",2],["item_industrial_carbon",1]], outputs: [["item_steel_alloy",1]] })
    && sc_recipe_register({ identity: { key: "recipe_titanium_alloy", name: "Titanium Alloy" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_refined_titanium",2],["item_carbon_composite",1]], outputs: [["item_titanium_alloy",1]] })
	&& sc_recipe_register({ identity: { key: "recipe_nickel_steel_alloy", name: "Nickel Steel Alloy" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_refined_iron",2],["item_refined_nickel",1]], outputs: [["item_nickel_steel_alloy",1]] })
    && sc_recipe_register({ identity: { key: "recipe_cobalt_superalloy", name: "Cobalt Superalloy" }, service: FacilityService.FABRICATOR, duration: 450, inputs: [["item_refined_cobalt",1],["item_refined_nickel",1],["item_refined_titanium",1]], outputs: [["item_cobalt_superalloy",1]] })
    && sc_recipe_register({ identity: { key: "recipe_tungsten_carbide", name: "Tungsten Carbide" }, service: FacilityService.FABRICATOR, duration: 390, inputs: [["item_refined_tungsten",2],["item_industrial_carbon",1]], outputs: [["item_tungsten_carbide",1]] })
    && sc_recipe_register({ identity: { key: "recipe_resonant_alloy", name: "Resonant Alloy" }, service: FacilityService.FABRICATOR, duration: 480, inputs: [["item_titanium_alloy",1],["item_resonant_crystal",1]], outputs: [["item_resonant_alloy",1]] })
    && sc_recipe_register({ identity: { key: "recipe_iridium_composite", name: "Iridium Composite" }, service: FacilityService.FABRICATOR, duration: 600, inputs: [["item_iridium_matrix",1],["item_titanium_alloy",1],["item_carbon_composite",1]], outputs: [["item_iridium_composite",1]] })
    && sc_recipe_register({ identity: { key: "recipe_iron_plate", name: "Iron Plate" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_refined_iron",2]], outputs: [["item_iron_plate",1]] })
    && sc_recipe_register({ identity: { key: "recipe_copper_wire", name: "Copper Wire" }, service: FacilityService.FABRICATOR, duration: 150, inputs: [["item_refined_copper",1]], outputs: [["item_copper_wire",2]] })
    && sc_recipe_register({ identity: { key: "recipe_copper_coil", name: "Copper Coil" }, service: FacilityService.FABRICATOR, duration: 210, inputs: [["item_refined_copper",2]], outputs: [["item_copper_coil",1]] })
    && sc_recipe_register({ identity: { key: "recipe_circuit_board", name: "Circuit Board" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_copper_wire",2],["item_silicon_wafer",1]], outputs: [["item_circuit_board",1]] })
    && sc_recipe_register({ identity: { key: "recipe_motor", name: "Motor" }, service: FacilityService.FABRICATOR, duration: 300, inputs: [["item_refined_iron",1],["item_copper_coil",1]], outputs: [["item_motor",1]] })
        && sc_recipe_register({ identity: { key: "recipe_steel_casing", name: "Steel Casing" }, service: FacilityService.FABRICATOR, duration: 180, inputs: [["item_steel_alloy",1]], outputs: [["item_steel_casing",2]] })
    && sc_recipe_register({ identity: { key: "recipe_reinforced_plate", name: "Reinforced Plate" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_steel_alloy",2]], outputs: [["item_reinforced_plate",1]] })
    && sc_recipe_register({ identity: { key: "recipe_titanium_frame", name: "Titanium Frame" }, service: FacilityService.FABRICATOR, duration: 300, inputs: [["item_titanium_alloy",2]], outputs: [["item_titanium_frame",1]] })
    && sc_recipe_register({ identity: { key: "recipe_ceramic_plate", name: "Ceramic Plate" }, service: FacilityService.FABRICATOR, duration: 210, inputs: [["item_industrial_ceramic",2]], outputs: [["item_ceramic_plate",1]] })

    && sc_recipe_register({ identity: { key: "recipe_bearing_assembly", name: "Bearing Assembly" }, service: FacilityService.FABRICATOR, duration: 180, inputs: [["item_steel_alloy",1]], outputs: [["item_bearing_assembly",2]] })
    && sc_recipe_register({ identity: { key: "recipe_servo_assembly", name: "Servo Assembly" }, service: FacilityService.FABRICATOR, duration: 300, inputs: [["item_motor",1],["item_circuit_board",1],["item_bearing_assembly",1]], outputs: [["item_servo_assembly",1]] })
    && sc_recipe_register({ identity: { key: "recipe_linear_actuator", name: "Linear Actuator" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_motor",1],["item_steel_casing",1],["item_copper_wire",1]], outputs: [["item_linear_actuator",1]] })
    && sc_recipe_register({ identity: { key: "recipe_pump_assembly", name: "Pump Assembly" }, service: FacilityService.FABRICATOR, duration: 300, inputs: [["item_motor",1],["item_steel_casing",1],["item_copper_coil",1]], outputs: [["item_pump_assembly",1]] })
    && sc_recipe_register({ identity: { key: "recipe_turbine_assembly", name: "Turbine Assembly" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_titanium_frame",1],["item_bearing_assembly",2],["item_motor",1]], outputs: [["item_turbine_assembly",1]] })
    && sc_recipe_register({ identity: { key: "recipe_gyroscope", name: "Gyroscope" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_titanium_frame",1],["item_motor",1],["item_circuit_board",1]], outputs: [["item_gyroscope",1]] })
    && sc_recipe_register({ identity: { key: "recipe_pressure_vessel", name: "Pressure Vessel" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_steel_alloy",2],["item_ceramic_plate",1]], outputs: [["item_pressure_vessel",1]] })
    && sc_recipe_register({ identity: { key: "recipe_heat_sink", name: "Heat Sink" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_refined_copper",1],["item_carbon_composite",1]], outputs: [["item_heat_sink",1]] })
    && sc_recipe_register({ identity: { key: "recipe_radiator_assembly", name: "Radiator Assembly" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_heat_sink",1],["item_titanium_frame",1],["item_copper_wire",1]], outputs: [["item_radiator_assembly",1]] })
    && sc_recipe_register({ identity: { key: "recipe_fuel_injector", name: "Fuel Injector" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_refined_nickel",1],["item_copper_wire",1],["item_steel_casing",1]], outputs: [["item_fuel_injector",1]] })
    && sc_recipe_register({ identity: { key: "recipe_weapon_mount", name: "Weapon Mount" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_reinforced_plate",1],["item_linear_actuator",1],["item_servo_assembly",1]], outputs: [["item_weapon_mount",1]] })
    && sc_recipe_register({ identity: { key: "recipe_drone_chassis", name: "Drone Chassis" }, service: FacilityService.FABRICATOR, duration: 390, inputs: [["item_titanium_frame",1],["item_carbon_composite",1],["item_servo_assembly",1]], outputs: [["item_drone_chassis",1]] })
    && sc_recipe_register({ identity: { key: "recipe_drill_head", name: "Drill Head" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_tungsten_carbide",1],["item_steel_alloy",1]], outputs: [["item_drill_head",1]] })

    && sc_recipe_register({ identity: { key: "recipe_optical_lens", name: "Optical Lens" }, service: FacilityService.FABRICATOR, duration: 180, inputs: [["item_optical_quartz",1]], outputs: [["item_optical_lens",2]] })
    && sc_recipe_register({ identity: { key: "recipe_focusing_lens", name: "Focusing Lens" }, service: FacilityService.FABRICATOR, duration: 300, inputs: [["item_optical_lens",1],["item_resonant_crystal",1]], outputs: [["item_focusing_lens",1]] })
    && sc_recipe_register({ identity: { key: "recipe_processor_core", name: "Processor Core" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_circuit_board",1],["item_silicon_wafer",1],["item_refined_platinum",1]], outputs: [["item_processor_core",1]] })
    && sc_recipe_register({ identity: { key: "recipe_control_unit", name: "Control Unit" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_processor_core",1],["item_copper_wire",2]], outputs: [["item_control_unit",1]] })
    && sc_recipe_register({ identity: { key: "recipe_sensor_package", name: "Sensor Package" }, service: FacilityService.FABRICATOR, duration: 390, inputs: [["item_processor_core",1],["item_optical_lens",1],["item_circuit_board",1]], outputs: [["item_sensor_package",1]] })
    && sc_recipe_register({ identity: { key: "recipe_navigation_computer", name: "Navigation Computer" }, service: FacilityService.FABRICATOR, duration: 450, inputs: [["item_processor_core",1],["item_gyroscope",1],["item_sensor_package",1]], outputs: [["item_navigation_computer",1]] })
    && sc_recipe_register({ identity: { key: "recipe_targeting_computer", name: "Targeting Computer" }, service: FacilityService.FABRICATOR, duration: 450, inputs: [["item_processor_core",1],["item_optical_lens",1],["item_sensor_package",1]], outputs: [["item_targeting_computer",1]] })
    && sc_recipe_register({ identity: { key: "recipe_guidance_unit", name: "Guidance Unit" }, service: FacilityService.FABRICATOR, duration: 390, inputs: [["item_processor_core",1],["item_optical_lens",1],["item_gyroscope",1]], outputs: [["item_guidance_unit",1]] })
    && sc_recipe_register({ identity: { key: "recipe_signal_amplifier", name: "Signal Amplifier" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_circuit_board",1],["item_refined_platinum",1],["item_copper_coil",1]], outputs: [["item_signal_amplifier",1]] })
    && sc_recipe_register({ identity: { key: "recipe_power_regulator", name: "Power Regulator" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_circuit_board",1],["item_copper_coil",1],["item_heat_sink",1]], outputs: [["item_power_regulator",1]] })
    && sc_recipe_register({ identity: { key: "recipe_magnetic_core", name: "Magnetic Core" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_refined_cobalt",1],["item_refined_iron",1]], outputs: [["item_magnetic_core",1]] })
    && sc_recipe_register({ identity: { key: "recipe_field_coil", name: "Field Coil" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_copper_coil",1],["item_magnetic_core",1]], outputs: [["item_field_coil",1]] })
    && sc_recipe_register({ identity: { key: "recipe_resonance_coil", name: "Resonance Coil" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_field_coil",1],["item_resonant_crystal",1]], outputs: [["item_resonance_coil",1]] })
    && sc_recipe_register({ identity: { key: "recipe_precision_contacts", name: "Precision Contacts" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_refined_platinum",1],["item_refined_copper",1]], outputs: [["item_precision_contacts",2]] })

    && sc_recipe_register({ identity: { key: "recipe_battery_cell", name: "Battery Cell" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_lithium_compound",1],["item_refined_copper",1]], outputs: [["item_battery_cell",2]] })
    && sc_recipe_register({ identity: { key: "recipe_battery_pack", name: "Battery Pack" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_battery_cell",3],["item_circuit_board",1],["item_copper_wire",1]], outputs: [["item_battery_pack",1]] })
    && sc_recipe_register({ identity: { key: "recipe_capacitor_bank", name: "Capacitor Bank" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_battery_pack",1],["item_copper_coil",1],["item_resonant_crystal",1]], outputs: [["item_capacitor_bank",1]] })

    && sc_recipe_register({ identity: { key: "recipe_cryogenic_coolant", name: "Cryogenic Coolant" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_separated_volatiles",2],["item_industrial_ceramic",1]], outputs: [["item_cryogenic_coolant",1]] })
    && sc_recipe_register({ identity: { key: "recipe_hydrogen_fuel", name: "Hydrogen Fuel" }, service: FacilityService.FABRICATOR, duration: 210, inputs: [["item_separated_volatiles",2]], outputs: [["item_hydrogen_fuel",1]] })
    && sc_recipe_register({ identity: { key: "recipe_coolant_cell", name: "Coolant Cell" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_cryogenic_coolant",1],["item_pressure_vessel",1]], outputs: [["item_coolant_cell",1]] })
    && sc_recipe_register({ identity: { key: "recipe_fuel_cell", name: "Fuel Cell" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_hydrogen_fuel",1],["item_pressure_vessel",1]], outputs: [["item_fuel_cell",1]] })
    && sc_recipe_register({ identity: { key: "recipe_reactor_fuel_pellet", name: "Reactor Fuel Pellet" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_enriched_uranium",1]], outputs: [["item_reactor_fuel_pellet",2]] })
    && sc_recipe_register({ identity: { key: "recipe_reactor_fuel_rod", name: "Reactor Fuel Rod" }, service: FacilityService.FABRICATOR, duration: 390, inputs: [["item_reactor_fuel_pellet",3],["item_nickel_steel_alloy",1],["item_ceramic_plate",1]], outputs: [["item_reactor_fuel_rod",1]] })
    && sc_recipe_register({ identity: { key: "recipe_reactor_core", name: "Reactor Core" }, service: FacilityService.FABRICATOR, duration: 540, inputs: [["item_reactor_fuel_rod",1],["item_cobalt_superalloy",1],["item_field_coil",1],["item_coolant_cell",1]], outputs: [["item_reactor_core",1]] })

    && sc_recipe_register({ identity: { key: "recipe_propellant_compound", name: "Propellant Compound" }, service: FacilityService.FABRICATOR, duration: 210, inputs: [["item_industrial_sulfur",1],["item_industrial_carbon",1]], outputs: [["item_propellant_compound",2]] })
    && sc_recipe_register({ identity: { key: "recipe_explosive_compound", name: "Explosive Compound" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_industrial_sulfur",2],["item_industrial_carbon",1]], outputs: [["item_explosive_compound",1]] })
    && sc_recipe_register({ identity: { key: "recipe_tungsten_penetrator", name: "Tungsten Penetrator" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_tungsten_carbide",1]], outputs: [["item_tungsten_penetrator",2]] })
    && sc_recipe_register({ identity: { key: "recipe_bullet_components", name: "Bullet Components" }, service: FacilityService.FABRICATOR, duration: 180, inputs: [["item_steel_casing",1],["item_propellant_compound",1]], outputs: [["item_bullet_components",4]] })
    && sc_recipe_register({ identity: { key: "recipe_ap_bullet_components", name: "AP Bullet Components" }, service: FacilityService.FABRICATOR, duration: 240, inputs: [["item_tungsten_penetrator",1],["item_propellant_compound",1],["item_steel_casing",1]], outputs: [["item_ap_bullet_components",3]] })
    && sc_recipe_register({ identity: { key: "recipe_rocket_warhead", name: "Rocket Warhead" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_steel_casing",1],["item_explosive_compound",1]], outputs: [["item_rocket_warhead",1]] })
    && sc_recipe_register({ identity: { key: "recipe_rocket_motor", name: "Rocket Motor" }, service: FacilityService.FABRICATOR, duration: 270, inputs: [["item_hydrogen_fuel",1],["item_steel_casing",1],["item_copper_wire",1]], outputs: [["item_rocket_motor",1]] })
    && sc_recipe_register({ identity: { key: "recipe_missile_assembly", name: "Missile Assembly" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_rocket_motor",1],["item_rocket_warhead",1],["item_guidance_unit",1]], outputs: [["item_missile_assembly",1]] })
    && sc_recipe_register({ identity: { key: "recipe_mine_charge", name: "Mine Charge" }, service: FacilityService.FABRICATOR, duration: 300, inputs: [["item_explosive_compound",1],["item_circuit_board",1],["item_steel_casing",1]], outputs: [["item_mine_charge",1]] })
   
   && sc_recipe_register({ identity: { key: "recipe_armour_plate", name: "Armour Plate" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_iron_plate",3]], outputs: [["item_armour_plate",1]] })
    && sc_recipe_register({ identity: { key: "recipe_lightweight_armour_plate", name: "Lightweight Armour Plate" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_carbon_composite",2],["item_iron_plate",1]], outputs: [["item_lightweight_armour_plate",1]] })
    && sc_recipe_register({ identity: { key: "recipe_radar_array", name: "Radar Array" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_iron_plate",1],["item_circuit_board",1]], outputs: [["item_radar_array",1]] })
    && sc_recipe_register({ identity: { key: "recipe_coolant_module_mk1", name: "Coolant Module Mk I" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_copper_coil",1],["item_circuit_board",1],["item_iron_plate",1]], outputs: [["item_coolant_module_mk1",1]] })
	    && sc_recipe_register({ identity: { key: "recipe_engine_governor_mk1", name: "Engine Governor Mk I" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_motor",1],["item_circuit_board",1],["item_copper_wire",1]], outputs: [["item_engine_governor_mk1",1]] })
    && sc_recipe_register({ identity: { key: "recipe_thruster_vectoring_mk1", name: "Thruster Vectoring Module Mk I" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_motor",1],["item_copper_coil",1],["item_iron_plate",1]], outputs: [["item_thruster_vectoring_mk1",1]] })
    && sc_recipe_register({ identity: { key: "recipe_shield_capacitor_mk1", name: "Shield Capacitor Mk I" }, service: FacilityService.FABRICATOR, duration: 390, inputs: [["item_copper_coil",2],["item_circuit_board",1]], outputs: [["item_shield_capacitor_mk1",1]] })
    && sc_recipe_register({ identity: { key: "recipe_reactor_regulator_mk1", name: "Reactor Regulator Mk I" }, service: FacilityService.FABRICATOR, duration: 420, inputs: [["item_copper_coil",1],["item_circuit_board",2],["item_iron_plate",1]], outputs: [["item_reactor_regulator_mk1",1]] })
    && sc_recipe_register({ identity: { key: "recipe_weapon_stabilizer_mk1", name: "Weapon Stabilizer Mk I" }, service: FacilityService.FABRICATOR, duration: 360, inputs: [["item_motor",1],["item_circuit_board",1],["item_iron_plate",1]], outputs: [["item_weapon_stabilizer_mk1",1]] })
    && sc_recipe_register({ identity: { key: "recipe_sensor_hardening_mk1", name: "Sensor Hardening Module Mk I" }, service: FacilityService.FABRICATOR, duration: 330, inputs: [["item_circuit_board",1],["item_copper_wire",2]], outputs: [["item_sensor_hardening_mk1",1]] })
    && sc_recipe_register({ identity: { key: "recipe_drone_command_processor_mk1", name: "Drone Command Processor Mk I" }, service: FacilityService.FABRICATOR, duration: 390, inputs: [["item_circuit_board",2],["item_copper_wire",1],["item_iron_plate",1]], outputs: [["item_drone_command_processor_mk1",1]] })
	&& sc_recipe_register({ identity: { key: "recipe_scanning_drone", name: "Scanning Drone" }, service: FacilityService.FABRICATOR, duration: 540, inputs: [["item_motor",1],["item_circuit_board",1],["item_iron_plate",2],["item_copper_wire",2]], outputs: [["item_scanning_drone",1]] });
}