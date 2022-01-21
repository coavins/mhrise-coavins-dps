# coavins dps meter for Monster Hunter Rise (PC)

![Small screenshot 1](https://i.imgur.com/8hTPG8H.png)
![Small screenshot 2](https://i.imgur.com/G5Fx7eQ.png)

This mod adds an overlay that displays different types of damage dealt by your party members, and ranks them by total damage output.

This mod is solely intended to empower players with means of self-improvement. Please don't use the information provided by this tool to make hurtful comments toward other players.

Requires [REFramework](https://github.com/praydog/REFramework).

## Install

Just copy the `.lua` file into the autorun folder provided by REFramework.

If the game is running, you will have to either restart the game or use the Reset Scripts button in the REFramework overlay.

## Configuration

There are a few settings available at the top of the `.lua` file.

The size of the table will vary greatly depending on the screen resolution. Use these settings to adjust the table as needed.

## Usage

![Small screenshot 1](https://i.imgur.com/8hTPG8H.png)

The overlay will display each party member using the same color-coding that is shown with the player names on the left side of the screen.
Some additional colors are used to indicate other types of damage.

By default:
* Primary colors are physical and elemental damage
* Pale red is ailment damage
* Light blue is damage dealt by your palico or palamute

The following additional information can be printed inside the bars for each player:

![Small screenshot 2](https://i.imgur.com/G5Fx7eQ.png)

1. Your damage
2. Your share of the party's total damage
3. How much damage you're doing compared to the party's top damage dealer
4. How many total hits you have dealt
5. Your highest damage dealt in a single blow

Currently, the table only displays a summary of damage dealt to all large monsters.

### TODO:
* Actually track DPS
* Allow filtering by monster
* Implement settings UI
* Unit testing
