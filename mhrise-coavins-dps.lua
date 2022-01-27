-- dps meter for monster hunter rise
-- written by github.com/coavins

--#region Configuration

local CFG = {};
local TXT = {};
local MIN = {};
local MAX = {};

local function applyDefaultConfiguration()
	-- general settings
	CFG['UPDATE_RATE'] = 0.5; -- in seconds, so 0.5 means two updates per second
	TXT['UPDATE_RATE'] = 'Update frequency (in seconds)';
	MIN['UPDATE_RATE'] = 0.01;
	MAX['UPDATE_RATE'] = 10.00;

	-- when the settings window is open, test data will be shown in the graph
	CFG['SHOW_TEST_DATA_WHILE_MENU_IS_OPEN'] = true;
	TXT['SHOW_TEST_DATA_WHILE_MENU_IS_OPEN'] = 'Show test data while menu is open';

	-- when true, damage from palicoes and palamutes will be counted as if dealt by their hunter
	-- when false, damage from palicoes and palamutes will be ignored completely
	CFG['OTOMO_DMG_IS_PLAYER_DMG'] = true;
	TXT['OTOMO_DMG_IS_PLAYER_DMG'] = 'Combine buddies with their hunter';

	CFG['DRAW_BAR_RELATIVE_TO_PARTY'] = false;
	TXT['DRAW_BAR_RELATIVE_TO_PARTY'] = 'Damage bars will represent share of overall party DPS';

	-- table settings
	CFG['DRAW_TITLE_TEXT'] = true;
	TXT['DRAW_TITLE_TEXT'] = 'Show title text';
	CFG['DRAW_TITLE_MONSTERS'] = true;
	TXT['DRAW_TITLE_MONSTERS'] = 'Show monsters in title';
	CFG['DRAW_TITLE_BACKGROUND'] = true;
	TXT['DRAW_TITLE_BACKGROUND'] = 'Show title background';
	CFG['DRAW_BAR_BACKGROUNDS'] = true;
	TXT['DRAW_BAR_BACKGROUNDS'] = 'Show bar background';
	CFG['DRAW_BAR_OUTLINES']    = false;
	TXT['DRAW_BAR_OUTLINES'] = 'Show bar outlines';
	CFG['DRAW_BAR_COLORBLOCK'] = true; -- shows block at the front of the bar with player's color
	TXT['DRAW_BAR_COLORBLOCK'] = 'Show color block';
	CFG['DRAW_BAR_TEXT_PADDING'] = 3;
	TXT['DRAW_BAR_TEXT_PADDING'] = 'Column padding';
	MIN['DRAW_BAR_TEXT_PADDING'] = 0;
	MAX['DRAW_BAR_TEXT_PADDING'] = 35;
	CFG['DRAW_BAR_TEXT_PADDING_FIXED'] = false;
	TXT['DRAW_BAR_TEXT_PADDING_FIXED'] = 'Fixed column widths'
	CFG['DRAW_BAR_USE_PLAYER_COLORS'] = true;
	TXT['DRAW_BAR_USE_PLAYER_COLORS'] = 'Show player bars with their assigned color';
	CFG['DRAW_BAR_USE_UNIQUE_COLORS'] = true;
	TXT['DRAW_BAR_USE_UNIQUE_COLORS'] = 'Show each type of damage in a different color';

	CFG['DRAW_BAR_TEXT_NAME']                = true; -- shows name of combatant
	TXT['DRAW_BAR_TEXT_NAME'] = 'Show names';
	CFG['DRAW_BAR_TEXT_YOU']                 = false; -- shows "YOU" on your bar
	TXT['DRAW_BAR_TEXT_YOU'] = 'Show "YOU" on your row';
	CFG['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] = true; -- show real player names instead of IDs
	TXT['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] = 'Reveal character names';
	CFG['DRAW_BAR_TEXT_TOTAL_DAMAGE']        = false; -- shows total damage dealt
	TXT['DRAW_BAR_TEXT_TOTAL_DAMAGE'] = 'Show total damage done';
	CFG['DRAW_BAR_TEXT_PERCENT_OF_PARTY']    = true; -- shows your share of party damage
	TXT['DRAW_BAR_TEXT_PERCENT_OF_PARTY'] = 'Show percent of party damage';
	CFG['DRAW_BAR_TEXT_PERCENT_OF_BEST']     = false; -- shows how close you are to the top damage dealer
	TXT['DRAW_BAR_TEXT_PERCENT_OF_BEST'] = 'Show percent of leader\'s damage';
	CFG['DRAW_BAR_TEXT_HIT_COUNT']           = false; -- shows how many hits you've landed
	TXT['DRAW_BAR_TEXT_HIT_COUNT'] = 'Show number of hits';
	CFG['DRAW_BAR_TEXT_BIGGEST_HIT']         = false; -- shows how much damage your biggest hit did
	TXT['DRAW_BAR_TEXT_BIGGEST_HIT'] = 'Show damage dealt by biggest hit';

	-- the damage bars will be removed, and the player blocks will receive shading instead
	CFG['USE_MINIMAL_BARS'] = false;
	TXT['USE_MINIMAL_BARS'] = 'Use a minimalist style for the damage bars';

	-- rows will be added on top of the title bar instead, making it easier to place the table at the bottom of the screen
	CFG['TABLE_GROWS_UPWARD'] = false;
	TXT['TABLE_GROWS_UPWARD'] = 'Table grows upward instead of down';

	-- when true, the row with the highest damage will be on bottom. you might want to use this with TABLE_GROWS_UPWARD
	CFG['TABLE_SORT_ASC'] = false;
	TXT['TABLE_SORT_ASC'] = 'Sort ascending';
	-- when true, player 1 will be first and player 4 will be last
	CFG['TABLE_SORT_IN_ORDER'] = false;
	TXT['TABLE_SORT_IN_ORDER'] = 'Sort by player';

	-- table position
	-- X/Y here is expressed as a percentage
	-- 0 is left/top of screen, 1 is right/bottom
	CFG['TABLE_X'] = 0.65;
	TXT['TABLE_X'] = 'Horizontal position';
	MIN['TABLE_X'] = 0.0;
	MAX['TABLE_X'] = 1.0;
	CFG['TABLE_Y'] = 0.00;
	TXT['TABLE_Y'] = 'Vertical position';
	MIN['TABLE_Y'] = 0.0;
	MAX['TABLE_Y'] = 1.0;
	CFG['TABLE_SCALE'] = 1.0; -- multiplier for width and height
	TXT['TABLE_SCALE'] = 'Scaling factor';
	MIN['TABLE_SCALE'] = 0.0;
	MAX['TABLE_SCALE'] = 10.00;

	CFG['TABLE_HEADER_TEXT_OFFSET_X'] = 3;
	TXT['TABLE_HEADER_TEXT_OFFSET_X'] = 'Table text offset X';
	MIN['TABLE_HEADER_TEXT_OFFSET_X'] = -100;
	MAX['TABLE_HEADER_TEXT_OFFSET_X'] = 100;
	CFG['TABLE_WIDTH'] = 350;
	TXT['TABLE_WIDTH'] = 'Table width';
	MIN['TABLE_WIDTH'] = 0;
	MAX['TABLE_WIDTH'] = 3000;

	CFG['TABLE_ROWH'] = 18;
	TXT['TABLE_ROWH'] = 'Row height';
	MIN['TABLE_ROWH'] = 0;
	MAX['TABLE_ROWH'] = 100;

	CFG['TABLE_ROW_PADDING'] = 0;
	TXT['TABLE_ROW_PADDING'] = 'Row padding'
	MIN['TABLE_ROW_PADDING'] = 0;
	MAX['TABLE_ROW_PADDING'] = 150;

	CFG['TABLE_ROW_TEXT_OFFSET_X'] = 0; -- x offset for damage bar text
	TXT['TABLE_ROW_TEXT_OFFSET_X'] = 'Row text offset X';
	MIN['TABLE_ROW_TEXT_OFFSET_X'] = -100;
	MAX['TABLE_ROW_TEXT_OFFSET_X'] = 100;
	CFG['TABLE_ROW_TEXT_OFFSET_Y'] = 0; -- y offset for damage bar text
	TXT['TABLE_ROW_TEXT_OFFSET_Y'] = 'Row text offset Y';
	MIN['TABLE_ROW_TEXT_OFFSET_Y'] = -100;
	MAX['TABLE_ROW_TEXT_OFFSET_Y'] = 100;

	-- colors
	-- 0x 12345678
	-- 12 = alpha
	-- 34 = green
	-- 56 = blue
	-- 78 = red

	-- basic palette
	CFG['COLOR_WHITE']  = 0xFFFFFFFF;
	CFG['COLOR_GRAY']   = 0xFFAFAFAF;
	CFG['COLOR_BLACK']  = 0xFF000000;
	CFG['COLOR_RED']    = 0xAF3232FF;
	CFG['COLOR_BLUE']   = 0xAFFF3232;
	CFG['COLOR_YELLOW'] = 0xAF32FFFF;
	CFG['COLOR_GREEN']  = 0xAF32FF32;

	-- players
	CFG['COLOR_PLAYER'] = {};
	CFG['COLOR_PLAYER'][0] = CFG['COLOR_RED'];
	CFG['COLOR_PLAYER'][1] = CFG['COLOR_BLUE'];
	CFG['COLOR_PLAYER'][2] = CFG['COLOR_YELLOW'];
	CFG['COLOR_PLAYER'][3] = CFG['COLOR_GREEN'];

	CFG['COLOR_OTOMO'] = 0xAFFCD032;

	-- table colors
	CFG['COLOR_TITLE_BG']         = 0x88000000;
	CFG['COLOR_TITLE_FG']         = 0xFFDADADA;
	CFG['COLOR_BAR_BG']           = 0x44000000;
	CFG['COLOR_BAR_OUTLINE']      = 0x44000000;

	CFG['COLOR_BAR_DMG_PHYSICAL'] = 0xAF616658;
	CFG['COLOR_BAR_DMG_PHYSICAL_UNIQUE'] = {};
	CFG['COLOR_BAR_DMG_PHYSICAL_UNIQUE'][0] = 0xAF2828CC; -- red
	CFG['COLOR_BAR_DMG_PHYSICAL_UNIQUE'][1] = 0xAFCC2828; -- blue
	CFG['COLOR_BAR_DMG_PHYSICAL_UNIQUE'][2] = 0xAF28CCCC; -- yellow
	CFG['COLOR_BAR_DMG_PHYSICAL_UNIQUE'][3] = 0xAF28CC28; -- green

	CFG['COLOR_BAR_DMG_ELEMENT']  = 0xAF919984;
	CFG['COLOR_BAR_DMG_ELEMENT_UNIQUE'] = {};
	CFG['COLOR_BAR_DMG_ELEMENT_UNIQUE'][0] = 0xAF1C1C8C; -- red
	CFG['COLOR_BAR_DMG_ELEMENT_UNIQUE'][1] = 0xAF8C1C1C; -- blue
	CFG['COLOR_BAR_DMG_ELEMENT_UNIQUE'][2] = 0xAF1C8C8C; -- yellow
	CFG['COLOR_BAR_DMG_ELEMENT_UNIQUE'][3] = 0xAF1C8C1C; -- green

	CFG['COLOR_BAR_DMG_AILMENT']  = 0xAF3E37A3;
	CFG['COLOR_BAR_DMG_OTOMO']    = 0xAFF0BB00;
	CFG['COLOR_BAR_DMG_OTHER']    = 0xAF616658;
end

--#endregion Configuration

--#region Presets

local PRESET_STANDARD = {};
PRESET_STANDARD['OTOMO_DMG_IS_PLAYER_DMG'] = true;
PRESET_STANDARD['DRAW_BAR_BACKGROUNDS'] = true;
PRESET_STANDARD['DRAW_BAR_OUTLINES'] = false;
PRESET_STANDARD['DRAW_BAR_TEXT_NAME'] = true;
PRESET_STANDARD['DRAW_BAR_TEXT_YOU'] = true;
PRESET_STANDARD['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] = false;
PRESET_STANDARD['DRAW_BAR_TEXT_TOTAL_DAMAGE'] = false;
PRESET_STANDARD['DRAW_BAR_TEXT_PERCENT_OF_PARTY'] = true;
PRESET_STANDARD['DRAW_BAR_TEXT_PERCENT_OF_BEST'] = false;
PRESET_STANDARD['DRAW_BAR_TEXT_HIT_COUNT'] = false;
PRESET_STANDARD['DRAW_BAR_TEXT_BIGGEST_HIT'] = false;
PRESET_STANDARD['USE_MINIMAL_BARS'] = false;
PRESET_STANDARD['TABLE_WIDTH'] = 350;
PRESET_STANDARD['TABLE_ROWH'] = 18;

local PRESET_DETAILED = {};
PRESET_DETAILED['OTOMO_DMG_IS_PLAYER_DMG'] = true;
PRESET_DETAILED['DRAW_BAR_BACKGROUNDS'] = true;
PRESET_DETAILED['DRAW_BAR_OUTLINES'] = false;
PRESET_DETAILED['DRAW_BAR_TEXT_NAME'] = true;
PRESET_DETAILED['DRAW_BAR_TEXT_YOU'] = true;
PRESET_DETAILED['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] = false;
PRESET_DETAILED['DRAW_BAR_TEXT_TOTAL_DAMAGE'] = true;
PRESET_DETAILED['DRAW_BAR_TEXT_PERCENT_OF_PARTY'] = true;
PRESET_DETAILED['DRAW_BAR_TEXT_PERCENT_OF_BEST'] = true;
PRESET_DETAILED['DRAW_BAR_TEXT_HIT_COUNT'] = true;
PRESET_DETAILED['DRAW_BAR_TEXT_BIGGEST_HIT'] = true;
PRESET_DETAILED['USE_MINIMAL_BARS'] = false;
PRESET_DETAILED['TABLE_SORT_ASC'] = false;
PRESET_DETAILED['TABLE_WIDTH'] = 350;
PRESET_DETAILED['TABLE_ROWH'] = 18;

local PRESET_FYLEX = {};
PRESET_FYLEX['OTOMO_DMG_IS_PLAYER_DMG'] = false;
PRESET_FYLEX['DRAW_TITLE_TEXT'] = false;
PRESET_FYLEX['DRAW_TITLE_BACKGROUND'] = false;
PRESET_FYLEX['DRAW_BAR_TEXT_NAME'] = true;
PRESET_FYLEX['DRAW_BAR_TEXT_YOU'] = false;
PRESET_FYLEX['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] = true;
PRESET_FYLEX['DRAW_BAR_TEXT_TOTAL_DAMAGE'] = true;
PRESET_FYLEX['DRAW_BAR_TEXT_PERCENT_OF_PARTY'] = true;
PRESET_FYLEX['DRAW_BAR_TEXT_PERCENT_OF_BEST'] = false;
PRESET_FYLEX['DRAW_BAR_TEXT_HIT_COUNT'] = false;
PRESET_FYLEX['DRAW_BAR_TEXT_BIGGEST_HIT'] = false;
PRESET_FYLEX['USE_MINIMAL_BARS'] = true;
PRESET_FYLEX['TABLE_SORT_IN_ORDER'] = false;
PRESET_FYLEX['TABLE_X'] = 0.72;
PRESET_FYLEX['TABLE_Y'] = 0.01;

local PRESET_MHROVERLAY = {};
PRESET_MHROVERLAY['DRAW_TITLE_TEXT'] = false;
PRESET_MHROVERLAY['DRAW_TITLE_BACKGROUND'] = false;
PRESET_MHROVERLAY['DRAW_BAR_BACKGROUNDS'] = true;
PRESET_MHROVERLAY['DRAW_BAR_COLORBLOCK'] = false;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_PADDING'] = 26;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_PADDING_FIXED'] = true;
PRESET_MHROVERLAY['DRAW_BAR_USE_PLAYER_COLORS'] = false;
PRESET_MHROVERLAY['DRAW_BAR_USE_UNIQUE_COLORS'] = false;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_NAME'] = true;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_YOU'] = false;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] = true;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_TOTAL_DAMAGE'] = true;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_PERCENT_OF_PARTY'] = true;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_PERCENT_OF_BEST'] = false;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_HIT_COUNT'] = false;
PRESET_MHROVERLAY['DRAW_BAR_TEXT_BIGGEST_HIT'] = false;
PRESET_MHROVERLAY['USE_MINIMAL_BARS'] = false;
PRESET_MHROVERLAY['TABLE_GROWS_UPWARD'] = false;
PRESET_MHROVERLAY['TABLE_SORT_ASC'] = false;
PRESET_MHROVERLAY['TABLE_SORT_IN_ORDER'] = true;
PRESET_MHROVERLAY['TABLE_SORT_ASC'] = false;
PRESET_MHROVERLAY['TABLE_X'] = 0.23;
PRESET_MHROVERLAY['TABLE_Y'] = 0.79;
PRESET_MHROVERLAY['TABLE_SCALE'] = 1;
PRESET_MHROVERLAY['TABLE_WIDTH'] = 316;
PRESET_MHROVERLAY['TABLE_ROWH'] = 6;
PRESET_MHROVERLAY['TABLE_ROW_PADDING'] = 19;
PRESET_MHROVERLAY['TABLE_ROW_TEXT_OFFSET_X'] = 5;
PRESET_MHROVERLAY['TABLE_ROW_TEXT_OFFSET_Y'] = -16;
PRESET_MHROVERLAY['COLOR_BAR_DMG_PHYSICAL'] = 0xAFE069AE;

