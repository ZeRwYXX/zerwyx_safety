# Zerwyx Chest Management System

## Description

This resource allows you to manage chests in your FiveM server with features such as code protection, weight and slot management, as well as full integration with **ox_inventory**. Additionally, you can modify chest codes, teleport to chests, and delete them with confirmation.

## Features

- **Chest Management**: Create, delete, and manage chest inventory directly in-game.
- **Code Protection**: Protect chests with a customizable code.
- **ox_inventory Integration**: Full support for **ox_inventory** stash management.
- **Notification System**: Modern notification system with Font Awesome icons.
- **Deletion Confirmation**: Confirm chest deletions with a pop-up.

## Installation

### Requirements

1. **ox_inventory** must be installed.
2. **ESX** (Latest version recommended).
3. **Font Awesome** for the notification icons.

### Steps

1. **Images Setup**
    - Place the inventory images in the folder: `Images/inventory`.
    - Make sure they are correctly loaded with **ox_inventory**.

2. **SQL Setup**
    - Depending on your version of ESX, you will need one of the following SQL files:
    
      - For limited items: Import `INSTALL-MOI/SQL/chest_limite.sql`.
      - For weight-based items: Import `INSTALL-MOI/SQL/chest_weight.sql`.

3. **Resource Installation**
    - Drop the `zerwyx_chest` folder into your FiveM resources directory.
    - Add `ensure zerwyx_chest` in your `server.cfg`.
    - Start your server and make sure no errors are reported.

### Configuration

You can configure the chest properties, such as slots and max weight, in the `config.lua` file.

## License

This resource is open-source and free to use under the MIT license.
