local eGestVeh = {
    DoorState = {
		FrontLeft = false,
		FrontRight = false,
		BackLeft = false,
		BackRight = false,
        All = false,
		Hood = false,
		Trunk = false
	},
	DoorIndex = 1,
	DoorList = {"Avant Gauche","Avant Droite","Arrière Gauche","Arrière Droite","Toutes les portes"},
    WindowIndex = 1,
    WindowList = {"Avant Gauche","Avant Droite","Arrière Gauche","Arrière Droite","Toutes les fenêtres"},

    PlaceIndex = 1,
    PlaceList = {"Conducteur","Passager","Arrière Gauche","Arrière Droit"},

    Limitateur = 1,
    StatusCapot = "~r~Fermer",
    StatusCoffre = "~r~Fermer",
}

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

function coolcoolmec(time)
    cooldown = true
    Citizen.SetTimeout(time,function()
        cooldown = false
    end)
end

function GetEtatMoteur()
    local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)

    if GetIsVehicleEngineRunning(plyVeh) then
        StatusMoteur = "~g~ON"
    elseif not GetIsVehicleEngineRunning(plyVeh) then
        StatusMoteur = "~r~OFF"
    end
end

function GetEtatPortes()
    local plyVeh = GetVehiclePedIsIn(PlayerPedId(), false)
    local locked = GetVehicleDoorLockStatus(plyVeh)
    if locked == 1 or locked == 0 then -- if unlocked
        StatusPortes = "~g~Ouvert"
    elseif locked == 2 then -- if locked
        StatusPortes = "~r~Fermer"
    end
end


