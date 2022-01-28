# coavins dps meter for Monster Hunter Rise (PC)

![screenshot-table-6](https://user-images.githubusercontent.com/91746207/151455752-8d84c769-f8d8-4aa6-9d11-4e98510fb1af.png)

This mod records all damage dealt to large monsters and can display a wide selection of information in a highly customizable overlay.

Please don't use the information provided by this tool to engage in harassment toward other players. All of the party members you meet are trying their best, and unsolicited comments about performance can be hurtful to players who may not have as much experience as you.

This mod is NOT intended to reveal any hidden information about monsters or give the player any unfair advantage. The goal is to help players know how they are performing without affecting the intended playing experience.

## Prerequisites

* [REFramework](https://github.com/praydog/REFramework)

## Install

1. Copy the `.lua` file into the autorun folder provided by REFramework.
2. Click `Reset scripts` in the REFramework window if the game was already running

## Configuration

There are some menus located in the REFramework window.
1. Expand `Script Generated UI`
2. Click on the coavins dps meter settings button

![Settings button](https://i.imgur.com/hYgwYE3.png)

![Settings menu](https://i.imgur.com/7i02AqR.png)

There are a few more settings available at the top of the `.lua` file. Saving and loading is not yet implemented, so if you want to change the default values, you will have to edit the lua file directly.

## Usage

![Small screenshot 1](https://i.imgur.com/8hTPG8H.png)

The overlay will display each party member using the same color-coding that is shown with the player names on the left side of the screen.
Some additional colors are used to indicate other types of damage.

By default:
* Primary colors are physical (light) and elemental damage (dark)
* Pale red is ailment damage
* Light blue is damage dealt by your palico or palamute

The following additional information can be printed inside the bars for each player:

![Small screenshot 2](https://i.imgur.com/G5Fx7eQ.png)

1. Your damage
2. Your share of the party's total damage
3. How much damage you're doing compared to the party's top damage dealer
4. How many total hits you have dealt
5. Your highest damage dealt in a single blow

You can also configure the table to show buddies, monsters, and NPCs as separate rows in the table.
