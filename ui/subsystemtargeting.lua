-- ffi setup 
local ffi = require("ffi") 
local C = ffi.C 
 
local Lib = require("extensions.sn_mod_support_apis.lua_library") 
local menu = {} 
local sto_menu = {} 
 
local config = { 
    mapRowHeight = Helper.standardTextHeight, 
    mapFontSize = Helper.standardFontSize, 
    infoFrameLayer2 = 5, 
    infoFrameLayer = 4, 
} 
 
local function init() 
    DebugError("Subsystem Targeting Orders Init") 
 
    menu = Lib.Get_Egosoft_Menu("MapMenu") 
    menu.setupLoadoutInfoSubmenuRows = sto_menu.setupLoadoutInfoSubmenuRows 
end 
 
function sto_menu.setupLoadoutInfoSubmenuRows(mode, inputtable, inputobject, instance) 
    local object64 = ConvertStringTo64Bit(tostring(inputobject)) 
    local isplayerowned, isonlineobject, isenemy, ishostile = GetComponentData(object64, "isplayerowned", "isonlineobject", "isenemy", "ishostile") 
    local titlecolor = Helper.color.white 
    if isplayerowned then 
        titlecolor = menu.holomapcolor.playercolor 
        if object64 == C.GetPlayerObjectID() then 
            titlecolor = menu.holomapcolor.currentplayershipcolor 
        end 
    elseif isonlineobject and menu.getFilterOption("layer_think") and menu.getFilterOption("think_diplomacy_highlightvisitor") then 
        titlecolor = menu.holomapcolor.visitorcolor 
    elseif ishostile then 
        titlecolor = menu.holomapcolor.hostilecolor 
    elseif isenemy then 
        titlecolor = menu.holomapcolor.enemycolor 
    end 
 
    local loadout = {} 
    if mode == "ship" or mode == "station" then 
        loadout = { ["component"] = {}, ["macro"] = {}, ["ware"] = {} } 
        for i, upgradetype in ipairs(Helper.upgradetypes) do 
            if upgradetype.supertype == "macro" then 
                loadout.component[upgradetype.type] = {} 
                local numslots = 0 
                if C.IsComponentClass(inputobject, "defensible") then 
                    numslots = tonumber(C.GetNumUpgradeSlots(inputobject, "", upgradetype.type)) 
                end 
                for j = 1, numslots do 
                    local current = C.GetUpgradeSlotCurrentComponent(inputobject, upgradetype.type, j) 
                    if current ~= 0 then 
                        table.insert(loadout.component[upgradetype.type], current) 
                    end 
                end 
            elseif upgradetype.supertype == "virtualmacro" then 
                loadout.macro[upgradetype.type] = {} 
                local numslots = tonumber(C.GetNumVirtualUpgradeSlots(inputobject, "", upgradetype.type)) 
                for j = 1, numslots do 
                    local current = ffi.string(C.GetVirtualUpgradeSlotCurrentMacro(inputobject, upgradetype.type, j)) 
                    if current ~= "" then 
                        table.insert(loadout.macro[upgradetype.type], current) 
                    end 
                end 
            elseif upgradetype.supertype == "software" then 
                loadout.ware[upgradetype.type] = {} 
                local numslots = C.GetNumSoftwareSlots(inputobject, "") 
                local buf = ffi.new("SoftwareSlot[?]", numslots) 
                numslots = C.GetSoftwareSlots(buf, numslots, inputobject, "") 
                for j = 0, numslots - 1 do 
                    local current = ffi.string(buf[j].current) 
                    if current ~= "" then 
                        table.insert(loadout.ware[upgradetype.type], current) 
                    end 
                end 
            elseif upgradetype.supertype == "ammo" then 
                loadout.macro[upgradetype.type] = {} 
            end 
        end 
    end 
 
    local cheatsecrecy = false 
    -- secrecy stuff 
    local nameinfo =                    cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "name") 
    local defenceinfo_low =             cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "defence_level") 
    local defenceinfo_high =            cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "defence_status") 
    local unitinfo_capacity =           cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_capacity") 
    local unitinfo_amount =             cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_amount") 
    local unitinfo_details =            cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_details") 
    local equipment_mods =              cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "equipment_mods") 
 
    --- title --- 
    local row = inputtable:addRow(false, {fixed = true, bgColor = Helper.defaultTitleBackgroundColor}) 
    row[1]:setColSpan(13):createText(ReadText(1001, 9413), Helper.headerRow1Properties) 
 
    local objectname = Helper.unlockInfo(nameinfo, ffi.string(C.GetComponentName(inputobject))) 
    -- object name 
    local row = inputtable:addRow("info_focus", { fixed = true, bgColor = Helper.defaultTitleBackgroundColor }) 
    row[13]:createButton({ width = config.mapRowHeight, cellBGColor = Helper.color.transparent }):setIcon("menu_center_selection", { width = config.mapRowHeight, height = config.mapRowHeight, y = (Helper.headerRow1Height - config.mapRowHeight) / 2 }) 
    row[13].handlers.onClick = function () return C.SetFocusMapComponent(menu.holomap, menu.infoSubmenuObject, true) end 
    if (mode == "ship") or (mode == "station") then 
        row[1]:setBackgroundColSpan(12):setColSpan(6):createText(objectname, Helper.headerRow1Properties) 
        row[1].properties.color = titlecolor 
        row[7]:setColSpan(6):createText(Helper.unlockInfo(nameinfo, ffi.string(C.GetObjectIDCode(inputobject))), Helper.headerRow1Properties) 
        row[7].properties.halign = "right" 
        row[7].properties.color = titlecolor 
    else 
        row[1]:setBackgroundColSpan(12):setColSpan(12):createText(objectname, Helper.headerRow1Properties) 
        row[1].properties.color = titlecolor 
    end 
 
    if mode == "ship" then 
        local pilot = GetComponentData(inputobject, "assignedpilot") 
        pilot = ConvertIDTo64Bit(pilot) 
        local pilotname, skilltable, postname, aicommandstack, aicommand, aicommandparam, aicommandaction, aicommandactionparam = "-", {}, ReadText(1001, 4847), {} 
        if pilot and IsValidComponent(pilot) then 
            pilotname, skilltable, postname, aicommandstack, aicommand, aicommandparam, aicommandaction, aicommandactionparam = GetComponentData(pilot, "name", "skills", "postname", "aicommandstack", "aicommand", "aicommandparam", "aicommandaction", "aicommandactionparam") 
        end 
 
        local isbigship = C.IsComponentClass(inputobject, "ship_m") or C.IsComponentClass(inputobject, "ship_l") or C.IsComponentClass(inputobject, "ship_xl") 
        -- weapon config 
        if isplayerowned and (#loadout.component.weapon > 0) then 
            local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
            row[1]:setColSpan(13):createText(ReadText(1001, 9409), Helper.headerRowCenteredProperties) -- Weapon Configuration 
            -- subheader 
            local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
            row[3]:setColSpan(5):createText(ReadText(1001, 9410), { font = Helper.standardFontBold }) -- Primary 
            row[8]:setColSpan(6):createText(ReadText(1001, 9411), { font = Helper.standardFontBold }) -- Secondary 
            -- active weapon groups 
            local row = inputtable:addRow("info_weaponconfig_active", { bgColor = Helper.color.transparent }) 
            row[2]:createText(ReadText(1001, 11218)) 
            for j = 1, 4 do 
                row[2 + j]:createCheckBox(function () return C.GetDefensibleActiveWeaponGroup(inputobject, true) == j end, { width = config.mapRowHeight, height = config.mapRowHeight, symbol = "arrow", bgColor = function () return menu.infoWeaponGroupCheckBoxColor(inputobject, j, true) end }) 
                row[2 + j].handlers.onClick = function () C.SetDefensibleActiveWeaponGroup(inputobject, true, j) end 
            end 
            for j = 1, 4 do 
                row[7 + j]:createCheckBox(function () return C.GetDefensibleActiveWeaponGroup(inputobject, false) == j end, { width = config.mapRowHeight, height = config.mapRowHeight, symbol = "arrow", bgColor = function () return menu.infoWeaponGroupCheckBoxColor(inputobject, j, false) end }) 
                row[7 + j].handlers.onClick = function () C.SetDefensibleActiveWeaponGroup(inputobject, false, j) end 
            end 
            inputtable:addEmptyRow(config.mapRowHeight / 2) 
            -- weapons 
            for i, gun in ipairs(loadout.component.weapon) do 
                local gun = ConvertStringTo64Bit(tostring(gun)) 
                local numweapongroups = C.GetNumWeaponGroupsByWeapon(inputobject, gun) 
                local rawweapongroups = ffi.new("UIWeaponGroup[?]", numweapongroups) 
                numweapongroups = C.GetWeaponGroupsByWeapon(rawweapongroups, numweapongroups, inputobject, gun) 
                local uiweapongroups = { primary = {}, secondary = {} } 
                for j = 0, numweapongroups - 1 do 
                    -- there are two sets: primary and secondary. 
                    -- each set has four groups. 
                    -- .primary tells you if this particular weapon is active in a group in the primary or secondary group set. 
                    -- .idx tells you which group in that group set it is active in. 
                    if rawweapongroups[j].primary then 
                        uiweapongroups.primary[rawweapongroups[j].idx] = true 
                    else 
                        uiweapongroups.secondary[rawweapongroups[j].idx] = true 
                    end 
                    --print("primary: " .. tostring(rawweapongroups[j].primary) .. ", idx: " .. tostring(rawweapongroups[j].idx)) 
                end 
 
                local row = inputtable:addRow("info_weaponconfig" .. i, { bgColor = Helper.color.transparent }) 
                row[2]:createText(ffi.string(C.GetComponentName(gun))) 
 
                -- primary weapon groups 
                for j = 1, 4 do 
                    row[2 + j]:createCheckBox(uiweapongroups.primary[j], { width = config.mapRowHeight, height = config.mapRowHeight, bgColor = function () return menu.infoWeaponGroupCheckBoxColor(inputobject, j, true) end }) 
                    row[2 + j].handlers.onClick = function() menu.infoSetWeaponGroup(inputobject, gun, true, j, not uiweapongroups.primary[j]) end 
                end 
 
                -- secondary weapon groups 
                for j = 1, 4 do 
                    row[7 + j]:createCheckBox(uiweapongroups.secondary[j], { width = config.mapRowHeight, height = config.mapRowHeight, bgColor = function () return menu.infoWeaponGroupCheckBoxColor(inputobject, j, false) end }) 
                    row[7 + j].handlers.onClick = function() menu.infoSetWeaponGroup(inputobject, gun, false, j, not uiweapongroups.secondary[j]) end 
                end 
 
                if IsComponentClass(gun, "missilelauncher") then 
                    local nummissiletypes = C.GetNumAllMissiles(inputobject) 
                    local missilestoragetable = ffi.new("AmmoData[?]", nummissiletypes) 
                    nummissiletypes = C.GetAllMissiles(missilestoragetable, nummissiletypes, inputobject) 
 
                    local gunmacro = GetComponentData(gun, "macro") 
                    local dropdowndata = {} 
                    for j = 0, nummissiletypes-1 do 
                        local ammomacro = ffi.string(missilestoragetable[j].macro) 
                        if C.IsAmmoMacroCompatible(gunmacro, ammomacro) then 
                            table.insert(dropdowndata, {id = ammomacro, text = GetMacroData(ammomacro, "name"), icon = "", displayremoveoption = false}) 
                        end 
                    end 
 
                    -- if the ship has no compatible ammunition in ammo storage, have the dropdown print "Out of ammo" and make it inactive. 
                    local currentammomacro = "empty" 
                    local dropdownactive = true 
                    if #dropdowndata == 0 then 
                        dropdownactive = false 
                        table.insert(dropdowndata, {id = "empty", text = ReadText(1001, 9412), icon = "", displayremoveoption = false}) -- Out of ammo 
                    else 
                        -- NB: currentammomacro can be null 
                        currentammomacro = ffi.string(C.GetCurrentAmmoOfWeapon(gun)) 
                    end 
 
                    row = inputtable:addRow(("info_weaponconfig" .. i .. "_ammo"), { bgColor = Helper.color.transparent }) 
                    row[2]:createText((ReadText(1001, 2800) .. ReadText(1001, 120)))    -- Ammunition, : 
                    row[3]:setColSpan(11):createDropDown(dropdowndata, {startOption = currentammomacro, active = dropdownactive}) 
                    row[3].handlers.onDropDownConfirmed = function(_, newammomacro) C.SetAmmoOfWeapon(gun, newammomacro) end 
                elseif pilot and IsValidComponent(pilot) and IsComponentClass(gun, "bomblauncher") then 
                    local numbombtypes = C.GetNumAllInventoryBombs(pilot) 
                    local bombstoragetable = ffi.new("AmmoData[?]", numbombtypes) 
                    numbombtypes = C.GetAllInventoryBombs(bombstoragetable, numbombtypes, pilot) 
 
                    local gunmacro = GetComponentData(gun, "macro") 
                    local dropdowndata = {} 
                    for j = 0, numbombtypes-1 do 
                        local ammomacro = ffi.string(bombstoragetable[j].macro) 
                        if C.IsAmmoMacroCompatible(gunmacro, ammomacro) then 
                            table.insert(dropdowndata, {id = ammomacro, text = GetMacroData(ammomacro, "name"), icon = "", displayremoveoption = false}) 
                        end 
                    end 
 
                    -- if the ship has no compatible ammunition in ammo storage, have the dropdown print "Out of ammo" and make it inactive. 
                    local currentammomacro = "empty" 
                    local dropdownactive = true 
                    if #dropdowndata == 0 then 
                        dropdownactive = false 
                        table.insert(dropdowndata, {id = "empty", text = ReadText(1001, 9412), icon = "", displayremoveoption = false}) -- Out of ammo 
                    else 
                        -- NB: currentammomacro can be null 
                        currentammomacro = ffi.string(C.GetCurrentAmmoOfWeapon(gun)) 
                    end 
 
                    row = inputtable:addRow(("info_weaponconfig" .. i .. "_ammo"), { bgColor = Helper.color.transparent }) 
                    row[2]:createText((ReadText(1001, 2800) .. ReadText(1001, 120)))    -- Ammunition, : 
                    row[3]:setColSpan(11):createDropDown(dropdowndata, {startOption = currentammomacro, active = dropdownactive}) 
                    row[3].handlers.onDropDownConfirmed = function(_, newammomacro) C.SetAmmoOfWeapon(gun, newammomacro) end 
                end 
            end 
        end 
    end 
    if (mode == "ship") or (mode == "station") then 
        -- turret behaviour 
        if isplayerowned and #loadout.component.turret > 0 then 
            local hasnormalturrets = false 
            local hasmissileturrets = false 
            local hasoperationalnormalturrets = false 
            local hasoperationalmissileturrets = false 
 
            local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
            row[1]:setColSpan(13):createText(ReadText(1001, 8612), Helper.headerRowCenteredProperties) -- Turret Behaviour 
            menu.turrets = {} 
            local numslots = tonumber(C.GetNumUpgradeSlots(inputobject, "", "turret")) 
            for j = 1, numslots do 
                local groupinfo = C.GetUpgradeSlotGroup(inputobject, "", "turret", j) 
                if (ffi.string(groupinfo.path) == "..") and (ffi.string(groupinfo.group) == "") then 
                    local current = C.GetUpgradeSlotCurrentComponent(inputobject, "turret", j) 
                    if current ~= 0 then 
                        if (not hasmissileturrets) or (not hasnormalturrets) then 
                            local ismissileturret = C.IsComponentClass(current, "missileturret") 
                            hasmissileturrets = hasmissileturrets or ismissileturret 
                            hasnormalturrets = hasnormalturrets or (not ismissileturret) 
                        end 
                        table.insert(menu.turrets, current) 
                    end 
                end 
            end 
 
            menu.turretgroups = {} 
            local n = C.GetNumUpgradeGroups(inputobject, "") 
            local buf = ffi.new("UpgradeGroup2[?]", n) 
            n = C.GetUpgradeGroups2(buf, n, inputobject, "") 
            for i = 0, n - 1 do 
                if (ffi.string(buf[i].path) ~= "..") or (ffi.string(buf[i].group) ~= "") then 
                    local group = { context = buf[i].contextid, path = ffi.string(buf[i].path), group = ffi.string(buf[i].group) } 
                    local groupinfo = C.GetUpgradeGroupInfo2(inputobject, "", group.context, group.path, group.group, "turret") 
                    if (groupinfo.count > 0) then 
                        group.operational = groupinfo.operational 
                        group.currentmacro = ffi.string(groupinfo.currentmacro) 
                        group.slotsize = ffi.string(groupinfo.slotsize) 
                        if (not hasmissileturrets) or (not hasnormalturrets) then 
                            local ismissileturret = IsMacroClass(group.currentmacro, "missileturret") 
                            hasmissileturrets = hasmissileturrets or ismissileturret 
                            hasnormalturrets = hasnormalturrets or (not ismissileturret) 
                            if ismissileturret then 
                                if not hasoperationalmissileturrets then 
                                    hasoperationalmissileturrets = group.operational > 0 
                                end 
                            else 
                                if not hasoperationalnormalturrets then 
                                    hasoperationalnormalturrets = group.operational > 0 
                                end 
                            end 
                        end 
                        table.insert(menu.turretgroups, group) 
                    end 
                end 
            end 
 
            if (#menu.turrets > 0) or (#menu.turretgroups > 0) then 
                if mode == "ship" then 
                    local turretmodes = { 
                        [1] = { id = "defend",          text = ReadText(1001, 8613),    icon = "",  displayremoveoption = false }, 
                        [2] = { id = "attackenemies",   text = ReadText(1001, 8614),    icon = "",  displayremoveoption = false }, 
                        [3] = { id = "attackcapital",   text = ReadText(1001, 8624),    icon = "",  displayremoveoption = false }, 
                        [4] = { id = "attackfighters",  text = ReadText(1001, 8625),    icon = "",  displayremoveoption = false }, 
                        [5] = { id = "mining",          text = ReadText(1001, 8616),    icon = "",  displayremoveoption = false }, 
                        [6] = { id = "missiledefence",  text = ReadText(1001, 8615),    icon = "",  displayremoveoption = false }, 
                        [7] = { id = "autoassist",      text = ReadText(1001, 8617),    icon = "",  displayremoveoption = false } 
                    } 
 
                    local turretmodesexpanded = { 
                        [1] = { id = "defend",          text = ReadText(1001, 8613),    icon = "",  displayremoveoption = false },
                        [2] = { id = "attackenemies",   text = ReadText(1001, 8614),    icon = "",  displayremoveoption = false },
                        [3] = { id = "attackcapital",   text = ReadText(1001, 8624),    icon = "",  displayremoveoption = false },
                        [4] = { id = "attackfighters",  text = ReadText(1001, 8625),    icon = "",  displayremoveoption = false },
                        [5] = { id = "mining",          text = ReadText(1001, 8616),    icon = "",  displayremoveoption = false },
                        [6] = { id = "missiledefence",  text = ReadText(1001, 8615),    icon = "",  displayremoveoption = false },
                        [7] = { id = "autoassist",      text = ReadText(1001, 8617),    icon = "",  displayremoveoption = false },
                        [8] = { id = "attackengines",   text = "Attack Engines",        icon = "",  displayremoveoption = false },
                        [9] = { id = "attackshields",   text = "Attack Shields",        icon = "",  displayremoveoption = false },
                        [10] = { id = "attackmturrets", text = "Attack M Turrets",      icon = "",  displayremoveoption = false },
                        [11] = { id = "attacklturrets", text = "Attack L Turrets",      icon = "",  displayremoveoption = false },
                        [12] = { id = "attackmissiles", text = "Attack Missile Turrets", icon = "",  displayremoveoption = false }
                    } 
 
                    local row = inputtable:addRow("info_turretconfig", { bgColor = Helper.color.transparent }) 
                    row[2]:setColSpan(3):createText(ReadText(1001, 2963)) 
                    row[5]:setColSpan(9):createDropDown(turretmodesexpanded, { startOption = function () return menu.getDropDownTurretModeOption(inputobject, "all") end }) 
                    row[5].handlers.onDropDownConfirmed = function(_, newturretmode)  
                        if newturretmode == "attackengines" or newturretmode == "attackshields" or newturretmode == "attackmturrets" or newturretmode == "attacklturrets" or newturretmode == "attackmissiles" then 
                            AddUITriggeredEvent("WeaponModeChanged", "onWeaponModeSelected", newturretmode) 
                        else
                            menu.noupdate = false 
                            C.SetAllTurretModes(inputobject, newturretmode) 
                        end 
                    end 
                    row[5].handlers.onDropDownActivated = function () menu.noupdate = true end 
 
                    local row = inputtable:addRow("info_turretconfig_2", { bgColor = Helper.color.transparent }) 
                    row[5]:setColSpan(9):createButton({ height = config.mapRowHeight }):setText(function () return menu.areTurretsArmed(inputobject) and ReadText(1001, 8631) or ReadText(1001, 8632) end, { halign = "center" }) 
                    row[5].handlers.onClick = function () return C.SetAllTurretsArmed(inputobject, not menu.areTurretsArmed(inputobject)) end 
 
                    local dropdownCount = 1 
                    for i, turret in ipairs(menu.turrets) do 
                        inputtable:addEmptyRow(config.mapRowHeight / 2) 
 
                        local row = inputtable:addRow("info_turretconfig" .. i, { bgColor = Helper.color.transparent }) 
                        row[2]:setColSpan(3):createText(ffi.string(C.GetComponentName(turret))) 
                        row[5]:setColSpan(9):createDropDown(turretmodes, { startOption = function () return menu.getDropDownTurretModeOption(turret) end }) 
                        row[5].handlers.onDropDownConfirmed = function(_, newturretmode) menu.noupdate = false; C.SetWeaponMode(turret, newturretmode) end 
                        row[5].handlers.onDropDownActivated = function () menu.noupdate = true end 
                        dropdownCount = dropdownCount + 1 
                        if dropdownCount == 14 then 
                            inputtable.properties.maxVisibleHeight = inputtable:getFullHeight() 
                        end 
 
                        local row = inputtable:addRow("info_turretconfig" .. i .. "_2", { bgColor = Helper.color.transparent }) 
                        row[5]:setColSpan(9):createButton({ height = config.mapRowHeight }):setText(function () return C.IsWeaponArmed(turret) and ReadText(1001, 8631) or ReadText(1001, 8632) end, { halign = "center" }) 
                        row[5].handlers.onClick = function () return C.SetWeaponArmed(turret, not C.IsWeaponArmed(turret)) end 
                    end 
 
                    for i, group in ipairs(menu.turretgroups) do 
                        inputtable:addEmptyRow(config.mapRowHeight / 2) 
 
                        local name = ReadText(1001, 8023) .. " " .. i .. ((group.currentmacro ~= "") and (" (" .. menu.getSlotSizeText(group.slotsize) .. " " .. GetMacroData(group.currentmacro, "shortname") .. ")") or "") 
 
                        local row = inputtable:addRow("info_turretgroupconfig" .. i, { bgColor = Helper.color.transparent }) 
                        row[2]:setColSpan(3):createText(name, { color = (group.operational > 0) and Helper.color.white or Helper.color.red }) 
                        row[5]:setColSpan(9):createDropDown(turretmodes, { startOption = function () return menu.getDropDownTurretModeOption(inputobject, group.context, group.path, group.group) end, active = group.operational > 0 }) 
                        row[5].handlers.onDropDownConfirmed = function(_, newturretmode) menu.noupdate = false; C.SetTurretGroupMode2(inputobject, group.context, group.path, group.group, newturretmode) end 
                        row[5].handlers.onDropDownActivated = function () menu.noupdate = true end 
                        dropdownCount = dropdownCount + 1 
                        if dropdownCount == 14 then 
                            inputtable.properties.maxVisibleHeight = inputtable:getFullHeight() 
                        end 
 
                        local row = inputtable:addRow("info_turretgroupconfig" .. i .. "_2", { bgColor = Helper.color.transparent }) 
                        row[5]:setColSpan(9):createButton({ height = config.mapRowHeight }):setText(function () return C.IsTurretGroupArmed(inputobject, group.context, group.path, group.group) and ReadText(1001, 8631) or ReadText(1001, 8632) end, { halign = "center" }) 
                        row[5].handlers.onClick = function () return C.SetTurretGroupArmed(inputobject, group.context, group.path, group.group, not C.IsTurretGroupArmed(inputobject, group.context, group.path, group.group)) end 
                    end 
                elseif mode == "station" then 
                    local turretmodes = { 
                        [1] = { id = "defend",          text = ReadText(1001, 8613),    icon = "",  displayremoveoption = false }, 
                        [2] = { id = "attackenemies",   text = ReadText(1001, 8614),    icon = "",  displayremoveoption = false }, 
                        [3] = { id = "attackcapital",   text = ReadText(1001, 8624),    icon = "",  displayremoveoption = false }, 
                        [4] = { id = "attackfighters",  text = ReadText(1001, 8625),    icon = "",  displayremoveoption = false }, 
                        [5] = { id = "missiledefence",  text = ReadText(1001, 8615),    icon = "",  displayremoveoption = false }, 
                    } 
 
                    if hasnormalturrets then 
                        -- non-missile 
                        local row = inputtable:addRow("info_turretconfig", { bgColor = Helper.color.transparent }) 
                        row[2]:setColSpan(3):createText(ReadText(1001, 8397)) 
                        row[5]:setColSpan(9):createDropDown(turretmodes, { startOption = function () return menu.getDropDownTurretModeOption(inputobject, "all", false) end, active = hasoperationalnormalturrets, mouseOverText = (not hasoperationalnormalturrets) and ReadText(1026, 3235) or nil }) 
                        row[5].handlers.onDropDownConfirmed = function(_, newturretmode) menu.noupdate = false; C.SetAllNonMissileTurretModes(inputobject, newturretmode) end 
                        row[5].handlers.onDropDownActivated = function () menu.noupdate = true end 
 
                        local row = inputtable:addRow("info_turretconfig_2", { bgColor = Helper.color.transparent }) 
                        row[5]:setColSpan(9):createButton({ height = config.mapRowHeight }):setText(function () return menu.areTurretsArmed(inputobject, false) and ReadText(1001, 8631) or ReadText(1001, 8632) end, { halign = "center" }) 
                        row[5].handlers.onClick = function () return C.SetAllNonMissileTurretsArmed(inputobject, not menu.areTurretsArmed(inputobject, false)) end 
                    end 
                    if hasmissileturrets then 
                        -- missile 
                        local row = inputtable:addRow("info_turretconfig_missile", { bgColor = Helper.color.transparent }) 
                        row[2]:setColSpan(3):createText(ReadText(1001, 9031)) 
                        row[5]:setColSpan(9):createDropDown(turretmodes, { startOption = function () return menu.getDropDownTurretModeOption(inputobject, "all", true) end, active = hasoperationalmissileturrets, mouseOverText = (not hasoperationalnormalturrets) and ReadText(1026, 3235) or nil }) 
                        row[5].handlers.onDropDownConfirmed = function(_, newturretmode) menu.noupdate = false; C.SetAllMissileTurretModes(inputobject, newturretmode) end 
                        row[5].handlers.onDropDownActivated = function () menu.noupdate = true end 
 
                        local row = inputtable:addRow("info_turretconfig_missile_2", { bgColor = Helper.color.transparent }) 
                        row[5]:setColSpan(9):createButton({ height = config.mapRowHeight }):setText(function () return menu.areTurretsArmed(inputobject, true) and ReadText(1001, 8631) or ReadText(1001, 8632) end, { halign = "center" }) 
                        row[5].handlers.onClick = function () return C.SetAllMissileTurretsArmed(inputobject, not menu.areTurretsArmed(inputobject, true)) end 
                    end 
                end 
            end 
        end 
        -- drones 
        local isplayeroccupiedship = menu.infoSubmenuObject == ConvertStringTo64Bit(tostring(C.GetPlayerOccupiedShipID())) 
 
        local unitstoragetable = C.IsComponentClass(object64, "defensible") and GetUnitStorageData(object64) or { stored = 0, capacity = 0 } 
        local locunitcapacity = Helper.unlockInfo(unitinfo_capacity, tostring(unitstoragetable.capacity)) 
        local locunitcount = Helper.unlockInfo(unitinfo_amount, tostring(unitstoragetable.stored)) 
        menu.drones = {} 
        local dronetypes = { 
            { id = "orecollector",  name = ReadText(20214, 500),    displayonly = true }, 
            { id = "gascollector",  name = ReadText(20214, 400),    displayonly = true }, 
            { id = "defence",       name = ReadText(20214, 300) }, 
            { id = "transport",     name = ReadText(20214, 900) }, 
            { id = "build",         name = ReadText(20214, 1000),   skipmode = true }, 
            { id = "repair",        name = ReadText(20214, 1100),   skipmode = true }, 
        } 
        for _, dronetype in ipairs(dronetypes) do 
            if C.GetNumStoredUnits(inputobject, dronetype.id, false) > 0 then 
                local entry 
                if not dronetype.skipmode then 
                    entry = { 
                        type = dronetype.id, 
                        name = dronetype.name, 
                        current = ffi.string(C.GetCurrentDroneMode(inputobject, dronetype.id)), 
                        modes = {}, 
                        displayonly = dronetype.displayonly, 
                    } 
                    local n = C.GetNumDroneModes(inputobject, dronetype.id) 
                    local buf = ffi.new("DroneModeInfo[?]", n) 
                    n = C.GetDroneModes(buf, n, inputobject, dronetype.id) 
                    for i = 0, n - 1 do 
                        local id = ffi.string(buf[i].id) 
                        if (id ~= "trade") or (id == entry.current) then 
                            table.insert(entry.modes, { id = id, text = ffi.string(buf[i].name), icon = "", displayremoveoption = false }) 
                        end 
                    end 
                else 
                    entry = { 
                        type = dronetype.id, 
                        name = dronetype.name, 
                    } 
                end 
                table.insert(menu.drones, entry) 
            end 
        end 
        if unitstoragetable.capacity > 0 then 
            -- title 
            local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
            row[1]:setColSpan(13):createText(ReadText(1001, 8619), Helper.headerRowCenteredProperties) 
            -- capcity 
            local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
            row[2]:createText(ReadText(1001, 8393)) 
            row[8]:setColSpan(6):createText(locunitcount .. " / " .. locunitcapacity, { halign = "right" }) 
            -- drones 
            if unitinfo_details then 
                for i, entry in ipairs(menu.drones) do 
                    if i ~= 1 then 
                        inputtable:addEmptyRow(config.mapRowHeight / 2) 
                    end 
                    local hasmodes = (mode == "ship") and entry.current 
                    -- drone name, amount and mode 
                    local row1 = inputtable:addRow("drone_config", { bgColor = Helper.color.transparent }) 
                    row1[2]:createText(entry.name) 
                    row1[3]:setColSpan(isplayerowned and 2 or 11):createText(function () return Helper.unlockInfo(unitinfo_amount, C.GetNumStoredUnits(inputobject, entry.type, false)) end, { halign = isplayerowned and "left" or "right" }) 
                    -- active and armed status 
                    local row2 = inputtable:addRow("drone_config", { bgColor = Helper.color.transparent }) 
                    row2[2]:createText("    " .. ReadText(1001, 11229), { color = hasmodes and function () return C.IsDroneTypeArmed(inputobject, entry.type) and Helper.color.white or Helper.color.grey end or nil }) 
                    row2[3]:setColSpan(isplayerowned and 2 or 11):createText(function () return Helper.unlockInfo(unitinfo_amount, C.GetNumUnavailableUnits(inputobject, entry.type)) end, { halign = isplayerowned and "left" or "right", color = hasmodes and function () return C.IsDroneTypeBlocked(inputobject, entry.type) and Helper.color.warningorange or (C.IsDroneTypeArmed(inputobject, entry.type) and Helper.color.white or Helper.color.grey) end or nil }) 
                     
                    -- drone mode support - disabled for mining drones, to avoid conflicts with order defined drone behaviour 
                    if hasmodes then 
                        local isblocked = C.IsDroneTypeBlocked(inputobject, entry.type) 
                        if isplayerowned then 
                            local active = (isplayeroccupiedship or (not entry.displayonly)) and (not isblocked) 
                            local mouseovertext = "" 
                            if isblocked then 
                                mouseovertext = ReadText(1026, 3229) 
                            elseif (not isplayeroccupiedship) and entry.displayonly then 
                                mouseovertext = ReadText(1026, 3230) 
                            end 
 
                            row1[5]:setColSpan(9):createDropDown(entry.modes, { startOption = function () return ffi.string(C.GetCurrentDroneMode(inputobject, entry.type)) end, active = active, mouseOverText = mouseovertext }) 
                            row1[5].handlers.onDropDownConfirmed = function (_, newdronemode) C.SetDroneMode(inputobject, entry.type, newdronemode) end 
 
                            row2[5]:setColSpan(9):createButton({ active = active, mouseOverText = mouseovertext, height = config.mapRowHeight }):setText(function () return C.IsDroneTypeArmed(inputobject, entry.type) and ReadText(1001, 8622) or ReadText(1001, 8623) end, { halign = "center" }) 
                            row2[5].handlers.onClick = function () return C.SetDroneTypeArmed(inputobject, entry.type, not C.IsDroneTypeArmed(inputobject, entry.type)) end 
                        end 
                    end 
                end 
            end 
        end 
        -- subordinates 
        if isplayerowned then 
            if C.IsComponentClass(inputobject, "controllable") then 
                local subordinates = GetSubordinates(inputobject) 
                local groups = {} 
                local usedassignments = {} 
                for _, subordinate in ipairs(subordinates) do 
                    local purpose, shiptype = GetComponentData(subordinate, "primarypurpose", "shiptype") 
                    local group = GetComponentData(subordinate, "subordinategroup") 
                    if group and group > 0 then 
                        if groups[group] then 
                            table.insert(groups[group].subordinates, subordinate) 
                            if shiptype == "resupplier" then 
                                groups[group].numassignableresupplyships = groups[group].numassignableresupplyships + 1 
                            end 
                            if purpose == "mine" then 
                                groups[group].numassignableminingships = groups[group].numassignableminingships + 1 
                            end 
                        else 
                            local assignment = ffi.string(C.GetSubordinateGroupAssignment(inputobject, group)) 
                            usedassignments[assignment] = group 
                            groups[group] = { assignment = assignment, subordinates = { subordinate }, numassignableresupplyships = (shiptype == "resupplier") and 1 or 0, numassignableminingships = (purpose == "mine") and 1 or 0 } 
                        end 
                    end 
                end 
 
                if #subordinates > 0 then 
                    -- title 
                    local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
                    row[1]:setColSpan(13):createText(ReadText(1001, 8626), Helper.headerRowCenteredProperties) 
 
                    local isstation = C.IsComponentClass(inputobject, "station") 
                    for i = 1, isstation and 4 or 10 do 
                        if groups[i] then 
                            local supplyactive = (groups[i].numassignableresupplyships == #groups[i].subordinates) and ((not usedassignments["supplyfleet"]) or (usedassignments["supplyfleet"] == i)) 
                            local subordinateassignments = { 
                                [1] = { id = "defence",         text = ReadText(20208, 40301),  icon = "",  displayremoveoption = false }, 
                                [2] = { id = "supplyfleet",     text = ReadText(20208, 40701),  icon = "",  displayremoveoption = false, active = supplyactive, mouseovertext = supplyactive and "" or ReadText(1026, 8601) }, 
                            } 
                            if GetComponentData(inputobject, "shiptype") == "resupplier" then 
                                table.insert(subordinateassignments, { id = "trade",            text = ReadText(20208, 40101),  icon = "",  displayremoveoption = false }) 
                            end 
 
                            if isstation then 
                                local miningactive = (groups[i].numassignableminingships == #groups[i].subordinates) and ((not usedassignments["mining"]) or (usedassignments["mining"] == i)) 
                                table.insert(subordinateassignments, { id = "mining", text = ReadText(20208, 40201), icon = "", displayremoveoption = false, active = miningactive, mouseovertext = miningactive and "" or ReadText(1026, 8602) }) 
                                local tradeactive = ((not usedassignments["trade"]) or (usedassignments["trade"] == i)) 
                                table.insert(subordinateassignments, { id = "trade", text = ReadText(20208, 40101), icon = "", displayremoveoption = false, active = tradeactive, mouseovertext = tradeactive and ((groups[i].numassignableminingships > 0) and (Helper.convertColorToText(Helper.color.warningorange) .. ReadText(1026, 8607)) or "") or ReadText(1026, 7840) }) 
                                local tradeforbuildstorageactive = (groups[i].numassignableminingships == 0) and ((not usedassignments["tradeforbuildstorage"]) or (usedassignments["tradeforbuildstorage"] == i)) 
                                table.insert(subordinateassignments, { id = "tradeforbuildstorage", text = ReadText(20208, 40801), icon = "", displayremoveoption = false, active = tradeforbuildstorageactive, mouseovertext = tradeforbuildstorageactive and "" or ReadText(1026, 8603) }) 
                            elseif C.IsComponentClass(inputobject, "ship") then 
                                table.insert(subordinateassignments, { id = "attack", text = ReadText(20208, 40901), icon = "", displayremoveoption = false }) 
                                table.insert(subordinateassignments, { id = "interception", text = ReadText(20208, 41001), icon = "", displayremoveoption = false }) 
                                table.insert(subordinateassignments, { id = "follow", text = ReadText(20208, 41301), icon = "", displayremoveoption = false }) 
                                local active = true 
                                local mouseovertext = "" 
                                local buf = ffi.new("Order") 
                                if not C.GetDefaultOrder(buf, inputobject) then 
                                    active = false 
                                    mouseovertext = ReadText(1026, 8606) 
                                end 
                                table.insert(subordinateassignments, { id = "assist", text = ReadText(20208, 41201), icon = "", displayremoveoption = false, active = active, mouseovertext = mouseovertext }) 
                            end 
 
                            local isdockingpossible = false 
                            for _, subordinate in ipairs(groups[i].subordinates) do 
                                if IsDockingPossible(subordinate, inputobject) then 
                                    isdockingpossible = true 
                                    break 
                                end 
                            end 
                            local active = true 
                            local mouseovertext = "" 
                            if not GetComponentData(inputobject, "hasshipdockingbays") then 
                                active = false 
                                mouseovertext = ReadText(1026, 8604) 
                            elseif not isdockingpossible then 
                                active = false 
                                mouseovertext = ReadText(1026, 8605) 
                            end 
 
                            local row = inputtable:addRow("subordinate_config", { bgColor = Helper.color.transparent }) 
                            row[2]:createText(function () menu.updateSubordinateGroupInfo(inputobject); return ReadText(20401, i) .. (menu.subordinategroups[i] and (" (" .. ((not C.ShouldSubordinateGroupDockAtCommander(inputobject, i)) and ((#menu.subordinategroups[i].subordinates - menu.subordinategroups[i].numdockedatcommander) .. "/") or "") .. #menu.subordinategroups[i].subordinates ..")") or "") end, { color = isblocked and Helper.color.warningorange or nil }) 
                            row[3]:setColSpan(11):createDropDown(subordinateassignments, { startOption = function () menu.updateSubordinateGroupInfo(inputobject); return menu.subordinategroups[i] and menu.subordinategroups[i].assignment or "" end }) 
                            row[3].handlers.onDropDownActivated = function () menu.noupdate = true end 
                            row[3].handlers.onDropDownConfirmed = function (_, newassignment) C.SetSubordinateGroupAssignment(inputobject, i, newassignment); menu.noupdate = false end 
                            local row = inputtable:addRow("subordinate_config", { bgColor = Helper.color.transparent }) 
                            row[3]:setColSpan(11):createButton({ active = active, mouseOverText = mouseovertext, height = config.mapRowHeight }):setText(function () return C.ShouldSubordinateGroupDockAtCommander(inputobject, i) and ReadText(1001, 8630) or ReadText(1001, 8629) end, { halign = "center" }) 
                            row[3].handlers.onClick = function () return C.SetSubordinateGroupDockAtCommander(inputobject, i, not C.ShouldSubordinateGroupDockAtCommander(inputobject, i)) end 
                        end 
                    end 
                end 
            end 
        end 
        -- ammunition 
        local nummissiletypes = C.GetNumAllMissiles(inputobject) 
        local missilestoragetable = ffi.new("AmmoData[?]", nummissiletypes) 
        nummissiletypes = C.GetAllMissiles(missilestoragetable, nummissiletypes, inputobject) 
        local totalnummissiles = 0 
        for i = 0, nummissiletypes - 1 do 
            totalnummissiles = totalnummissiles + missilestoragetable[i].amount 
        end 
        local missilecapacity = 0 
        if C.IsComponentClass(inputobject, "defensible") then 
            missilecapacity = GetComponentData(inputobject, "missilecapacity") 
        end 
        local locmissilecapacity = Helper.unlockInfo(defenceinfo_low, tostring(missilecapacity)) 
        local locnummissiles = Helper.unlockInfo(defenceinfo_high, tostring(totalnummissiles)) 
        if totalnummissiles > 0 then 
            -- title 
            local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
            row[1]:setColSpan(12):createText(ReadText(1001, 2800), Helper.headerRowCenteredProperties) -- Ammunition 
            -- capcity 
            local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
            row[2]:createText(ReadText(1001, 8393)) 
            row[8]:setColSpan(6):createText(locnummissiles .. " / " .. locmissilecapacity, { halign = "right" }) 
            if defenceinfo_high then 
                for i = 0, nummissiletypes - 1 do 
                    local macro = ffi.string(missilestoragetable[i].macro) 
                    local row = inputtable:addRow({ "info_weapons", macro, inputobject }, { bgColor = Helper.color.transparent }) 
                    row[2]:createText(GetMacroData(macro, "name")) 
                    row[8]:setColSpan(6):createText(tostring(missilestoragetable[i].amount), { halign = "right" }) 
                end 
            end 
        end 
    end 
    if mode == "ship" then 
        -- countermeasures 
        local numcountermeasuretypes = C.GetNumAllCountermeasures(inputobject) 
        local countermeasurestoragetable = ffi.new("AmmoData[?]", numcountermeasuretypes) 
        numcountermeasuretypes = C.GetAllCountermeasures(countermeasurestoragetable, numcountermeasuretypes, inputobject) 
        local totalnumcountermeasures = 0 
        for i = 0, numcountermeasuretypes - 1 do 
            totalnumcountermeasures = totalnumcountermeasures + countermeasurestoragetable[i].amount 
        end 
        local countermeasurecapacity = GetComponentData(object64, "countermeasurecapacity") 
        local loccountermeasurecapacity = Helper.unlockInfo(defenceinfo_low, tostring(countermeasurecapacity)) 
        local locnumcountermeasures = Helper.unlockInfo(defenceinfo_high, tostring(totalnumcountermeasures)) 
        if totalnumcountermeasures > 0 then 
            -- title 
            local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
            row[1]:setColSpan(13):createText(ReadText(20215, 1701), Helper.headerRowCenteredProperties) -- Countermeasures 
            -- capcity 
            local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
            row[2]:createText(ReadText(1001, 8393)) 
            row[8]:setColSpan(6):createText(locnumcountermeasures .. " / " .. loccountermeasurecapacity, { halign = "right" }) 
            if defenceinfo_high then 
                for i = 0, numcountermeasuretypes - 1 do 
                    local row = inputtable:addRow(true, { bgColor = Helper.color.transparent, interactive = false }) 
                    row[2]:createText(GetMacroData(ffi.string(countermeasurestoragetable[i].macro), "name")) 
                    row[8]:setColSpan(6):createText(tostring(countermeasurestoragetable[i].amount), { halign = "right" }) 
                end 
            end 
        end 
        -- deployables 
        local consumables = { 
            { id = "satellite",     type = "civilian",  getnum = C.GetNumAllSatellites,     getdata = C.GetAllSatellites,       callback = C.LaunchSatellite }, 
            { id = "navbeacon",     type = "civilian",  getnum = C.GetNumAllNavBeacons,     getdata = C.GetAllNavBeacons,       callback = C.LaunchNavBeacon }, 
            { id = "resourceprobe", type = "civilian",  getnum = C.GetNumAllResourceProbes, getdata = C.GetAllResourceProbes,   callback = C.LaunchResourceProbe }, 
            { id = "lasertower",    type = "military",  getnum = C.GetNumAllLaserTowers,    getdata = C.GetAllLaserTowers,      callback = C.LaunchLaserTower }, 
            { id = "mine",          type = "military",  getnum = C.GetNumAllMines,          getdata = C.GetAllMines,            callback = C.LaunchMine }, 
        } 
        local totalnumdeployables = 0 
        local consumabledata = {} 
        for _, entry in ipairs(consumables) do 
            local n = entry.getnum(inputobject) 
            local buf = ffi.new("AmmoData[?]", n) 
            n = entry.getdata(buf, n, inputobject) 
            consumabledata[entry.id] = {} 
            for i = 0, n - 1 do 
                table.insert(consumabledata[entry.id], { macro = ffi.string(buf[i].macro), name = GetMacroData(ffi.string(buf[i].macro), "name"), amount = buf[i].amount, capacity = buf[i].capacity }) 
                totalnumdeployables = totalnumdeployables + buf[i].amount 
            end 
        end 
        local deployablecapacity = C.GetDefensibleDeployableCapacity(inputobject) 
        local printednumdeployables = Helper.unlockInfo(defenceinfo_low, tostring(totalnumdeployables)) 
        local printeddeployablecapacity = Helper.unlockInfo(defenceinfo_low, tostring(deployablecapacity)) 
        if totalnumdeployables > 0 then 
            -- title 
            local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
            row[1]:setColSpan(13):createText(ReadText(1001, 1332), Helper.headerRowCenteredProperties) -- Deployables 
            -- capcity 
            local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
            row[2]:createText(ReadText(1001, 8393)) 
            row[8]:setColSpan(6):createText(printednumdeployables .. " / " .. printeddeployablecapacity, { halign = "right" }) 
            if defenceinfo_high then 
                for _, entry in ipairs(consumables) do 
                    if #consumabledata[entry.id] > 0 then 
                        for _, data in ipairs(consumabledata[entry.id]) do 
                            local row = inputtable:addRow({ "info_deploy", data.macro, inputobject }, { bgColor = Helper.color.transparent }) 
                            row[2]:createText(data.name) 
                            row[8]:setColSpan(6):createText(data.amount, { halign = "right" }) 
                        end 
                    end 
                end 
                if isplayerowned then 
                    -- deploy 
                    local row = inputtable:addRow("info_deploy", { bgColor = Helper.color.transparent }) 
                    row[3]:setColSpan(11):createButton({ height = config.mapRowHeight, active = function () return next(menu.infoTablePersistentData[instance].macrostolaunch) ~= nil end }):setText(ReadText(1001, 8390), { halign = "center" }) 
                    row[3].handlers.onClick = function () return menu.buttonDeploy(instance) end 
                end 
            end 
        end 
    end 
    if (mode == "ship") or (mode == "station") then 
        -- loadout 
        if (#loadout.component.weapon > 0) or (#loadout.component.turret > 0) or (#loadout.component.shield > 0) or (#loadout.component.engine > 0) or (#loadout.macro.thruster > 0) or (#loadout.ware.software > 0) then 
            if defenceinfo_high then 
                local hasshown = false 
                -- title 
                local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
                row[1]:setColSpan(13):createText(ReadText(1001, 9413), Helper.headerRowCenteredProperties) -- Loadout 
                local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
                row[2]:setColSpan(5):createText(ReadText(1001, 7935), { font = Helper.standardFontBold }) 
                row[7]:setColSpan(4):createText(ReadText(1001, 1311), { font = Helper.standardFontBold, halign = "right" }) 
                row[11]:setColSpan(3):createText(ReadText(1001, 12), { font = Helper.standardFontBold, halign = "right" }) 
 
                inputtable:addEmptyRow(config.mapRowHeight / 2) 
 
                local macroequipment = { 
                    { type = "weapon", encyclopedia = "info_weapon" }, 
                    { type = "turret", encyclopedia = "info_weapon" }, 
                    { type = "shield", encyclopedia = "info_equipment" }, 
                    { type = "engine", encyclopedia = "info_equipment" }, 
                } 
                for _, entry in ipairs(macroequipment) do 
                    if #loadout.component[entry.type] > 0 then 
                        if hasshown then 
                            inputtable:addEmptyRow(config.mapRowHeight / 2) 
                        end 
                        hasshown = true 
                        local locmacros = menu.infoCombineLoadoutComponents(loadout.component[entry.type]) 
                        for macro, data in pairs(locmacros) do 
                            local row = inputtable:addRow({ entry.encyclopedia, macro, inputobject }, { bgColor = Helper.color.transparent }) 
                            row[2]:setColSpan(5):createText(GetMacroData(macro, "name")) 
                            row[7]:setColSpan(4):createText(data.count .. " / " .. data.count + data.construction, { halign = "right" }) 
                            local shieldpercent = data.shieldpercent 
                            local hullpercent = data.hullpercent 
                            if data.count > 0 then 
                                shieldpercent = shieldpercent / data.count 
                                hullpercent = hullpercent / data.count 
                            end 
                            row[11]:setColSpan(3):createShieldHullBar(shieldpercent, hullpercent, { scaling = false, width = row[11]:getColSpanWidth() / 2, x = row[11]:getColSpanWidth() / 4 }) 
 
                            AddKnownItem(GetMacroData(macro, "infolibrary"), macro) 
                        end 
                    end 
                end 
 
                if #loadout.macro.thruster > 0 then 
                    if hasshown then 
                        inputtable:addEmptyRow(config.mapRowHeight / 2) 
                    end 
                    hasshown = true 
                    -- ships normally only have 1 set of thrusters. in case a ship has more, this will list all of them. 
                    for i, val in ipairs(loadout.macro.thruster) do 
                        local row = inputtable:addRow({ "info_equipment", macro, inputobject }, { bgColor = Helper.color.transparent }) 
                        row[2]:setColSpan(12):createText(GetMacroData(val, "name")) 
 
                        AddKnownItem(GetMacroData(val, "infolibrary"), val) 
                    end 
                end 
                if #loadout.ware.software > 0 then 
                    if hasshown then 
                        inputtable:addEmptyRow(config.mapRowHeight / 2) 
                    end 
                    hasshown = true 
                    for i, val in ipairs(loadout.ware.software) do 
                        local row = inputtable:addRow({ "info_software", val, inputobject }, { bgColor = Helper.color.transparent }) 
                        row[2]:setColSpan(12):createText(GetWareData(val, "name")) 
 
                        AddKnownItem("software", val) 
                    end 
                end 
            else 
                local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
                row[2]:setColSpan(12):createText(ReadText(1001, 3210)) 
            end 
        end 
    end 
    if mode == "ship" then 
        -- mods 
        -- title 
        local row = inputtable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor }) 
        row[1]:setColSpan(13):createText(ReadText(1001, 8031), Helper.headerRowCenteredProperties) 
        if equipment_mods and GetComponentData(object64, "hasanymod") then 
            local hasshown = false 
            -- chassis 
            local hasinstalledmod, installedmod = Helper.getInstalledModInfo("ship", inputobject) 
            if hasinstalledmod then 
                if hasshown then 
                    inputtable:addEmptyRow(config.mapRowHeight / 2) 
                end 
                hasshown = true 
                row = menu.addEquipmentModInfoRow(inputtable, "ship", installedmod, ReadText(1001, 8008)) 
            end 
            -- weapon 
            for i, weapon in ipairs(loadout.component.weapon) do 
                local hasinstalledmod, installedmod = Helper.getInstalledModInfo("weapon", weapon) 
                if hasinstalledmod then 
                    if hasshown then 
                        inputtable:addEmptyRow(config.mapRowHeight / 2) 
                    end 
                    hasshown = true 
                    row = menu.addEquipmentModInfoRow(inputtable, "weapon", installedmod, ffi.string(C.GetComponentName(weapon))) 
                end 
            end 
            -- turret 
            for i, turret in ipairs(loadout.component.turret) do 
                local hasinstalledmod, installedmod = Helper.getInstalledModInfo("turret", turret) 
                if hasinstalledmod then 
                    if hasshown then 
                        inputtable:addEmptyRow(config.mapRowHeight / 2) 
                    end 
                    hasshown = true 
                    row = menu.addEquipmentModInfoRow(inputtable, "weapon", installedmod, ffi.string(C.GetComponentName(turret))) 
                end 
            end 
            -- shield 
            local shieldgroups = {} 
            local n = C.GetNumShieldGroups(inputobject) 
            local buf = ffi.new("ShieldGroup[?]", n) 
            n = C.GetShieldGroups(buf, n, inputobject) 
            for i = 0, n - 1 do 
                local entry = {} 
                entry.context = buf[i].context 
                entry.group = ffi.string(buf[i].group) 
                entry.component = buf[i].component 
 
                table.insert(shieldgroups, entry) 
            end 
            for i, entry in ipairs(shieldgroups) do 
                if (entry.context == inputobject) and (entry.group == "") then 
                    shieldgroups.hasMainGroup = true 
                    -- force maingroup to first index 
                    table.insert(shieldgroups, 1, entry) 
                    table.remove(shieldgroups, i + 1) 
                    break 
                end 
            end 
            for i, shieldgroupdata in ipairs(shieldgroups) do 
                local hasinstalledmod, installedmod = Helper.getInstalledModInfo("shield", inputobject, shieldgroupdata.context, shieldgroupdata.group) 
                if hasinstalledmod then 
                    local name = GetMacroData(GetComponentData(ConvertStringTo64Bit(tostring(shieldgroupdata.component)), "macro"), "name") 
                    if (i == 1) and shieldgroups.hasMainGroup then 
                        name = ReadText(1001, 8044) 
                    end 
                    if hasshown then 
                        inputtable:addEmptyRow(config.mapRowHeight / 2) 
                    end 
                    hasshown = true 
                    row = menu.addEquipmentModInfoRow(inputtable, "shield", installedmod, name) 
                end 
            end 
            -- engine 
            local hasinstalledmod, installedmod = Helper.getInstalledModInfo("engine", inputobject) 
            if hasinstalledmod then 
                if hasshown then 
                    inputtable:addEmptyRow(config.mapRowHeight / 2) 
                end 
                hasshown = true 
                row = menu.addEquipmentModInfoRow(inputtable, "engine", installedmod, ffi.string(C.GetComponentName(loadout.component.engine[1]))) 
            end 
        else 
            local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
            row[2]:setColSpan(12):createText(Helper.unlockInfo(equipment_mods, ReadText(1001, 8394))) 
        end 
    end 
    if mode == "none" then 
        local row = inputtable:addRow(false, { bgColor = Helper.color.unselectable }) 
        row[2]:setColSpan(12):createText(ReadText(1001, 6526)) 
    end 
end 
 
init()