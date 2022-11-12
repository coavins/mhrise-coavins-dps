local this = {}

-- list of columns sorted for the combo box
-- key is dropdown index, value is column id
this.TABLE_COLUMNS_OPTIONS_ID = {}
this.TABLE_COLUMNS_OPTIONS_ID[1] = 1
this.TABLE_COLUMNS_OPTIONS_ID[2] = 2
this.TABLE_COLUMNS_OPTIONS_ID[3] = 20
this.TABLE_COLUMNS_OPTIONS_ID[4] = 3
this.TABLE_COLUMNS_OPTIONS_ID[5] = 10
this.TABLE_COLUMNS_OPTIONS_ID[6] = 4
this.TABLE_COLUMNS_OPTIONS_ID[7] = 16
this.TABLE_COLUMNS_OPTIONS_ID[8] = 5
this.TABLE_COLUMNS_OPTIONS_ID[9] = 17
this.TABLE_COLUMNS_OPTIONS_ID[10] = 23
this.TABLE_COLUMNS_OPTIONS_ID[11] = 18
this.TABLE_COLUMNS_OPTIONS_ID[12] = 24
this.TABLE_COLUMNS_OPTIONS_ID[13] = 12
this.TABLE_COLUMNS_OPTIONS_ID[14] = 13
this.TABLE_COLUMNS_OPTIONS_ID[15] = 11
this.TABLE_COLUMNS_OPTIONS_ID[16] = 6
this.TABLE_COLUMNS_OPTIONS_ID[17] = 7
this.TABLE_COLUMNS_OPTIONS_ID[18] = 14
this.TABLE_COLUMNS_OPTIONS_ID[19] = 15
this.TABLE_COLUMNS_OPTIONS_ID[20] = 8
this.TABLE_COLUMNS_OPTIONS_ID[21] = 9
this.TABLE_COLUMNS_OPTIONS_ID[22] = 19
this.TABLE_COLUMNS_OPTIONS_ID[23] = 21
this.TABLE_COLUMNS_OPTIONS_ID[24] = 22
-- populated when locale is loaded
this.TABLE_COLUMNS_OPTIONS_READABLE = {}
for i,_ in ipairs(this.TABLE_COLUMNS_OPTIONS_ID) do
	this.TABLE_COLUMNS_OPTIONS_READABLE[i] = ''
end

