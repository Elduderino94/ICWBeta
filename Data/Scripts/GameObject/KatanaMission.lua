--//////////////////////////////////////////////////////////////////////////////////
-- Spawn pirate units randomly
-- � Pox
--//////////////////////////////////////////////////////////////////////////////////

require("PGStateMachine")
require("PGStoryMode")
require("PGSpawnUnits")
require("PGMoveUnits")




function Definitions()

DebugMessage("%s -- In Definitions", tostring(Script))
--Define_State("State_Init", State_Init);
invaders = Find_Player("Hutts")
--attack_chance = 0

StoryModeEvents = { Battle_Start = State_Init }

defender = nil
attacker = nil




end


function State_Init(message)
if message == OnEnter then



factions = {"Rebel", "Empire"}
unit_types = {{"Skirmish_CR90", "Skirmish_MC80B", "Skirmish_MC40a", "Skirmish_Alliance_Assault_Frigate"}, {"Skirmish_Lancer_Frigate", "Skirmish_Carrack_Cruiser", "Skirmish_Star_Destroyer_Two", "Skirmish_Victory_Destroyer"}}



-- Defender
for i, sub in pairs(starbases) do
for k, base in pairs(sub) do
if Find_First_Object(base) then
table.remove(factions, i)
table.remove(unit_types, i)
found_base = true
break


end
if Find_First_Object(base) == nil then
if i==table.getn(starbases) then
if k == table.getn(sub) then
Game_Message("TEXT_STRANGE_SIGNAL")
ScriptExit()
end
end
end

end
if found_base then
break
end

end


-- Attacker
for j, faction in pairs(factions) do
if table.getn(Find_All_Objects_Of_Type(Find_Player(faction))) > 0 then
table.remove(factions, j)
table.remove(unit_types, j)
break
end
end

raider = GameRandom(1,3)


entry = Find_First_Object("Attacker Entry Position")
moveto = Find_First_Object("Space Station Position")
Random_Spawn(unit_types[raider], invaders, entry, moveto, 100, 5)

end
end


function Random_Spawn(unit_list, faction, spawnpoint, target, probability, max_ship_number)
if type(unit_list) == "table" then

attack_chance = GameRandom(1,100)
anzahl = GameRandom(2,max_ship_number)
if raider == 3 then
anzahl = anzahl + 3
end
spawnliste = {}
count = 0


if attack_chance <= 100 then
repeat
einheit = GameRandom(raider,table.getn(unit_list))
table.insert(spawnliste, unit_list[einheit])
count = count + 1
until count == anzahl
end

if factions[raider] == "Rebel" then
Sleep(90)
Game_Message("TEXT_DETECTED_FLEET")

elseif factions[raider] == "Empire" then
Sleep(90)
Game_Message("TEXT_DETECTED_FLEET")

elseif factions[raider] == "Underworld" then
Sleep(90)
Game_Message("TEXT_DETECTED_FLEET")
elseif factions[raider] == "Pirates" then
Sleep(90)
Game_Message("TEXT_DETECTED_FLEET")
elseif factions[raider] == "Hapes_Consortium" then
Sleep(90)
Game_Message("TEXT_DETECTED_FLEET")

end

Sleep(10)

ReinforceList(spawnliste,spawnpoint,faction,true,false)
Sleep(10)


attack_chance = 0
else
ScriptExit()


end
end
