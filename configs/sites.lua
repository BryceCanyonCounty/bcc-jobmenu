-- Job Centers
Sites = {
    valentine = {
        shop = {
            name = 'Valentine Job Center',   -- Name of Shop on Menu
            prompt = 'Valentine Job Center', -- Text Below the Prompt Button
            distance = 2.0,                  -- Distance from NPC to Get Menu Prompt
            hours = {
                active = false,              -- Shop uses Open and Closed Hours
                open = 7,                    -- Shop Open Time / 24 Hour Clock
                close = 21                   -- Shop Close Time / 24 Hour Clock
            }
        },
        blip = {
            name = 'Valentine Job Center', -- Name of Blip on Map
            sprite = -1954662204,          -- Blip Sprite (Icon)
            show = {
                open = true,               -- Show Blip On Map when Open
                closed = true              -- Show Blip On Map when Closed
            },
            color = {
                open = 'WHITE', -- Shop Open - Default: White - Blip Colors Shown in Main Config
                closed = 'RED'  -- Shop Closed - Deafault: Red - Blip Colors Shown in Main Config
            }
        },
        npc = {
            active = true,                            -- Turns NPC On / Off
            model = 'U_M_M_BIVFOREMAN_01',            -- Model Used for NPC
            coords = vector3(-192.6, 627.36, 114.03), -- NPC and Shop Blip Positions
            heading = -30.0,                          -- NPC Heading
            distance = 100.0                          -- Distance Between Player and Shop for NPC to Spawn
        }
    },
}