--#endregion Presets

--#region enums

-- via.hid.KeyboardKey
local ENUM_KEYBOARD_KEY = {};
ENUM_KEYBOARD_KEY[0] = 'None';
ENUM_KEYBOARD_KEY[1] = 'LButton';
ENUM_KEYBOARD_KEY[2] = 'RButton';
ENUM_KEYBOARD_KEY[3] = 'Cancel';
ENUM_KEYBOARD_KEY[4] = 'MButton';
ENUM_KEYBOARD_KEY[5] = 'XButton1';
ENUM_KEYBOARD_KEY[6] = 'XButton2';
ENUM_KEYBOARD_KEY[8] = 'Back';
ENUM_KEYBOARD_KEY[9] = 'Tab';
ENUM_KEYBOARD_KEY[12] = 'Clear';
ENUM_KEYBOARD_KEY[13] = 'Enter';
ENUM_KEYBOARD_KEY[16] = 'Shift'; -- modifier
ENUM_KEYBOARD_KEY[17] = 'Control'; -- modifier
ENUM_KEYBOARD_KEY[18] = 'Menu';
ENUM_KEYBOARD_KEY[19] = 'Pause';
ENUM_KEYBOARD_KEY[20] = 'Capital';
ENUM_KEYBOARD_KEY[21] = 'Kana';
ENUM_KEYBOARD_KEY[23] = 'Junja';
ENUM_KEYBOARD_KEY[24] = 'Final';
ENUM_KEYBOARD_KEY[25] = 'Hanja';
ENUM_KEYBOARD_KEY[27] = 'Escape';
ENUM_KEYBOARD_KEY[28] = 'Convert';
ENUM_KEYBOARD_KEY[29] = 'NonConvert';
ENUM_KEYBOARD_KEY[30] = 'Accept';
ENUM_KEYBOARD_KEY[31] = 'ModeChange';
ENUM_KEYBOARD_KEY[32] = 'Space';
ENUM_KEYBOARD_KEY[33] = 'Prior';
ENUM_KEYBOARD_KEY[34] = 'Next';
ENUM_KEYBOARD_KEY[35] = 'End';
ENUM_KEYBOARD_KEY[36] = 'Home';
ENUM_KEYBOARD_KEY[37] = 'Left';
ENUM_KEYBOARD_KEY[38] = 'Up';
ENUM_KEYBOARD_KEY[39] = 'Right';
ENUM_KEYBOARD_KEY[40] = 'Down';
ENUM_KEYBOARD_KEY[41] = 'Select';
ENUM_KEYBOARD_KEY[42] = 'Print';
ENUM_KEYBOARD_KEY[43] = 'Execute';
ENUM_KEYBOARD_KEY[44] = 'SnapShot';
ENUM_KEYBOARD_KEY[45] = 'Insert';
ENUM_KEYBOARD_KEY[46] = 'Delete';
ENUM_KEYBOARD_KEY[47] = 'Help';
ENUM_KEYBOARD_KEY[48] = 'Alpha0';
ENUM_KEYBOARD_KEY[49] = 'Alpha1';
ENUM_KEYBOARD_KEY[50] = 'Alpha2';
ENUM_KEYBOARD_KEY[51] = 'Alpha3';
ENUM_KEYBOARD_KEY[52] = 'Alpha4';
ENUM_KEYBOARD_KEY[53] = 'Alpha5';
ENUM_KEYBOARD_KEY[54] = 'Alpha6';
ENUM_KEYBOARD_KEY[55] = 'Alpha7';
ENUM_KEYBOARD_KEY[56] = 'Alpha8';
ENUM_KEYBOARD_KEY[57] = 'Alpha9';
ENUM_KEYBOARD_KEY[65] = 'A';
ENUM_KEYBOARD_KEY[66] = 'B';
ENUM_KEYBOARD_KEY[67] = 'C';
ENUM_KEYBOARD_KEY[68] = 'D';
ENUM_KEYBOARD_KEY[69] = 'E';
ENUM_KEYBOARD_KEY[70] = 'F';
ENUM_KEYBOARD_KEY[71] = 'G';
ENUM_KEYBOARD_KEY[72] = 'H';
ENUM_KEYBOARD_KEY[73] = 'J';
ENUM_KEYBOARD_KEY[75] = 'K';
ENUM_KEYBOARD_KEY[76] = 'L';
ENUM_KEYBOARD_KEY[77] = 'M';
ENUM_KEYBOARD_KEY[78] = 'N';
ENUM_KEYBOARD_KEY[79] = 'O';
ENUM_KEYBOARD_KEY[80] = 'P';
ENUM_KEYBOARD_KEY[81] = 'Q';
ENUM_KEYBOARD_KEY[82] = 'R';
ENUM_KEYBOARD_KEY[83] = 'S';
ENUM_KEYBOARD_KEY[84] = 'T';
ENUM_KEYBOARD_KEY[85] = 'U';
ENUM_KEYBOARD_KEY[86] = 'V';
ENUM_KEYBOARD_KEY[87] = 'W';
ENUM_KEYBOARD_KEY[88] = 'X';
ENUM_KEYBOARD_KEY[89] = 'Y';
ENUM_KEYBOARD_KEY[90] = 'Z';
ENUM_KEYBOARD_KEY[91] = 'LWin';
ENUM_KEYBOARD_KEY[92] = 'RWin';
ENUM_KEYBOARD_KEY[93] = 'Apps';
ENUM_KEYBOARD_KEY[95] = 'Sleep';
ENUM_KEYBOARD_KEY[96] = 'NumPad0';
ENUM_KEYBOARD_KEY[97] = 'NumPad1';
ENUM_KEYBOARD_KEY[98] = 'NumPad2';
ENUM_KEYBOARD_KEY[99] = 'NumPad3';
ENUM_KEYBOARD_KEY[100] = 'NumPad4';
ENUM_KEYBOARD_KEY[101] = 'NumPad5';
ENUM_KEYBOARD_KEY[102] = 'NumPad6';
ENUM_KEYBOARD_KEY[103] = 'NumPad7';
ENUM_KEYBOARD_KEY[104] = 'NumPad8';
ENUM_KEYBOARD_KEY[105] = 'NumPad9';
ENUM_KEYBOARD_KEY[106] = 'Multiply';
ENUM_KEYBOARD_KEY[107] = 'Add';
ENUM_KEYBOARD_KEY[108] = 'Separator';
ENUM_KEYBOARD_KEY[109] = 'Subtract';
ENUM_KEYBOARD_KEY[110] = 'Decimal';
ENUM_KEYBOARD_KEY[111] = 'Divide';
ENUM_KEYBOARD_KEY[112] = 'F1';
ENUM_KEYBOARD_KEY[113] = 'F2';
ENUM_KEYBOARD_KEY[114] = 'F3';
ENUM_KEYBOARD_KEY[115] = 'F4';
ENUM_KEYBOARD_KEY[116] = 'F5';
ENUM_KEYBOARD_KEY[117] = 'F6';
ENUM_KEYBOARD_KEY[118] = 'F7';
ENUM_KEYBOARD_KEY[119] = 'F8';
ENUM_KEYBOARD_KEY[120] = 'F9';
ENUM_KEYBOARD_KEY[121] = 'F10';
ENUM_KEYBOARD_KEY[122] = 'F11';
ENUM_KEYBOARD_KEY[123] = 'F12';
ENUM_KEYBOARD_KEY[124] = 'F13';
ENUM_KEYBOARD_KEY[125] = 'F14';
ENUM_KEYBOARD_KEY[126] = 'F15';
ENUM_KEYBOARD_KEY[127] = 'F16';
ENUM_KEYBOARD_KEY[128] = 'F17';
ENUM_KEYBOARD_KEY[129] = 'F18';
ENUM_KEYBOARD_KEY[130] = 'F19';
ENUM_KEYBOARD_KEY[131] = 'F20';
ENUM_KEYBOARD_KEY[132] = 'F21';
ENUM_KEYBOARD_KEY[133] = 'F22';
ENUM_KEYBOARD_KEY[134] = 'F23';
ENUM_KEYBOARD_KEY[135] = 'F24';
ENUM_KEYBOARD_KEY[144] = 'NumLock';
ENUM_KEYBOARD_KEY[145] = 'Scroll';
ENUM_KEYBOARD_KEY[146] = 'NumPadEnter';
ENUM_KEYBOARD_KEY[160] = 'LShift';
ENUM_KEYBOARD_KEY[161] = 'RShift';
ENUM_KEYBOARD_KEY[162] = 'LControl';
ENUM_KEYBOARD_KEY[163] = 'RControl';
ENUM_KEYBOARD_KEY[164] = 'LMenu';
ENUM_KEYBOARD_KEY[165] = 'RMenu';
ENUM_KEYBOARD_KEY[186] = 'OEM_1';
ENUM_KEYBOARD_KEY[187] = 'OEM_Plus';
ENUM_KEYBOARD_KEY[188] = 'OEM_Comma';
ENUM_KEYBOARD_KEY[189] = 'OEM_Minus';
ENUM_KEYBOARD_KEY[190] = 'OEM_Period';
ENUM_KEYBOARD_KEY[191] = 'Slash';
ENUM_KEYBOARD_KEY[192] = 'OEM_3';
ENUM_KEYBOARD_KEY[219] = 'OEM_4';
ENUM_KEYBOARD_KEY[220] = 'OEM_5';
ENUM_KEYBOARD_KEY[221] = 'OEM_6';
ENUM_KEYBOARD_KEY[222] = 'OEM_7';
ENUM_KEYBOARD_KEY[223] = 'OEM_8';
ENUM_KEYBOARD_KEY[226] = 'OEM_102';
ENUM_KEYBOARD_KEY[220] = 'BackSlash';
ENUM_KEYBOARD_KEY[254] = 'DefinedEnter';
ENUM_KEYBOARD_KEY[255] = 'DefinedCancel';

