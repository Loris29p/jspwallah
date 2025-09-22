local defaultState = {
    active = false,
    personnalizeMenu = "",
    ["creation_character"] = {
        cam = nil, 
        hair = {
            getValue = function(ped)
                local hairNum = GetPedDrawableVariation(ped, 2)
                return hairNum
            end,
            setValue = function(value)
                local ped = GetPlayer().Ped
                SetPedComponentVariation(ped, 2, value, GetPedPaletteVariation(ped, 2), GetPedTextureVariation(ped, 2))
            end,
        },
        beard = {
            getValue = function()
                local ped = GetPlayer().Ped
                local beardNum = 28
                return beardNum
            end,
            setValue = function(value)
                local ped = GetPlayer().Ped
                SetPedHeadOverlayColor(ped, 1, value, 1, 1.0)
            end,
        }
    },
}

local sex = 0

local m_tblConfigSkinMaker = Deepcopy(defaultState)

-- local GetPlayerData = exports["gamemode"]:GetPlayerData()

-- Quick Menu 

local function onButtonSelected(currentMenu, r, p, currentButton, PMenu)
    if currentMenu == "list of characters" then
        ChangeApparence({
            model = currentButton.name,
        })
        SetPedMaxHealth(PlayerPedId(), 200)
        SetPlayerMaxArmour(PlayerId(), 100)
        Tse("pedaccess:PutModel", currentButton.name)
    end
end

local function onBack(menuData, PMenu, lastMenu)
    print(menuData, PMenu, lastMenu, "onBack")
    if lastMenu == "list of characters" then
        if MyCharacter.model and MyCharacter.skin and MyCharacter.skin.shape then
            ChangeApparence({
                model = MyCharacter.model
            })
            Wait(100)
            ChangeApparence({
                skin = {
                    shape = MyCharacter.skin.shape
                }
            })
            Wait(100)
            ChangeApparence({
                clothes = MyCharacter.clothes,
                head = MyCharacter.head,
                skin = {
                    face = MyCharacter.skin.face
                }
            })
        else
            print("ERROR: MyCharacter has invalid values:", MyCharacter.model, MyCharacter.skin)
        end
    end
end

