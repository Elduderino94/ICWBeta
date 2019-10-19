--******************************************************************************
--     _______ __
--    |_     _|  |--.----.---.-.--.--.--.-----.-----.
--      |   | |     |   _|  _  |  |  |  |     |__ --|
--      |___| |__|__|__| |___._|________|__|__|_____|
--     ______
--    |   __ \.-----.--.--.-----.-----.-----.-----.
--    |      <|  -__|  |  |  -__|     |  _  |  -__|
--    |___|__||_____|\___/|_____|__|__|___  |_____|
--                                    |_____|
--*   @Author:              Corey
--*   @Date:                2017-12-18T14:01:09+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            GCWarlordsCampaign.lua
--*   @Last modified by:
--*   @Last modified time:  2018-03-13T22:28:32-04:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************

require("PGStoryMode")
require("PGSpawnUnits")
require("trlib-util/ChangeOwnerUtilities")
StoryUtil = require("trlib-util/StoryUtil")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    StoryModeEvents = {
        Determine_Faction_LUA = Find_Faction
    }
end

function Find_Faction(message)
    if message == OnEnter then

        local p_republic = Find_Player("Empire")


        techLevel = p_republic.Get_Tech_Level()

        if techLevel == 1 then
            Story_Event("START_LEVEL_01")
        elseif techLevel == 2 then
            Story_Event("START_LEVEL_02")
        elseif techLevel == 3 then
            Story_Event("START_LEVEL_03")
        elseif techLevel == 4 then
            Story_Event("START_LEVEL_04")
        elseif techLevel == 5 then
            Story_Event("START_LEVEL_05")
        end

    end
end
