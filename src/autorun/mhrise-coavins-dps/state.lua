local USER_OPTIONS = require 'mhrise-coavins-dps.user_options'

local this = {}

this.USE_PLUGIN_D2D = USER_OPTIONS.USE_PLUGIN_D2D
this.RE_FONT_NAME_JP = 'NotoSansJP-Regular.otf'
this.RE_FONT_NAME_SC = 'NotoSansSC-Regular.otf'
this.RE_FONT_NAME_HK = 'ChironHeiHK-R.otf'

this.RE_FONT_SIZE = 18
this.CJK_GLYPH_RANGES = {
	0x0020, 0x00FF, -- Basic Latin + Latin Supplement
	0x2000, 0x206F, -- General Punctuation
	0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
	0x31F0, 0x31FF, -- Katakana Phonetic Extensions
	0xFF00, 0xFFEF, -- Half-width characters
	0x4e00, 0x9FAF, -- CJK Ideograms
	0,
}
this.IMGUI_FONT = nil
this.CHANGE_IMGUI_FONT = nil

-- auto-detect missing plugin
if not d2d then
	this.USE_PLUGIN_D2D = false
end

this.DPS_ENABLED = true
this.HOOKS_ENABLED = true
this.LAST_UPDATE_TIME = 0
this.DRAW_OVERLAY = true
this.DRAW_WINDOW_SETTINGS = false
this.DRAW_WINDOW_HOTKEYS  = false
this.DRAW_WINDOW_DEBUG    = false
this.WINDOW_FLAGS = 0x120
this.PICKER_FLAGS = 0x40000
this.IS_ONLINE = false
this.QUEST_DURATION = 0.0
this.IS_IN_QUEST = false
this.IS_POST_QUEST = false
this.IS_RESULT_SCREEN = false
this.IS_IN_VILLAGE = false
this.IS_IN_TRAININGHALL = false

this.NEEDS_UPDATE = false

this._CFG = {}
this.DATADIR = 'mhrise-coavins-dps/'
this._COLORS = {}
this._FILTERS = {}
this._HOTKEYS = {}
this.HOTKEY_WAITING_TO_REGISTER = nil -- if a string, will register next key press as that hotkey
this.HOTKEY_WAITING_TO_REGISTER_WITH_MODIFIER = {} -- table of modifiers for new hotkey
this.CURRENTLY_HELD_MODIFIERS = {}
this.ASSIGNED_HOTKEY_THIS_FRAME = false

this.FONT = nil

this._PRESETS = {}
this.PRESET_OPTIONS = {}
this.PRESET_OPTIONS_SELECTED = 1
this._COLORSCHEMES = {}
this.COLORSCHEME_OPTIONS = {}
this.COLORSCHEME_OPTIONS_SELECTED = 1
this._LOCALES = {}
this.LOCALE_OPTIONS = {}
this.LOCALE_OPTIONS_SELECTED = 1
this.LOCALE_OPTIONS_TXT2LOCALE = {}
this.LOCALE = 'en-US'

this.SCREEN_W = 0.0
this.SCREEN_H = 0.0
this.DEBUG_Y = 0

this.FAKE_OTOMO_RANGE_START = 9990 -- it is important that attacker ids near this are never used by the game
this.FAKE_ATTACKER_ID = 10189 -- monsters with id=0 are treated as if they had this attacker id
this.COMBINE_ALL_OTHERS_ATTACKER_ID = 10295 -- when this option is used, all attackers except for us use this id
this.MISSING_ATTACKER_ID = 10304 -- a report item can be created with this attacker id to represent missing damage
this.HIGH_NUMBER = 9999.0
this.OTOMO_ATTACKER_TYPE_ID = 21
this.MONSTER_DAMAGE_TYPE_ID = 34

this.LARGE_MONSTERS = {}
this.TEST_MONSTERS = nil -- like LARGE_MONSTERS, but holds dummy/test data
this.DAMAGE_REPORTS = {}

this.REPORT_MONSTERS = {} -- a subset of LARGE_MONSTERS or TEST_MONSTERS that will appear in reports
this.ORDERED_MONSTERS = {} -- an index of LARGE_MONSTERS keys but ordered as an array, used by hotkeys
this.ORDERED_MONSTERS_SELECTED = 0 -- which index is currently selected, used by hotkeys

this.SERVANTS = {}

this.MY_PLAYER_ID = nil
this.PLAYER_NAMES = {}
this.OTOMO_NAMES = {}
this.PLAYER_RANKS = {}
this.PLAYER_MASTERRANKS = {}
this.PLAYER_TIMES = {} -- the time when they entered the quest
this.PLAYER_DEATHS = {} -- how many times each player carted
this.MEMBERS_COUNT = {}
this.MEMBERS_INFO = {}
this.WEAPON_INFO = {}
this.QUEST_NO = -1
this.QUEST_TARGET_ID = {}
this.WEAPON_ID = {}
this.PLAYER_SKILL = {}
this.KITCHEN_SKILL = {}
this.OTOMO_INFO = {}
this.SWITCH_ACTION_ID = {}

-- initialized later when they become available
this.MANAGER = {}
this.MANAGER.PLAYER   = nil
this.MANAGER.ENEMY    = nil
this.MANAGER.QUEST    = nil
this.MANAGER.MESSAGE  = nil
this.MANAGER.LOBBY    = nil
this.MANAGER.AREA     = nil
this.MANAGER.OTOMO    = nil
this.MANAGER.KEYBOARD = nil
this.MANAGER.SCENE    = nil
this.MANAGER.PROGRESS = nil
this.MANAGER.SERVANT  = nil
this.MANAGER.EQUIP_STATUS_PARAM  = nil

this.SCENE_MANAGER_TYPE = nil
this.SCENE_MANAGER_VIEW = nil

this.QUEST_MANAGER_TYPE = nil
this.QUEST_MANAGER_TYPE_RECV_FORFEIT = nil
this.QUEST_MANAGER_TYPE_SEND_FORFEIT = nil
this.QUEST_MANAGER_TYPE_NOTIFY_DEATH = nil

this.SNOW_ENEMY_ENEMYCHARACTERBASE = nil
this.SNOW_ENEMY_ENEMYCHARACTERBASE_AFTERCALCDAMAGE_DAMAGESIDE = nil
this.SNOW_ENEMY_ENEMYCHARACTERBASE_UPDATE = nil

this.SNOW_ENEMY_ENEMYPOISONDAMAGEPARAM = nil
this.SNOW_ENEMY_ENEMYPOISONDAMAGEPARAM_ONACTIVATEPROC = nil
this.SNOW_ENEMY_ENEMYBLASTDAMAGEPARAM = nil
this.SNOW_ENEMY_ENEMYBLASTDAMAGEPARAM_ONACTIVATEPROC = nil

return this