local function onSlide(menuData, currentButton, currentSlt, PMenu)
    if menuData.currentMenu == "parents" then
        local buttonsData = PMenu.tempData[1]
        if buttonsData and buttonsData[1] and buttonsData[2] then
            local father = buttonsData[1].slidenum
            local mother = buttonsData[2].slidenum

            
            local displayFatherIndex = (father - 1) % 21
            local displayMotherIndex = (mother - 1) % 21
            
            PMenu.Menu["parents"].father = "male_" .. displayFatherIndex
            PMenu.Menu["parents"].mother = "female_" .. displayMotherIndex
            
            ChangeApparence({ 
                skin = { 
                    shape = { 
                        first = father - 1,
                        second = mother - 1,
                        shapeMix = 0.5,
                        skinMix = 0.5,
                        third = 0,
                        skinFirst = father - 1,
                        skinSecond = mother - 1, 
                        skinThird = 0,
                        thirdMix = 0
                    } 
                },
                save = true,
            })
        end
    end

    if menuData.currentMenu == "apparence" then
        local buttonsData = PMenu.tempData[1]
        if buttonsData and buttonsData[1] and buttonsData[2] then -- Hair
            local colorHair = buttonsData[1].advSlider[3]
            local typeHair = buttonsData[1].slidenum - 1
            local typeBeard = buttonsData[2].slidenum - 1
            local beardColor = buttonsData[2].advSlider[3]          
            ChangeApparence({
                clothes = {
                    hairs = {
                        color = colorHair,
                        id = typeHair,
                    }
                },
                head = {
                    beard = {
                        color = beardColor,
                        opacity = buttonsData[2].opacity,
                        id = typeBeard,
                    },
                    eyebrows = {
                        color = buttonsData[3].advSlider[3],
                        opacity = buttonsData[3].opacity,
                        id = buttonsData[3].slidenum - 1,
                    }
                },
                save = true
            })
        end
    end
    
    if menuData.currentMenu == "faces" then
        local faceFeatureMap = {
            ["Node width"] = 0,
            ["Nose width"] = 1,
            ["Nose peak height"] = 2,
            ["Nose peak length"] = 3,
            ["Nose bone height"] = 4,
            ["Nose peak lowering"] = 5,
            ["Nose bone twist"] = 6,
            ["Eyebrow height"] = 7,
            ["Eyebrow forward"] = 8,
            ["Cheeks bone height"] = 9,
            ["Cheeks bone width"] = 10,
            ["Cheeks width"] = 11,
            ["Eyes opening"] = 12,
            ["Lips thickness"] = 13,
            ["Jaw bone width"] = 14,
            ["Jaw bone length"] = 15,
            ["Chin bone lowering"] = 16,
            ["Chin bone length"] = 17,
            ["Chin bone width"] = 18,
            ["Chin hole"] = 19,
            ["Neck thickness"] = 20
        }
        
        local featureIndex = faceFeatureMap[currentButton.name]
        if featureIndex ~= nil then
            -- Convertir currentSlt (0-100) vers une échelle de -1 à 1
            -- 0 = -1.0, 50 = 0.0, 100 = 1.0
            local featureValue = ((currentSlt / 100) * 2) - 1
            
            -- Créer la structure de données pour la mise à jour du visage
            local faceData = {}
            
            if featureIndex == 0 then faceData.node_width = featureValue
            elseif featureIndex == 1 then faceData.nose_width = featureValue
            elseif featureIndex == 2 then faceData.nose_peak_height = featureValue
            elseif featureIndex == 3 then faceData.nose_peak_length = featureValue
            elseif featureIndex == 4 then faceData.nose_bone_height = featureValue
            elseif featureIndex == 5 then faceData.nose_peak_lowering = featureValue
            elseif featureIndex == 6 then faceData.nose_bone_twist = featureValue
            elseif featureIndex == 7 then faceData.eyebrow_height = featureValue
            elseif featureIndex == 8 then faceData.eyebrow_forward = featureValue
            elseif featureIndex == 9 then faceData.cheeks_bone_height = featureValue
            elseif featureIndex == 10 then faceData.cheeks_bone_width = featureValue
            elseif featureIndex == 11 then faceData.cheeks_width = featureValue
            elseif featureIndex == 12 then faceData.eyes_opening = featureValue
            elseif featureIndex == 13 then faceData.lips_thickness = featureValue
            elseif featureIndex == 14 then faceData.jaw_bone_width = featureValue
            elseif featureIndex == 15 then faceData.jaw_bone_length = featureValue
            elseif featureIndex == 16 then faceData.chin_bone_lowering = featureValue
            elseif featureIndex == 17 then faceData.chin_bone_length = featureValue
            elseif featureIndex == 18 then faceData.chin_bone_width = featureValue
            elseif featureIndex == 19 then faceData.chin_hole = featureValue
            elseif featureIndex == 20 then faceData.neck_thickness = featureValue
            end
            
            ChangeApparence({
                skin = {
                    face = faceData
                },
                save = true
            })
        end
    end

    if menuData.currentMenu == "variation ped" then 
        local ped = PlayerPedId()
        local componentId = currentButton.id
        
        -- La valeur actuelle de slidenum représente l'indice du drawable (model) sélectionné
        local drawableIndex = currentSlt
        print(drawableIndex, "drawableIndex", currentSlt, currentButton.slidenum-1, currentButton.advSlider[3])
        
        SetPedComponentVariation(ped, componentId, currentButton.slidenum-1, currentButton.advSlider[3], 0)
    end
end

