script_name("Ultimate Helper")

script_author("Mike")

script_version("1.2.5.1")



local sampev = require 'lib.samp.events'

local json = require 'dkjson'

local SCRIPT_VERSION = "1.2.5.1"

local UPDATE_URL_VERSION = "https://raw.githubusercontent.com/abhiarya531a/UltimateHelper/main/version.txt"

local UPDATE_URL_SCRIPT  = "https://raw.githubusercontent.com/abhiarya531a/UltimateHelper/main/uhhelper.lua"

local LOCAL_SCRIPT_PATH  = getWorkingDirectory() .. "\\uhhelper.lua"

local alreadyCheckedUpdate = false



local requests = require 'requests'





local defPath = 'moonloader\\config\\UltimateHelper\\Definations.json'

local def = {}



local file = io.open(defPath, "r")

if file then

    local content = file:read("*a")

    file:close()



    local data, _, err = json.decode(content)

    if err then

        sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}JSON Decode Error: " .. err, -1)

    else

        def = data

    end

else

    sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}FILE NOT FOUND: Definations.json", -1)

end



local checkpoint, blip



function download_version(callback)

    lua_thread.create(function()

        local r = requests.get(UPDATE_URL_VERSION)

        if r ~= nil and r.status_code == 200 then

            callback(r.text:gsub("%s+", ""))

        else

            callback(nil)

        end

    end)

end







function download_script(newVersion, callback)

    lua_thread.create(function()

        local r = requests.get(UPDATE_URL_SCRIPT)



        if r == nil or r.status_code ~= 200 then

            callback(false)

            return

        end



        local f = io.open(LOCAL_SCRIPT_PATH, "w")

        if not f then

            callback(false)

            return

        end



        f:write(r.text)

        f:close()



        -- Save version

        local vf = io.open(getWorkingDirectory() .. "\\version.txt", "w")

        vf:write(newVersion)

        vf:close()



        callback(true)

    end)

end



function checkForUpdates(auto)
    if auto and alreadyCheckedUpdate then return end
    if auto then alreadyCheckedUpdate = true end

    lua_thread.create(function()

        if not auto then
            sampAddChatMessage("{00FFCC}[Ultimate Helper]{FFFFFF} Manually checking for updates...", -1)
        end

        local versionFile = getWorkingDirectory() .. "\\version.txt"
        local localVer = SCRIPT_VERSION   -- fallback

        local f = io.open(versionFile, "r")
        if f then
            local line = f:read("*l")
            if line and line ~= "" then
                localVer = line
            end
            f:close()
        end

        download_version(function(remoteVer)

            if not remoteVer then
                sampAddChatMessage("{FF0000}[Ultimate Helper]{FFFFFF} Failed to check for updates.", -1)
                return
            end

            if localVer == remoteVer then
                if not auto then
                    sampAddChatMessage("{00FFCC}[Ultimate Helper]{FFFFFF} No updates available.", -1)
                end
                return
            end

            sampAddChatMessage("{00FFCC}[Ultimate Helper]{FFFFFF} Update found! Downloading...", -1)

            download_script(remoteVer, function(success)

                if not success then
                    sampAddChatMessage("{FF0000}[Ultimate Helper]{FFFFFF} Update failed!", -1)
                    return
                end

                -- Save version AFTER successful download
                local wf = io.open(versionFile, "w")
                if wf then
                    wf:write(remoteVer)
                    wf:close()
                end

                sampAddChatMessage("{00FFCC}[Ultimate Helper]{FFFFFF} Update installed! Restarting script...", -1)

                wait(300)
                thisScript():reload()
            end)
        end)
    end)
end




function main()

    repeat wait(100) until isSampAvailable()



    sampAddChatMessage("{00FFCC}[Ultimate Helper]{FFFFFF} Loaded successfully. Use /uhhelp", -1)

    register_commands()



    wait(1500) -- Good, prevents instant loop during startup

    checkForUpdates(true)

end





----------------------------------------------------

-- Clear checkpoint

----------------------------------------------------

function clearCheckpoint()

    if blip ~= nil then

        removeBlip(blip)

        blip = nil

    end

    if checkpoint ~= nil then

        deleteCheckpoint(checkpoint)

        checkpoint = nil

    end

end



----------------------------------------------------

-- Locations Checkpoints

----------------------------------------------------

