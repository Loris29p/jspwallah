MyCharacter = {
    model = "mp_m_freemode_01",
    clothes = {
        hairs = { id = 0, txt = 0,color = 0 },
        torso = { id = 0, txt = 0},
        tops = {id = 0, txt = 0},
        undershirt = {id = 0, txt = 0},
        body_armor = {id = 0, txt = 0},
        backpacks = {id = 0, txt = 0},
        texture = {id = 0, txt = 0},
        feet = {id = 0, txt = 0},
        legs = {id = 0, txt = 0},
        accessories = { id = 0, txt = 0 },
        mask = { toggle = false, id = 0, txt = 0 },
        hat = { toggle = false, id = -1, txt = 0 },
        glasses = { toggle = false, id = -1, txt = 0 },
        ears = { toggle = false, id = -1, txt = 0 },
        watches = { toggle = false, id = -1, txt = 0 },
        bracelets = { toggle = false, id = -1, txt = 0 },
    },
    head = {
        beard = { id = 0, overlayId = 0, index = 0, opacity = 0 },
        eyebrows = { id = 0, opacity = 0, color = 0 },
        makeup = { id = 0, opacity = 0, color = 0 },
        blush = { id = 0, opacity = 0, color = 0 },
        lipstick = { id = 0, opacity = 0, color = 0 },
        eyes = { id = 0, opacity = 0, color = 0 },
    },
    skin = {
        shape = {
            first = 0,
            second = 0,
            third = 0,
            skinFirst = 0,
            skinSecond = 0,
            skinThird = 0, 
            shapeMix = 0,
            skinMix = 0,
            thirdMix = 0,
        },
        face = {}
    }
}

