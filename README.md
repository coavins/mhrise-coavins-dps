# coavins dps meter for Monster Hunter Rise (PC)

This mod records all damage dealt to large monsters and can display a wide selection of information in a highly customizable overlay.

![Standard look](https://user-images.githubusercontent.com/91746207/154783176-0961a66b-aa51-4c3c-b718-73d037b84683.png)

Please don't use the information provided by this tool to engage in harassment toward other players. All of the party members you meet are trying their best, and unsolicited comments about performance can be hurtful to players who may not have as much experience as you.

This mod is NOT intended to reveal any hidden information about monsters or give the player any unfair advantage. The goal is to help players know how they are performing without affecting the intended playing experience. 

## Prerequisites

* [REFramework](https://github.com/praydog/REFramework)
* [REFramework Direct2D](https://github.com/cursey/reframework-d2d)

## Install

1. Extract the .zip file into the `reframework` directory under your game install folder.

You should end up with the following folder structure:
```
MonsterHunterRise/
  reframework/
    autorun/
      mhrise-coavins-dps.lua
      mhrise-coavins-dps/
        <Numerous .lua files>
    data/
      mhrise-coavins-dps/
        colors/
        presets/
        saves/
        default.json
```
          
2. Click `Reset scripts` in the REFramework window if the game was already running.

## Configuration

You can configure settings from the UI inside the REFramework window.

1. Open the REFramework menu (default key: `Insert`)
2. Expand `Script Generated UI`
3. Click on the coavins dps meter `open settings` button

### Select columns

The following columns can be chosen to appear on the table for each player:

* Player HR
* Player name
* qDPS (based on elapsed quest duration)
* mDPS (based on time selected monsters have spent in combat)
* pDPS (based on time each player has been in the quest with you)
* Total damage
* Poison damage (poison ticking damage)
* Blast damage (blast explosion)
* Status buildup (paralysis, sleep, poison, blast, stun, etc.)
* Party % (percent of total party damage)
* Best % (percent of best damage dealer's output)
* Hits (number of hits)
* MaxHit (biggest single hit)
* Crit % (percent of hits that were critical)
* Weak % (percent of hits that were weak due to negative affinity)

Note: Poison and blast damage will be credited proportionately to players based on how much status buildup you contributed.

You can also configure the filters to show all damage dealers, not just players: buddies, monsters, and villager NPCs can appear as separate rows in the table.

## Usage

The overlay will display each party member using the same color-coding that is shown with the player names on the left side of the screen. Some additional colors are used to indicate different types of damage.

By default:
* Light player color is physical damage
* Dark player color is elemental damage
* Pale red is status buildup
* Pink is poison damage
* Orange is blast damage
* Light blue is damage dealt by your palico or palamute

## Screenshots

### Presets

#### Fylex
![Fylex preset](https://user-images.githubusercontent.com/91746207/154783679-3d8a7107-05fd-4677-a28d-32657b43dae8.png)

#### Immersive
![Immersive preset](https://user-images.githubusercontent.com/91746207/154784291-27369bb3-bb97-4fa7-8f8e-e9d6ce179190.png)

#### Clean
![Clean preset](https://user-images.githubusercontent.com/91746207/154781422-9747faa8-16f9-4b9f-aa8c-9667c6573e51.png)
