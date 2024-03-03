Config = {
    defaultlang = "en_lang", -- Default language

    Key = 0x446258B6,        --PGUP open menu

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
            label = "Hunter",
            value = "hunter",
            desc = "Become a bounty hunter!",
            jobGrades = {
                {
                    label = "Novice Tracker",
                    grade = 1,

                },
                {
                    label = "Apprentice Huntsman",
                    grade = 2,

                },
                {
                    label = "Skilled Stalker",
                    grade = 3,

                },
                {
                    label = "Seasoned Marksman",
                    grade = 4,

                },
                {
                    label = "Expert Ranger",
                    grade = 5,

                },
                {
                    label = "Master Huntsman",
                    grade = 6,

                },
            }
        },
        {
            label = "Bank Man",
            value = "bankman",
            desc = "I guess you work in a bank?",
            jobGrades = true
        },
        {
            label = "Stable Man",
            value = "stableman",
            desc = "I guess you work in the stables?",
            jobGrades = false
        }
    }
}