local locations = {

    {keywords={"City Hall"}, X=1481.1517, Y=-1771.6178, Z=18.7958},

    {keywords={"Pizza Stacks"}, X=2105.0439, Y=-1806.6025, Z=13.5547},

    {keywords={"Precinct 13","P13"}, X=2114.3904, Y=-1742.7971, Z=13.5547},

    {keywords={"Precinct 14","P14"}, X=1892.6206, Y=-2244.0203, Z=13.5469},

    {keywords={"Precinct 16","P16"}, X=2851.0537, Y=-1532.5785, Z=11.0991},

    {keywords={"Precinct 47","P47"}, X=2231.5164, Y=-2414.696,  Z=13.5469},

    {keywords={"LSPD Substation","substation"}, X=671.044189, Y=-1580.689331,  Z=14.233282},

    {keywords={"All Saints General Hospital","Saints"}, X=1172.0851, Y=-1323.4723, Z=15.4033},

    {keywords={"Name Change Point"}, X=1154.731, Y=-1440.1605, Z=15.7969},

    {keywords={"Black Market (Market)","BM Market"}, X=1286.8057, Y=-1349.8904, Z=13.5705},

    {keywords={"Black Market (Blueberry)","BM Blueberry"}, X=162.354721, Y=-51.204547, Z=1.578125},

    {keywords={"County General Hospital", "CGH"}, X=126.224327, Y=-185.685729, Z=1.578125},

    {keywords={"Black Market (Glen Park)","BM Glen Park"}, X=1994.0483, Y=-1283.4844, Z=23.9656},

    {keywords={"Black Market (Idlewood)","BM Idlewood"}, X=2002.3705, Y=-1782.2762, Z=13.5537},

    {keywords={"The Dice Casino","Dice Casino","DC"}, X=761.08, Y=-1564.1429, Z=13.9289},

    {keywords={"Drug House","DH"}, X=2165.9602, Y=-1671.2227, Z=15.0732},

    {keywords={"Crack Lab","CL"}, X=2351.9561, Y=-1170.6648, Z=28.0747},

    {keywords={"Maximus Club","MC"}, X=1909.9646, Y=-1681.7267, Z=13.3234},

    {keywords={"Blueberry Clinic","BBC"}, X=1286.8057, Y=-1349.8904, Z=13.5705},

    {keywords={"Materials Factory 2","MF2"}, X=2287.9580, Y=-1105.7039, Z=37.9766},

    {keywords={"Materials Factory 3","MF3"}, X=-535.401794, Y=-502.685668, Z=25.517845},

    {keywords={"Materials Pickup 2","MP2"}, X=2390.4368, Y=-2007.8759, Z=13.5537},

    {keywords={"Fossil Fuel Company","FFC"}, X=2629.5376, Y=-2107.6904, Z=16.9531},

    {keywords={"Materials Pickup 1","MP1"}, X=1423.615, Y=-1320.486, Z=13.5547},

    {keywords={"Materials Factory 1","MF1"}, X=2171.877, Y=-2263.6768, Z=13.3312},

    {keywords={"Bank of Los Santos"}, X=1457.052, Y=-1009.9227, Z=26.8438},

    {keywords={"Precinct 3","P3"}, X=1329.161, Y=-982.8823, Z=33.8966},

    {keywords={"Rodeo Bank"}, X=595.5873, Y=-1250.7998, Z=18.2983},

    {keywords={"DMV"}, X=854.6744, Y=-605.1007, Z=18.4219},

    {keywords={"Drug Factory","DF"}, X=52.0209, Y=-293.1667, Z=1.7019},

    {keywords={"Materials Pickup 3","MP3"}, X=2159.0435, Y=-99.95099, Z=2.7487},

    {keywords={"Paintball","PB"}, X=1782.9871, Y=-1565.5262, Z=13.3472},

    {keywords={"Sprunk Factory","SF"}, X=1324.950805, Y=287.867492, Z=20.045194},

    {keywords={"Jefferson Motel"}, X=2233.1855, Y=-1159.8304, Z=25.8906},

    {keywords={"Boxing Arena","Boxing"}, X=2520.2581, Y=-1517.0487, Z=24.0009},

    {keywords={"The Smokin Beef Grill","The Smokin"}, X=2108.0776, Y=-1933.1447, Z=14.672},

    {keywords={"Auto Export Company","AEC"}, X=2729.7612, Y=-2451.5254, Z=17.5937},

}



local function getMatch(locations, kw)

    kw = kw:lower()

    for _, loc in ipairs(locations) do

        for _, k in ipairs(loc.keywords) do

            if k:lower():find(kw, 1, true) then

                return loc

            end

        end

    end

    return nil

end



function getMatchjson(a, kw)

    kw = kw:lower():gsub(' ', ''):gsub('-', '')

    local bm = nil



    for _, e in ipairs(a) do

        if e.keywords and type(e.keywords) == 'table' then

            for _, ekw in ipairs(e.keywords) do

                local ekws = ekw:lower():gsub(' ', ''):gsub('-', '')



                -- match ANYWHERE in the keyword

                if ekws:find(kw, 1, true) then

                    return e  -- first good match

                end

            end

        end

    end



    return nil

end





function cmdDef(kw)

    if kw == nil or kw == "" then

        sampAddChatMessage('USAGE: /def [query]', 0xAFAFAF)

        return

    end



    -- match entry

    local bm = getMatchjson(def, kw)

    if bm == nil then

        sampAddChatMessage('{00FFCC}[Ultimate Helper] {FFFFFF}No match found.', -1)

        return

    end



    ---------------------------------------------------------------------

    -- BUILD MESSAGE FROM JSON ENTRY

    ---------------------------------------------------------------------



    local msgt = {}



    -- First show main keyword

    if bm.keywords and bm.keywords[1] then

        table.insert(msgt, bm.keywords[1])

    end



    -- Add all other fields

    for k, v in pairs(bm) do

        if k ~= "keywords" then

            local keyname = k:sub(1,1):upper() .. k:sub(2)

            table.insert(msgt, string.format("%s: %s", keyname, v))

        end

    end



    -- Merge all results into one string

    local msg = table.concat(msgt, " | ")



    while #msg > 144 do

        sampAddChatMessage(msg:sub(1, 144), -1)

        msg = "-.." .. msg:sub(145)

    end



    sampAddChatMessage(msg, -1)

end







local function clearCheckpointSafe()

    if blip ~= nil then removeBlip(blip) blip=nil end

    if checkpoint ~= nil then deleteCheckpoint(checkpoint) checkpoint=nil end

end



