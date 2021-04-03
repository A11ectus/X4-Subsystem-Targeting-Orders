Subsystem Targeting Orders
by Allectus

https://github.com/A11ectus/X4-Subsystem-Targeting-Orders

Mod effects:
============
Adds several new orders to the holomap right-click menu that allows you to direct your owned ships to explicitly target ship and station subsystems:

-AI order: Attack Engines
-AI order: Attack Shields
-AI order: Attack Weps, Med Turrets
-AI order: Attack Weps, Hvy Turrets
-AI order: Attack Weps, Missile Launchers
-AI order: Attack Weps, Main Batteries
-AI order: Attack Subs, Disable All
-AI order: Attack Station Docks
-AI order: Attack Station Storage
-AI order: Attack Station Production
-AI order: Attack Station Def. Platforms
-AI order: Attack Station Shipyard Platforms

Requirements:
=============
SirNukes Mod Suppot API

What the mod does:
==================

This mod adds several orders to the right click menu on the map that allow you to explicitly target subsystems on hostile capital ships and stations.  The commands are context sensitive and will only appear if a salient target is available.

* AI order: Attack Engines -- destroy engines

* AI order: Attack Shields -- destroy shield generators of size L or XL, focussing on the active shield generators that provide the most maximum shield

* AI order: Attack Weps, Med Turrets -- destroy S & M sized turrets, focussing on weapons with the lowest max hp (correlates with anti-fighter weapons)

* AI order: Attack Weps, Hvy Turrets -- destroy L & XL sized turrets, focussing on weapons with the highest max hp (correlates with anti-capital weapons)

* AI order: Attack Weps, Missile Launchers  -- destroy missile turrets, focusing on weapons with the highest max hp (correlates with anti-capital weapons)

* AI order: Attack Weps, Main Batteries  -- destroy fixed weapons, focusing on weapons with the highest max hp (correlates with anti-capital weapons)

* AI order: Attack Subs, Disable All  -- single command that proceeds through all of the above commands in order: engines -> missile launchers -> med turrets -> hvy turrets -> shields -> batteries

* AI order: Attack Station Docks  -- Attack station dock modules, focussing on the closest matching target

* AI order: Attack Station Storage  -- Attack station storage modules, focussing on the closest matching target

* AI order: Attack Station Production  -- Attack station production modules, focussing on the closest matching target

* AI order: Attack Station Def. Platforms  -- Attack station defense platforms, focussing on the closest matching target

* AI order: Attack Station Shipyard Platforms  -- Attack station shipbuilding and outfitting modules, focussing on the closest matching target

Some Notes:

	* Once the subsystems covered by a given order have been destroyed the order concludes and wing may be tasked elsewhere.  This allows you to string together the commands as you see fit.  I recommend basically always knocking engines out first as it much easier to hit the other targets. 
	
	* Attack Weps, Main Batteries -- This targeting behaviour was originally rolled into the Attack Weps options but it turns out that the armoured cowling around, for example, the Behemoth's main batteries is actually pretty effective at protecting them and player ships can have a hard time finding a good attack vector without some manual help on initial positioning (in fact it's not clear that the logic is picking up on the batteries being obstructed by the hull and I haven't yet found a fix for it).  This often resulted in the target dying before any weapons were disabled if ships didn't have a good initial vector. Use wisely, commander.
		
	* Attack Subs, Disable All-- While convenient, note that this substantially amounts to an order to kill the target, but to do it much slower than if you'd just given a standard attack command since few ships are able to survive the sustained fire it takes to completely strip them while it still takes longer than necessary to apply that fire as your ships maneuver on target.  Use wisely, commander.
	
Recommended patterns:  
	
	* Attack engines (repeat on new target) : to get control of the battlespace
	
	* Attack engines -> attack missiles -> attack med turrets -> normal attack command : is my standard pattern to use bees to kill something dangerous.  
	
	* Attack engines -> attack missiles -> attack hvy turrets : to disable something for destroyers to mop up
	
	* Attack engines -> attack shields (repeat on new target) : if you have shield piercing weapons to rapidly remove hostile defences.
	
	* Attack storage (repeat on new target) : to cripple a hostile economy quickly and efficiently

See here for a demonstration: https://youtu.be/lxINgqgoo7U

1.1 update video here w/ fixed icon: https://www.youtube.com/watch?v=XuIgBJZ86S4

2.0 update video here: https://youtu.be/FqfZG0Jiw-Q

Install:
========
-Unzip to 'X4 Foundations/extensions/al_subsystem_targeting_orders'.

-Make sure the sub-folders and files are in 'X4 Foundations/extensions/al_subsystem_targeting_orders' and not in 'X4 Foundations/extensions/al_subsystem_targeting_orders'.

