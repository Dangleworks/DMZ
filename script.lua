dmz_uiid = 0
dmz_zones = {}
dmz_radius = 1000
popups = {}

function onCreate(world_create)
	dmz_uiid = server.getMapID()
	dmz_zones = server.getZones("dmz")
end

function onPlayerJoin(steam_id, name, peer_id, is_admin, is_auth)
	addDMZZones(peer_id)
end

function addDMZZones(peer_id)
	for _, zone in pairs(dmz_zones) do
		local x,y,z = matrix.position(zone.transform)
		server.addMapObject(peer_id, dmz_uiid, 0, 8, x, z, 0, 0, 0, 0, "DMZ  - No PvP", dmz_radius, "No PvP in this zone", 0, 255, 0, 255)
	end
end
	
function onCustomCommand(full_message, user_peer_id, is_admin, is_auth, command, args)
	if  command == "?dmztest" and is_admin then
		server.announce("[DEBUG]", "Reloaded map markers")
		server.removeMapID(peer_id, dmz_uiid)
		addDMZZones(user_peer_id)
		local pos = server.getPlayerPos(user_peer_id)
		for _, z in ipairs(dmz_zones) do
			if matrix.distance(pos, z.transform) < dmz_radius then
				server.announce("[DEBUG]", "Is in zone")	
			end
		end
		
		for pid, val in pairs(popups) do
			server.announce("[DEBUG]", pid.."="..tostring(val))
		end
	end
end

function onTick(ticks)
	for i, p in ipairs(server.getPlayers()) do
		local in_zone = false
		for _, z in ipairs(dmz_zones) do
			local pos = server.getPlayerPos(p.id)
			if matrix.distance(pos, z.transform) < dmz_radius then
				in_zone = true
			end
		end
		if in_zone == true and not popups[p.id] then
			popups[p.id] = true
			server.setPopupScreen(p.id, dmz_uiid, "pvp", true, "You are in a DMZ\n\nNo PvP is allowed in this zone", 0.88, -0.7)
		elseif in_zone == false and popups[p.id] == true  then
			popups[p.id] = false
			server.removePopup(p.id, dmz_uiid)
		end
	end
end