function SaveCharacter(tblData)
    if type(tblData) ~= "table" then return end

    local ped = GetPlayerPed(-1)
    if tblData.model then 
        MyCharacter.model = tblData.model
        print("SaveCharacter - Model:", MyCharacter.model)
    end
    if tblData.clothes then 
        if tblData.clothes.torso then 
            MyCharacter.clothes.torso.id = tblData.clothes.torso.id or GetPedDrawableVariation(ped, 3)
            MyCharacter.clothes.torso.txt = tblData.clothes.torso.txt or GetPedTextureVariation(ped, 3)
        end
        if tblData.clothes.hairs then
            MyCharacter.clothes.hairs.id = tblData.clothes.hairs.id or GetPedDrawableVariation(ped, 2)
            MyCharacter.clothes.hairs.txt = tblData.clothes.hairs.txt or GetPedTextureVariation(ped, 2)
            MyCharacter.clothes.hairs.color = tblData.clothes.hairs.color or GetPedHairColor(ped) 
        end
        if tblData.clothes.tops then 
            MyCharacter.clothes.tops.id = tblData.clothes.tops.id or GetPedDrawableVariation(ped, 11)
            MyCharacter.clothes.tops.txt = tblData.clothes.tops.txt or GetPedTextureVariation(ped, 11)
        end
        if tblData.clothes.undershirt then 
            MyCharacter.clothes.undershirt.id = tblData.clothes.undershirt.id or GetPedDrawableVariation(ped, 8)
            MyCharacter.clothes.undershirt.txt = tblData.clothes.undershirt.txt or GetPedTextureVariation(ped, 8)
        end
        if tblData.clothes.body_armor then
            MyCharacter.clothes.body_armor.id = tblData.clothes.body_armor.id or GetPedDrawableVariation(ped, 9)
            MyCharacter.clothes.body_armor.txt = tblData.clothes.body_armor.txt or GetPedTextureVariation(ped, 9)
        end
        if tblData.clothes.backpacks then
            MyCharacter.clothes.backpacks.id = tblData.clothes.backpacks.id or GetPedDrawableVariation(ped, 5)
            MyCharacter.clothes.backpacks.txt = tblData.clothes.backpacks.txt or GetPedTextureVariation(ped, 5)
        end
        if tblData.clothes.texture then
            MyCharacter.clothes.texture.id = tblData.clothes.texture.id or GetPedDrawableVariation(ped, 10)
            MyCharacter.clothes.texture.txt = tblData.clothes.texture.txt or GetPedTextureVariation(ped, 10)
        end
        if tblData.clothes.feet then
            MyCharacter.clothes.feet.id = tblData.clothes.feet.id or GetPedDrawableVariation(ped, 6)
            MyCharacter.clothes.feet.txt = tblData.clothes.feet.txt or GetPedTextureVariation(ped, 6)
        end
        if tblData.clothes.legs then
            MyCharacter.clothes.legs.id = tblData.clothes.legs.id or GetPedDrawableVariation(ped, 4)
            MyCharacter.clothes.legs.txt = tblData.clothes.legs.txt or GetPedTextureVariation(ped, 4)
        end
        if tblData.clothes.accessories then
            MyCharacter.clothes.accessories.id = tblData.clothes.accessories.id or GetPedDrawableVariation(ped, 7)
            MyCharacter.clothes.accessories.txt = tblData.clothes.accessories.txt or GetPedTextureVariation(ped, 7)
        end
        if tblData.clothes.mask then
            MyCharacter.clothes.mask.toggle = tblData.clothes.mask.toggle or false
            MyCharacter.clothes.mask.id = tblData.clothes.mask.id or GetPedDrawableVariation(ped, 1)
            MyCharacter.clothes.mask.txt = tblData.clothes.mask.txt or GetPedTextureVariation(ped, 1)
        end
        if tblData.clothes.hat then
            MyCharacter.clothes.hat.toggle = tblData.clothes.hat.toggle or false
            MyCharacter.clothes.hat.id = tblData.clothes.hat.id or GetPedPropIndex(ped, 0)
            MyCharacter.clothes.hat.txt = tblData.clothes.hat.txt or GetPedPropTextureIndex(ped, 0)
        end
        if tblData.clothes.glasses then
            MyCharacter.clothes.glasses.toggle = tblData.clothes.glasses.toggle or false
            MyCharacter.clothes.glasses.id = tblData.clothes.glasses.id or GetPedPropIndex(ped, 1)
            MyCharacter.clothes.glasses.txt = tblData.clothes.glasses.txt or GetPedPropTextureIndex(ped, 1)
        end
        if tblData.clothes.ears then
            MyCharacter.clothes.ears.toggle = tblData.clothes.ears.toggle or false
            MyCharacter.clothes.ears.id = tblData.clothes.ears.id or GetPedPropIndex(ped, 2)
            MyCharacter.clothes.ears.txt = tblData.clothes.ears.txt or GetPedPropTextureIndex(ped, 2)
        end
        if tblData.clothes.watches then
            MyCharacter.clothes.watches.toggle = tblData.clothes.watches.toggle or false
            MyCharacter.clothes.watches.id = tblData.clothes.watches.id or GetPedPropIndex(ped, 6)
            MyCharacter.clothes.watches.txt = tblData.clothes.watches.txt or GetPedPropTextureIndex(ped, 6)
        end
        if tblData.clothes.bracelets then
            MyCharacter.clothes.bracelets.toggle = tblData.clothes.bracelets.toggle or false
            MyCharacter.clothes.bracelets.id = tblData.clothes.bracelets.id or GetPedPropIndex(ped, 7)
            MyCharacter.clothes.bracelets.txt = tblData.clothes.bracelets.txt or GetPedPropTextureIndex(ped, 7)            
        end
    end

    if tblData.skin then
        if tblData.skin.shape then 
            local ped = GetPlayerPed(-1)
            local success, shapeFirstId, shapeSecondId, shapeThirdId, skinFirstId, skinSecondId, skinThirdId, shapeMix, skinMix, thirdMix = GetPedHeadBlendData(ped)
            
            if success then
                print("SaveCharacter - Current skin values:", 
                     "shapeFirstId:", shapeFirstId, 
                     "shapeSecondId:", shapeSecondId,
                     "skinFirstId:", skinFirstId,
                     "skinSecondId:", skinSecondId,
                     "shapeMix:", shapeMix,
                     "skinMix:", skinMix)
                
                print("SaveCharacter - New skin values:", 
                     "first:", tblData.skin.shape.first, 
                     "second:", tblData.skin.shape.second,
                     "skinFirst:", tblData.skin.shape.skinFirst,
                     "skinSecond:", tblData.skin.shape.skinSecond,
                     "shapeMix:", tblData.skin.shape.shapeMix,
                     "skinMix:", tblData.skin.shape.skinMix)
            end
            
            -- Assurez-vous que toutes les valeurs sont définies
            MyCharacter.skin.shape.first = tblData.skin.shape.first ~= nil and tblData.skin.shape.first or shapeFirstId
            MyCharacter.skin.shape.second = tblData.skin.shape.second ~= nil and tblData.skin.shape.second or shapeSecondId
            MyCharacter.skin.shape.third = tblData.skin.shape.third ~= nil and tblData.skin.shape.third or shapeThirdId
            MyCharacter.skin.shape.skinFirst = tblData.skin.shape.skinFirst ~= nil and tblData.skin.shape.skinFirst or skinFirstId
            MyCharacter.skin.shape.skinSecond = tblData.skin.shape.skinSecond ~= nil and tblData.skin.shape.skinSecond or skinSecondId
            MyCharacter.skin.shape.skinThird = tblData.skin.shape.skinThird ~= nil and tblData.skin.shape.skinThird or skinThirdId
            MyCharacter.skin.shape.shapeMix = tblData.skin.shape.shapeMix ~= nil and tblData.skin.shape.shapeMix or shapeMix
            MyCharacter.skin.shape.skinMix = tblData.skin.shape.skinMix ~= nil and tblData.skin.shape.skinMix or skinMix
            MyCharacter.skin.shape.thirdMix = tblData.skin.shape.thirdMix ~= nil and tblData.skin.shape.thirdMix or thirdMix
        end

        if tblData.skin.face then
            MyCharacter.skin.face = {
                node_width = tblData.skin.face.node_width or GetPedFaceFeature(ped, 0),
                nose_width = tblData.skin.face.nose_width or GetPedFaceFeature(ped, 1),
                nose_peak_height = tblData.skin.face.nose_peak_height or GetPedFaceFeature(ped, 2),
                nose_peak_length = tblData.skin.face.nose_peak_length or GetPedFaceFeature(ped, 3),
                nose_bone_height = tblData.skin.face.nose_bone_height or GetPedFaceFeature(ped, 4),
                nose_peak_lowering = tblData.skin.face.nose_peak_lowering or GetPedFaceFeature(ped, 5),
                nose_bone_twist = tblData.skin.face.nose_bone_twist or GetPedFaceFeature(ped, 6),
                eyebrow_height = tblData.skin.face.eyebrow_height or GetPedFaceFeature(ped, 7),
                eyebrow_forward = tblData.skin.face.eyebrow_forward or GetPedFaceFeature(ped, 8),
                cheeks_bone_height = tblData.skin.face.cheeks_bone_height or GetPedFaceFeature(ped, 9),
                cheeks_bone_width = tblData.skin.face.cheeks_bone_width or GetPedFaceFeature(ped, 10),
                cheeks_width = tblData.skin.face.cheeks_width or GetPedFaceFeature(ped, 11),
                eyes_opening = tblData.skin.face.eyes_opening or GetPedFaceFeature(ped, 12),
                lips_thickness = tblData.skin.face.lips_thickness or GetPedFaceFeature(ped, 13),
                jaw_bone_width = tblData.skin.face.jaw_bone_width or GetPedFaceFeature(ped, 14),
                jaw_bone_length = tblData.skin.face.jaw_bone_length or GetPedFaceFeature(ped, 15),
                chin_bone_lowering = tblData.skin.face.chin_bone_lowering or GetPedFaceFeature(ped, 16),
                chin_bone_length = tblData.skin.face.chin_bone_length or GetPedFaceFeature(ped, 17),
                chin_bone_width = tblData.skin.face.chin_bone_width or GetPedFaceFeature(ped, 18),
                chin_hole = tblData.skin.face.chin_hole or GetPedFaceFeature(ped, 19),
                neck_thickness = tblData.skin.face.neck_thickness or GetPedFaceFeature(ped, 20),
            }
        end
    end

    if tblData.head then 
        if tblData.head.beard then
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, 1)
            
            if success then
                print("SaveCharacter - Beard current values:", 
                     "overlayValue:", overlayValue, 
                     "opacity:", overlayOpacity,
                     "color:", firstColour)
                     
                print("SaveCharacter - Beard new values:", 
                     "id:", tblData.head.beard.id,
                     "opacity:", tblData.head.beard.opacity,
                     "color:", tblData.head.beard.color)
            end
            
            MyCharacter.head.beard.id = tblData.head.beard.id ~= nil and tblData.head.beard.id or overlayValue
            MyCharacter.head.beard.opacity = tblData.head.beard.opacity ~= nil and tblData.head.beard.opacity or overlayOpacity
            MyCharacter.head.beard.color = tblData.head.beard.color ~= nil and tblData.head.beard.color or firstColour
        end
        if tblData.head.eyebrows then
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, 2)
            
            if success then
                print("SaveCharacter - Eyebrows current values:", 
                     "overlayValue:", overlayValue, 
                     "opacity:", overlayOpacity,
                     "color:", firstColour)
                     
                print("SaveCharacter - Eyebrows new values:", 
                     "id:", tblData.head.eyebrows.id,
                     "opacity:", tblData.head.eyebrows.opacity,
                     "color:", tblData.head.eyebrows.color)
            end
            
            MyCharacter.head.eyebrows.id = tblData.head.eyebrows.id ~= nil and tblData.head.eyebrows.id or overlayValue
            MyCharacter.head.eyebrows.opacity = tblData.head.eyebrows.opacity ~= nil and tblData.head.eyebrows.opacity or overlayOpacity
            MyCharacter.head.eyebrows.color = tblData.head.eyebrows.color ~= nil and tblData.head.eyebrows.color or firstColour
        end
        if tblData.head.makeup then
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, 4)
            MyCharacter.head.makeup.id = tblData.head.makeup.id or overlayValue
            MyCharacter.head.makeup.opacity = tblData.head.makeup.opacity or overlayOpacity
            MyCharacter.head.makeup.color = tblData.head.makeup.color or firstColour
        end
        if tblData.head.blush then
            local overlayId = tblData.head.blush.overlayId or 5
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, overlayId)
            MyCharacter.head.blush.id = tblData.head.blush.id or overlayValue
            MyCharacter.head.blush.overlayId = overlayId
            MyCharacter.head.blush.index = tblData.head.blush.index or colourType
            MyCharacter.head.blush.opacity = tblData.head.blush.opacity or overlayOpacity
            MyCharacter.head.blush.color = tblData.head.blush.color or firstColour
        end
        if tblData.head.lipstick then
            local overlayId = tblData.head.lipstick.overlayId or 8
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, overlayId)
            MyCharacter.head.lipstick.id = tblData.head.lipstick.id or overlayValue
            MyCharacter.head.lipstick.overlayId = overlayId
            MyCharacter.head.lipstick.index = tblData.head.lipstick.index or colourType
            MyCharacter.head.lipstick.opacity = tblData.head.lipstick.opacity or overlayOpacity
            MyCharacter.head.lipstick.color = tblData.head.lipstick.color or firstColour
        end
        if tblData.head.eyes then
            MyCharacter.head.eyes.color = tblData.head.eyes.color or GetPedEyeColor(ped)
        end
    end

    -- TriggerServerEvent("Saveskin", MyCharacter)