local ATTACKER_TYPES = {};
ATTACKER_TYPES[0] = 'weapon';
ATTACKER_TYPES[1] = 'barrelbombl';
ATTACKER_TYPES[2] = 'makimushi';
ATTACKER_TYPES[3] = 'nitro';
ATTACKER_TYPES[4] = 'onibimine';
ATTACKER_TYPES[5] = 'ballistahate';
ATTACKER_TYPES[6] = 'capturesmokebomb';
ATTACKER_TYPES[7] = 'capturebullet';
ATTACKER_TYPES[8] = 'barrelbombs';
ATTACKER_TYPES[9] = 'kunai';
ATTACKER_TYPES[10] = 'waterbeetle';
ATTACKER_TYPES[11] = 'detonationgrenade';
ATTACKER_TYPES[12] = 'hmballista';
ATTACKER_TYPES[13] = 'hmcannon';
ATTACKER_TYPES[14] = 'hmgatling';
ATTACKER_TYPES[15] = 'hmtrap';
ATTACKER_TYPES[16] = 'hmnpc';
ATTACKER_TYPES[17] = 'hmflamethrower';
ATTACKER_TYPES[18] = 'hmdragonator';
ATTACKER_TYPES[19] = 'otomo';
ATTACKER_TYPES[20] = 'fg005';
ATTACKER_TYPES[21] = 'ecbatexplode';
ATTACKER_TYPES[23] = 'monster';

local ATTACKER_TYPE_TEXT = {};
ATTACKER_TYPE_TEXT['weapon']            = 'Weapon';
ATTACKER_TYPE_TEXT['barrelbombl']       = 'Large Barrel Bomb';
ATTACKER_TYPE_TEXT['makimushi']         = 'makimushi';
ATTACKER_TYPE_TEXT['nitro']             = 'nitro';
ATTACKER_TYPE_TEXT['onibimine']         = 'onibimine';
ATTACKER_TYPE_TEXT['ballistahate']      = 'ballistahate';
ATTACKER_TYPE_TEXT['capturesmokebomb']  = 'Tranq Bomb';
ATTACKER_TYPE_TEXT['capturebullet']     = 'Tranq Ammo';
ATTACKER_TYPE_TEXT['barrelbombs']       = 'Barrel Bomb';
ATTACKER_TYPE_TEXT['kunai']             = 'Kunai';
ATTACKER_TYPE_TEXT['waterbeetle']       = 'waterbeetle';
ATTACKER_TYPE_TEXT['detonationgrenade'] = 'detonationgrenade';
ATTACKER_TYPE_TEXT['hmballista']        = 'Ballista';
ATTACKER_TYPE_TEXT['hmcannon']          = 'Cannon';
ATTACKER_TYPE_TEXT['hmgatling']         = 'Machine Cannon';
ATTACKER_TYPE_TEXT['hmtrap']            = 'Bamboo Bomb';
ATTACKER_TYPE_TEXT['hmnpc']             = 'Defenders';
ATTACKER_TYPE_TEXT['hmflamethrower']    = 'Wyvernfire';
ATTACKER_TYPE_TEXT['hmdragonator']      = 'Dragonator';
ATTACKER_TYPE_TEXT['otomo']             = 'Buddy';
ATTACKER_TYPE_TEXT['fg005']             = 'fg005';
ATTACKER_TYPE_TEXT['ecbatexplode']      = 'ecbatexplode';
ATTACKER_TYPE_TEXT['monster']           = 'Monster';

--#endregion

--#region globals

local DPS_ENABLED = true;
local DPS_DEBUG = false;
local LAST_UPDATE_TIME = 0;
local DRAW_OVERLAY = true;
local DRAW_WINDOW_SETTINGS = false;
local DRAW_WINDOW_REPORT = false;
local DRAW_WINDOW_HOTKEYS = false;
local WINDOW_FLAGS = 0x10120;
local IS_ONLINE = false;

local ASSIGNED_HOTKEY_THIS_FRAME = false;
local HOTKEY_TOGGLE_OVERLAY = 109; -- 109 is numpad minus
local HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false; -- if true, will register next key press as the new hotkey

local PRESETS = {};
local PRESET_OPTIONS = {};
local PRESET_OPTIONS_SELECTED = 1;

-- load presets
PRESETS['Standard'] = PRESET_STANDARD;
PRESETS['Detailed'] = PRESET_DETAILED;
PRESETS['Fylex'] = PRESET_FYLEX;
PRESETS['MHR Overlay'] = PRESET_MHROVERLAY;