-- via.hid.KeyboardKey
this.ENUM_KEYBOARD_KEY = {}
this.ENUM_KEYBOARD_KEY[0] = 'None'
this.ENUM_KEYBOARD_KEY[1] = 'LButton'
this.ENUM_KEYBOARD_KEY[2] = 'RButton'
this.ENUM_KEYBOARD_KEY[3] = 'ControlBreak'
this.ENUM_KEYBOARD_KEY[4] = 'MButton'
this.ENUM_KEYBOARD_KEY[5] = 'XButton1'
this.ENUM_KEYBOARD_KEY[6] = 'XButton2'
this.ENUM_KEYBOARD_KEY[8] = 'Back'
this.ENUM_KEYBOARD_KEY[9] = 'Tab'
this.ENUM_KEYBOARD_KEY[12] = 'Clear'
this.ENUM_KEYBOARD_KEY[13] = 'Enter'
--this.ENUM_KEYBOARD_KEY[16] = 'Shift'
--this.ENUM_KEYBOARD_KEY[17] = 'Control'
--this.ENUM_KEYBOARD_KEY[18] = 'Menu'
this.ENUM_KEYBOARD_KEY[19] = 'PauseBreak'
this.ENUM_KEYBOARD_KEY[20] = 'CapsLock'
this.ENUM_KEYBOARD_KEY[21] = 'Kana/Hangual/Hangul'
this.ENUM_KEYBOARD_KEY[22] = 'IME On'
this.ENUM_KEYBOARD_KEY[23] = 'Junja'
this.ENUM_KEYBOARD_KEY[24] = 'Final'
this.ENUM_KEYBOARD_KEY[25] = 'Hanja/Kanji'
this.ENUM_KEYBOARD_KEY[26] = 'IME Off'
this.ENUM_KEYBOARD_KEY[27] = 'Escape'
this.ENUM_KEYBOARD_KEY[28] = 'Convert'
this.ENUM_KEYBOARD_KEY[29] = 'NonConvert'
this.ENUM_KEYBOARD_KEY[30] = 'Accept'
this.ENUM_KEYBOARD_KEY[31] = 'ModeChange'
this.ENUM_KEYBOARD_KEY[32] = 'Space'
this.ENUM_KEYBOARD_KEY[33] = 'PageUp'
this.ENUM_KEYBOARD_KEY[34] = 'PageDown'
this.ENUM_KEYBOARD_KEY[35] = 'End'
this.ENUM_KEYBOARD_KEY[36] = 'Home'
this.ENUM_KEYBOARD_KEY[37] = 'Left'
this.ENUM_KEYBOARD_KEY[38] = 'Up'
this.ENUM_KEYBOARD_KEY[39] = 'Right'
this.ENUM_KEYBOARD_KEY[40] = 'Down'
this.ENUM_KEYBOARD_KEY[41] = 'Select'
this.ENUM_KEYBOARD_KEY[42] = 'PrintScreen'
this.ENUM_KEYBOARD_KEY[43] = 'Execute'
this.ENUM_KEYBOARD_KEY[44] = 'SnapShot'
this.ENUM_KEYBOARD_KEY[45] = 'Insert'
this.ENUM_KEYBOARD_KEY[46] = 'Delete'
this.ENUM_KEYBOARD_KEY[47] = 'Help'
this.ENUM_KEYBOARD_KEY[48] = '0'
this.ENUM_KEYBOARD_KEY[49] = '1'
this.ENUM_KEYBOARD_KEY[50] = '2'
this.ENUM_KEYBOARD_KEY[51] = '3'
this.ENUM_KEYBOARD_KEY[52] = '4'
this.ENUM_KEYBOARD_KEY[53] = '5'
this.ENUM_KEYBOARD_KEY[54] = '6'
this.ENUM_KEYBOARD_KEY[55] = '7'
this.ENUM_KEYBOARD_KEY[56] = '8'
this.ENUM_KEYBOARD_KEY[57] = '9'
this.ENUM_KEYBOARD_KEY[65] = 'A'
this.ENUM_KEYBOARD_KEY[66] = 'B'
this.ENUM_KEYBOARD_KEY[67] = 'C'
this.ENUM_KEYBOARD_KEY[68] = 'D'
this.ENUM_KEYBOARD_KEY[69] = 'E'
this.ENUM_KEYBOARD_KEY[70] = 'F'
this.ENUM_KEYBOARD_KEY[71] = 'G'
this.ENUM_KEYBOARD_KEY[72] = 'H'
this.ENUM_KEYBOARD_KEY[73] = 'I'
this.ENUM_KEYBOARD_KEY[74] = 'J'
this.ENUM_KEYBOARD_KEY[75] = 'K'
this.ENUM_KEYBOARD_KEY[76] = 'L'
this.ENUM_KEYBOARD_KEY[77] = 'M'
this.ENUM_KEYBOARD_KEY[78] = 'N'
this.ENUM_KEYBOARD_KEY[79] = 'O'
this.ENUM_KEYBOARD_KEY[80] = 'P'
this.ENUM_KEYBOARD_KEY[81] = 'Q'
this.ENUM_KEYBOARD_KEY[82] = 'R'
this.ENUM_KEYBOARD_KEY[83] = 'S'
this.ENUM_KEYBOARD_KEY[84] = 'T'
this.ENUM_KEYBOARD_KEY[85] = 'U'
this.ENUM_KEYBOARD_KEY[86] = 'V'
this.ENUM_KEYBOARD_KEY[87] = 'W'
this.ENUM_KEYBOARD_KEY[88] = 'X'
this.ENUM_KEYBOARD_KEY[89] = 'Y'
this.ENUM_KEYBOARD_KEY[90] = 'Z'
this.ENUM_KEYBOARD_KEY[91] = 'LWin'
this.ENUM_KEYBOARD_KEY[92] = 'RWin'
this.ENUM_KEYBOARD_KEY[93] = 'Apps'
this.ENUM_KEYBOARD_KEY[95] = 'Sleep'
this.ENUM_KEYBOARD_KEY[96] = 'Numpad 0'
this.ENUM_KEYBOARD_KEY[97] = 'Numpad 1'
this.ENUM_KEYBOARD_KEY[98] = 'Numpad 2'
this.ENUM_KEYBOARD_KEY[99] = 'Numpad 3'
this.ENUM_KEYBOARD_KEY[100] = 'Numpad 4'
this.ENUM_KEYBOARD_KEY[101] = 'Numpad 5'
this.ENUM_KEYBOARD_KEY[102] = 'Numpad 6'
this.ENUM_KEYBOARD_KEY[103] = 'Numpad 7'
this.ENUM_KEYBOARD_KEY[104] = 'Numpad 8'
this.ENUM_KEYBOARD_KEY[105] = 'Numpad 9'
this.ENUM_KEYBOARD_KEY[106] = 'Numpad Multiply'
this.ENUM_KEYBOARD_KEY[107] = 'Numpad Plus'
this.ENUM_KEYBOARD_KEY[108] = 'Numpad Separator'
this.ENUM_KEYBOARD_KEY[109] = 'Numpad Minus'
this.ENUM_KEYBOARD_KEY[110] = 'Numpad Period'
this.ENUM_KEYBOARD_KEY[111] = 'Numpad Divide'
this.ENUM_KEYBOARD_KEY[112] = 'F1'
this.ENUM_KEYBOARD_KEY[113] = 'F2'
this.ENUM_KEYBOARD_KEY[114] = 'F3'
this.ENUM_KEYBOARD_KEY[115] = 'F4'
this.ENUM_KEYBOARD_KEY[116] = 'F5'
this.ENUM_KEYBOARD_KEY[117] = 'F6'
this.ENUM_KEYBOARD_KEY[118] = 'F7'
this.ENUM_KEYBOARD_KEY[119] = 'F8'
this.ENUM_KEYBOARD_KEY[120] = 'F9'
this.ENUM_KEYBOARD_KEY[121] = 'F10'
this.ENUM_KEYBOARD_KEY[122] = 'F11'
this.ENUM_KEYBOARD_KEY[123] = 'F12'
this.ENUM_KEYBOARD_KEY[124] = 'F13'
this.ENUM_KEYBOARD_KEY[125] = 'F14'
this.ENUM_KEYBOARD_KEY[126] = 'F15'
this.ENUM_KEYBOARD_KEY[127] = 'F16'
this.ENUM_KEYBOARD_KEY[128] = 'F17'
this.ENUM_KEYBOARD_KEY[129] = 'F18'
this.ENUM_KEYBOARD_KEY[130] = 'F19'
this.ENUM_KEYBOARD_KEY[131] = 'F20'
this.ENUM_KEYBOARD_KEY[132] = 'F21'
this.ENUM_KEYBOARD_KEY[133] = 'F22'
this.ENUM_KEYBOARD_KEY[134] = 'F23'
this.ENUM_KEYBOARD_KEY[135] = 'F24'
this.ENUM_KEYBOARD_KEY[144] = 'NumLock'
this.ENUM_KEYBOARD_KEY[145] = 'ScrollLock'
this.ENUM_KEYBOARD_KEY[146] = 'NumPad Enter'
this.ENUM_KEYBOARD_KEY[160] = 'Left Shift'
this.ENUM_KEYBOARD_KEY[161] = 'Right Shift'
this.ENUM_KEYBOARD_KEY[162] = 'Left Control'
this.ENUM_KEYBOARD_KEY[163] = 'Right Control'
this.ENUM_KEYBOARD_KEY[164] = 'Left Alt'
this.ENUM_KEYBOARD_KEY[165] = 'Right Alt'
this.ENUM_KEYBOARD_KEY[186] = ';'
this.ENUM_KEYBOARD_KEY[187] = '+'
this.ENUM_KEYBOARD_KEY[188] = ','
this.ENUM_KEYBOARD_KEY[189] = '-'
this.ENUM_KEYBOARD_KEY[190] = '.'
this.ENUM_KEYBOARD_KEY[191] = '/'
this.ENUM_KEYBOARD_KEY[192] = '`'
this.ENUM_KEYBOARD_KEY[219] = '['
this.ENUM_KEYBOARD_KEY[220] = '\\'
this.ENUM_KEYBOARD_KEY[221] = ']'
this.ENUM_KEYBOARD_KEY[222] = '\''
this.ENUM_KEYBOARD_KEY[223] = 'OEM_8'
this.ENUM_KEYBOARD_KEY[226] = '<'
this.ENUM_KEYBOARD_KEY[254] = 'Clear'
this.ENUM_KEYBOARD_KEY[255] = 'Backspace'