local function cmdLoc(kw)

    if #kw == 0 then

        sampAddChatMessage("USAGE: /loc [query]", 0xAFAFAF)

        return

    end

    local bm = getMatch(locations, kw)

    if not bm then

        sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}No match found.", 0xFF5555)

        return

    end



    clearCheckpointSafe()

    blip = addBlipForCoord(bm.X, bm.Y, bm.Z)

    setCoordBlipAppearance(blip, 2)

    checkpoint = createCheckpoint(2, bm.X, bm.Y, bm.Z, bm.X, bm.Y, bm.Z, 15)



    lua_thread.create(function()

        while checkpoint ~= nil or blip ~= nil do

            local cx, cy, cz = getCharCoordinates(PLAYER_PED)

            if getDistanceBetweenCoords3d(cx, cy, cz, bm.X, bm.Y, bm.Z) <= 15 then

                clearCheckpointSafe()

				sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}You have reached your destination", -1)

                addOneOffSound(cx, cy, cz, 1058)

                break

            end

            wait(100)

        end

    end)



    sampAddChatMessage(string.format("{00FFCC}[Ultimate Helper] {FFFFFF}Follow the checkpoint to %s.", bm.keywords[1]), -1)

end



----------------------------------------------------

-- Definations Library

----------------------------------------------------

local ITEMS = {

    {

		keywords = {"Portable Radio"},

		from_shop = "$500",

		usage = "/setfreq or /pr"

	},

	{

		keywords = {"Cellphone"},

		from_shop = "$50",

		usage = "/call, /sms, /p, /h, /number, /rt, or /speakerphone"

	},

	{

		keywords = {"Phone Book"},

		from_shop = "$25",

		usage = "/number"

	},

	{

		keywords = {"Sprunk"},

		from_shop = "$1",

		usage = "/usesprunk"

	},

	{

		keywords = {"Industrial Lock"},

		from_shop = "$5,000",

		usage = "/pvl"

	},

	{

		keywords = {"Alarm Lock"},

		from_shop = "$1,000",

		usage = "Just an Alarm lock, always active"

	},

	{

		keywords = {"Spraycan"},

		from_shop = "$20",

		usage = "/colorcar or /paintcar"

	},

	{

		keywords = {"Dice"},

		from_shop = "$50",

		usage = "/dicebet as lvl 10+ or /dice"

	},

	{

		keywords = {"Condom"},

		from_shop = "$5",

		usage = "/sex"

	},

	{

		keywords = {"CD Player"},

		from_shop = "$5",

		usage = "/music"

	},

	{

		keywords = {"Cigar"},

		from_shop = "$5",

		usage = "/usecigar"

	},

	{

		keywords = {"Camera"},

		from_shop = "$20",

		usage = "Click Pictures"

	},

	{

		keywords = {"Rope"},

		from_shop = "$100",

		usage = "/tie, /drag, /detain, or /untie"

	},

	{

		keywords = {"Blindfold"},

		from_shop = "$100",

		usage = "/blindfold, /bf, /removeblindfold, or /removebf"

	},

}