local function onAdvSlide(PMenu, menuData, currentButton, _, currentButtons)
   if menuData.currentMenu == "apparence" then
        if currentButton.name == "Hair" then
            local hairColorIndex = currentButton.advSlider[3]
            ChangeApparence({
                clothes = {
                    hairs = {
                        color = hairColorIndex,
                    }
                },
                save = true
            })
        elseif currentButton.name == "Beard" then
            local beardColorIndex = currentButton.advSlider[3]
            local beardId = GetCurrentBeardStyle()
            ChangeApparence({
                head = {
                    beard = {
                        color = beardColorIndex,
                        id = beardId,
                        opacity = currentButton.opacity
                    }
                },
                save = true
            })
        elseif currentButton.name == "Eyebrows" then
            local eyebrowsColorIndex = currentButton.advSlider[3]   
            local eyebrowsOpacity = currentButton.opacity
            ChangeApparence({
                head = {
                    eyebrows = {
                        color = eyebrowsColorIndex,
                        opacity = eyebrowsOpacity
                    }
                },
                save = true
            })
        end
   end

   if menuData.currentMenu == "variation ped" then 
        local ped = PlayerPedId()
        local componentId = currentButton.id
        local currentDrawable = GetPedDrawableVariation(ped, componentId)
        local textureIndex = currentButton.advSlider[3]
        
        -- S'assurer que l'index de texture est valide
        local maxTextures = GetNumberOfPedTextureVariations(ped, componentId, currentDrawable)
        if textureIndex >= 0 and textureIndex < maxTextures then
            -- Appliquer la variation de texture
            SetPedComponentVariation(ped, componentId, currentDrawable, textureIndex, 0)
        end
   end
end

local function onSlider(PMenu, menuData, currentButton, _, _, parentSlider)
    if menuData.currentMenu == "parents" then
        print(json.encode(menuData), parentSlider, "onSlider")
        
        local buttonsData = PMenu.tempData[1]
        if buttonsData and buttonsData[1] and buttonsData[2] then
            local father = buttonsData[1].slidenum
            local mother = buttonsData[2].slidenum
            
            -- Calculate cycling index only for the menu display
            local displayFatherIndex = (father - 1) % 22
            local displayMotherIndex = (mother - 1) % 22
            
            -- Mettre à jour directement dans l'objet du menu
            -- Cette étape est importante pour conserver les valeurs
            PMenu.Menu["parents"].father = "male_" .. displayFatherIndex
            PMenu.Menu["parents"].mother = "female_" .. displayMotherIndex
            
            local skinData = {
                first = father - 1,
                second = mother - 1,
                skinFirst = father - 1,
                skinSecond = mother - 1,
                third = 0,
                skinThird = 0,
                thirdMix = 0
            }
            
            if currentButton.name == "Resemblance" then
                skinData.shapeMix = parentSlider
            elseif currentButton.name == "Tone" then
                skinData.skinMix = parentSlider
            end
            
            ChangeApparence({ 
                skin = { 
                    shape = skinData
                },
                save = true,
            })
        end
    end
end


local function onSelected(PMenu, MenuData, currentButton, currentSlt)

    if MenuData.currentMenu == "list of characters" then
        SaveCharacter({
            model = currentButton.name,
        })
        Tse("pedaccess:PutModel", currentButton.name)
    end

    if MenuData.currentMenu == "creation_character" then
        if currentButton.name == "List of characters" then
            print("List of characters")
        elseif currentButton.name == "Start playing" then
            CloseMenu(true)
            CloseCharacterCreation()
        end
    end
end