-- build preset options list
for name,_ in pairs(PRESETS) do
	table.insert(PRESET_OPTIONS, name);
end
table.sort(PRESET_OPTIONS);
table.insert(PRESET_OPTIONS, 1, 'Select a preset');

local SCREEN_W = 0;
local SCREEN_H = 0;
local DEBUG_Y = 0;
local FAKE_OTOMO_RANGE_START = 9990; -- it is important that attacker ids near this are never used by the game

local LARGE_MONSTERS = {};
local TEST_MONSTERS = nil; -- like LARGE_MONSTERS, but holds dummy/test data
local DAMAGE_REPORTS = {};

local REPORT_MONSTERS = {}; -- a subset of LARGE_MONSTERS or TEST_MONSTERS that will appear in reports
local REPORT_ATTACKER_TYPES = {}; -- a subset of ATTACKER_TYPES that will appear in reports
local REPORT_OTOMO = false; -- show otomo in the report
local REPORT_OTHER = false; -- show monsters, etc in the report

local MY_PLAYER_ID = nil;
local PLAYER_NAMES = {};
local OTOMO_NAMES = {};

-- initialized later when they become available
local PLAYER_MANAGER   = nil;
local ENEMY_MANAGER    = nil;
local QUEST_MANAGER    = nil;
local MESSAGE_MANAGER  = nil;
local LOBBY_MANAGER    = nil;
local AREA_MANAGER     = nil;
local OTOMO_MANAGER    = nil;
local KEYBOARD_MANAGER = nil;

local SCENE_MANAGER      = sdk.get_native_singleton("via.SceneManager");
local SCENE_MANAGER_TYPE = sdk.find_type_definition("via.SceneManager");
local SCENE_MANAGER_VIEW = sdk.call_native_func(SCENE_MANAGER, SCENE_MANAGER_TYPE, "get_MainView");

local QUEST_MANAGER_TYPE = sdk.find_type_definition("snow.QuestManager");
local QUEST_MANAGER_METHOD_ONCHANGEDGAMESTATUS = QUEST_MANAGER_TYPE:get_method("onChangedGameStatus");
--local QUEST_MANAGER_METHOD_ADDKPIATTACKDAMAGE = QUEST_MANAGER_TYPE:get_method("addKpiAttackDamage");
local SNOW_ENEMY_ENEMYCHARACTERBASE = sdk.find_type_definition("snow.enemy.EnemyCharacterBase");
-- stockDamage function also works, for host only
local SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE =
	SNOW_ENEMY_ENEMYCHARACTERBASE:get_method("afterCalcDamage_DamageSide");
local SNOW_ENEMY_ENEMYCHARACTERBASE_UPDATE = SNOW_ENEMY_ENEMYCHARACTERBASE:get_method("update");

--#endregion

--#region Helper functions

local function debug_line(text)
	DEBUG_Y = DEBUG_Y + 20;
	draw.text(text, 0, DEBUG_Y, 0xFFFFFFFF);
end

local function log_info(text)
	log.info('mhrise-coavins-dps: ' .. text);
end

local function log_error(text)
	log.error('mhrise-coavins-dps: ' .. text);
end

local function readScreenDimensions()
	local size = SCENE_MANAGER_VIEW:call("get_Size");
	if not size then
		log_error('could not get screen size');
	end;

	SCREEN_W = size:get_field("w");
	SCREEN_H = size:get_field("h");
end

local function getScreenXFromX(x)
	return SCREEN_W * x;
end

local function getScreenYFromY(y)
	return SCREEN_H * y;
end

local function hasManagedResources()
	if not PLAYER_MANAGER then
		PLAYER_MANAGER = sdk.get_managed_singleton("snow.player.PlayerManager");
		if not PLAYER_MANAGER then
			return false;
		end
	end

	if not QUEST_MANAGER then
		QUEST_MANAGER = sdk.get_managed_singleton("snow.QuestManager");
		if not QUEST_MANAGER then
			return false;
		end
	end

	if not ENEMY_MANAGER then
		ENEMY_MANAGER = sdk.get_managed_singleton("snow.enemy.EnemyManager");
		if not ENEMY_MANAGER then
			return false;
		end
	end

	if not MESSAGE_MANAGER then
		MESSAGE_MANAGER = sdk.get_managed_singleton("snow.gui.MessageManager");
		if not MESSAGE_MANAGER then
			return false;
		end
	end

	if not LOBBY_MANAGER then
		LOBBY_MANAGER = sdk.get_managed_singleton("snow.LobbyManager");
		if not LOBBY_MANAGER then
			return false;
		end
	end

	if not OTOMO_MANAGER then
		OTOMO_MANAGER = sdk.get_managed_singleton("snow.otomo.OtomoManager");
		if not OTOMO_MANAGER then
			return false;
		end
	end

	if not KEYBOARD_MANAGER then
		local softKeyboard = sdk.get_managed_singleton("snow.GameKeyboard");
		if softKeyboard then
			KEYBOARD_MANAGER = softKeyboard:get_field("hardKeyboard");
			if not KEYBOARD_MANAGER then
				return false;
			end
		else
			return false;
		end
	end

	-- not required since it doesn't seem to always be available
	if not AREA_MANAGER then
		AREA_MANAGER = sdk.get_managed_singleton("snow.VillageAreaManager");
	end

	return true;
end

local function applySelectedPreset()
	applyDefaultConfiguration();
	local name = PRESET_OPTIONS[PRESET_OPTIONS_SELECTED];
	local preset = PRESETS[name];
	if preset then
		for setting,value in pairs(preset) do
			CFG[setting] = value;
		end
	end
end

local function cleanUpData()
	LAST_UPDATE_TIME = 0;
	LARGE_MONSTERS  = {};
	DAMAGE_REPORTS  = {};
	REPORT_MONSTERS = {};
	log_info('cleared captured data');
end

local function AddMonsterToReport(enemyToAdd, bossInfo)
	REPORT_MONSTERS[enemyToAdd] = bossInfo;
	log_info(string.format('%s added to report', bossInfo.name));
end

local function RemoveMonsterFromReport(enemyToRemove)
	for enemy,boss in pairs(REPORT_MONSTERS) do
		if enemy == enemyToRemove then
			REPORT_MONSTERS[enemy] = nil;
			log_info(string.format('%s removed from report', boss.name));
			return;
		end
	end
end

local function AddAttackerTypeToReport(typeToAdd)
	REPORT_ATTACKER_TYPES[typeToAdd] = true;
	log_info(string.format('damage type %s added to report', typeToAdd));
end

local function RemoveAttackerTypeFromReport(typeToRemove)
	REPORT_ATTACKER_TYPES[typeToRemove] = nil;
	log_info(string.format('damage type %s removed from report', typeToRemove));
end

local function attackerIdIsPlayer(attackerId)
	if attackerId >= 0 and attackerId <= 3 then
		return true;
	else
		return false;
	end
end

local function attackerIdIsOtomo(attackerId)
	if attackerId >= FAKE_OTOMO_RANGE_START
	and attackerId <= FAKE_OTOMO_RANGE_START + 4
	then
		return true;
	else
		return false;
	end
end

local function getFakeAttackerIdForOtomoId(otomoId)
	return FAKE_OTOMO_RANGE_START + otomoId;
end

local function getOtomoIdFromFakeAttackerId(fakeAttackerId)
	return fakeAttackerId - FAKE_OTOMO_RANGE_START;
end

local function updatePlayerNames()
	-- get offline player name
	local myHunter = LOBBY_MANAGER:get_field("_myHunterInfo");
	if myHunter then
		PLAYER_NAMES[MY_PLAYER_ID + 1] = myHunter:get_field("_name");
	end

	-- get online player names
	local hunterInfo = LOBBY_MANAGER:get_field("_questHunterInfo");
	if hunterInfo then
		local hunterCount = hunterInfo:call("get_Count");
		if hunterCount then
			for i = 0, hunterCount-1 do
				local hunter = hunterInfo:call("get_Item", i);
				if hunter then
					local playerId = hunter:get_field("_memberIndex");
					local name = hunter:get_field("_name");

					if playerId and name then
						PLAYER_NAMES[playerId + 1] = name;
					end
				end
			end
		end
	end

	-- get offline otomo names
	local firstOtomo = OTOMO_MANAGER:call("getMasterOtomoInfo", 0);
	if firstOtomo then
		local name = firstOtomo:get_field("Name");
		--local level = firstOtomo:get_field("Level");
		OTOMO_NAMES[1] = name;
	end

	local secondOtomo = OTOMO_MANAGER:call("getMasterOtomoInfo", 1);
	if secondOtomo then
		local name = secondOtomo:get_field("Name");
		--local level = firstOtomo:get_field("Level");
		-- the secondary otomo is actually the fifth one!
		OTOMO_NAMES[5] = name;
	end

	-- get online otomo names
	local otomoInfo = LOBBY_MANAGER:get_field("_questOtomoInfo");
	if otomoInfo then
		local otomoCount = otomoInfo:call("get_Count");
		if otomoCount then
			for i=0, otomoCount-1 do
				local otomo = otomoInfo:call("get_Item", i);
				if otomo then
					local otomoId = i;
					local name = otomo:get_field("_Name");

					if otomoId and name then
						OTOMO_NAMES[otomoId + 1] = name;
					end
				end
			end
		end
	end
end

--#endregion Helper functions

--#region Sanity checking

if not SCENE_MANAGER then
	log_error('could not find scene manager');
	return;
end

if not SCENE_MANAGER_TYPE then
	log_error('could not find scene manager type');
	return;
end

if not SCENE_MANAGER_VIEW then
	log_error('could not find scene manager view');
	return;
end

if not SNOW_ENEMY_ENEMYCHARACTERBASE then
	log_error('could not find type snow.enemy.EnemyCharacterBase');
	return;
end

if not SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE then
	log_error('could not find method snow.enemy.EnemyCharacterBase::afterCalcDamage_DamageSide');
	return;
end

if not CFG['UPDATE_RATE'] or tonumber(CFG['UPDATE_RATE']) == nil then
	CFG['UPDATE_RATE'] = 0.5;
end
if CFG['UPDATE_RATE'] < 0.01 then
	CFG['UPDATE_RATE'] = 0.01;
end
if CFG['UPDATE_RATE'] > 3 then
	CFG['UPDATE_RATE'] = 3;
end

--#endregion

--#region Damage sources

-- damage counter
local function initializeDamageCounter()
	local c = {};
	c['physical']  = 0.0;
	c['elemental'] = 0.0;
	c['condition'] = 0.0;
	return c;
end

local function initializeDamageCounterWithDummyData()
	local c = initializeDamageCounter();
	c['physical']  = math.random(1,1000);
	c['elemental'] = math.random(1,600);
	c['condition'] = math.random(1,100);
	return c;