local VEHICLES = {

	{

		keywords = {"Sultan"},

		from_grotti = "$50,000",

		from_players = "$40,000",

		seats = "4",

		speed = "140 MPH"

	},

	{

		keywords = {"Comet"},

		from_grotti = "$60,000",

		from_players = "$40,000",

		seats = "2",

		speed = "153 MPH"

	},

	{

		keywords = {"Super GT"},

		from_grotti = "$75,000",

		from_players = "$45,000",

		seats = "2",

		speed = "149 MPH"

	},

	{

		keywords = {"Alpha"},

		from_grotti = "$38,500",

		from_players = "$20,000",

		seats = "2",

		speed = "140 MPH"

	},

	{

		keywords = {"Blista Compact"},

		from_grotti = "$25,000",

		from_players = "$15,000",

		seats = "2",

		speed = "135 MPH"

	},

	{

		keywords = {"Sabre"},

		from_grotti = "$27,000",

		from_players = "$15,000",

		seats = "2",

		speed = "143 MPH"

	},

	{

		keywords = {"Club"},

		from_grotti = "$29,000",

		from_players = "$20,000",

		seats = "2",

		speed = "135 MPH"

	},

	{

		keywords = {"Euros"},

		from_grotti = "$32,000",

		from_players = "$20,000",

		seats = "2",

		speed = "137 MPH"

	},

	{

		keywords = {"ZR 350"},

		from_grotti = "$34,000",

		from_players = "$20,000",

		seats = "2",

		speed = "155 MPH"

	},

	{

		keywords = {"Perennial"},

		from_junkers = "$1,000",

		from_players = "$2,000",

		seats = "4",

		speed = "110 MPH"

	},

	{

		keywords = {"Sadler"},

		from_junkers = "$1,300",

		from_players = "$1,500",

		seats = "2 (Surfable)",

		speed = "125 MPH"

	},

	{

		keywords = {"Glendale"},

		from_junkers = "$1,500",

		from_players = "$2,000",

		seats = "4",

		speed = "122 MPH"

	},

	{

		keywords = {"Tampa"},

		from_junkers = "$1,500",

		from_players = "$2,000",

		seats = "2",

		speed = "127 MPH"

	},

	{

		keywords = {"Bravura"},

		from_junkers = "$2,000",

		from_players = "2,000",

		seats = "2",

		speed = "122 MPH"

	},

	{

		keywords = {"Vincent"},

		from_junkers = "$2,350",

		from_players = "$2,000",

		seats = "4",

		speed = "124 MPH"

	},

	{

		keywords = {"Willard"},

		from_junkers = "$2,500",

		from_players = "$2,000",

		seats = "4",

		speed = "124 MPH"

	},

	{

		keywords = {"Clover"},

		from_junkers = "$2,900",

		from_players = "$2,000",

		seats = "2",

		speed = "136 MPH"

	},

	{

		keywords = {"BMX"},

		from_willowfield = "$500",

		from_players = "$1,000",

		seats = "1",

		speed = "80 MPH"

	},

	{

		keywords = {"Faggio"},

		from_willowfield = "$1,000",

		from_players = "$2,000",

		seats = "2",

		speed = "153 MPH+"

	},

	{

		keywords = {"Wayfarer"},

		from_willowfield = "$9,000",

		from_players = "$10,000",

		seats = "2",

		speed = "153 MPH+"

	},

	{

		keywords = {"Freeway"},

		from_willowfield = "$14,000",

		from_players = "$15,000",

		seats = "2",

		speed = "170 MPH+"

	},

	{

		keywords = {"FCR 900"},

		from_willowfield = "$17,000",

		from_players = "$15,000",

		seats = "2",

		speed = "171 MPH+"

	},

	{

		keywords = {"BF 400"},

		from_willowfield = "$19,000",

		from_players = "$15,000",

		seats = "2",

		speed = "155 MPH+"

	},

	{

		keywords = {"Tornado"},

		from_coutt = "$8,500",

		from_players = "$10,000",

		seats = "2",

		speed = "131 MPH"

	},

	{

		keywords = {"Blade"},

		from_coutt = "$8,500",

		from_players = "$10,000",

		seats = "2",

		speed = "143 MPH"

	},

	{

		keywords = {"Voodoo"},

		from_coutt = "$8,500",

		from_players = "$10,000",

		seats = "2",

		speed = "140 MPH"

	},

	{

		keywords = {"Remington"},

		from_coutt = "$9,250",

		from_players = "$10,000",

		seats = "2",

		speed = "140 MPH"

	},

	{

		keywords = {"Broadway"},

		from_coutt = "$10,000",

		from_players = "$10,000",

		seats = "2",

		speed = "131 MPH"

	},

	{

		keywords = {"Savanna"},

		from_coutt = "$10,000",

		from_players = "$10,000",

		seats = "4",

		speed = "143 MPH"

	},

	{

		keywords = {"Virgo"},

		from_saints = "$11,000",

		from_players = "$10,000",

		seats = "2",

		speed = "124 MPH"

	},

	{

		keywords = {"Merit"},

		from_saints = "$12,500",

		from_players = "$10,000",

		seats = "4",

		speed = "130 MPH"

	},

	{

		keywords = {"Greenwood"},

		from_saints = "$12,500",

		from_players = "10,000",

		seats = "4",

		speed = "116 MPH"

	},

	{

		keywords = {"Elegant"},

		from_saints = "$14,500",

		from_players = "$10,000",

		seats = "4",

		speed = "138 MPH"

	},

	{

		keywords = {"Washington"},

		from_saints = "$15,000",

		from_players = "$10,000",

		seats = "4",

		speed = "127 MPH"

	},

	{

		keywords = {"Rancher"},

		from_saints = "$16,000",

		from_players = "$10,000",

		seats = "2",

		speed = "116 MPH"

	},

	{

		keywords = {"Premier"},

		from_saints = "$16,500",

		from_players = "$10,000",

		seats = "4",

		speed = "144 MPH"

	},

	{

		keywords = {"Admiral"},

		from_saints = "$19,500",

		from_players = "$15,000",

		seats = "4",

		speed = "136 MPH"

	},

	{

		keywords = {"Huntley"},

		from_saints = "$21,000",

		from_players = "$15,000",

		seats = "4",

		speed = "131 MPH"

	},

	{

		keywords = {"Picador"},

		from_blueberry = "$13,000",

		from_players = "$7,000",

		seats = "2 (Surfable)",

		speed = "125 MPH"

	},

	{

		keywords = {"Walton"},

		from_blueberry = "$10,000",

		from_players = "$15,000",

		seats = "2 (Surfable)",

		speed = "97 MPH"

	},

	{

		keywords = {"Quad"},

		from_blueberry = "$15,000",

		from_players = "$10,000",

		seats = "2",

		speed = "91 MPH"

	},

	{

		keywords = {"Bobcat"},

		from_blueberry = "$17,000",

		from_players = "$10,000",

		seats = "2 (Surfable)",

		speed = "116 MPH"

	},

	{

		keywords = {"Yosemite"},

		from_blueberry = "$17,000",

		from_players = "$10,000",

		seats = "2 (Surfable)",

		speed = "119 MPH"

	},

	{

		keywords = {"Yankee"},

		from_trucker = "$19,500",

		from_players = "$19,000",

		seats = "2",

		speed = "88 MPH"

	},

	{

		keywords = {"Mule"},

		from_trucker = "$21,500",

		from_players = "$17,000",

		seats = "2",

		speed = "87 MPH"

	},

	{

		keywords = {"Benson"},

		from_trucker = "$26,500",

		from_players = "$22,000",

		seats = "2",

		speed = "102 MPH"

	},

	{

		keywords = {"Buffalo"},

		from_sapphire = "$95,000",

		from_players = "$60,000",

		seats = "2",

		speed = "159 MPH"

	},

	{

		keywords = {"Cheetah"},

		from_sapphire = "$95,000",

		from_players = "$60,000",

		seats = "2",

		speed = "155 MPH"

	},

	{

		keywords = {"Elegy"},

		from_sapphire = "$95,000",

		from_players = "$60,000",

		seats = "2",

		speed = "147 MPH"

	},

	{

		keywords = {"Uranus"},

		from_sapphire = "$95,000",

		from_players = "$60,000",

		seats = "2",

		speed = "129 MPH"

	},

	{

		keywords = {"Jester"},

		from_sapphire = "$95,000",

		from_players = "$60,000",

		seats = "2",

		speed = "147 MPH"

	},

	{

		keywords = {"Banshee"},

		from_diamond = "$125,000",

		from_players = "$60,000",

		seats = "2",

		speed = "167 MPH"

	},

	{

		keywords = {"Turismo"},

		from_diamond = "$125,000",

		from_players = "$60,000",

		seats = "2",

		speed = "160 MPH"

	},

	{

		keywords = {"Bullet"},

		from_diamond = "$125,000",

		from_players = "$60,000",

		seats = "2",

		speed = "168 MPH"

	},

	{

		keywords = {"Infernus"},

		from_diamond = "$500,000",

		from_players = "$60,000",

		seats = "2",

		speed = "184 MPH"

	},

	{

		keywords = {"BF Injection"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "112 MPH"

	},

	{

		keywords = {"Baggage"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "82 MPH"

	},

	{

		keywords = {"Bandito"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "121 MPH"

	},

	{

		keywords = {"Barracks"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "91 MPH"

	},

	{

		keywords = {"Bike 1"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "86 MPH"

	},

	{

		keywords = {"Bike 2"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "107 MPH"

	},

	{

		keywords = {"Bloodring Banger"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "143 MPH"

	},

	{

		keywords = {"Boxville"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "89 MPH"

	},

	{

		keywords = {"Buccaneer"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "136 MPH"

	},

	{

		keywords = {"Burrito"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "130 MPH"

	},

	{

		keywords = {"Bus"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "9",

		speed = "108 MPH"

	},

	{

		keywords = {"Cabbie"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "118 MPH"

	},

	{

		keywords = {"Caddy"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "79 MPH"

	},

	{

		keywords = {"Cadrona"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "124 MPH"

	},

	{

		keywords = {"Camper"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "3",

		speed = "102 MPH"

	},

	{

		keywords = {"Cement Truck"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "108 MPH"

	},

	{

		keywords = {"Coach"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "9",

		speed = "131 MPH"

	},

	{

		keywords = {"Combine Harvester"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "91 MPH"

	},

	{

		keywords = {"DFT 30"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "108 MPH"

	},

	{

		keywords = {"Dozer"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "53 MPH"

	},

	{

		keywords = {"Duneride"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "91 MPH"

	},

	{

		keywords = {"Emperor"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "127 MPH"

	},

	{

		keywords = {"Esperanto"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "124 MPH"

	},

	{

		keywords = {"Feltzer"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "138 MPH"

	},

	{

		keywords = {"Flash"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "137 MPH"

	},

	{

		keywords = {"Flatbed"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "131 MPH"

	},

	{

		keywords = {"Forklift"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "50 MPH"

	},

	{

		keywords = {"Fortune"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "131 MPH"

	},

	{

		keywords = {"Hermes"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "124 MPH"

	},

	{

		keywords = {"Hotdog"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "89 MPH"

	},

	{

		keywords = {"Hotknife"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "138 MPH"

	},

	{

		keywords = {"Hotring Racer"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "178 MPH"

	},

	{

		keywords = {"Hotring Racer A"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "178 MPH"

	},

	{

		keywords = {"Hotring Racer B"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "178 MPH"

	},

	{

		keywords = {"Hustler"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "122 MPH"

	},

	{

		keywords = {"Intruder"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "124 MPH"

	},

	{

		keywords = {"Journey"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2 - Interior",

		speed = "89 MPH"

	},

	{

		keywords = {"Kart"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "77 MPH"

	},

	{

		keywords = {"Landstalker"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "131 MPH"

	},

	{

		keywords = {"Linerunner"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "91 MPH"

	},

	{

		keywords = {"Majestic"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "130 MPH"

	},

	{

		keywords = {"Manana"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "107 MPH"

	},

	{

		keywords = {"Mesa"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "116 MPH"

	},

	{

		keywords = {"Moonbeam"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "96 MPH"

	},

	{

		keywords = {"Mower"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "50 MPH"

	},

	{

		keywords = {"Mr Whoopee"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "82 MPH"

	},

	{

		keywords = {"Nebula"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "130 MPH"

	},

	{

		keywords = {"Oceanic"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "116 MPH"

	},

	{

		keywords = {"Packer"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "130 MPH"

	},

	{

		keywords = {"Patriot"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4 (Surfable)",

		speed = "130 MPH"

	},

	{

		keywords = {"Phoenix"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "142 MPH"

	},

	{

		keywords = {"Pony"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "91 MPH"

	},

	{

		keywords = {"Previon"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "124 MPH"

	},

	{

		keywords = {"Primo"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "118 MPH"

	},

	{

		keywords = {"Regina"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "116 MPH"

	},

	{

		keywords = {"Roadtrain"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "118 MPH"

	},

	{

		keywords = {"Romero"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "115 MPH"

	},

	{

		keywords = {"Rumpo"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "113 MPH"

	},

	{

		keywords = {"Sanchez"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "144 MPH"

	},

	{

		keywords = {"Sandking"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "146 MPH"

	},

	{

		keywords = {"Securicar"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4 - Interior",

		speed = "130 MPH"

	},

	{

		keywords = {"Sentinel"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "136 MPH"

	},

	{

		keywords = {"Slamvan"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "131 MPH"

	},

	{

		keywords = {"Solair"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "130 MPH"

	},

	{

		keywords = {"Stafford"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "127 MPH"

	},

	{

		keywords = {"Stallion"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "140 MPH"

	},

	{

		keywords = {"Stratum"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "128 MPH"

	},

	{

		keywords = {"Stretch"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "131 MPH"

	},

	{

		keywords = {"Sunrise"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "120 MPH"

	},

	{

		keywords = {"Sweeper"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "50 MPH"

	},

	{

		keywords = {"Tahoma"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "133 MPH"

	},

	{

		keywords = {"Tanker"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "100 MPH"

	},

	{

		keywords = {"Taxi"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "120 MPH"

	},

	{

		keywords = {"Topfun Van"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "113 MPH"

	},

	{

		keywords = {"Tractor"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "58 MPH"

	},

	{

		keywords = {"Trashmaster"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "83 MPH"

	},

	{

		keywords = {"Tug"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "71 MPH"

	},

	{

		keywords = {"Utility Van"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "100 MPH"

	},

	{

		keywords = {"Vortex"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "82 MPH"

	},

	{

		keywords = {"Windsor"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "131 MPH"

	},

	{

		keywords = {"Dodo"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "135 MPH+"

	},

	{

		keywords = {"Nevada"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "170 MPH+"

	},

	{

		keywords = {"Shamal"},

		from_importers = "$300,000",

		from_players = "$200,000",

		seats = "1 - Interior",

		speed = "225 MPH"

	},

	{

		keywords = {"Beagle"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "110 MPH+"

	},

	{

		keywords = {"Cropdust"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "105 MPH+"

	},

	{

		keywords = {"Stuntplane"},

		from_importers = "$300,000",

		from_players = "$250,000",

		seats = "2",

		speed = "125 MPH+"

	},

	{

		keywords = {"Cargobob"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2 - Interior",

		speed = "110 MPH+"

	},

	{

		keywords = {"Raindance"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "115 MPH+"

	},

	{

		keywords = {"Leviathan"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "2",

		speed = "85 MPH+"

	},

	{

		keywords = {"Sparrow"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1",

		speed = "60 MPH+"

	},

	{

		keywords = {"Maverick"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "4",

		speed = "90 MPH+"

	},

	{

		keywords = {"Squalo"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "85 MPH+"

	},

	{

		keywords = {"speeder"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "85 MPH+"

	},

	{

		keywords = {"Reefer"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "40 MPH+"

	},

	{

		keywords = {"Tropic"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "90 MPH+"

	},

	{

		keywords = {"Launch"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "65 MPH+"

	},

	{

		keywords = {"Coastguard"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "100 MPH+"

	},

	{

		keywords = {"Dinghy"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "85 MPH+"

	},

	{

		keywords = {"Marquis"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "45 MPH+"

	},

	{

		keywords = {"Jetmax"},

		from_importers = "$250,000",

		from_players = "$180,000",

		seats = "1 (Surfable)",

		speed = "65 MPH+"

	},

    {

        keywords = {"PCJ 600"},

        from_willowfield = "$20,000",

        from_players = "$15,000",

        seats = "2",

        speed = "140 MPH+"

    },

}



----------------------------------------------------

-- Gang HQ checkpoint

----------------------------------------------------

function cmdLocGangHQ(id)

    local gang = {

        [1]  = {2515.730712, -1363.045410, 28.359375, "{FFFF00}Barrio Vagos Locos XIII"},

        [2]  = {2513.364501, -1665.942626, 13.572557, "{00541B}Grove Street Families"},

        [3]  = {1022.388549, -1129.624145, 23.870040, "{990000}Yakuza"},

        [4]  = {1457.399658, -1487.122680, 13.546875, "{a3a3a3}Cosa Nostra"},

        [5]  = {2078.736328, -1201.436401, 23.909107, "{800080}Lynch Mob Ballas"},

        [6]  = {1567.918457, -1888.939941, 13.640942, "{666666}The Black Hand Triads"},

        [7]  = {2683.088867, -1417.370971, 30.496028, "{FF0000}East Side Bloods"},

        [8]  = {552.496948,  -1462.468017, 14.997178, "{335577}Extrema Nostra Tule"},

        [9]  = {2514.975830, -1954.274047, 16.810714, "{00FFFB}Puente Estrada"}

    }



    local g = gang[id]

    if not g then

        sampAddChatMessage("{FF5555}Invalid ID. Use 1 - 10.", -1)

		sampAddChatMessage("{BBBBBB}Gang 10 has been disbanded.", -1)

        return

    end



    local x, y, z, name = g[1], g[2], g[3], g[4]



    clearCheckpoint()



    blip = addBlipForCoord(x, y, z)

    setCoordBlipAppearance(blip, 2)

    checkpoint = createCheckpoint(2, x, y, z, x, y, z, 15)



    lua_thread.create(function()

        while checkpoint ~= nil or blip ~= nil do

            local cx, cy, cz = getCharCoordinates(PLAYER_PED)

            if getDistanceBetweenCoords3d(cx, cy, cz, x, y, z) <= 15 then

                clearCheckpoint()

				sampAddChatMessage("{00FFCC}[Ultimate Helper]  {FFFFFF}You have reached your destination", -1)

                addOneOffSound(cx, cy, cz, 1058)

                break

            end

            wait(100)

        end

    end)



    sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}Follow the checkpoint to " .. name, -1)

end



----------------------------------------------------

-- Faction HQ checkpoint

----------------------------------------------------

function cmdLocFacHQ(name)

    local factions = {

        ares = {2800.350097, -1087.771240, 30.718750, "{1C77B3}ARES Defence Solutions"},

        lspd = {1543.425781, -1675.820312, 13.556430, "{2641FE}Los Santos Police Department"},

        san  = {639.938598, -1357.453125, 13.406890, "{049C71}SAN News"},

        fbi  = {333.079132, -1516.795776, 35.867187, "{8D8DFF}Federal Bureau of Investigation"},

        fmd  = {1587.635620, -2188.119873, 13.546875, "{FF8282}Los Santos Fire and Medical Department"},

        sasd = {633.558044, -571.803955, 16.335937, "{CC9933}San Andreas Sheriff Department"}

    }



    if #name == 0 then

        sampAddChatMessage("{BBBBBB}Usage: /locfachq [Name]", -1)

        sampAddChatMessage("{BBBBBB}Available Names: ares | lspd | san | fbi | fmd | sasd", -1)

        return

    end



    local key = name:lower()

    local f = factions[key]

    if not f then

        sampAddChatMessage("{BBBBBB}Invalid Name. Available: ares | lspd | san | fbi | fmd | sasd", -1)

        return

    end



    local x, y, z, displayName = f[1], f[2], f[3], f[4]



    clearCheckpoint()



    blip = addBlipForCoord(x, y, z)

    setCoordBlipAppearance(blip, 2)

    checkpoint = createCheckpoint(2, x, y, z, x, y, z, 15)



    lua_thread.create(function()

        while checkpoint ~= nil or blip ~= nil do

            local cx, cy, cz = getCharCoordinates(PLAYER_PED)

            if getDistanceBetweenCoords3d(cx, cy, cz, x, y, z) <= 15 then

                clearCheckpoint()

                sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}You have reached your destination", -1)

                addOneOffSound(cx, cy, cz, 1058)

                break

            end

            wait(100)

        end

    end)



    sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}Follow the checkpoint to " .. displayName, -1)

end

function cmd_checkupdates()

    sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}Manually checking for updates...", -1)

    checkForUpdates()

end



function numWithCommas(n)

    return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()

end



function cmdlvl(level)

    level = tonumber(level)

    if level == nil or level < 2 then

        sampAddChatMessage('USAGE: /lvl [number should be >= 2]', 0xAFAFAF)

        return

    end



    local rp = 8 + (level - 2) * 4

    local mon = 5000 + (level - 2) * 2500

    local rpsum = (level - 1) * (8 + rp) / 2

    local monsum = (level - 1) * (5000 + mon) / 2



    sampAddChatMessage(string.format(

        "{33CCFF}Level %s:{FFFFFF} %s respect points + $%s | {33CCFF}Total from level 1:{FFFFFF} %s respect points + $%s",

        numWithCommas(level),

        numWithCommas(rp),

        numWithCommas(mon),

        numWithCommas(rpsum),

        numWithCommas(monsum)

    ), -1)

end



function cmdN(msg)

    if #msg == 0 then

        sampAddChatMessage('USAGE: (/n)ewbie [text]', 0xAFAFAF)

        return

    end



    local limit = 85  -- safe limit



    if #msg <= limit then

        sampSendChat("/newb " .. msg)

        return

    end



    -- FIND SAFE BREAKPOINT (last space before limit)

    local breakpoint = msg:sub(1, limit):match(".*() ")



    if not breakpoint then

        breakpoint = limit  -- fallback: no spaces found

    end



    -- FIRST PART: cut at last word boundary

    local part1 = msg:sub(1, breakpoint - 1) .. "..."



    -- SECOND PART: full word included

    local part2 = "..." .. msg:sub(breakpoint + 1)



    -- SEND MESSAGES

    sampSendChat("/newb " .. part1)

    sampSendChat("/g " .. part2)

end





function cmdAhr(params)

    if #params == 0 then

        sampAddChatMessage('USAGE: (/a)ccept(h)elp(r)equest [playerid]', 0xAFAFAF)

        return

    end

    sampSendChat('/accepthelp ' .. params)

end

function findItemByName(name)

    name = name:lower()

    for _, item in ipairs(ITEMS) do

        for _, key in ipairs(item.keywords) do

            if key:lower() == name then

                return item

            end

        end

    end

    return nil

end

----------------------------------------------------

-- Register commands

----------------------------------------------------

function register_commands()

    sampRegisterChatCommand("locghq", function(params)

        local id = tonumber(params)

        if not id then

            sampAddChatMessage("{BBBBBB}Usage: /locghq [Slot Number]", -1)

            return

        end

        cmdLocGangHQ(id)

    end)



    sampRegisterChatCommand("locfachq", function(params)

        cmdLocFacHQ(params)

    end)



    sampRegisterChatCommand("cpclear", function()

        clearCheckpoint()

        sampAddChatMessage("{00FFCC}[Ultimate Helper] {00FF00}All checkpoints cleared.", -1)

    end)



    sampRegisterChatCommand("hrs", function()

        sampSendChat("/helprequests")

    end)

    sampRegisterChatCommand("checkupdates", cmd_checkupdates)

    sampRegisterChatCommand("vehinfo", function(arg)

        if not arg or arg == "" then

            sampAddChatMessage("{BBBBBB}Usage: /vehinfo [vehicle name]", -1)

            return

        end

    

        local query = arg:lower():gsub("%s+", "")

    

        for _, v in ipairs(VEHICLES) do

            for __, key in ipairs(v.keywords) do

                if key:lower():gsub("%s+", "") == query then

                    local msg = string.format(

                        "{00FFCC}%s Info:{FFFFFF} | From Dealer: %s | From Players: %s | Seats: %s | Top Speed: %s",

                        key,

                        v.from_grotti or v.from_junkers or v.from_willowfield or v.from_importers or v.from_saints or v.from_blueberry or v.from_sapphire or v.from_diamond or v.from_coutt or v.from_trucker or "N/A",

                        v.from_players or "N/A",

                        v.seats or "N/A",

                        v.speed or "N/A"

                    )

					sampAddChatMessage("{00FFCC}[Ultimate Helper] {FFFFFF}", -1)

                    sampAddChatMessage(msg, -1)

                    return

                end

            end

        end

    

        sampAddChatMessage("{00FFCC}[Ultimate Helper] {FF8080}No vehicle found for: " .. arg, -1)

    end)



    sampRegisterChatCommand("uhhelp", function()

        sampAddChatMessage("{00FFCC}---- Ultimate Helper Commands ----", -1)

        sampAddChatMessage("{FFFFFF}/locghq [Slot Number] {BBBBBB}- Gang HQ locations", -1)

        sampAddChatMessage("{FFFFFF}/locfachq [Name] {BBBBBB}- Faction HQ locations", -1)

        sampAddChatMessage("{FFFFFF}/loc [Name] {BBBBBB}- Locate miscellaneous locations", -1)

        sampAddChatMessage("{FFFFFF}/vehinfo [Name] {BBBBBB}- Vehicle Information", -1)

        sampAddChatMessage("{FFFFFF}/cpclear {BBBBBB}- Clear checkpoint/blip", -1)

        sampAddChatMessage("{FFFFFF}/hrs {BBBBBB}- Show active help requests", -1)

        sampAddChatMessage("{FFFFFF}/lvl {BBBBBB}- Calculate the cost of level up", -1)

        sampAddChatMessage("{FFFFFF}/n {BBBBBB}- Shortform of /newb", -1)

        sampAddChatMessage("{FFFFFF}(/a)ccept(h)elp(r)equest [playerid] {BBBBBB}- Accept Help Request", -1)

        sampAddChatMessage("{FFFFFF}/iteminfo {BBBBBB}- Info about 24/7 items", -1)

		sampAddChatMessage("{FFFFFF}/def {BBBBBB}- Other Definations", -1)

		sampAddChatMessage("{FFFFFF}/checkupdates {BBBBBB}- Manually check for updates", -1)

		sampAddChatMessage("{FFFFFF}/uhupdates {BBBBBB}- Show Ultimate Helper update logs", -1)

        sampAddChatMessage("{FFFFFF}/uhhelp {BBBBBB}- Show command list", -1)

        sampAddChatMessage("{FFFFFF}-----------------------------", -1)

    end)



	sampRegisterChatCommand("uhupdates", function()

		sampAddChatMessage("{00FFCC}---- Ultimate Helper Updates ----", -1)

		sampAddChatMessage("{FFFFFF}v1.2.4 {BBBBBB}- Smart /n update.", -1)

		sampAddChatMessage("{FFFFFF}v1.2.3 {BBBBBB}- Minor Bugs Fixed", -1)

		sampAddChatMessage("{FFFFFF}v1.2.2 {BBBBBB}- Added Auto Update", -1)

		sampAddChatMessage("{FFFFFF}v1.2.1 {BBBBBB}- Added Auto Update(Beta Version)", -1)

		sampAddChatMessage("{FFFFFF}v1.2.0 {BBBBBB}- Added /def command", -1) 

		sampAddChatMessage("{FFFFFF}v1.1.2 {BBBBBB}- Gang List Updated", -1)

		sampAddChatMessage("{FFFFFF}v1.1.1 {BBBBBB}- Added /vehinfo command", -1)

		sampAddChatMessage("{FFFFFF}v1.1.1 {BBBBBB}- Added /iteminfo command", -1)

		sampAddChatMessage("{FFFFFF}v1.1.0 {BBBBBB}- Fixed /locghq command", -1)

		sampAddChatMessage("{FFFFFF}v1.0.0 {BBBBBB}- Initial release", -1)

		sampAddChatMessage("{FFFFFF}-----------------------------", -1)

	end)





    sampRegisterChatCommand("iteminfo", function(param)

        if not param or param == "" then

            sampAddChatMessage("{BBBBBB}USAGE:{FFFFFF} /iteminfo [item name]", -1)

            return

        end

    

        local item = findItemByName(param)

        if not item then

            sampAddChatMessage("{00FFCC}[Ultimate Helper] {FF0000}Item not found!", -1)

            return

        end

    

        sampAddChatMessage(

            string.format(

                "{00FFCC}Name: {FFFFFF}%s | {00FFCC}Price at 24/7: {FFFFFF}%s | {00FFCC}Usage: {FFFFFF}%s",

                table.concat(item.keywords, ", "),

                item.from_shop or "N/A",

                item.usage or "N/A"

            ), -1

        )

    end)



    sampRegisterChatCommand("loc", cmdLoc)

    sampRegisterChatCommand('lvl', cmdlvl)

    sampRegisterChatCommand('n', cmdN)

	sampRegisterChatCommand('ahr', cmdAhr)

	sampRegisterChatCommand('def', cmdDef)



    sampRegisterChatCommand("cpclear", function()

        clearCheckpointSafe()

        sampAddChatMessage("{00FFCC}[Ultimate Helper] {00FF00}All checkpoints cleared.", -1)

    end)

    sampRegisterChatCommand("clearcp", function()

        clearCheckpointSafe()

        sampAddChatMessage("{00FFCC}[Ultimate Helper] {00FF00}All checkpoints cleared.", -1)

    end)

end






























