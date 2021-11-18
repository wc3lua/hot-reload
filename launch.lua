HOT_RELOAD_POSTFIX = compiletime(function()
    HOT_RELOAD_POSTFIX = '_hotreload.txt'
    return HOT_RELOAD_POSTFIX
end)
HOT_RELOAD_START_MODULE = compiletime(function()
    HOT_RELOAD_START_MODULE = 'src.index'
    return HOT_RELOAD_START_MODULE
end)

HOT_RELOAD_TRIGGER = CreateTrigger()
BlzTriggerRegisterPlayerKeyEvent(HOT_RELOAD_TRIGGER, Player(0), OSKEY_F7, 0, false)
TriggerAddAction(HOT_RELOAD_TRIGGER, function()
    local filename = MAP_NAME .. HOT_RELOAD_POSTFIX
    Preloader(filename)
    local text = BlzGetAbilityTooltip(FourCC('Agyv'), 0)
    load(text, '', 't')()
    ClearTextMessages()
    ForReload:clear_all()
    CreateRegions()
    CreateAllDestructables()
    CreateAllUnits()
    require(HOT_RELOAD_START_MODULE)
    ceres.modules[HOT_RELOAD_START_MODULE].initialized = false
end)