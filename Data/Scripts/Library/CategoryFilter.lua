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
--*   @Author:              [TR]Pox <Pox>
--*   @Date:                2018-01-13T11:47:17+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            CategoryFilter.lua
--*   @Last modified by:    Pox
--*   @Last modified time:  2018-02-27T20:36:57+01:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************



require("PGSpawnUnits")
require("Class")

CategoryFilter = Class {

        EventNames = {
            "Filter_Non_Capital",
            "Filter_Capitals",
            "Filter_Structures"
        },

        CategoryFlags = {
            ["SELECT_NON_CAPITAL"] = "Non_Capital_Category_Dummy",
            ["SELECT_CAPITAL"] = "Capital_Category_Dummy",
            ["SELECT_STRUCTURE"] = "Structure_Category_Dummy"
        },

        Placeholder = "Placeholder_Category_Dummy",

        ActiveFilter = "SELECT_NON_CAPITAL",

        SpawnedHumanDummies = {},

        SpawnedAiDummies = {},

        LastAiDummyCheck = nil,

        Constructor = function(self)
            local plot = GLOBALS.PLAYER_AGNOSTIC_PLOT

            if not plot then
                return
            end

            GLOBALS.Events.SelectedPlanetChanged:AttachListener(self.SpawnCategoryDummy, self)
            GLOBALS.Events.PlanetOwnerChanged:AttachListener(self.OnPlanetOwnerChanged, self)

            for _, eventName in pairs(self.EventNames) do
                local event = plot.Get_Event(eventName)
                if event then
                    event.Set_Reward_Parameter(1, GLOBALS.PLAYER.Get_Faction_Name())
                end
            end


            local allPlanets = GLOBALS.ALL_PLANETS
            for _, planet in pairs(allPlanets) do
                self:SpawnAiDummies(planet)
            end

            self.LastAiDummyCheck = GetCurrentTime()
        end,

        Update = function(self)
            self:HandleFilterChange()
            self:RespawnMissingDummies()
        end,

        HandleFilterChange = function (self)
            for categoryFlag, _ in pairs(self.CategoryFlags) do
                if Check_Story_Flag(GLOBALS.PLAYER, categoryFlag, nil, true) then
                    if self.ActiveFilter == categoryFlag then
                        break
                    end
                    self.ActiveFilter = categoryFlag
                    self:SpawnCategoryDummy(GLOBALS.GetSelectedPlanet())
                    break
                end
            end
        end,

        OnPlanetOwnerChanged = function(self, planet)
            if not planet then
                return
            end

            self:ClearAiDummies(planet)
            if planet.Get_Owner().Is_Human() then
                if planet == GLOBALS.GetSelectedPlanet() then
                    self:SpawnCategoryDummy(GLOBALS.GetSelectedPlanet())
                end
            else
                self:SpawnAiDummies(planet)
            end
        end,

        RespawnMissingDummies = function(self)
            if (GetCurrentTime() - self.LastAiDummyCheck) < 10 then
                return
            end

            for _, planet in pairs(FindPlanet.Get_All_Planets()) do
                if not planet.Get_Owner().Is_Human() then
                    self:CreateAiEntry(planet)
                    self:RemoveInvalidEntries(self.SpawnedAiDummies[planet])
                    if table.getn(self.SpawnedAiDummies[planet]) == 0 then
                        self:SpawnAiDummies(planet)
                    end
                end
            end

            self.LastAiDummyCheck = GetCurrentTime()
        end,

        RemoveInvalidEntries = function(self, tab)
            for i, object in pairs(tab) do
                if not TestValid(object) then
                    table.remove(tab, i)
                end
            end
        end,

        CreateAiEntry = function(self, planet)
            if not self.SpawnedAiDummies[planet] then
                self.SpawnedAiDummies[planet] = {}
            end
        end,

        SpawnCategoryDummy = function(self, selectedPlanet)
            self:ClearDummies()

            if not selectedPlanet then
                return
            end

            if not selectedPlanet.Get_Owner().Is_Human() then
                return
            end

            if not self.ActiveFilter then
                return
            end

            local typeList = {
                self.CategoryFlags[self.ActiveFilter],
                self.Placeholder,
                self.Placeholder
            }

            local dummies = SpawnList(typeList, selectedPlanet, GLOBALS.PLAYER, false, false)
        end,

        SpawnAiDummies = function(self, planet)
            local owner = planet.Get_Owner()
            if owner.Is_Human() or owner == Find_Player("Neutral") then
                return
            end

            -- if EvaluatePerception("Has_Starbase", owner, planet) == 0 then
            --     return
            -- end

            self:ClearAiDummies(planet)
            self:CreateAiEntry(planet)

            local typeList = {
                "Non_Capital_Category_Dummy",
                "Capital_Category_Dummy",
                "Structure_Category_Dummy"
            }

            local dummies = SpawnList(typeList, planet, planet.Get_Owner(), false, false)
            for _, dummy in pairs(dummies) do
                table.insert(self.SpawnedAiDummies[planet], dummy)
            end
        end,

        ClearDummies = function(self)
            local dummies = nil
            for _, dummyType in pairs(self.CategoryFlags) do
                dummies = Find_All_Objects_Of_Type(dummyType)
                for _, dummy in pairs(dummies) do
                    if TestValid(dummy) and dummy.Get_Owner().Is_Human() then
                        dummy.Despawn()
                    end
                end
            end

            dummies = Find_All_Objects_Of_Type(self.Placeholder)
            for _, dummy in pairs(dummies) do
                if TestValid(dummy) and dummy.Get_Owner().Is_Human() then
                    dummy.Despawn()
                end
            end
        end,

        ClearAiDummies = function(self, planet)
            if not self.SpawnedAiDummies[planet] then
                return
            end

            for i, dummy in pairs(self.SpawnedAiDummies[planet]) do
                if TestValid(dummy) then
                    dummy.Despawn()
                end
                table.remove(self.SpawnedAiDummies[planet], i)
            end
        end
}

return CategoryFilter