local function getListOfCharacters()
    local tblCharacters = {}
    for k, v in pairs(SkinMakerConfig.listCharacters) do
        tblCharacters[#tblCharacters + 1] = {name = v.model, role_temp = v.role}
    end
    return tblCharacters
end


local function getButtonsApparence()
    local tblButtons = {}
    tblButtons[#tblButtons + 1] = {name = "Hair", slidemax = function(slide) local ped = PlayerPedId() local maxHair = GetNumberOfPedDrawableVariations(ped, 2) return maxHair end, askX = true,
    advSlider = {0, GetNumHairColors()-1, 0}}
    tblButtons[#tblButtons + 1] = {name = "Beard", slidemax = GetPedHeadOverlayNum(1), askX = true,
    advSlider = {0, GetNumHairColors()-1, 0}, opacity = 1}   
    tblButtons[#tblButtons + 1] = {name = "Eyebrows", slidemax = GetPedHeadOverlayNum(2), askX = true,
    advSlider = {0, GetNumHairColors()-1, 0}, opacity = 1}
    return tblButtons
end

local function getMakeUp()
    local tblButtons = {}
    tblButtons[#tblButtons + 1] = {name = "Makeup", slidemax = GetPedHeadOverlayNum(4), askX = true,
    advSlider = {0, GetNumHairColors()-1, 0}, opacity = 1}
    tblButtons[#tblButtons + 1] = {name = "Blush", slidemax = GetPedHeadOverlayNum(5), askX = true,
    advSlider = {0, GetNumHairColors()-1, 0}, opacity = 1}
    tblButtons[#tblButtons + 1] = {name = "Lipstick", slidemax = GetPedHeadOverlayNum(8), askX = true,
    advSlider = {0, GetNumHairColors()-1, 0}, opacity = 1}
    return tblButtons
end

local function getFaces()
    local tblButtons = {}
    tblButtons[#tblButtons + 1] = {name = "Node width", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Nose width", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Nose peak height", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Nose peak length", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Nose bone height", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Nose peak lowering", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Nose bone twist", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Eyebrow height", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Eyebrow forward", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Cheeks bone height", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Cheeks bone width", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Cheeks width", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Eyes opening", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Lips thickness", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Jaw bone width", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Jaw bone length", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Chin bone lowering", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Chin bone length", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Chin bone width", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Chin hole", slidemax = 100, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Neck thickness", slidemax = 100, askX = true}
    return tblButtons
end

local function getInitPersonnalizeMenu()
    local tblButtons = {}

    tblButtons[#tblButtons + 1] = {name = "List of characters", ask = ">", askX = true}
    tblButtons[#tblButtons + 1] = {name = "Parents", ask = ">", askX = true}
    tblButtons[#tblButtons + 1] = {name = "Variation ped", ask = ">", askX = true}
    -- tblButtons[#tblButtons + 1] = {name = "Apparence", ask = ">", askX = true}
    -- tblButtons[#tblButtons + 1] = {name = "Make-up", ask = ">", askX = true}
    -- tblButtons[#tblButtons + 1] = {name = "Faces", ask = ">", askX = true}
    -- tblButtons[#tblButtons + 1] = {name = "Username", ask = ">", askX = true, canSee = function()
    --     if m_tblConfigSkinMaker.personnalizeMenu == "creation_character" then
    --         return true
    --     end
    --     return false
    -- end}
    tblButtons[#tblButtons + 1] = {name = "Start playing", ask = ">", askX = true}
    return tblButtons
end

local mother = {"Fatima", "Fatiha", "Kenza", "Mariam", "Paola", "Inès", "Myriam", "Jasmine", "Marla", "Léa", "Célia", "Alicia", "Solange", "Émilie", "Clara", "Clémence", "Camille", "Anais", "Emma", "Eva", "Marion", "Leonie", "Audrey", "Jasmine", "Giselle", "Amelia", "Isabella", "Zoe", "Ava", "Camilia", "Violet", "Sophie", "Evelyn", "Nicole", "Ashley", "Grace", "Briana", "Natalie", "Olivia", "Elizabeth", "Charlotte", "Emma", "Niko", "John"}
local father = {"Benjamin", "Daniel", "Joshua", "Noah", "Andrew", "Juan", "Alex", "Isaac", "Evan", "Ethan", "Vincent", "Angel", "Diego", "Adrian", "Gabriel", "Michael", "Santiago", "Kevin", "Louis", "Samuel", "Anthony", "Erwan", "Samuel", "Kevin", "Loic", "Sacha", "Etienne", "Elias", "Ayoub", "Hugo", "Lorenzo", "Gaspard", "Valentin", "Mathis", "Quentin", "Alexandre", "Kylian", "Ewan", "Luka", "Julian", "Thibault", "Tom", "Eliot", "Ilan"}


local function getParents()
    local tblButtons = {}
    tblButtons[#tblButtons + 1] = {name = "Father", slidemax = father, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Mother", slidemax = mother, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Resemblance", parentSlider = .75, askX = true}
    tblButtons[#tblButtons + 1] = {name = "Tone", parentSlider = .75, askX = true}
    return tblButtons
end

local function getVariationPed()
    local tblButtons = {}
    local pPed = PlayerPedId() 
    
    -- Check specifically for head variation (ID 0)
    local headDrawableVariations = GetNumberOfPedDrawableVariations(pPed, 0) - 1
    local currentHeadDrawable = GetPedDrawableVariation(pPed, 0)
    local headTextureVariations = GetNumberOfPedTextureVariations(pPed, 0, currentHeadDrawable) - 1
    
    -- Add head variation if it's modifiable
    if headDrawableVariations > 0 or headTextureVariations > 0 then
        tblButtons[#tblButtons + 1] = {
            name = "Head (Variation #0)",
            id = 0,
            advSlider = {0, math.max(headTextureVariations, 0), 0},
            slidemax = function(slide) return GetNumberOfPedDrawableVariations(PlayerPedId(), slide.id) - 1 end,
        }
    end
    
    -- Process other variations
    for i = 1, 20 do 
        local MaxVaria = GetNumberOfPedTextureVariations(pPed, i, GetPedDrawableVariation(pPed, i)) - 1
        if GetNumberOfPedDrawableVariations(pPed, i) - 1 > 0 or MaxVaria > 0 then
            tblButtons[#tblButtons + 1] = {
                name = "Variation #" .. i,
                id = i,
                advSlider = {0, math.max(MaxVaria, 0), 0},
                slidemax = function(slide) return GetNumberOfPedDrawableVariations(PlayerPedId(), slide.id) - 1 end,
            }
        end
    end

    return tblButtons
end


local _tableValue = {
    {id = 0, name = "ped"},
    {id = 1, name = "mask"},
    {id = 2, name = "hair"},
    {id = 3, name = "arms"},
    {id = 4, name = "pants"},
    {id = 5, name = "bags"},
    {id = 6, name = "shoes"},
    {id = 7, name = "chain"},
    {id = 8, name = "tshirt"},
    {id = 9, name = "bproof"},
    {id = 10, name = "decals"},
    {id = 11, name = "torso"},
}

local _tableValueProps = {
    {id = 0, name = "helmet"},
    {id = 1, name = "glasses"},
    {id = 2, name = "ears"},
    {id = 6, name = "watches"},
    {id = 7, name = "bracelets"},
}


local QuickMenu = {
    Base = { Header = {"commonmenu", "interaction_bgd"}, Blocked = true, Title = "Character Creation"},
    Data = { currentMenu = "creation_character"},
    Events = {
        onSlide = onSlide, 
        onSelected = onSelected,
        onButtonSelected = onButtonSelected,
        onBack = onBack, 
        onSlider = onSlider,
        onAdvSlide = onAdvSlide,
    },
    Menu = {
        ["creation_character"] = {NewTitle = "Character creation", label = "Character creation", b = getInitPersonnalizeMenu},
        ["list of characters"] = {b = getListOfCharacters},
        ["variation ped"] = {
            extra = true,
            NewTitle = "Variation ped", 
            label = "Variation ped", 
            b = getVariationPed, 
            -- canSee = function() return sex < 2 end
        },
        -- ["parents"] = {NewTitle = "Parents choice",label = "Parents", extra = true, charCreator = true, father = 'male_0', mother = 'female_0', b = getParents},
        -- ["apparence"] = {extra = true, NewTitle = "Apparence", label = "Apparence", b = getButtonsApparence},
        -- ["make-up"] = {extra = true,  NewTitle = "Make-up", label = "Make-up", b = getMakeUp},
        -- ["faces"] = {extra = true, NewTitle = "Faces", label = "Faces", b = getFaces},
    }
}

local function resetSceneAssets()
    DoScreenFadeOut(500)
    Wait(500)

    if m_tblConfigSkinMaker["creation_character"].cam then
        SetCamActive(m_tblConfigSkinMaker["creation_character"].cam, false)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(m_tblConfigSkinMaker["creation_character"].cam, false)
        m_tblConfigSkinMaker["creation_character"].cam = nil
    end

    m_tblConfigSkinMaker = Deepcopy(defaultState)
    Wait(250)
    DoScreenFadeIn(500)
end



local function requestSceneAssets() 
    DoScreenFadeOut(500)
    Wait(500)
    RequestStreamedTextureDict("pause_menu_pages_char_mom_dad", false)
    SetStreamedTextureDictAsNoLongerNeeded("pause_menu_pages_char_mom_dad", false)
    SetStreamedTextureDictAsNoLongerNeeded("pause_menu_pages_char_mom_dad", false)
    RequestStreamedTextureDict("char_creator_portraits", false)
    RequestStreamedTextureDict("mpleaderboard", false)
    SetStreamedTextureDictAsNoLongerNeeded("char_creator_portraits", false)
    
    -- Réinitialiser MyCharacter aux valeurs par défaut
    MyCharacter = {
        model = SkinMakerConfig.defaultModel or "mp_m_freemode_01",
        clothes = {
            hairs = { id = 0, txt = 0, color = 0 },
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
            beard = { id = 0, opacity = 1.0, color = 0 },
            eyebrows = { id = 0, opacity = 1.0, color = 0 },
            makeup = { id = 0, opacity = 0, color = 0 },
            blush = { id = 0, opacity = 0, color = 0 },
            lipstick = { id = 0, opacity = 0, color = 0 },
            eyes = { id = 0, opacity = 0, color = 0 },
        },
        skin = {
            shape = {
                first = 21,
                second = 15,
                third = 0,
                skinFirst = 21,
                skinSecond = 15,
                skinThird = 0, 
                shapeMix = 0.5,
                skinMix = 0.5,
                thirdMix = 0,
            },
            face = {
                nose_width = 0.5,        
                nose_peak_height = -0.3,  
                eyes_opening = 0.2,       
                lips_thickness = 0.1,     
                jaw_bone_width = 0.4,     
                cheeks_bone_height = 0.3
            }
        }
    }
    
    -- Appliquer le modèle de personnage
    ChangeApparence({
        model = MyCharacter.model,
    })
    
    Wait(250)
    
    -- Appliquer les caractéristiques du visage
    ChangeApparence({
        skin = MyCharacter.skin,
        save = true,
    })

    local ped = PlayerPedId()
    
    -- Définir une valeur par défaut pour les cheveux (ID 2)
    SetPedComponentVariation(ped, 2, 1, 0, 0) -- Changer 1 par un autre ID si nécessaire
    
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    
    local playerX, playerY, playerZ = table.unpack(pedCoords)
    
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
    m_tblConfigSkinMaker["creation_character"].cam = cam
    
    ClearPedProp(ped)
    SetPedComponentVariation(ped, 1, 0, 0, 2)
    
    local angle = math.rad(pedHeading)
    local camX = playerX + (math.sin(angle) * 1.5)
    local camY = playerY + (math.cos(angle) * 1.5)
    local camZ = playerZ
    SetCamCoord(cam, camX + 1.2, camY, camZ + 0.2)
    PointCamAtEntity(cam, ped, 0.0, 0.0, 0.0, true)
    
    SetCamFov(cam, 80.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    
    SetFocusEntity(ped)
    
    DisableControlAction(0, 30, true)
    DisableControlAction(0, 31, true)
    
    Wait(250)
    DoScreenFadeIn(500)
end

function OpenCharacterCreation(type)
    if m_tblConfigSkinMaker.active or not m_tblConfigSkinMaker[type] or IsPMenuVisible() then Logger:error("Personnalize Menu", "Skin Maker is already active or type is not valid") return end
    m_tblConfigSkinMaker.active = true
    m_tblConfigSkinMaker.personnalizeMenu = type or "creation_character"
    
    DoScreenFadeOut(500)
    Wait(500)
    requestSceneAssets()
    Wait(250)
    DoScreenFadeIn(500)

    CreateMenu(QuickMenu, {}) 
end




Citizen.CreateThread(function()
    local NPC_PedAccess = {
        safezone = "Hospital",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(229.0483, -1387.175, 30.47833, 231.0789),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                else 
                    ShowAboveRadarMessage("~r~You don't have access to this feature. Please buy ped access or be vip/vip+/mvp")
                end
            else
                ShowAboveRadarMessage("~r~You cannot open the ped access menu in a vehicle")
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_PedAccess_Highway = {
        safezone = "Highway",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(734.3801, -1210.297, 44.86603, 280.9143),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                else 
                    ShowAboveRadarMessage("~r~You don't have access to this feature. Please buy ped access or be vip/vip+/mvp")
                end
            else
                ShowAboveRadarMessage("~r~You cannot open the ped access menu in a vehicle")
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_PedAccess_Beach = {
        safezone = "Beach Safezone",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(-1078.883301, -1265.459839, 5.776030, 301.891357),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                else 
                    ShowAboveRadarMessage("~r~You don't have access to this feature. Please buy ped access or be vip/vip+/mvp")
                end
            else
                ShowAboveRadarMessage("~r~You cannot open the ped access menu in a vehicle")
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_PedAccess_Mara = {
        safezone = "Marabunta",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(1137.761, -1501.506, 34.6925, 275.3628),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                else 
                    ShowAboveRadarMessage("~r~You don't have access to this feature. Please buy ped access or be vip/vip+/mvp")
                end
            else
                ShowAboveRadarMessage("~r~You cannot open the ped access menu in a vehicle")
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_PedAccess_AA = {
        safezone = "Cross Field",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(1200.801, 1865.899, 78.01537, 234.5927),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                else 
                    ShowAboveRadarMessage("~r~You don't have access to this feature. Please buy ped access or be vip/vip+/mvp")
                end
            else
                ShowAboveRadarMessage("~r~You cannot open the ped access menu in a vehicle")
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_PedAccess_Blaine = {
        safezone = "Sandy Shores Safezone",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(2768.177, 3465.416, 55.60536, 70.1848),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                else 
                    ShowAboveRadarMessage("~r~You don't have access to this feature. Please buy ped access or be vip/vip+/mvp")
                end
            else
                ShowAboveRadarMessage("~r~You cannot open the ped access menu in a vehicle")
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }
    
    local NPC_PedAccess_Paleto = {
        safezone = "Hideout",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(1482.683, 6360.631, 23.80005, 102.1819),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                else 
                    ShowAboveRadarMessage("~r~You don't have access to this feature. Please buy ped access or be vip/vip+/mvp")
                end
            else
                ShowAboveRadarMessage("~r~You cannot open the ped access menu in a vehicle")
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_PedAccess_Paleto2 = {
        safezone = "Paleto",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(-946.4725, 6196.467, 3.759636, 42.12233),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                else 
                    ShowAboveRadarMessage("~r~You don't have access to this feature. Please buy ped access or be vip/vip+/mvp")
                end
            else
                ShowAboveRadarMessage("~r~You cannot open the ped access menu in a vehicle")
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    local NPC_PedAccess_Mountain = {
        safezone = "Mountain",
        pedType = 4,
        model = "a_f_y_epsilon_01",
        pos = vector4(-414.4756, 1127.17, 325.9052, 166.1116),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                end
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }


    local NPC_PedAccess_Main = {
        safezone = "Main SafeZone",
        pedType = 4,
        model = "a_f_y_fitness_02",
        pos = vector4(-525.2672, -218.4138, 37.61145, 36.55478),
        weapon = "weapon_combatmg",
        action = function()
            if not IsPedInAnyVehicle(PlayerPedId(), false) then
                if (GM.Player.Role == "vip" or GM.Player.Role == "vip+" or GM.Player.Role == "mvp" or GM.Player.Role == "god") or GM.Player.Data.ped_access then
                    OpenCharacterCreation("creation_character")
                end
            end
        end,
        drawText = "[ ~r~PED ACCESS ~s~]", 
        distanceLimit = 2.0,
        distanceShowText = 20.0,
    }

    RegisterSafeZonePedAction(NPC_PedAccess)
    RegisterSafeZonePedAction(NPC_PedAccess_Beach)
    RegisterSafeZonePedAction(NPC_PedAccess_Mara)
    RegisterSafeZonePedAction(NPC_PedAccess_AA)
    RegisterSafeZonePedAction(NPC_PedAccess_Blaine)
    RegisterSafeZonePedAction(NPC_PedAccess_Paleto)
    RegisterSafeZonePedAction(NPC_PedAccess_Paleto2)
    RegisterSafeZonePedAction(NPC_PedAccess_Mountain)
    RegisterSafeZonePedAction(NPC_PedAccess_Main)
end)

-- Function to clean up resources when exiting the character creation
function CloseCharacterCreation()
    if not m_tblConfigSkinMaker.active then return end
    
    resetSceneAssets()
    m_tblConfigSkinMaker.active = false
    m_tblConfigSkinMaker.personnalizeMenu = ""
end

-- Fonction pour obtenir le style de barbe actuel
function GetCurrentBeardStyle()
    local ped = PlayerPedId()
    local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(ped, 1)
    if success then
        return overlayValue
    end
    return 0 -- Valeur par défaut si échec
end