end

local function getTotalDamageForDamageCounter(c)
	return c.physical + c.elemental + c.condition;
end

local function mergeDamageCounters(a, b)
	if not a then a = initializeDamageCounter(); end
	if not b then b = initializeDamageCounter(); end
	local c = initializeDamageCounter();
	c.physical  = a.physical  + b.physical;
	c.elemental = a.elemental + b.elemental;
	c.condition = a.condition + b.condition;
	return c;
end

-- damage source
local function initializeDamageSource(attackerId)
	local s = {};
	s.id = attackerId;

	s.damageCounters = {};
	for _,type in pairs(ATTACKER_TYPES) do
		s.damageCounters[type] = initializeDamageCounter();
	end

	s.numHit = 0; -- how many hits
	s.maxHit = 0; -- biggest hit

	return s;
end

local function initializeDamageSourceWithDummyPlayerData(attackerId)
	local s = initializeDamageSource(attackerId);

	s.damageCounters['weapon'] = initializeDamageCounterWithDummyData();

	s.numHit = math.random(1,380);
	s.maxHit = math.random(1,1000);

	return s;
end

local function initializeDamageSourceWithDummyOtomoData(attackerId)
	local s = initializeDamageSource(attackerId);

	s.damageCounters['otomo'] = initializeDamageCounter();
	s.damageCounters['otomo'].physical = math.random(0,400);

	s.numHit = math.random(1,500);
	s.maxHit = math.random(1,100);

	return s;
end

local function initializeDamageSourceWithDummyMonsterData(attackerId)
	local s = initializeDamageSource(attackerId);

	s.damageCounters['monster'] = initializeDamageCounter();
	s.damageCounters['monster'].physical = math.random(0,150);

	s.numHit = math.random(1,10);
	s.maxHit = math.random(1,50);

	return s;
end

-- boss
local function initializeBossMonster(bossEnemy)
	local boss = {};

	boss.enemy = bossEnemy;

	boss.species = bossEnemy:call("get_EnemySpecies");
	boss.genus   = bossEnemy:call("get_BossEnemyGenus");

	-- get name
	local enemyType = bossEnemy:get_field("<EnemyType>k__BackingField");
	boss.name = MESSAGE_MANAGER:call("getEnemyNameMessage", enemyType);

	boss.damageSources = {};

	boss.hp = {};
	boss.hp.current = 0.0;
	boss.hp.max     = 0.0;
	boss.hp.missing = 0.0;
	boss.hp.percent = 0.0;

	-- store it in the table
	LARGE_MONSTERS[bossEnemy] = boss;

	-- all monsters are in the report by default
	AddMonsterToReport(bossEnemy, boss);

	log_info('initialized new ' .. boss.name);
end

local function initializeBossMonsterWithDummyData(bossKey, fakeName)
	local boss = {};

	boss.enemy = bossKey;

	boss.genus = 999;
	boss.species = 0;

	boss.name = fakeName;

	local s = {};
	-- players
	s[0] = initializeDamageSourceWithDummyPlayerData(0);
	s[1] = initializeDamageSourceWithDummyPlayerData(1);
	s[2] = initializeDamageSourceWithDummyPlayerData(2);
	s[3] = initializeDamageSourceWithDummyPlayerData(3);

	-- otomo
	local dummyId = getFakeAttackerIdForOtomoId(0);
	s[dummyId] = initializeDamageSourceWithDummyOtomoData(dummyId);
	dummyId = getFakeAttackerIdForOtomoId(1);
	s[dummyId] = initializeDamageSourceWithDummyOtomoData(dummyId);
	dummyId = getFakeAttackerIdForOtomoId(2);
	s[dummyId] = initializeDamageSourceWithDummyOtomoData(dummyId);
	dummyId = getFakeAttackerIdForOtomoId(3);
	s[dummyId] = initializeDamageSourceWithDummyOtomoData(dummyId);

	-- monster
	s[1001] = initializeDamageSourceWithDummyMonsterData(1001);

	boss.damageSources = s;

	TEST_MONSTERS[bossKey] = boss;
	AddMonsterToReport(bossKey, boss);
end

local function initializeTestData()
	TEST_MONSTERS = {};
	REPORT_MONSTERS = {};

	initializeBossMonsterWithDummyData(111, 'Rathian');
	initializeBossMonsterWithDummyData(222, 'Tigrex');
	initializeBossMonsterWithDummyData(333, 'Qurupeco');
end

local function isInTestMode()
	return (TEST_MONSTERS ~= nil);
end

local function clearTestData()
	TEST_MONSTERS = nil;
	REPORT_MONSTERS = {};
	for enemy, boss in pairs(LARGE_MONSTERS) do
		AddMonsterToReport(enemy, boss);
	end
	log_info('cleared test data');
end

--#endregion

--#region Reports

local function initializeReport()
	local report = {};

	report.items = {};

	report.topDamage = 0.0;
	report.totalDamage = 0.0;

	return report;
end

local function getReportItem(report, id)
	for _,item in ipairs(report.items) do
		if item.id == id then
			return item;
		end
	end
	return nil;
end

local function initializeReportItem(id)
	if not id then
		log_error('initializing report item with no id');
	end

	local item = {};

	item.id = id;
	item.playerNumber = nil;
	item.otomoNumber = nil;
	item.name = nil;

	-- initialize player number and name if we can
	if item.id >= 0 and item.id <= 3 then
		item.playerNumber = item.id + 1;
		item.name = PLAYER_NAMES[item.playerNumber];
	elseif attackerIdIsOtomo(item.id) then
		item.otomoNumber = getOtomoIdFromFakeAttackerId(item.id) + 1;
		item.name = OTOMO_NAMES[item.otomoNumber];
	end

	item.counters = {};

	item.total = 0.0;

	item.totalPhysical = 0.0;
	item.totalElemental = 0.0;
	item.totalCondition = 0.0;
	item.totalOtomo = 0.0;

	item.percentOfTotal = 0.0;
	item.percentOfBest = 0.0;

	item.numHit = 0;
	item.maxHit = 0;

	return item;
end

-- saves the total into the item itself
local function calculateTotalsForReportItem(item)
	-- initialize totals to zero
	item.total = 0.0;
	item.totalPhysical = 0.0;
	item.totalElemental = 0.0;
	item.totalCondition = 0.0;
	item.totalOtomo = 0.0;

	-- get totals from counters
	for type,counter in pairs(item.counters) do
		if REPORT_ATTACKER_TYPES[type] then
			if type == 'otomo' then
				local counterTotal = getTotalDamageForDamageCounter(counter);

				-- sum together otomo's different types of damage and store it as its own type of damage instead
				item.totalOtomo = item.totalOtomo + counterTotal;

				item.total = item.total + counterTotal;
			else
				item.totalPhysical  = item.totalPhysical  + counter.physical;
				item.totalElemental = item.totalElemental + counter.elemental;
				item.totalCondition = item.totalCondition + counter.condition;

				item.total = item.total + getTotalDamageForDamageCounter(counter);
			end
		end
	end
end

local function mergeReportItemCounters(a, b)
	local counters = {};
	for _,type in pairs(ATTACKER_TYPES) do
		counters[type] = mergeDamageCounters(a[type], b[type]);
	end
	return counters;
end

local function mergeDamageSourceIntoReportItem(item, source)
	-- don't allow merging source and item with different IDs
	if item.id ~= source.id then
		-- make an exception for otomo and player to account for the trick we pulled in mergeDamageSourcesIntoReport()
		if not attackerIdIsOtomo(source.id) then
			log_error('tried to merge a damage source into a report item with a different id');
			return;
		end
	end

	item.counters = mergeReportItemCounters(item.counters, source.damageCounters);

	item.numHit = item.numHit + source.numHit;
	item.maxHit = math.max(item.maxHit, source.maxHit);
end

local function sortReportItems_DESC(a, b)
	return a.total > b.total;
end

local function sortReportItems_ASC(a, b)
	return a.total < b.total;
end

local function sortReportItems_Player(a, b)
	return a.id < b.id;
end

-- main function responsible for loading a boss into a report
local function mergeDamageSourcesIntoReport(report, damageSources)
	local totalDamage = 0.0;
	local bestDamage = 0.0;

	-- merge damage sources
	for _,source in pairs(damageSources) do
		local effSourceId = source.id;

		-- merge otomo with master
		if CFG['OTOMO_DMG_IS_PLAYER_DMG'] and attackerIdIsOtomo(effSourceId) then
			local otomoId = getOtomoIdFromFakeAttackerId(effSourceId);

			-- handle primary otomo
			if otomoId >= 0 and otomoId <= 3 then
				-- pretend this damage source belongs to this player
				effSourceId = otomoId;
			end
			-- handle secondary otomo
			if otomoId == 4 then
				-- pretend to be player 1
				effSourceId = 0;
			end
		end

		-- if we aren't excluding this type of source
		if attackerIdIsPlayer(effSourceId)
		or (attackerIdIsOtomo(effSourceId) and REPORT_OTOMO)
		or (not attackerIdIsOtomo(effSourceId) and REPORT_OTHER)
		then
			-- get report item, creating it if necessary
			local item = getReportItem(report, effSourceId);
			if not item then
				item = initializeReportItem(effSourceId);
				table.insert(report.items, item);
			end

			mergeDamageSourceIntoReportItem(item, source);
		end
	end

	-- now loop all report items and calculate totals
	for _,item in ipairs(report.items) do
		-- calculate the item's own total damage
		calculateTotalsForReportItem(item)

		-- remember which combatant has the most damage
		if item.total > bestDamage then
			bestDamage = item.total;
		end;

		-- accumulate total overall damage
		totalDamage = totalDamage + item.total;
	end

	report.totalDamage = totalDamage;
	report.topDamage = bestDamage;

	-- loop again to calculate percents using the totals we got before
	for _,item in ipairs(report.items) do
		if report.totalDamage ~= 0 then
			item.percentOfTotal = tonumber(string.format("%.3f", item.total / report.totalDamage));
		end
		if report.topDamage ~= 0 then
			item.percentOfBest  = tonumber(string.format("%.3f", item.total / report.topDamage));
		end
	end

	-- sort report items
	if CFG['TABLE_SORT_IN_ORDER'] then
		table.sort(report.items, sortReportItems_Player);
	elseif CFG['TABLE_SORT_ASC'] then
		table.sort(report.items, sortReportItems_ASC);
	else
		table.sort(report.items, sortReportItems_DESC);
	end
end

local function generateReport(filterBosses)
	DAMAGE_REPORTS = {};

	local report = initializeReport();

	for _,boss in pairs(filterBosses) do
		mergeDamageSourcesIntoReport(report, boss.damageSources);
	end

	table.insert(DAMAGE_REPORTS, report);
