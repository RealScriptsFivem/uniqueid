# r_uid

This script lets you give every player a short unique ID, that will make your life easier, first of all, you can easily make this script work with your logging system and you can be sure which player is who, also those ID can be used as a flex factor for your players, the one who has a lower ID, started playing the server earlier. This system of SSN is used on most big server on fivem, so I decided to do one of myself.

---

## Features

- **Unique Identifier** Every player has a unique identifier.
- **Dynamic System:** Identifiers go from 1 to how much your server had players.
- **Exports** I created 3 basic exports for you to use with this resource.
- **Auto ESX:** So basically it will work with `ESX_MULTICHARACTER` and give ID automaticly without you having to put the export to generate it anywhere!

---

## Installation

1. **Download/Clone** the repository and place the `r_uid` folder into your FiveM resources directory.
2. Add the following line to your `server.cfg`:
   ```cfg
   ensure r_uid
   ```
3. Put the `setPlayerSSN` export to your multicharacter `IF` you use manual mode, ESX is fully automated so you dont need to change anything
4. You can use those exports in other resources (for example multicharacter for SSN display as on preview, or scoreboard to give player information about their SSN)
   ```lua
exports['r_uid']:getPlayerSSN(identifier)
exports['r_uid']:changePlayerSSN(identifier, numb)
exports['r_uid']:setPlayerSSN(identifier)
    ```

> **Note:** IF you need any help, then join my discord: [click](https://discord.gg/Yxx78f6rbG)
