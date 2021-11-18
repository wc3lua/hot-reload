ForReload = {
    alloc = function(self, nativeCreateName, nativeRemove)
        local xs = {}
    
        local nativeCreate = _G[nativeCreateName]
        _G[nativeCreateName] = function(...)
            local x = nativeCreate(table.unpack({...}))
            xs[#xs + 1] = x
            return x
        end
        return {
            xs = xs,
            newNative = _G[nativeCreateName],
            clearFun = function()
                for a = #xs, 1, -1 do
                    nativeRemove(xs[a])
                    xs[a] = nil
                end
            end
        }
    end,
    add = function(self, nativeCreateName, nativeRemove)
        local t = {
            nativeName = nativeCreateName,
            oldNative = _G[nativeCreateName],
        }
        local funcs = self:alloc(nativeCreateName, nativeRemove)
        t.newNative = funcs.newNative
        t.clearFun = funcs.clearFun
        self.list[#self.list + 1] = t
        self.list[nativeCreateName] = funcs.xs
    end,
    addArray = function(self, arr)
        for i = 1, #arr do
            self:add(arr[i][1], arr[i][2])
        end
    end,
    addFun = function(self, fun)
        table.insert(self.list.funcs, fun)
    end,
    dealloc = function(self)
        for i = 1, #self.list do
            local nativeName = self.list[i].nativeName
            _G[nativeName] = self.list[i].oldNative
        end
    end,
    realloc = function(self)
        for i = 1, #self.list do
            local nativeName = self.list[i].nativeName
            _G[nativeName] = self.list[i].newNative
        end
    end,
    clear_all = function(self)
        for i = 1, #self.list do
            self.list[i].clearFun()
        end
        for i = 1, #self.list.funcs do
            self.list.funcs[i]()
            self.list.funcs[i] = nil
        end
    end,
    list = {
        funcs = {}
    },
    isReloaded = false,
    destructables = {}
}

local scope = ForReload
scope:addArray({
    { 'CreateBlightedGoldmine', RemoveUnit },
    { 'CreateDestructable', RemoveDestructable },
    { 'CreateDestructableZ', RemoveDestructable },
    { 'CreateDeadDestructable', RemoveDestructable },
    { 'CreateDeadDestructableZ', RemoveDestructable },
    { 'DialogCreate', DialogDestroy },
    { 'AddWeatherEffect', RemoveWeatherEffect },
    -- TerrainDeform
    { 'AddSpecialEffect', DestroyEffect },
    { 'AddSpecialEffectLoc', DestroyEffect },
    { 'AddSpecialEffectTarget', DestroyEffect }, 
    { 'AddSpellEffect', DestroyEffect }, 
    { 'AddSpellEffectLoc', DestroyEffect },
    { 'AddSpellEffectById', DestroyEffect }, 
    { 'AddSpellEffectByIdLoc', DestroyEffect },
    { 'AddSpellEffectTarget', DestroyEffect },
    { 'AddSpellEffectTargetById', DestroyEffect },
    { 'AddLightning', DestroyLightning },
    { 'AddLightningEx', DestroyLightning },
    { 'CreateFogModifierRect', DestroyFogModifier },
    { 'CreateFogModifierRadius', DestroyFogModifier },
    { 'CreateFogModifierRadiusLoc', DestroyFogModifier },
    { 'CreateForce', DestroyForce },
    { 'BlzCreateFrame', BlzDestroyFrame },
    { 'BlzCreateSimpleFrame', BlzDestroyFrame },
    { 'BlzCreateFrameByType', BlzDestroyFrame },
    { 'CreateGroup', DestroyGroup },
    { 'InitHashtable', FlushParentHashtable },
    { 'CreateImage', DestroyImage },
    { 'CreateItem', RemoveItem },
    { 'CreateLeaderboard', DestroyLeaderboard },
    -- LeaderBoardItem
    { 'CreateMultiboard', DestroyMultiboard },
    -- MultiBoardItem
    { 'CreateQuest', DestroyQuest },
    { 'CreateDefeatCondition', DestroyDefeatCondition },
    { 'CreateUnitPool', DestroyUnitPool },
    { 'PlaceRandomUnit', RemoveUnit },
    { 'CreateItemPool', DestroyItemPool },
    { 'PlaceRandomItem', RemoveItem },
    { 'Rect', RemoveRect },
    { 'RectFromLoc', RemoveRect },
    { 'CreateRegion', RemoveRegion },
    { 'Location', RemoveLocation },
    { 'CreateSound', KillSoundWhenDone },
    { 'CreateSoundFilenameWithLabel', KillSoundWhenDone },
    { 'CreateSoundFromLabel', KillSoundWhenDone },
    { 'CreateMIDISound', KillSoundWhenDone },
    { 'CreateTimerDialog', DestroyTimerDialog },
    { 'CreateTimer', function(timer)
        PauseTimer(timer)
        DestroyTimer(timer)
    end },
    { 'CreateTrackable', function(trackable) end },
    { 'CreateTrigger', function(trigger)
        TriggerClearConditions(trigger)
        TriggerClearActions(trigger)
        DestroyTrigger(trigger)
    end },
    { 'CreateUbersplat', DestroyUbersplat },
    { 'CreateUnit', RemoveUnit },
    { 'CreateUnitByName', RemoveUnit },
    { 'CreateUnitAtLoc', RemoveUnit },
    { 'CreateUnitAtLocByName', RemoveUnit },
    { 'CreateCorpse', RemoveUnit },
    { 'CreateTextTag', DestroyTextTag }
})

local _InitBlizzard = InitBlizzard
function InitBlizzard()
    scope:dealloc()
    _InitBlizzard()
    if  not scope.isReloaded then
        scope.isReloaded = true
        EnumDestructablesInRect(bj_mapInitialPlayableArea, nil, function()
            scope.destructables[#scope.destructables + 1] = GetEnumDestructable()
        end)
    end
    scope:realloc()
end

local _CreateAllDestructables = CreateAllDestructables
function CreateAllDestructables()
    _CreateAllDestructables()
    if  scope.isReloaded then
        for i = 1, #scope.destructables do
            if  IsDestructableDeadBJ(scope.destructables[i]) then
                DestructableRestoreLife(scope.destructables[i], GetDestructableMaxLife(scope.destructables[i]), false)
            end
        end
    end
end