end

--#endregion

--#region Drawing

local function drawRichDamageBar(item, x, y, maxWidth, h, colorPhysical, colorElemental)
	local w;
	local colorAilment = CFG['COLOR_BAR_DMG_AILMENT'];
	local colorOtomo = CFG['COLOR_BAR_DMG_OTOMO'];
	local colorOther = CFG['COLOR_BAR_DMG_OTHER'];

	if not CFG['DRAW_BAR_USE_UNIQUE_COLORS'] then
		colorElemental = colorPhysical;
		colorAilment = colorPhysical;
		colorOtomo = colorPhysical;
		colorOther = colorPhysical;
	end

	-- draw physical damage
	--debug_line(string.format('damagePhysical: %d', source.damagePhysical));
	w = (item.totalPhysical / item.total) * maxWidth;
	draw.filled_rect(x, y, w, h, colorPhysical);
	x = x + w;
	-- draw elemental damage
	--debug_line(string.format('damageElemental: %d', source.damageElemental));
	w = (item.totalElemental / item.total) * maxWidth;
	draw.filled_rect(x, y, w, h, colorElemental);
	x = x + w;
	-- draw ailment damage
	--debug_line(string.format('damageAilment: %f', source.damageAilment));
	w = (item.totalCondition / item.total) * maxWidth;
	draw.filled_rect(x, y, w, h, colorAilment);
	x = x + w;
	-- draw otomo damage
	--debug_line(string.format('damageOtomo: %d', source.damageOtomo));
	w = (item.totalOtomo / item.total) * maxWidth;
	draw.filled_rect(x, y, w, h, colorOtomo);
	x = x + w;
	-- draw whatever's left, just in case
	local remainder = item.total - item.totalPhysical - item.totalElemental - item.totalCondition - item.totalOtomo;
	--debug_line(string.format('remainder: %d', remainder));
	w = (remainder / item.total) * maxWidth;
	draw.filled_rect(x, y, w, h, colorOther);
	--debug_line(string.format('total: %d', source.damageTotal));
end

