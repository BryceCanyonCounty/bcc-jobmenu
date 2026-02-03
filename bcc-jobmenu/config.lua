Config = {
    defaultlang = "en_lang", -- Default language

    Key = 0x760A9C6F,        --PGUP open menu    key = 0x760A9C6F, --[G]   0x760A9C6F

    jobChangeDelay = 10,     -- Time in minutes

    Jobs = {
        {
            label = "Police",
            value = "police",
            desc = "Become a Police Officer!",
            jobGrades = {
                {
                    label = "Cadet",
                    grade = 1,

                },
                {
                    label = "Officer",
                    grade = 2,

                },
                {
                    label = "Sergeant",
                    grade = 3,

                },
                {
                    label = "Lieutenant",
                    grade = 4,

                },
                {
                    label = "Captain",
                    grade = 5,

                },
                {
                    label = "Chief",
                    grade = 6,

                },
            }
        },
        {
            label = "Doctor",
            value = "doctor",
            desc = "Become a bounty doctor!",
            jobGrades = false
        },
        {
            label = "Train Driver",
            value = "trainer",
            desc = "I guess you work in a train drive?",
            jobGrades = true
        },
        {
            label = "Farmer",
            value = "farmer",
            desc = "I guess you work in a farmer?",
            jobGrades = true
        },
        {
            label = "Rancher",
            value = "rancher",
            desc = "I guess you work in the rancher?",
            jobGrades = false
        }
    }
}

Config.locations = {
    { label = "Valentine",   coords = vector4(-192.6, 627.36, 114.03, -30.0) }
 --   { label = "Blackwater",  coords = vector4(-875.0, -1329.27, 43.96, 90.0) },
}

Config.NpcJobModel = "U_M_M_BIVFOREMAN_01"

Config.BlipJobName = "Job Center"