function MenuGestionVeh()
    local main = RageUI.CreateMenu(Config.MenuName, Config.SubName)
    if Config.BanniereCouleur == true then 
        main:SetRectangleBanner(Config.ColorMenu.R, Config.ColorMenu.G, Config.ColorMenu.B, Config.ColorMenu.O)
    end
    
        RageUI.Visible(main, not RageUI.Visible(main))
        while main do
            Citizen.Wait(0)
            RageUI.IsVisible(main, true, true, true, function()  
                local Ped = PlayerPedId()
                local GetSourcevehicle = GetVehiclePedIsIn(Ped, false)
                local Vengine = GetVehicleEngineHealth(GetSourcevehicle) / 10
                local Plaque = GetVehicleNumberPlateText(GetSourcevehicle)
                local essence = GetVehicleFuelLevel(GetSourcevehicle)

                if Config.InfoSeparator == true then
                RageUI.Line()
                RageUI.Separator("Plaque d'immatriculation → ~b~" ..Plaque.. " ")
                RageUI.Separator("État du moteur~s~ →~b~ " ..math.floor(Vengine).. "% ~s~/ Essence → ~b~ "..math.floor(essence).. "%")
                RageUI.Line()
                end

                if Config.StatusPorte == true then
                RageUI.ButtonWithStyle("→ Status des portes", nil, {RightLabel = "→ "..StatusPortes.. " ~s~←"}, not cooldown,function(Hovered, Active, Selected)
                    if (Selected) then
                        local locked = GetVehicleDoorLockStatus(GetSourcevehicle)
                        if locked == 1 or locked == 0 then -- if unlocked
                            SetVehicleDoorsLocked(GetSourcevehicle, 2)
                            PlayVehicleDoorCloseSound(GetSourcevehicle, 1)
                            RageUI.Popup({ message = "~r~Vous avez fermé le véhicule"})
                        elseif locked == 2 then -- if locked
                            SetVehicleDoorsLocked(GetSourcevehicle, 1)
                            PlayVehicleDoorOpenSound(GetSourcevehicle, 0)
                            RageUI.Popup({ message = "~g~Vous avez ouvert le véhicule"})
                        end
                        GetEtatPortes()
                        coolcoolmec(Config.Cooldown)
                    end
                end)
                end
                
                if Config.StatusMoteur == true then
                RageUI.ButtonWithStyle("→ Status du moteur", nil, {RightLabel = "→ "..StatusMoteur.. " ~s~←"}, not cooldown,function(Hovered, Active, Selected)
                    if (Selected) then
                        if GetIsVehicleEngineRunning(GetSourcevehicle) then
                            SetVehicleEngineOn(GetSourcevehicle, false, false, true)
                            SetVehicleUndriveable(GetSourcevehicle, true)
                            StatusMoteur = "~r~OFF"
                        elseif not GetIsVehicleEngineRunning(GetSourcevehicle) then
                            SetVehicleEngineOn(GetSourcevehicle, true, false, true)
                            SetVehicleUndriveable(GetSourcevehicle, false)
                            StatusMoteur = "~g~ON"
                        end
                        coolcoolmec(Config.Cooldown)
                    end
                end)
                end
    
                if Config.StatusCapot == true then
                RageUI.ButtonWithStyle("→ Status du Capot", nil, {RightLabel = "→ "..eGestVeh.StatusCapot.. " ~s~←"}, not cooldown,function(Hovered, Active, Selected)
                    if (Selected) then
                        if not eGestVeh.DoorState.Hood then
                            eGestVeh.DoorState.Hood = true
                            SetVehicleDoorOpen(GetSourcevehicle, 4, false, false)
                            eGestVeh.StatusCapot = "~g~Ouvert"
                        elseif eGestVeh.DoorState.Hood then
                            eGestVeh.DoorState.Hood = false
                            SetVehicleDoorShut(GetSourcevehicle, 4, false, false)
                            eGestVeh.StatusCapot = "~r~Fermer"
                        end
                        coolcoolmec(Config.Cooldown)
                    end
                end)
                end

                if Config.StatusCoffre == true then
                RageUI.ButtonWithStyle("→ Status du Coffre", nil, {RightLabel = "→ "..eGestVeh.StatusCoffre.. " ~s~←"}, not cooldown,function(Hovered, Active, Selected)
                    if (Selected) then
                        if not eGestVeh.DoorState.Trunk then
                            eGestVeh.DoorState.Trunk = true
                            SetVehicleDoorOpen(GetSourcevehicle, 5, false, false)
                            eGestVeh.StatusCoffre = "~g~Ouvert"
                        elseif eGestVeh.DoorState.Trunk then
                            eGestVeh.DoorState.Trunk = false
                            SetVehicleDoorShut(GetSourcevehicle, 5, false, false)
                            eGestVeh.StatusCoffre = "~r~Fermer"
                        end
                        coolcoolmec(Config.Cooldown)
                    end
                end)
                end

                if Config.GestionPorte == true then
                RageUI.List("→ Gestion portes", eGestVeh.DoorList, eGestVeh.DoorIndex, nil, {}, not cooldown,function(Hovered, Active, Selected, Index)
                    if (Selected) then
                        if Index == 1 then
                            if not eGestVeh.DoorState.FrontLeft then
                                eGestVeh.DoorState.FrontLeft = true
                                SetVehicleDoorOpen(GetSourcevehicle, 0, false, false)
                            elseif eGestVeh.DoorState.FrontLeft then
                                eGestVeh.DoorState.FrontLeft = false
                                SetVehicleDoorShut(GetSourcevehicle, 0, false, false)
                            end
                        elseif Index == 2 then
                            if not eGestVeh.DoorState.FrontRight then
                                eGestVeh.DoorState.FrontRight = true
                                SetVehicleDoorOpen(GetSourcevehicle, 1, false, false)
                            elseif eGestVeh.DoorState.FrontRight then
                                eGestVeh.DoorState.FrontRight = false
                                SetVehicleDoorShut(GetSourcevehicle, 1, false, false)
                            end
                        elseif Index == 3 then
                            if not eGestVeh.DoorState.BackLeft then
                                eGestVeh.DoorState.BackLeft = true
                                SetVehicleDoorOpen(GetSourcevehicle, 2, false, false)
                            elseif eGestVeh.DoorState.BackLeft then
                                eGestVeh.DoorState.BackLeft = false
                                SetVehicleDoorShut(GetSourcevehicle, 2, false, false)
                            end
                        elseif Index == 4 then
                            if not eGestVeh.DoorState.BackRight then
                                eGestVeh.DoorState.BackRight = true
                                SetVehicleDoorOpen(GetSourcevehicle, 3, false, false)
                            elseif eGestVeh.DoorState.BackRight then
                                eGestVeh.DoorState.BackRight = false
                                SetVehicleDoorShut(GetSourcevehicle, 3, false, false)
                            end
                        elseif Index == 5 then
                            if not eGestVeh.DoorState.All then
                                eGestVeh.DoorState.All = true
                                SetVehicleDoorOpen(GetSourcevehicle, 0, false, false)
                                SetVehicleDoorOpen(GetSourcevehicle, 1, false, false)
                                SetVehicleDoorOpen(GetSourcevehicle, 2, false, false)
                                SetVehicleDoorOpen(GetSourcevehicle, 3, false, false)
                            elseif eGestVeh.DoorState.All then
                                eGestVeh.DoorState.All = false
                                SetVehicleDoorShut(GetSourcevehicle, 0, false, false)
                                SetVehicleDoorShut(GetSourcevehicle, 1, false, false)
                                SetVehicleDoorShut(GetSourcevehicle, 2, false, false)
                                SetVehicleDoorShut(GetSourcevehicle, 3, false, false)
                            end
                        end
                        coolcoolmec(Config.Cooldown)
                    end
                    eGestVeh.DoorIndex = Index
                end)
                end

                if Config.GestionFenetre == true then
                RageUI.List('→ Gestion fenêtres', eGestVeh.WindowList, eGestVeh.WindowIndex, nil, {RightLabel = ""}, not cooldown, function(Hovered, Active, Selected, Index)
                    if (Selected) then 
                        if Index == 1 then
                            if not avantg then
                                avantg = true
                                RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 0) 
                            elseif avantg then
                                avantg = false
                                RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 0) 
                            end
                        end
                        if Index == 2 then
                            if not avantd then
                                avantd = true
                                RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 1) 
                            elseif avantd then
                                avantd = false
                                RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 1) 
                            end
                        end
                        if Index == 3 then
                            if not arrg then
                                arrg = true
                                RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 2) 
                            elseif arrg then
                                arrg = false
                                RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 2) 
                            end
                        end
                        if Index == 4 then
                            if not arrd then
                                arrd = true
                                RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 3) 
                            elseif arrd then
                                arrd = false
                                RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 3) 
                            end
                        end
                        if Index == 5 then
                            if not allw then
                                allw = true
                                RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 0)
                                RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 1) 
                                RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 2) 
                                RollDownWindow(GetVehiclePedIsIn(PlayerPedId()), 3) 
                            elseif allw then
                                allw = false
                                RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 0) 
                                RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 1) 
                                RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 2) 
                                RollUpWindow(GetVehiclePedIsIn(PlayerPedId()), 3) 
                            end
                        end
                        coolcoolmec(Config.Cooldown)
                    end
                    eGestVeh.WindowIndex = Index           
                end)
                end
        
                if Config.Limitateur == true then
                RageUI.List("→ Limitateur", {"Par défaut", "Personalisé", "50/KMH", "80/KMH", "130/KMH"}, eGestVeh.Limitateur, nil,{}, not cooldown, function(_, _, Selected, Index)
                    if (Selected) then
                        if Index == 1 then
                            SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 1000.0 / 3.6)
                            crtSpeed = "Aucun(e)"
                            RageUI.Popup({ message = "Limitateur par ~b~défaut" })
                        elseif Index == 2 then
                            local crtSpeed = KeyboardInput("Vitesse ?", "", 3)
                            if crtSpeed ~= nil and tonumber(crtSpeed) then
                                RageUI.Popup({ message = "Limitateur à ~b~" .. crtSpeed .. "/KMH" })
                                SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), crtSpeed / 3.6)
                            else
                                RageUI.Popup({ message = "Champ invalide" })
                            end
                        elseif Index == 3 then
                            RageUI.Popup({ message = "Limitateur à ~b~50/KMH" })
                            SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 50.0 / 3.6)
                        elseif Index == 4 then
                            RageUI.Popup({ message = "Limitateur à ~b~80/KMH" })
                            SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 80.0 / 3.6)
                        elseif Index == 5 then
                            RageUI.Popup({ message = "Limitateur à ~b~130/KMH" })
                            SetEntityMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), 130.0 / 3.6)
                        end
                        coolcoolmec(Config.Cooldown)
                    end
                    eGestVeh.Limitateur = Index
                end)
                end

                if Config.ChangerPlace == true then
                RageUI.List("→ Changer de place", eGestVeh.PlaceList, eGestVeh.PlaceIndex, nil, {}, not cooldown,function(Hovered, Active, Selected, Index)
                    if (Selected) then
                        CarSpeed = GetEntitySpeed(GetSourcevehicle) * 3.6 
                        if CarSpeed <= 50.0 then -- si la vitesse du véhicule est au dessus ou égale à 50 km/h
                            if Index == 1 then
                                SetPedIntoVehicle(Ped, GetSourcevehicle, -1)
                            elseif Index == 2 then
                                SetPedIntoVehicle(Ped, GetSourcevehicle, 0)
                            elseif Index == 3 then
                                SetPedIntoVehicle(Ped, GetSourcevehicle, 1)
                            elseif Index == 4 then
                                SetPedIntoVehicle(Ped, GetSourcevehicle, 2)
                            end
                        else
                            RageUI.Popup({ message = "[~b~Gestion Véhicule~s~]\n~r~La vitesse du véhicule est trop élevée"})
                        end
                        coolcoolmec(Config.Cooldown)
                    end
                    eGestVeh.PlaceIndex = Index
                end)
                end
        
            end, function()
            end)
            if not RageUI.Visible(main) then
            main = RMenu:DeleteType(main, true)
        end
    end
end


exports("MenuGestionVeh", MenuGestionVeh)


if Config.OpenCommand == true then 
    RegisterCommand(Config.OpenCmd, function()
        if IsEntityDead(PlayerPedId()) then return end 
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            GetEtatPortes()
            GetEtatMoteur()
            MenuGestionVeh()
        else
            RageUI.Popup({ message = "[~b~Gestion Véhicule~s~]\n~r~Vous n'êtes pas dans un véhicule"})
        end
    end, false)
end

if Config.OpenWithKey == true then
    Keys.Register(Config.OpenKey, 'Gestion', 'Ouvrir le menu gestion véhicule', function()
        if IsEntityDead(PlayerPedId()) then return end 
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            GetEtatPortes()
            GetEtatMoteur()
            MenuGestionVeh()
        else
            RageUI.Popup({ message = "[~b~Gestion Véhicule~s~]\n~r~Vous n'êtes pas dans un véhicule"})
        end
    end)
end