-If 'X4 Foundations/extensions/' is inaccessible, try 'Documents/Egosoft/X4/XXXXXXXX/extensions/al_subsystem_targeting_orders' - where XXXXXXXX is a number that is specific to your computer.

-Installation is savegame safe

Uninstall:
==========
-Delete the mod folder.

My Thanks:
============
-Forleyor, the maker of the wonderful Info Center mod ( http://www.nexusmods.com/x4foundations/mods/268 ) went to great pains to help me with the icon issue and was instrumental in resolving it

-SirNukes for the Mod Support API ( http://www.nexusmods.com/x4foundations/mods/503 )that made the right click integration possible

-Vali_Lutzifer for the German translation

-Rovermicrover, the maker of several Improved * mods ( https://github.com/rovermicrover ) for some tips on how to better identify turret types

-Egosoft for making such a great game and supporting the mod community

History:
========
1.0, 2021-03-27: Initial release
1.1, 2021-03-27: Substantial refactor to address "question mark" icon issue.  Thanks to Forleyor for helping figure it out.
1.2, 2021-03-28: Added German translation; modified heaviest weapon targeting routine to allow multiple instances of the order to select different targets from the list of heaviest available weapons instead of always selecting the same target (avoids massive overkill for torp runs, but will make standard gun runs a little less effective--though more cinematic!).
1.3, 2021-03-29: Improved target handling for wings. Wingmates with the "attack" assignment should now properly follow the targeting priorities of their wing leader.
2.0, 2021-04-02: Major feature release to support station targeting, provide generic disable command, and provide finer control over weapon targeting

2.0 major update:
	* Added filters to better control which orders appear in the right click menu
		* Player will only see subsystem targeting orders if target is not owned by the player
		* Each subsystem targeting order will only appear if a relevant active/destroyable subsystem is present on the target

	* Modified existing commands
		* Attack Shields will now only target shield generators larger than M size. This is based off of the module tags, so if a modder has added subsystems that do not respect Egosoft's tagging pradigm the subsystem may not be targeted.
		* Attack Weps, Lightest First has become Attack Weps, Med Turrets -- will only target M size or smaller turrets.  This is based off of the module tags, so if a modder has added subsystems that do not respect Egosoft's tagging pradigm the subsystem may not be targeted.
		* Attack Weps, Heaviest First has become Attack Weps, Hvy Turrets -- will only target turrets larger than M size.  This is based off of the module tags, so if a modder has added subsystems that do not respect Egosoft's tagging pradigm the subsystem may not be targeted.

	* Added new commands
		* Attack Weps, Main Batteries -- Will attack fixed weapons (not turrets) on the ship.  This targeting behaviour was originally rolled into the Attack Weps options but it turns out that the armoured cowling around, for example, the Behemoth's main batteries is actually pretty effective at protecting them and player ships can have a hard time finding a good attack vector without some manual help on initial positioning (in fact it's not clear that the logic is picking up on the batteries being obstructed by the hull and I haven't yet found a fix for it).  This often resulted in the target dying before the weapons were disabled if ships didn't have a good initial vector. Use wisely, commander.
		* Attack Subs, Disable All-- Single command that attacks all of the designated target's subsystems in the following order engines -> missile launchers -> med turrets -> hvy turrets -> shields -> batteries.  Note that this substantially amounts to an order to kill the target, but to do it much slower than if you'd just given a standard attack command since few ships are able to survive the sustained fire it takes to completely strip them while it still taking longer than necessary to apply that fire as your ships maneuver on target.  Use wisely, commander.
		* Attack Station Docks -- Attack the designated station's dock modules
		* Attack Station Storage -- Attack the designated station's storage modules
		* Attack Station Production -- Attack the designated station's production modules
		* Attack Station Def. Platforms -- Attack the designated station's defense platforms (including Admin towers)
		* Attack Station Shipyard Platforms -- Attack the designated station's ship construction/maintenance platforms
		
	* Modified targeting logic
		* Station module targeting orders will select the matching station module that is closest to the ship at the time the order is initiated (or recycled, if multiple matching modules are present and the first target is destroyed).  This will generally focus fire, but positioning of your fleet at order initiation is important and your fleet could be split up if they spread out.  Also note that these commands are functionally no different from the standard Egosoft attack commands--they just set the target.  Your ships may still wander into fire, as per vanilla behaviour.
		* Other orders will select target priorities based upon ancillary stats: M turrets order selects for the lowest max hull values; L turrets/battery/missiles selects for the highest max hull value; shields selects for the highest max shield value. The target will be randomly selected from the 3 highest scoring targets within the subsystem group.
	
	
