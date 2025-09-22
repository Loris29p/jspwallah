fx_version 'cerulean'
-- fx_version 'adamant'
game 'common'

shared_scripts {
	'@library/init.lua',
	"sh_init.lua",
};

this_is_a_map 'yes'

client_script {
	'@kaykl_core/sh_core.lua',
	'@kaykl_core/sh_logs.lua',
	'@kaykl_core/cl_ped.lua',
	'@kaykl_core/cl_cam.lua',
	'@kaykl_core/cl_core.lua',
	'@kaykl_core/cl_players.lua',
	'@kaykl_core/cl_vehicles.lua',
	'@kaykl_core/cl_pmenu.lua',
	'@kaykl_core/cl_dialogue.lua',
	'@kaykl_core/cl_screen.lua',
	'@kaykl_core/cl_bars.lua',

    -- config
    "config/*.lua",

    -- base 
    "base/sh_*.lua",
    "base/cl_*.lua",

    -- load
    "items/sh_*.lua",

    -- modules 
    "modules/**/sh_*.lua",
    "modules/**/cl_*.lua",

    -- core 
    "core/**/sh_*.lua",
    "core/**/cl_*.lua",

}

server_script {

    "@oxmysql/lib/MySQL.lua",
    "@mysql-async/lib/MySQL.lua",

    "@kaykl_core/sh_core.lua",
    "@kaykl_core/sh_logs.lua",
    "@kaykl_core/sv_core.lua",

    -- config
    "config/*.lua",
    -- base
    "base/sh_*.lua",
    "base/sv_*.lua",
    -- load
    "items/sh_*.lua",

    -- module 
    "modules/**/sh_*.lua",
    "modules/**/sv_*.lua",

    -- core
    "core/**/sh_*.lua",
    "core/**/sv_*.lua",
    
}

files {
    'ui/**/*',
	'popcycle.dat',
    'visualsettings.dat',
    'data/carcols_gen9.meta',
    'data/carmodcols_gen9.meta',
    'data/carmodcols.ymt',
    'stream/vehicle_paint_ramps.ytd',
    'ui/leaderboard.html',
    'ui/welcome.html',
    'ui/video-rzpvp.html',
    'ui/spawn.html',
    'timecycles/*.xml',
    '**/weaponarchetypes.meta',
	'**/weaponanimations.meta',
	'**/pedpersonality.meta',
	'**/weapons.meta',
}

data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'

data_file 'POPSCHED_FILE' 'popcycle.dat'

data_file "CARCOLS_GEN9_FILE" "data/carcols_gen9.meta"
data_file "CARMODCOLS_GEN9_FILE" "data/carmodcols_gen9.meta"
data_file "FIVEM_LOVES_YOU_447B37BE29496FA0" "data/carmodcols.ymt"

data_file 'TIMECYCLEMOD_FILE' 'timecycles/guild_timecycle_mods_1.xml'

ui_page 'ui/index.html'

lua54 "yes"

escrow_ignore {
    "base/sv_*.lua",
    "modules/**/sv_*.lua",
    "core/**/sv_*.lua",
}

dependencies {
	"/native:0x6AE51D4B",
	"oxmysql",
	"library"
};

exports {
    "TeleportToWp",
}