this.ENUM_KEYBOARD_MODIFIERS = {}
--this.ENUM_KEYBOARD_MODIFIERS[16] = true -- shift
--this.ENUM_KEYBOARD_MODIFIERS[17] = true -- control
--this.ENUM_KEYBOARD_MODIFIERS[18] = true -- alt
this.ENUM_KEYBOARD_MODIFIERS[160] = true -- left shift
this.ENUM_KEYBOARD_MODIFIERS[161] = true -- right shift
this.ENUM_KEYBOARD_MODIFIERS[162] = true -- left control
this.ENUM_KEYBOARD_MODIFIERS[163] = true -- right control
this.ENUM_KEYBOARD_MODIFIERS[164] = true -- left alt
this.ENUM_KEYBOARD_MODIFIERS[165] = true -- right alt

-- snow.enemy.EnemyDef.DamageAttackerType
this.DAMAGE_TYPES = {}
this.DAMAGE_TYPES[0] = 'PlayerWeapon'
this.DAMAGE_TYPES[1] = 'BarrelBombLarge'
this.DAMAGE_TYPES[2] = 'Makimushi'
this.DAMAGE_TYPES[3] = 'Nitro'
this.DAMAGE_TYPES[4] = 'OnibiMine'
this.DAMAGE_TYPES[5] = 'BallistaHate'
this.DAMAGE_TYPES[6] = 'CaptureSmokeBomb'
this.DAMAGE_TYPES[7] = 'CaptureBullet'
this.DAMAGE_TYPES[8] = 'BarrelBombSmall'
this.DAMAGE_TYPES[9] = 'Kunai'
this.DAMAGE_TYPES[10] = 'WaterBeetle'
this.DAMAGE_TYPES[11] = 'DetonationGrenade'
this.DAMAGE_TYPES[12] = 'Kabutowari'
this.DAMAGE_TYPES[13] = 'FlashBoll'
this.DAMAGE_TYPES[14] = 'HmBallista'
this.DAMAGE_TYPES[15] = 'HmCannon'
this.DAMAGE_TYPES[16] = 'HmGatling'
this.DAMAGE_TYPES[17] = 'HmTrap'
this.DAMAGE_TYPES[18] = 'HmNpc'
this.DAMAGE_TYPES[19] = 'HmFlameThrower'
this.DAMAGE_TYPES[20] = 'HmDragnator'
this.DAMAGE_TYPES[21] = 'Otomo'
this.DAMAGE_TYPES[22] = 'OtAirouShell014'
this.DAMAGE_TYPES[23] = 'OtAirouShell102'
this.DAMAGE_TYPES[24] = 'Fg005'
this.DAMAGE_TYPES[25] = 'EcBatExplode'
this.DAMAGE_TYPES[26] = 'EcWallTrapBugExplode'
this.DAMAGE_TYPES[27] = 'EcPiranha'
this.DAMAGE_TYPES[28] = 'EcFlash'
this.DAMAGE_TYPES[29] = 'EcSandWallShooter'
this.DAMAGE_TYPES[30] = 'EcForestWallShooter'
this.DAMAGE_TYPES[31] = 'EcSwampLeech'
this.DAMAGE_TYPES[32] = 'EcPenetrateFish'
this.DAMAGE_TYPES[33] = 'Max'
this.DAMAGE_TYPES[34] = 'Monster' -- is actually "Invalid" in game
-- defined here for convenience, but is not really in the game
this.DAMAGE_TYPES[125] = 'marionette'

