# Job Menu

#### Description

Allows players to switch between jobs at will. Players set their own Job Grade after selecting a job from the menu.

### FEATURES

- Configurable job menu open to all users
- Set job grade between 1 and 99

### Configuration

```lua
DisallowSetGrade = false -- Set to true and the default grade is set.

Jobs = {
    {
        label = "Police", -- Label shown on the menu.
        value = "police", -- job name.
        defaultGrade = 1, -- Default Grade for the job. Used if DisallowSetGrade is true.
        desc = "Become a Police Officer!" -- Description shown (Might outline grade options)
    },
    {
        label = "Hunter", -- Label shown on the menu.
        value = "hunter", -- job name.
        defaultGrade = 1, -- Default Grade for the job. Used if DisallowSetGrade is true.
        desc = "Become a Bounty Hunter!" -- Description shown (Might outline grade options)
    },
}
```

#### INSTALATION

- add `ensure bcc_jobmenu` to your `resources.cfg`.
- restart server, enjoy.

### DEPENDENCIES

- Lua version of [VORP_INPUTS](https://github.com/VORPCORE/vorp_inputs-lua)
- [menuapi](https://github.com/outsider31000/menuapi)

### SUPPORT

Feel free to create an issue if you need assitance or have issues. You can also visit my [official support discord](https://discord.gg/BSmJQbtBQ8).

### Credits

- Outsider for the Menu API and Inputs. I also used vorp_admin as a reference to using the menu api.