local function drawReport(index)
	local report = DAMAGE_REPORTS[index];
	if not report then
		return;
	end

	local origin_x = getScreenXFromX(CFG['TABLE_X']);
	local origin_y = getScreenYFromY(CFG['TABLE_Y']);
	local tableWidth = CFG['TABLE_WIDTH'] * CFG['TABLE_SCALE'];
	local rowHeight = CFG['TABLE_ROWH'] * CFG['TABLE_SCALE'];
	local colorBlockWidth = 20;
	local text_offset_x = CFG['TABLE_ROW_TEXT_OFFSET_X'];
	local text_offset_y = CFG['TABLE_ROW_TEXT_OFFSET_Y'];

	if not CFG['DRAW_BAR_COLORBLOCK'] then
		colorBlockWidth = 0;
	end

	if CFG['TABLE_GROWS_UPWARD'] then
		origin_y = origin_y - rowHeight;
	end

	-- title bar
	if CFG['DRAW_TITLE_BACKGROUND'] then
		-- title background
		draw.filled_rect(origin_x, origin_y, tableWidth, rowHeight, CFG['COLOR_TITLE_BG'])
	end

	if CFG['DRAW_TITLE_TEXT'] then
		-- generate the title text

		-- get quest duration
		local timeMinutes = QUEST_MANAGER:call("getQuestElapsedTimeMin");
		local timeSeconds = QUEST_MANAGER:call("getQuestElapsedTimeSec");
		timeSeconds = timeSeconds - (timeMinutes * 60);

		-- use a fake duration in test mode
		if isInTestMode() then
			timeMinutes = 5;
			timeSeconds = 37;
		end

		local timeText = string.format("%d:%02.0f", timeMinutes, timeSeconds);
		local monsterText = '';

		if CFG['DRAW_TITLE_MONSTERS'] then
			monsterText = ' - '
			-- add monster names
			local monsterCount = 0;
			for _,boss in pairs(REPORT_MONSTERS) do
				if monsterCount < 3 then
					if monsterCount > 0 then monsterText = monsterText .. ', '; end
					monsterText = monsterText .. string.format('%s', boss.name);
				end
				monsterCount = monsterCount + 1;
			end

			if monsterCount > 3 then
				monsterText = monsterText .. ', etc...';
			elseif monsterCount == 0 then
				monsterText = monsterText .. 'No monsters selected';
			end
		end

		local titleText = timeText .. monsterText;
		local offsetX = CFG['TABLE_HEADER_TEXT_OFFSET_X'];
		draw.text(titleText, origin_x + offsetX, origin_y, CFG['COLOR_TITLE_FG']);
	end

	if CFG['TABLE_GROWS_UPWARD'] then
		-- adjust starting position for drawing report items
		origin_y = origin_y - rowHeight * (#report.items + 1);
	end

	-- draw report items
	if #report.items == 0 then
		local x = origin_x + colorBlockWidth + 2 + text_offset_x;
		local y = origin_y + rowHeight + CFG['TABLE_ROW_PADDING'] + text_offset_y;
		draw.text('No data', x, y, CFG['COLOR_GRAY']);
	end

	for i,item in ipairs(report.items) do
		if item.total == 0 then
			goto skip_report_item
		end

		local y = origin_y + (rowHeight + CFG['TABLE_ROW_PADDING']) * i;

		local combatantColor = CFG['COLOR_GRAY'];
		if item.playerNumber then
			combatantColor = CFG['COLOR_PLAYER'][item.id];
		elseif item.otomoNumber then
			combatantColor = CFG['COLOR_OTOMO'];
		end

		local physicalColor = CFG['COLOR_BAR_DMG_PHYSICAL_UNIQUE'][item.id];
		if not physicalColor or not CFG['DRAW_BAR_USE_PLAYER_COLORS'] then
			physicalColor = CFG['COLOR_BAR_DMG_PHYSICAL'];
		end

		local elementalColor = CFG['COLOR_BAR_DMG_ELEMENT_UNIQUE'][item.id];
		if not elementalColor then
			elementalColor = CFG['COLOR_BAR_DMG_ELEMENT'];
		end

		local damageBarWidthMultiplier = item.percentOfBest;
		if CFG['DRAW_BAR_RELATIVE_TO_PARTY'] then
			damageBarWidthMultiplier = item.percentOfTotal;
		end

		if CFG['USE_MINIMAL_BARS'] then
			-- color block
			draw.filled_rect(origin_x, y, colorBlockWidth, rowHeight, elementalColor);

			-- damage bar
			local damageBarWidth = colorBlockWidth * damageBarWidthMultiplier;
			draw.filled_rect(origin_x, y, damageBarWidth, rowHeight, combatantColor);
		else
			if CFG['DRAW_BAR_BACKGROUNDS'] then
				-- draw background
				draw.filled_rect(origin_x, y, tableWidth, rowHeight, CFG['COLOR_BAR_BG']);
			end

			if CFG['DRAW_BAR_COLORBLOCK'] then
				-- color block
				draw.filled_rect(origin_x, y, colorBlockWidth, rowHeight, combatantColor);
			end

			-- damage bar
			local damageBarWidth = (tableWidth - colorBlockWidth) * damageBarWidthMultiplier;
			--draw.filled_rect(origin_x + colorBlockWidth, y, damageBarWidth, rowHeight, physicalColor);
			drawRichDamageBar(item, origin_x + colorBlockWidth, y, damageBarWidth, rowHeight, physicalColor, elementalColor);
		end

		-- draw text (TODO: REFACTOR THIS MESS)
		local text_x = origin_x + colorBlockWidth + 2 + text_offset_x;
		local text_y = y + text_offset_y;
		local barText = '';
		local paddingCount = CFG['DRAW_BAR_TEXT_PADDING'];
		local spacer = string.rep(' ', paddingCount);
		local fixedSpacing = CFG['DRAW_BAR_TEXT_PADDING_FIXED'];

		if CFG['DRAW_BAR_TEXT_NAME'] then
			-- player names
			if item.playerNumber then
				if CFG['DRAW_BAR_TEXT_YOU'] and item.id == MY_PLAYER_ID then
					barText = barText .. 'YOU' .. spacer;
				elseif CFG['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] and item.name then
					barText = barText .. string.format('%s', item.name)  .. spacer;
				else
					barText = barText .. string.format('Player %.0f', item.id + 1) .. spacer;
				end
			elseif item.otomoNumber then
				if CFG['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] and item.name then
					if IS_ONLINE then
						barText = barText .. string.format('%s (%.0f)', item.name, item.otomoNumber) .. spacer;
					else
						barText = barText .. string.format('%s', item.name) .. spacer;
					end
				else
					barText = barText .. string.format('Buddy %.0f', item.otomoNumber) .. spacer;
				end
			else
				-- just draw the name
				barText = barText .. string.format('%s', item.name or '') .. spacer;
			end
		elseif CFG['DRAW_BAR_TEXT_YOU'] then
			if item.id == MY_PLAYER_ID then
				barText = barText .. 'YOU' .. spacer;
			end
		end

		if fixedSpacing and barText ~= '' then
			draw.text(barText, text_x, text_y, CFG['COLOR_WHITE']);
			text_x = text_x + (5 * paddingCount);
			barText = '';
		end

		if CFG['DRAW_BAR_TEXT_TOTAL_DAMAGE'] then
			barText = barText .. string.format('%.0f', item.total)  .. spacer;
		end

		if fixedSpacing and barText ~= '' then
			draw.text(barText, text_x, text_y, CFG['COLOR_WHITE']);
			text_x = text_x + (5 * paddingCount);
			barText = '';
		end

		if CFG['DRAW_BAR_TEXT_PERCENT_OF_PARTY'] then
			barText = barText .. string.format('%.1f%%', item.percentOfTotal * 100.0)  .. spacer;
		end

		if fixedSpacing and barText ~= '' then
			draw.text(barText, text_x, text_y, CFG['COLOR_WHITE']);
			text_x = text_x + (5 * paddingCount);
			barText = '';
		end

		if CFG['DRAW_BAR_TEXT_PERCENT_OF_BEST'] then
			barText = barText .. string.format('(%.1f%%)', item.percentOfBest * 100.0)  .. spacer;
		end

		if fixedSpacing and barText ~= '' then
			draw.text(barText, text_x, text_y, CFG['COLOR_WHITE']);
			text_x = text_x + (5 * paddingCount);
			barText = '';
		end

		if CFG['DRAW_BAR_TEXT_HIT_COUNT'] then
			barText = barText .. string.format('%d', item.numHit)  .. spacer;
		end

		if fixedSpacing and barText ~= '' then
			draw.text(barText, text_x, text_y, CFG['COLOR_WHITE']);
			text_x = text_x + (5 * paddingCount);
			barText = '';
		end

		if CFG['DRAW_BAR_TEXT_BIGGEST_HIT'] then
			barText = barText .. string.format('[%d]', item.maxHit)  .. spacer;
		end

		if fixedSpacing and barText ~= '' then
			draw.text(barText, text_x, text_y, CFG['COLOR_WHITE']);
			text_x = text_x + (5 * paddingCount);
			barText = '';
		end

		if not fixedSpacing then
			draw.text(barText, text_x, text_y, CFG['COLOR_WHITE']);
		end

		if CFG['DRAW_BAR_OUTLINES'] then
			-- draw outline
			draw.outline_rect(origin_x, y, tableWidth, rowHeight, CFG['COLOR_BAR_OUTLINE']);
		end

		::skip_report_item::
	end
end

-- debug info stuff
local function drawDebugStats()
	--local kpiData         = QUEST_MANAGER:call("get_KpiData");
	--local playerPhysical  = kpiData:call("get_PlayerTotalAttackDamage");
	--local playerElemental = kpiData:call("get_PlayerTotalElementalAttackDamage");
	--local playerAilment   = kpiData:call("get_PlayerTotalStatusAilmentsDamage");
	--local playerDamage    = playerPhysical + playerElemental + playerAilment;

	-- get player
	--local myPlayerId = PLAYER_MANAGER:call("getMasterPlayerID");
	--local myPlayer = PLAYER_MANAGER:call("getPlayer", myPlayerId);

	-- get enemy
	local bossCount = ENEMY_MANAGER:call("getBossEnemyCount");

	for i = 0, bossCount-1 do
		local bossEnemy = ENEMY_MANAGER:call("getBossEnemy", i);

		-- get this boss from the table
		local boss = LARGE_MONSTERS[bossEnemy];
		if not boss then
			return;
		end

		local is_combat_str;
		if boss.isInCombat then is_combat_str = " (In Combat)";
		                   else is_combat_str = "";
		end

		local hpStr = string.format('%.0f / %.0f (%.1f%%) -%.0f'
			, boss.hp.current
			, boss.hp.max
			, boss.hp.percent * 100
			, boss.hp.missing);

		debug_line(string.format("%s %s %s", boss.name, hpStr, is_combat_str));

	end

	--debug_line('');
	--debug_line(string.format('Total damage (KPI): %d', playerDamage));

	debug_line('');
	local report = DAMAGE_REPORTS[1];
	if report then
		for _,item in ipairs(report.items) do
			debug_line(item.name or 'no name');
			for type,counter in pairs(item.counters) do
				if counter.total > 0 then
					debug_line(string.format('%s\t\t%f',type, counter.total));
				end
			end
		end
	end

	-- monster state
	-- isEnableFastTravelCondition

	--[[
		snow.enemy.EnemyCombatSystemData
		snow.enemy.EnemyCombatSystemData.CombatTimeInfo

		EnemyManager.get_CombatMonsterSystem()
			returns:
		snow.enemy.EnemyCombatMonsterManager
			getGroupInfo(EnemyCharacterBase)
			returns:
		snow.enemy.EnemyCombatMonsterManager.GroupInfo
			get_CombatTime()
			getSelfCombatMonsterResult(EnemyCharacterBase)
	]]
end

-- main draw function
local function dpsDraw()
	DEBUG_Y = 0;

	-- draw the first report
	drawReport(1);

	if DPS_DEBUG then
		drawDebugStats();
	end
end

--#endregion

--#region Updating

-- main update function
local function dpsUpdate()
	-- update screen dimensions
	readScreenDimensions();

	-- get player id
	MY_PLAYER_ID = PLAYER_MANAGER:call("getMasterPlayerID");

	if CFG['DRAW_BAR_TEXT_NAME_USE_REAL_NAMES'] then
		-- get player names
		updatePlayerNames();
	end

	-- ensure bosses are initialized
	local bossCount = ENEMY_MANAGER:call("getBossEnemyCount");
	for i = 0, bossCount-1 do
		local bossEnemy = ENEMY_MANAGER:call("getBossEnemy", i);

		if not LARGE_MONSTERS[bossEnemy] then
			-- initialize data for this boss
			initializeBossMonster(bossEnemy);
		end
	end

	-- generate report for selected bosses
	generateReport(REPORT_MONSTERS);
end

-- update based on wall clock
local function dpsUpdateOccasionally(realSeconds)
	if realSeconds > LAST_UPDATE_TIME + CFG['UPDATE_RATE'] then
		dpsUpdate();
		LAST_UPDATE_TIME = realSeconds;
	end
end

-- runs every frame
local function dpsFrame()
	-- make sure managed resources are initialized
	if not hasManagedResources() then
		return;
	end

	local questStatus = QUEST_MANAGER:get_field("_QuestStatus");

	local villageArea = 0;
	if AREA_MANAGER then
		villageArea = AREA_MANAGER:get_field("<_CurrentAreaNo>k__BackingField");
	end

	local isInQuest = (questStatus >= 2);
	local isInTrainingHall = (villageArea == 5);

	IS_ONLINE = (LOBBY_MANAGER and LOBBY_MANAGER:call("IsQuestOnline")) or false;

	if not ASSIGNED_HOTKEY_THIS_FRAME and KEYBOARD_MANAGER:call("getTrg", HOTKEY_TOGGLE_OVERLAY) then
		DRAW_OVERLAY = not DRAW_OVERLAY;
	end

	-- if the window is open
	if DRAW_WINDOW_SETTINGS then
		-- update every frame
		dpsUpdate();
	-- when a quest is active
	elseif isInQuest then
		local totalSeconds = QUEST_MANAGER:call("getQuestElapsedTimeSec");
		dpsUpdateOccasionally(totalSeconds);
	-- when you are in the training area
	elseif isInTrainingHall then
		local totalSeconds = AREA_MANAGER:call("get_TrainingHallStayTime");
		dpsUpdateOccasionally(totalSeconds);
	else
		-- clean up some things in between quests
		if LAST_UPDATE_TIME ~= 0 then
			cleanUpData();
		end
	end

	if DRAW_WINDOW_SETTINGS -- always draw overlay if settings window is open
	or (DRAW_OVERLAY and -- draw in one of the following circumstances if overlay is enabled
	   (isInTestMode() or isInQuest or isInTrainingHall)) then
		-- draw on every frame
		dpsDraw();
	end
end

--#endregion

--#region imgui interface

local function showCheckboxForSetting(setting)
	local changed, value = imgui.checkbox(TXT[setting], CFG[setting]);
	if changed then
		CFG[setting] = value;
	end
end

local function showSliderForFloatSetting(setting)
	local changed, value = imgui.slider_float(TXT[setting], CFG[setting], MIN[setting], MAX[setting], '%.2f');
	if changed then
		CFG[setting] = value;
	end
end

local function showSliderForIntSetting(setting)
	local changed, value = imgui.slider_int(TXT[setting], CFG[setting], MIN[setting], MAX[setting], '%d');
	if changed then
		CFG[setting] = value;
	end
end

local function DrawWindowSettings()
	local changed, wantsIt, value;

	wantsIt = imgui.begin_window('coavins dps meter - settings', DRAW_WINDOW_SETTINGS, WINDOW_FLAGS);
	if DRAW_WINDOW_SETTINGS and not wantsIt then
		DRAW_WINDOW_SETTINGS = false;

		if isInTestMode() then
			clearTestData();
		end
	end

	-- Enabled
	changed, wantsIt = imgui.checkbox('Enabled', DPS_ENABLED);
	if changed then
		DPS_ENABLED = wantsIt;
	end
	--[[
	imgui.same_line();
	if imgui.button('Save settings') then

	end
	imgui.same_line();
	if imgui.button('Load settings') then
	end;
	]]

	-- Show test data
	changed, wantsIt = imgui.checkbox('Show test data while menu is open', CFG['SHOW_TEST_DATA_WHILE_MENU_IS_OPEN']);
	if changed then
		CFG['SHOW_TEST_DATA_WHILE_MENU_IS_OPEN'] = wantsIt;
		if wantsIt then
			initializeTestData();
		else
			clearTestData();
		end
	end

	-- Presets
	imgui.new_line();
	imgui.text('Presets');

	changed, value = imgui.combo('', PRESET_OPTIONS_SELECTED, PRESET_OPTIONS);
	if changed then
		PRESET_OPTIONS_SELECTED = value;
	end
	imgui.same_line();
	if imgui.button('Apply') then
		applySelectedPreset();
	end

	-- Settings
	imgui.new_line();
	imgui.text('Settings');

	imgui.same_line();
	if imgui.button('Refresh') then
		if isInTestMode() then
			-- reinitialize test data
			initializeTestData();
		end

		dpsUpdate();
	end

	--showSliderForFloatSetting('UPDATE_RATE');
	showCheckboxForSetting('OTOMO_DMG_IS_PLAYER_DMG');
	showCheckboxForSetting('DRAW_BAR_RELATIVE_TO_PARTY');

	imgui.new_line();

	showCheckboxForSetting('DRAW_TITLE_TEXT');
	showCheckboxForSetting('DRAW_TITLE_MONSTERS');
	showCheckboxForSetting('DRAW_TITLE_BACKGROUND');
	showCheckboxForSetting('DRAW_BAR_BACKGROUNDS');
	showCheckboxForSetting('DRAW_BAR_OUTLINES');
	showCheckboxForSetting('DRAW_BAR_COLORBLOCK');
	showSliderForIntSetting('DRAW_BAR_TEXT_PADDING');
	showCheckboxForSetting('DRAW_BAR_TEXT_PADDING_FIXED');
	showCheckboxForSetting('DRAW_BAR_USE_PLAYER_COLORS');
	showCheckboxForSetting('DRAW_BAR_USE_UNIQUE_COLORS');

	imgui.new_line();

	showCheckboxForSetting('DRAW_BAR_TEXT_NAME');
	showCheckboxForSetting('DRAW_BAR_TEXT_YOU');
	showCheckboxForSetting('DRAW_BAR_TEXT_NAME_USE_REAL_NAMES');
	showCheckboxForSetting('DRAW_BAR_TEXT_TOTAL_DAMAGE');
	showCheckboxForSetting('DRAW_BAR_TEXT_PERCENT_OF_PARTY');
	showCheckboxForSetting('DRAW_BAR_TEXT_PERCENT_OF_BEST');
	showCheckboxForSetting('DRAW_BAR_TEXT_HIT_COUNT');
	showCheckboxForSetting('DRAW_BAR_TEXT_BIGGEST_HIT');

	imgui.new_line();

	showCheckboxForSetting('USE_MINIMAL_BARS');
	showCheckboxForSetting('TABLE_GROWS_UPWARD');
	showCheckboxForSetting('TABLE_SORT_ASC');
	showCheckboxForSetting('TABLE_SORT_IN_ORDER');

	imgui.new_line();

	showSliderForFloatSetting('TABLE_X');
	showSliderForFloatSetting('TABLE_Y');
	showSliderForFloatSetting('TABLE_SCALE');
	showSliderForIntSetting('TABLE_HEADER_TEXT_OFFSET_X');
	showSliderForIntSetting('TABLE_WIDTH');

	imgui.new_line();

	showSliderForIntSetting('TABLE_ROWH');
	showSliderForIntSetting('TABLE_ROW_PADDING');
	showSliderForIntSetting('TABLE_ROW_TEXT_OFFSET_X');
	showSliderForIntSetting('TABLE_ROW_TEXT_OFFSET_Y');

	imgui.new_line();

	imgui.end_window();
end

local function showCheckboxForAttackerType(type)
	local typeIsInReport = REPORT_ATTACKER_TYPES[type];
	local changed, wantsIt = imgui.checkbox(ATTACKER_TYPE_TEXT[type], typeIsInReport);
	if changed then
		if wantsIt then
			AddAttackerTypeToReport(type);
		else
			RemoveAttackerTypeFromReport(type);
		end
		generateReport(REPORT_MONSTERS);
	end
end

local function DrawWindowReport()
	local changed, wantsIt;

	wantsIt = imgui.begin_window('coavins dps meter - filters', DRAW_WINDOW_REPORT, WINDOW_FLAGS);
	if DRAW_WINDOW_REPORT and not wantsIt then
		DRAW_WINDOW_REPORT = false;
	end

	changed, wantsIt = imgui.checkbox('Include buddies', REPORT_OTOMO);
	if changed then
		REPORT_OTOMO = wantsIt;
		generateReport(REPORT_MONSTERS);
	end

	changed, wantsIt = imgui.checkbox('Include monsters, etc', REPORT_OTHER);
	if changed then
		REPORT_OTHER = wantsIt;
		generateReport(REPORT_MONSTERS);
	end

	imgui.new_line();

	-- draw buttons for each boss monster in the cache
	imgui.text('Monsters');

	local monsterCollection = TEST_MONSTERS or LARGE_MONSTERS;
	local foundMonster = false;
	for enemy,boss in pairs(monsterCollection) do
		foundMonster = true;
		local monsterIsInReport = REPORT_MONSTERS[enemy];
		changed, wantsIt = imgui.checkbox(boss.name, monsterIsInReport);
		if changed then
			if wantsIt then
				AddMonsterToReport(enemy, boss);
			else
				RemoveMonsterFromReport(enemy);
			end
			generateReport(REPORT_MONSTERS);
		end
	end
	if not foundMonster then
		imgui.text('(n/a)');
	end

	imgui.new_line();

	-- draw buttons for attacker types
	imgui.text('Attack type');

	showCheckboxForAttackerType('weapon');
	showCheckboxForAttackerType('otomo');
	showCheckboxForAttackerType('monster');

	imgui.new_line();

	showCheckboxForAttackerType('barrelbombs');
	showCheckboxForAttackerType('barrelbombl');
	showCheckboxForAttackerType('nitro');
	showCheckboxForAttackerType('capturesmokebomb');
	showCheckboxForAttackerType('capturebullet');
	showCheckboxForAttackerType('kunai');

	imgui.new_line();

	showCheckboxForAttackerType('hmballista');
	showCheckboxForAttackerType('hmcannon');
	showCheckboxForAttackerType('hmgatling');
	showCheckboxForAttackerType('hmtrap');
	showCheckboxForAttackerType('hmnpc');
	showCheckboxForAttackerType('hmflamethrower');
	showCheckboxForAttackerType('hmdragonator');

	imgui.new_line();

	showCheckboxForAttackerType('makimushi');
	showCheckboxForAttackerType('onibimine');
	showCheckboxForAttackerType('ballistahate');
	showCheckboxForAttackerType('waterbeetle');
	showCheckboxForAttackerType('detonationgrenade');
	showCheckboxForAttackerType('fg005');
	showCheckboxForAttackerType('ecbatexplode');

	imgui.end_window();
end

local function DrawWindowHotkeys()
	local wantsIt;

	wantsIt = imgui.begin_window('coavins dps meter - hotkeys', DRAW_WINDOW_HOTKEYS, WINDOW_FLAGS);
	if DRAW_WINDOW_HOTKEYS and not wantsIt then
		DRAW_WINDOW_HOTKEYS = false;
		HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false;
	end

	imgui.text('Toggle overlay:');
	imgui.same_line();
	local text = 'Set key';
	if HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER then
		text = 'Press key...';
	end
	if imgui.button(text) then
		HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = not HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER;
	end
	imgui.same_line();
	text = string.format('%s (%d)', ENUM_KEYBOARD_KEY[HOTKEY_TOGGLE_OVERLAY], HOTKEY_TOGGLE_OVERLAY);
	imgui.text(text);

	imgui.end_window();
end

--#endregion

--#region sdk hooks

-- know when we return from a quest
local function read_onChangedGameStatus(args)
	local status = sdk.to_int64(args[3]);
	if status == 1 then
		-- entered the village
		cleanUpData();
	end
end

-- register function hook
sdk.hook(QUEST_MANAGER_METHOD_ONCHANGEDGAMESTATUS,
function(args)
	read_onChangedGameStatus(args);
end, function(retval) return retval end);

-- keep track of some things on monsters
local function updateBossEnemy(args)
	local enemy = sdk.to_managed_object(args[2]);

	-- get this boss from the table
	local boss = LARGE_MONSTERS[enemy];
	if not boss then
		return;
	end

	-- get is in combat
	boss.isInCombat = enemy:call("get_IsCombatMode");

	-- get health
	local physicalParam = enemy:get_field("<PhysicalParam>k__BackingField");
	if physicalParam then
		local vitalParam = physicalParam:call("getVital", 0, 0);
		if vitalParam then
			boss.hp.current = vitalParam:call("get_Current");
			boss.hp.max = vitalParam:call("get_Max");
			boss.hp.missing = boss.hp.max - boss.hp.current;
			if boss.hp.max ~= 0 then
				boss.hp.percent = boss.hp.current / boss.hp.max;
			else
				boss.hp.percent = 0;
			end
		end
	end
end

-- register function hook
sdk.hook(SNOW_ENEMY_ENEMYCHARACTERBASE_UPDATE,
function(args)
	updateBossEnemy(args);
end,
function(retval)
return retval
end);

-- track damage taken by monsters
local function read_AfterCalcInfo_DamageSide(args)
	local enemy = sdk.to_managed_object(args[2]);
	if not enemy then
		return;
	end

	local boss = LARGE_MONSTERS[enemy];
	if not boss then
		return;
	end

	if enemy:call('getHpVital') == 0 then
		return;
	end

	local sources = boss.damageSources;

	local info = sdk.to_managed_object(args[3]); -- snow.hit.EnemyCalcDamageInfo.AfterCalcInfo_DamageSide
	local attackerId     = info:call("get_AttackerID");
	local attackerTypeId = info:call("get_DamageAttackerType");
	local attackerType   = ATTACKER_TYPES[attackerTypeId];

	local isOtomo   = (attackerTypeId == 19);

	--log_info(string.format('damage instance from attacker %d of type %s', attackerId, attackerType));
	if isOtomo then
		-- separate otomo from their master
		attackerId = getFakeAttackerIdForOtomoId(attackerId);
	end

	-- get the damage source for this attacker
	if not sources[attackerId] then
		sources[attackerId] = initializeDamageSource(attackerId);
	end
	local s = sources[attackerId];

	-- get the damage counter for this type
	if not s.damageCounters[attackerType] then
		s.damageCounters[attackerType] = initializeDamageCounter();
	end
	local c = s.damageCounters[attackerType];

	local totalDamage     = tonumber(info:call("get_TotalDamage"));
	local physicalDamage  = tonumber(info:call("get_PhysicalDamage"));
	local elementDamage   = tonumber(info:call("get_ElementDamage"));
	local conditionDamage = tonumber(info:call("get_ConditionDamage"));

	-- add damage facts to counter
	c.physical  = c.physical  + physicalDamage;
	c.elemental = c.elemental + elementDamage;
	c.condition = c.condition + conditionDamage;

	-- hit count
	s.numHit = s.numHit + 1;

	-- biggest hit
	if totalDamage > s.maxHit then
		s.maxHit = totalDamage;
	end
end

-- register function hook
sdk.hook(SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE,
function(args)
	read_AfterCalcInfo_DamageSide(args);
end,
function(retval)
	return retval
end);

--#endregion

--#region REFramework

local function registerWaitingHotkeys()
	if HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER then
		for key,_ in pairs(ENUM_KEYBOARD_KEY) do
			if KEYBOARD_MANAGER:call("getDown", key) then
				HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false;
				HOTKEY_TOGGLE_OVERLAY = key;
				ASSIGNED_HOTKEY_THIS_FRAME = true;
			end
		end
	end
end

re.on_frame(function()
	if DRAW_WINDOW_SETTINGS then
		DrawWindowSettings();
	end

	if DRAW_WINDOW_REPORT then
		DrawWindowReport();
	end

	if DRAW_WINDOW_HOTKEYS then
		DrawWindowHotkeys();
	else
		HOTKEY_TOGGLE_OVERLAY_WAITING_TO_REGISTER = false;
	end

	registerWaitingHotkeys();

	if DPS_ENABLED then
		dpsFrame();
	end

	ASSIGNED_HOTKEY_THIS_FRAME = false;
end)

re.on_draw_ui(function()
	imgui.begin_group();
	imgui.text('coavins dps meter');

	if imgui.button('settings') then
		DRAW_WINDOW_SETTINGS = not DRAW_WINDOW_SETTINGS;

		if CFG['SHOW_TEST_DATA_WHILE_MENU_IS_OPEN'] then
			initializeTestData();
		end
	end

	imgui.same_line();

	if imgui.button('filters') then
		DRAW_WINDOW_REPORT = not DRAW_WINDOW_REPORT;
	end

	imgui.same_line();

	if imgui.button('hotkeys') then
		DRAW_WINDOW_HOTKEYS = not DRAW_WINDOW_HOTKEYS;
	end

	imgui.end_group();
end)

--#endregion

for _,type in pairs(ATTACKER_TYPES) do
	AddAttackerTypeToReport(type);
end

applyDefaultConfiguration();

log_info('init complete');