end


function changeModel(skin)
	local model = GetHashKey(skin)
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetPedDefaultComponentVariation(PlayerPedId())
        SetModelAsNoLongerNeeded(model)
        -- Set max health and armor for all models
        SetPedMaxHealth(PlayerPedId(), 200)
        SetPlayerMaxArmour(PlayerId(), 100)
    end
end


function ChangeApparence(tblData)
    if type(tblData) ~= "table" then return end
    local ped = GetPlayerPed(-1)
    if tblData.model then 
        local model = tblData.model
        changeModel(model)
    end
    if tblData.head then 
        if tblData.head.beard then 
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, 1)
            local drawableId = tblData.head.beard.id or overlayValue
            local opacity = tblData.head.beard.opacity or overlayOpacity
            
            print("Setting beard: ID=", drawableId, "Opacity=", opacity)
            SetPedHeadOverlay(ped, 1, drawableId, opacity)
            if tblData.head.beard.color then
                print("Setting beard color:", tblData.head.beard.color)
                SetPedHeadOverlayColor(ped, 1, 1, tblData.head.beard.color, 0)
            else 
                SetPedHeadOverlayColor(ped, 1, 1, firstColour, secondColour)
            end
        end
        if tblData.head.eyebrows then 
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, 2)
            local drawableId = tblData.head.eyebrows.id or overlayValue
            local opacity = tblData.head.eyebrows.opacity or overlayOpacity
            
            SetPedHeadOverlay(ped, 2, drawableId, opacity)
            if tblData.head.eyebrows.color then
                SetPedHeadOverlayColor(ped, 2, 1, tblData.head.eyebrows.color, 0)
            else
                SetPedHeadOverlayColor(ped, 2, colourType, firstColour, secondColour)
            end
        end
        if tblData.head.makeup then
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, 4)
            local drawableId = tblData.head.makeup.id or overlayValue
            local opacity = tblData.head.makeup.opacity or overlayOpacity
            
            SetPedHeadOverlay(ped, 4, drawableId, opacity)
            if tblData.head.makeup.color then
                SetPedHeadOverlayColor(ped, 4, 2, tblData.head.makeup.color, 0)
            else
                SetPedHeadOverlayColor(ped, 4, colourType, firstColour, secondColour)
            end
        end
        if tblData.head.blush then
            local overlayId = tblData.head.blush.overlayId or 5
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, overlayId)
            local drawableId = tblData.head.blush.id or overlayValue
            local opacity = tblData.head.blush.opacity or overlayOpacity
            local index = tblData.head.blush.index or colourType or 2
            
            SetPedHeadOverlay(ped, overlayId, drawableId, opacity)
            if tblData.head.blush.color then
                SetPedHeadOverlayColor(ped, overlayId, index, tblData.head.blush.color, 0)
            else
                SetPedHeadOverlayColor(ped, overlayId, colourType, firstColour, secondColour)
            end
        end
        if tblData.head.lipstick then
            local overlayId = tblData.head.lipstick.overlayId or 8
            local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, overlayId)
            local drawableId = tblData.head.lipstick.id or overlayValue
            local opacity = tblData.head.lipstick.opacity or overlayOpacity
            local index = tblData.head.lipstick.index or colourType or 2
            
            SetPedHeadOverlay(ped, overlayId, drawableId, opacity)
            if tblData.head.lipstick.color then
                SetPedHeadOverlayColor(ped, overlayId, index, tblData.head.lipstick.color, 0)
            else
                SetPedHeadOverlayColor(ped, overlayId, colourType, firstColour, secondColour)
            end
        end
        if tblData.head.eyes then
            SetPedEyeColor(ped, tblData.head.eyes.color or 0)
        end
    end
    if tblData.clothes then 
        if tblData.clothes.torso then 
            local drawableId = tblData.clothes.torso.id or GetPedDrawableVariation(ped, 3)
            local textureId = tblData.clothes.torso.txt or GetPedTextureVariation(ped, 3)
            
            SetPedComponentVariation(ped, 3, drawableId, textureId, 0)
        end
        if tblData.clothes.hairs then 
            local drawableId = tblData.clothes.hairs.id or GetPedDrawableVariation(ped, 2)
            local textureId = tblData.clothes.hairs.txt or GetPedTextureVariation(ped, 2)
            
            SetPedComponentVariation(ped, 2, drawableId, textureId, 0)
            if tblData.clothes.hairs.color then 
                local color = tblData.clothes.hairs.color or GetPedHairColor(ped)
                SetPedHairColor(ped, color, 0)
            end
        end
        if tblData.clothes.tops then 
            local drawableId = tblData.clothes.tops.id or GetPedDrawableVariation(ped, 11)
            local textureId = tblData.clothes.tops.txt or GetPedTextureVariation(ped, 11)
            
            SetPedComponentVariation(ped, 11, drawableId, textureId, 0)
        end
        if tblData.clothes.undershirt then 
            local drawableId = tblData.clothes.undershirt.id or GetPedDrawableVariation(ped, 8)
            local textureId = tblData.clothes.undershirt.txt or GetPedTextureVariation(ped, 8)
            
            SetPedComponentVariation(ped, 8, drawableId, textureId, 0)
        end
        if tblData.clothes.body_armor then
            local drawableId = tblData.clothes.body_armor.id or GetPedDrawableVariation(ped, 9)
            local textureId = tblData.clothes.body_armor.txt or GetPedTextureVariation(ped, 9)
            
            SetPedComponentVariation(ped, 9, drawableId, textureId, 0)
        end
        if tblData.clothes.backpacks then
            local drawableId = tblData.clothes.backpacks.id or GetPedDrawableVariation(ped, 5)
            local textureId = tblData.clothes.backpacks.txt or GetPedTextureVariation(ped, 5)
            print("TEXTURE", tblData.clothes.backpacks.txt, tblData.clothes.backpacks.id)
            
            SetPedComponentVariation(ped, 5, drawableId, textureId, 0)
        end
        if tblData.clothes.texture then
            local drawableId = tblData.clothes.texture.id or GetPedDrawableVariation(ped, 10)
            local textureId = tblData.clothes.texture.txt or GetPedTextureVariation(ped, 10)
            
            SetPedComponentVariation(ped, 10, drawableId, textureId, 0)
        end
        if tblData.clothes.feet then
            local drawableId = tblData.clothes.feet.id or GetPedDrawableVariation(ped, 6)
            local textureId = tblData.clothes.feet.txt or GetPedTextureVariation(ped, 6)
            
            SetPedComponentVariation(ped, 6, drawableId, textureId, 0)
        end
        if tblData.clothes.legs then
            local drawableId = tblData.clothes.legs.id or GetPedDrawableVariation(ped, 4)
            local textureId = tblData.clothes.legs.txt or GetPedTextureVariation(ped, 4)
            
            SetPedComponentVariation(ped, 4, drawableId, textureId, 0)
        end
        if tblData.clothes.accessories then
            local drawableId = tblData.clothes.accessories.id or GetPedDrawableVariation(ped, 7)
            local textureId = tblData.clothes.accessories.txt or GetPedTextureVariation(ped, 7)
            
            SetPedComponentVariation(ped, 7, drawableId, textureId, 0)
        end
        if tblData.clothes.mask then
            if tblData.clothes.mask.toggle then 
                local drawableId = tblData.clothes.mask.id or GetPedDrawableVariation(ped, 1)
                local textureId = tblData.clothes.mask.txt or GetPedTextureVariation(ped, 1)
                
                SetPedComponentVariation(ped, 1, drawableId, textureId, 0)
            else
                SetPedComponentVariation(Ped, 1, 0, 0, 0)
            end
        end
        if tblData.clothes.hat then
            if tblData.clothes.hat.toggle then 
                local drawableId = tblData.clothes.hat.id or GetPedPropIndex(ped, 0)
                local textureId = tblData.clothes.hat.txt or GetPedPropTextureIndex(ped, 0)
                print("TEXTURE", tblData.clothes.hat.txt, tblData.clothes.hat.id)
                
                SetPedPropIndex(ped, 0, drawableId, textureId, true)
            else
                ClearPedProp(ped, 0)
            end
        end
        if tblData.clothes.glasses then
            if tblData.clothes.glasses.toggle then 
                local drawableId = tblData.clothes.glasses.id or GetPedPropIndex(ped, 1)
                local textureId = tblData.clothes.glasses.txt or GetPedPropTextureIndex(ped, 1)
                
                SetPedPropIndex(ped, 1, drawableId, textureId, true)
            else
                ClearPedProp(ped, 1)
            end
        end
        if tblData.clothes.ears then
            if tblData.clothes.ears.toggle then 
                local drawableId = tblData.clothes.ears.id or GetPedPropIndex(ped, 2)
                local textureId = tblData.clothes.ears.txt or GetPedPropTextureIndex(ped, 2)
                
                SetPedPropIndex(ped, 2, drawableId, textureId, true)
            else
                ClearPedProp(ped, 2)
            end
        end
        if tblData.clothes.watches then
            if tblData.clothes.watches.toggle then 
                local drawableId = tblData.clothes.watches.id or GetPedPropIndex(ped, 6)
                local textureId = tblData.clothes.watches.txt or GetPedPropTextureIndex(ped, 6)
                
                SetPedPropIndex(ped, 6, drawableId, textureId, true)
            else
                ClearPedProp(ped, 6)
            end
        end
        if tblData.clothes.bracelets then
            if tblData.clothes.bracelets.toggle then 
                local drawableId = tblData.clothes.bracelets.id or GetPedPropIndex(ped, 7)
                local textureId = tblData.clothes.bracelets.txt or GetPedPropTextureIndex(ped, 7)
                
                SetPedPropIndex(ped, 7, drawableId, textureId, true)
            else
                ClearPedProp(ped, 7)
            end
            
        end
    end

    if tblData.skin then

        if tblData.skin.shape then 
            local success, currentFirstId, currentSecondId, currentThirdId, currentSkinFirstId, currentSkinSecondId, currentSkinThirdId, currentShapeMix, currentSkinMix, currentThirdMix = GetPedHeadBlendData(ped)
            
            local shapeFirstId = tblData.skin.shape.first ~= nil and tblData.skin.shape.first or (success and currentFirstId or 0)
            local shapeSecondId = tblData.skin.shape.second ~= nil and tblData.skin.shape.second or (success and currentSecondId or 0)  
            local shapeThirdId = tblData.skin.shape.third ~= nil and tblData.skin.shape.third or (success and currentThirdId or 0)
            local skinFirstId = tblData.skin.shape.skinFirst ~= nil and tblData.skin.shape.skinFirst or (success and currentSkinFirstId or shapeFirstId)
            local skinSecondId = tblData.skin.shape.skinSecond ~= nil and tblData.skin.shape.skinSecond or (success and currentSkinSecondId or shapeSecondId)
            local skinThirdId = tblData.skin.shape.skinThird ~= nil and tblData.skin.shape.skinThird or (success and currentSkinThirdId or shapeThirdId)
            local shapeMix = tblData.skin.shape.shapeMix ~= nil and tblData.skin.shape.shapeMix or (success and currentShapeMix or 0.5)
            local skinMix = tblData.skin.shape.skinMix ~= nil and tblData.skin.shape.skinMix or (success and currentSkinMix or 0.5)
            local thirdMix = tblData.skin.shape.thirdMix ~= nil and tblData.skin.shape.thirdMix or (success and currentThirdMix or 0.0)

            print("ChangeApparence - Setting head blend data - shapeFirstId:", shapeFirstId, 
                  "shapeSecondId:", shapeSecondId, 
                  "shapeMix:", shapeMix, 
                  "skinMix:", skinMix)

            SetPedHeadBlendData(ped, shapeFirstId, shapeSecondId, shapeThirdId, skinFirstId, skinSecondId, skinThirdId, shapeMix, skinMix, thirdMix, false)
        end

        if tblData.skin.face then
            local node_width = GetPedFaceFeature(ped, 0)
            local nose_width = GetPedFaceFeature(ped, 1) 
            local nose_peak_height = GetPedFaceFeature(ped, 2)
            local nose_peak_length = GetPedFaceFeature(ped, 3)
            local nose_bone_height = GetPedFaceFeature(ped, 4)
            local nose_peak_lowering = GetPedFaceFeature(ped, 5)
            local nose_bone_twist = GetPedFaceFeature(ped, 6)
            local eyebrow_height = GetPedFaceFeature(ped, 7)
            local eyebrow_forward = GetPedFaceFeature(ped, 8)
            local cheeks_bone_height = GetPedFaceFeature(ped, 9)
            local cheeks_bone_width = GetPedFaceFeature(ped, 10)
            local cheeks_width = GetPedFaceFeature(ped, 11)
            local eyes_opening = GetPedFaceFeature(ped, 12)
            local lips_thickness = GetPedFaceFeature(ped, 13)
            local jaw_bone_width = GetPedFaceFeature(ped, 14)
            local jaw_bone_length = GetPedFaceFeature(ped, 15)
            local chin_bone_lowering = GetPedFaceFeature(ped, 16)
            local chin_bone_length = GetPedFaceFeature(ped, 17)
            local chin_bone_width = GetPedFaceFeature(ped, 18)
            local chin_hole = GetPedFaceFeature(ped, 19)
            local neck_thickness = GetPedFaceFeature(ped, 20)

            SetPedFaceFeature(ped, 0, tblData.skin.face.node_width or node_width)
            SetPedFaceFeature(ped, 1, tblData.skin.face.nose_width or nose_width)
            SetPedFaceFeature(ped, 2, tblData.skin.face.nose_peak_height or nose_peak_height)
            SetPedFaceFeature(ped, 3, tblData.skin.face.nose_peak_length or nose_peak_length)
            SetPedFaceFeature(ped, 4, tblData.skin.face.nose_bone_height or nose_bone_height)
            SetPedFaceFeature(ped, 5, tblData.skin.face.nose_peak_lowering or nose_peak_lowering)
            SetPedFaceFeature(ped, 6, tblData.skin.face.nose_bone_twist or nose_bone_twist)
            SetPedFaceFeature(ped, 7, tblData.skin.face.eyebrow_height or eyebrow_height)
            SetPedFaceFeature(ped, 8, tblData.skin.face.eyebrow_forward or eyebrow_forward)
            SetPedFaceFeature(ped, 9, tblData.skin.face.cheeks_bone_height or cheeks_bone_height)
            SetPedFaceFeature(ped, 10, tblData.skin.face.cheeks_bone_width or cheeks_bone_width)
            SetPedFaceFeature(ped, 11, tblData.skin.face.cheeks_width or cheeks_width)
            SetPedFaceFeature(ped, 12, tblData.skin.face.eyes_opening or eyes_opening)
            SetPedFaceFeature(ped, 13, tblData.skin.face.lips_thickness or lips_thickness)
            SetPedFaceFeature(ped, 14, tblData.skin.face.jaw_bone_width or jaw_bone_width)
            SetPedFaceFeature(ped, 15, tblData.skin.face.jaw_bone_length or jaw_bone_length)
            SetPedFaceFeature(ped, 16, tblData.skin.face.chin_bone_lowering or chin_bone_lowering)
            SetPedFaceFeature(ped, 17, tblData.skin.face.chin_bone_length or chin_bone_length)
            SetPedFaceFeature(ped, 18, tblData.skin.face.chin_bone_width or chin_bone_width)
            SetPedFaceFeature(ped, 19, tblData.skin.face.chin_hole or chin_hole)
            SetPedFaceFeature(ped, 20, tblData.skin.face.neck_thickness or neck_thickness)
        end
    end

    if tblData.save then 
        SaveCharacter(tblData)
    end
