Area = {}
function Area:IsInZoneSafeRadius(position, safezone, radius)
    local dist = Vdist(position, safezone.coords.x, safezone.coords.y, safezone.coords.z)
    if dist <= radius then 
        return true 
    else
        return false
    end
end


Anim = {}
function Anim:RequestDict(dict)
	if dict and DoesAnimDictExist(dict) and not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)
		while not HasAnimDictLoaded(dict) do 
            Citizen.Wait(100) 
        end
	end
end

function Anim:RequestAnim(anim)
    if not HasAnimSetLoaded(anim) then
		RequestAnimSet(anim)
		while not HasAnimSetLoaded(anim) do
			Citizen.Wait(1)
		end
	end
end

Props = {}
function Props:RequestModel(model)
	if model and IsModelInCdimage(model) and not HasModelLoaded(model) then
		RequestModel(model)
		while not HasModelLoaded(model) do 
			Citizen.Wait(100) 
		end
	end
end