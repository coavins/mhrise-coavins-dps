# coavins dps meter for Monster Hunter Rise (PC)

![Small screenshot 1](https://i.imgur.com/fSoDNnL.png)
![Small screenshot 2](https://i.imgur.com/Bt1Aro8.png)

This mod adds an overlay that displays different types of damage dealt by your party members, and ranks them by total damage output.

Requires [REFramework](https://github.com/praydog/REFramework).

## Install

Just copy the `.lua` file into the autorun folder provided by REFramework.

If the game is running, you will have to either restart the game or use the Reset Scripts button in the REFramework overlay.

## Configuration

There are a few settings available at the top of the `.lua` file.

The size of the table will vary greatly depending on the screen resolution. Use these settings to adjust the table as needed.

## Usage

The overlay will display each party member using the same color-coding that is shown with the player names on the left side of the screen.
Some additional colors are used to indicate other types of damage. By default:
* Primary colors are physical (dark) and elemental (light) damage
* Dark red is ailment damage
* Light blue is damage dealt by your palico or palamute

The following additional information is printed inside the bars for each player:
1. Your damage
2. Your share of the party's total damage
3. How much damage you're doing compared to the party's top damage dealer

Currently, the table only displays a summary of damage dealt to all large monsters.

![Large screenshot](https://i.imgur.com/3yhX77g.png)

### TODO:
* Allow filtering by monster
* Implement settings UI
* Unit testing
