Config = {

    UseESX = true,
    ESXTrigg = "esx:getSharedObject",

    MenuName = "Gestion véhicule",
    SubName = "Information(s)",
    BanniereCouleur = true,
    ColorMenu = {R = 47, G = 170, B = 255, O = 205},
    

    OpenWithKey = true,
    OpenKey = "F3",
    OpenCommand = true, 
    OpenCmd = "OuvrirGestionVeh",
    ExportName = "OuvrirGestionVeh",

    Cooldown = 1200, 

    InfoSeparator = true,

    StatusPorte = true,
    StatusMoteur = true,
    StatusCapot = true,
    StatusCoffre = true,
    GestionPorte = true,
    GestionFenetre = true,
    Limitateur = true,
    ChangerPlace = true,

}


if Config.UseESX == true then 
    if IsDuplicityVersion() then 
        ESX = nil
        TriggerEvent(Config.ESXTrigg, function(obj) ESX = obj end)
    else
        ESX = nil
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent(Config.ESXTrigg, function(obj) ESX = obj end)
                Citizen.Wait(0)
            end
        end)
    end
end