this.LANGUAGES = {}
this.LANGUAGES['en'] = 'English'
this.LANGUAGES['es'] = 'Español'
this.LANGUAGES['fr'] = 'Français'
this.LANGUAGES['ja'] = '日本語'
this.LANGUAGES['zh'] = '汉语'
this.LANGUAGES['zh-HK'] = '中文（香港）'

-- ver
this.VERSION = {
	"10.0.3.0"
	, "11.0.1.0"
	, "11.0.2.0"
	, "12.0.0.0"
	, "12.0.1.1"
}
this.TOOL_VERSION = {
	"2.11.4"
	, "2.11.6"
	, "2.11.7"
}

-- define count
this.WEAPON_INFO_COUNT = 4		-- 武器情報取得要素数
this.PLAYER_SKILL_COUNT = 48	-- プレイヤー装備中スキル枠数
this.PLAYER_SKILL_LV_COUNT = 24	-- プレイヤー装備中スキルLv枠数
this.SKILL_LV_THRESHOLD = 16	-- 第一第二スキルのレベル計算に使用する閾値
this.KITCHEN_SKILL_COUNT = 6	-- キッチンスキル枠数
this.KITCHEN_SKILL_LV_COUNT = 3	-- キッチンスキルLv枠数
this.OTOMO_SUPPORT_ACTION_COUNT = 6		-- オトモ装備中サポート行動スキル枠数
this.OTOMO_SKILL_COUNT = 8		-- オトモ装備中スキル枠数
this.DOG_TOOL_TYPE_COUNT = 2	-- 猟犬具枠数


return this