end

Character = {
    changeApp = ChangeApparence,
    save = SaveCharacter,
}

-- AddEventHandler("skin:LoadingSkin", function(tblData)
--     ChangeApparence(tblData)
-- end) 

-- RegisterCommand("test_skin", function()
--     ChangeApparence({
--         clothes = {
--             torso = {
--                 id = 50, 
--                 txt = 2  
--             },
--             tops = {
--                 id = 30,
--                 txt = 1,
--             },

--             undershirt = {
--                 id = 15,
--                 txt = 0,
--             },
--             body_armor = {
--                 id = 0,
--                 txt = 0,
--             },
--             backpacks = {
--                 id = 0,
--                 txt = 0,
--             },
--             texture = {
--                 id = 0,
--                 txt = 0,
--             },
--             feet = {
--                 id = 6,
--                 txt = 0,
--             },
--             legs = {
--                 id = 50,
--                 txt = 0,
--             },
--             accessories = {
--                 id = 0,
--                 txt = 0,
--             },
--             mask = {
--                 toggle = false,
--                 id = 0,
--                 txt = 0,
--             },
--             hat = {
--                 toggle = true,
--                 id = 20,
--                 txt = 0,
--             },
--             glasses = {
--                 toggle = true,
--                 id = 4,
--                 txt = 0,
--             },
--             ears = {
--                 toggle = true,
--                 id = 7,
--                 txt = 0,
--             },
--             watches = {
--                 toggle = true,
--                 id = 12,
--                 txt = 0,
--             },
--         },
--         skin = {
            
--             shape = {
--                 first = 21,       
--                 second = 15,      
--                 third = 0,       
--                 skinFirst = 21,   
--                 skinSecond = 15,  
--                 skinThird = 0,    
--                 shapeMix = 0.5,   --(0.0 - 1.0)
--                 skinMix = 0.5,    --(0.0 - 1.0)
--                 thirdMix = 0.0    
--             },
            
--             face = {
--                 nose_width = 0.5,        
--                 nose_peak_height = -0.3,  
--                 eyes_opening = 0.2,       
--                 lips_thickness = 0.1,     
--                 jaw_bone_width = 0.4,     
--                 cheeks_bone_height = 0.3  
--             }
--         },
--     })
-- end)