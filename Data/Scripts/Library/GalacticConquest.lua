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
--*   @Author:              [TR]Pox
--*   @Date:                2018-03-10T03:05:37+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            GalacticConquest.lua
--*   @Last modified by:    [TR]Pox
--*   @Last modified time:  2018-03-10T19:27:15+01:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************

require("PGSpawnUnits")
require("TRUtil")
require("Class")
require("GalacticEvents")
require("Planet")
require("GovernmentNewRepublic")

GalacticConquest = class()
function GalacticConquest:new(player_agnostic_plot, playableFactions)
    self.HumanPlayer = self:FindHumanPlayerInTable(playableFactions)

    self.NRGOV = GovernmentNewRepublic()

    self.Planets = self:GetPlanets()
    self:InitializeEvents(player_agnostic_plot)
    self.LastCycleTime = 0

    self.Events = {
        SelectedPlanetChanged = SelectedPlanetChangedEvent(self.HumanPlayer, self.Planets),
        PlanetOwnerChanged = PlanetOwnerChangedEvent(self.Planets),
        GalacticProductionFinished = ProductionFinishedEvent(self.Planets),
        GalacticWeekChanged = GalacticWeekChangedEvent(self.Player),
        GalacticHeroKilled = GalacticHeroKilledEvent()
    }
end

function GalacticConquest:Update()
    self.Events.SelectedPlanetChanged:Check()
    self.Events.PlanetOwnerChanged:Check()
    self.Events.GalacticProductionFinished:Check()
    self.Events.GalacticHeroKilled:Check()
    local current = GetCurrentTime()
    if current - self.LastCycleTime >= 40 then
        for _, planet in pairs(self.Planets) do
            planet:update_influence_information()
        end
        self.LastCycleTime = current
    end
    self.NRGOV:Update()
end

function GalacticConquest:GetSelectedPlanet()
    local selectedPlanetName = GlobalValue.Get("SELECTED_PLANET")
    if not TRUtil.ValidGlobalValue(selectedPlanetName) then
        return nil
    end

    return self.Planets[selectedPlanetName]
end

function GalacticConquest:FindHumanPlayerInTable(factions)
    for _, faction in pairs(factions) do
        local player = Find_Player(faction)
        if player.Is_Human() then
            return player
        end
    end
end

function GalacticConquest:InitializeEvents(plot)
    for _, planet in pairs(self.Planets) do
        local planetName = planet:get_name()
        local event = plot.Get_Event("Zoom_Into_" .. planetName)
        if event then
            event.Set_Reward_Parameter(1, self.HumanPlayer.Get_Faction_Name())
        end
    end
end

function GalacticConquest:GetPlanets()
    local all_planets = FindPlanet.Get_All_Planets()

    local planets = {}
    for _, planet in pairs(all_planets) do
        local planet_name = planet.Get_Type().Get_Name()
        planets[planet_name] = Planet(planet_name)
    end

    return planets
end

return GalacticConquest
