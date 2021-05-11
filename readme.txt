Subsystem Targeting Orders:
============

By: Allectus

Contributors: Forleyor, Rovermicrover, runekn 
Translation: Vali_Lutzifer (DE), TiomTang (CN)

Github: https://github.com/A11ectus/X4-Subsystem-Targeting-Orders

Steam: https://steamcommunity.com/sharedfiles/filedetails/?id=2437198154

Nexus: https://www.nexusmods.com/x4foundations/mods/645

Mod effects:
============
Adds additional turret behaviours and several new orders to the holomap right-click menu that allows you to direct your owned ships to explicitly target ship and station subsystems.

Requirements:
=============
SirNukes' Mod Support API - https://www.nexusmods.com/x4foundations/mods/503
	Required for right click menu integration

(Optional) Kuertee's UI Extensions and HUD - https://www.nexusmods.com/x4foundations/mods/552
	If present with version of 2.06 or greater the mod will load in a high compatibility mode making it less likely (though not immune) to conflict with other UI mods

What the mod does:
==================

This mod adds several orders to the right click menu on the map that allow you to explicitly target subsystems on hostile capital ships and stations.  The commands are context sensitive and will only appear if a salient target is available.

	* AI order: Attack Engines -- destroy engines

	* AI order: Attack Shields -- destroy shield generators of size L or XL, focussing on the active shield generators that provide the most maximum shield

	* AI order: Attack Weps, Med Turrets -- destroy S & M sized turrets, focussing on weapons with the lowest max hp (correlates with anti-fighter weapons)

	* AI order: Attack Weps, Hvy Turrets -- destroy L & XL sized turrets, focussing on weapons with the highest max hp (correlates with anti-capital weapons)

	* AI order: Attack Weps, Missile Launchers  -- destroy missile turrets, focusing on weapons with the highest max hp (correlates with anti-capital weapons)

	* AI order: Attack Weps, Main Batteries  -- destroy fixed weapons, focusing on weapons with the highest max hp (correlates with anti-capital weapons)

	* AI order: Attack Subs, Disable All  -- single command that proceeds through all of the above commands in order: engines -> missile launchers -> hvy turrets -> med turrets -> shields -> batteries

	* AI order: Attack Station Docks  -- Attack station dock modules, focussing on the closest matching target

	* AI order: Attack Station Storage  -- Attack station storage modules, focussing on the closest matching target

	* AI order: Attack Station Production  -- Attack station production modules, focussing on the closest matching target

	* AI order: Attack Station Def. Platforms  -- Attack station defense platforms, focussing on the closest matching target

	* AI order: Attack Station Shipyard Platforms  -- Attack station shipbuilding and outfitting modules, focussing on the closest matching target

	* AI order: Clear Turret Subsystem Target  -- Clears turret subsystem targeting priority (see below) for all selected ships	
	
This mod further modifies turret targeting behaviour to allow for secondary targets and subsystem targeting:

	* Defend: No change

	* Attack All Enemies: attack subsystem target (if set) -> attack all enemies

	* Attack Capital Ships: No change

	* Attack Fighters: attack fighters -> attack incoming missiles -> attack subsystem target (if set) -> attack all enemies

	* Mining: No change    
    
	* Missile defence: attack incoming missiles -> attack fighters (as of X4 4.0HF3 the underlying vanilla missile defence routine is broken and will not attack targets under most circumstances; this is a vanilla bug and not a result of this mod)

	* Attack My Target: No change (hardcoded by Egosoft/cannot be changed)

Some Notes:

	* Once the subsystems covered by a given order have been destroyed the order concludes and wing may be tasked elsewhere.  This allows you to string together the commands as you see fit.  I recommend basically always knocking engines out first as it much easier to hit the other targets. 

	* Turret targeting behaviour is set/cleared for all turrets via the 'all turrets' drop down menu in the turret interface.  Turrets with a set subsystem target will prioritize subsystems on your selected target.  If a subsystem targeting order is given to the ship a matching subsystem turret target priority will also be set.  If the order subsequently concludes normally the turret subsystem targeting will be reset to the state it was in prior to the order being issued--if the order is forcefully cancelled this reset will not occur and the turret target will persist.
	
	* Turret targeting is a bit sticky by design and will not rapidly switch if new targets appear.  This is the reason I have not added attack all enemies to the stack for fighters/missile defence--they'll frequently get locked on to capitals and not do their primary job effectively.
	
	* When attacking with capital ships (L/XL) they will only see as valid targets subsystems that are within line of sight at order initiation (or order recycling if the initial target is destroyed).  If you see an available subsystem targeting order in the right click menu (indicating active subsystems) but your capital ships cancel the order immediately after it's issued it's because they don't have line of sight to the remaining active subsystems in that category.  This is to prevent excessive capital ship maneuvering to try and get shots on subsystems on the far side of the target.  This requirement is not enforced when targeting station modules.  Carriers are exempted from this requirement, so that they may appropriately send their subordinates to attack subsystems.
	
	* Attack Weps, Main Batteries -- This targeting behaviour was originally rolled into the Attack Weps options but it turns out that the armoured cowling around, for example, the Behemoth's main batteries is actually pretty effective at protecting them and player ships can have a hard time finding a good attack vector without some manual help on initial positioning (in fact it's not clear that the logic is picking up on the batteries being obstructed by the hull and I haven't yet found a fix for it).  This often resulted in the target dying before any weapons were disabled if ships didn't have a good initial vector. Use wisely, commander.
		
	* Attack Subs, Disable All-- While convenient, note that this substantially amounts to an order to kill the target, but to do it much slower than if you'd just given a standard attack command since few ships are able to survive the sustained fire it takes to completely strip them while it still takes longer than necessary to apply that fire as your ships maneuver on target.  Note also that the turret version of this command does note enforce any subsystem priority and will instead attack any available subsystem. Use wisely, commander. 
	
Recommended patterns:  
	
	* Attack engines (repeat on new target) : to get control of the battlespace
	
	* Attack engines -> attack missiles -> attack med turrets -> normal attack command : is my standard pattern to use bees to kill something dangerous.  
	
	* Attack engines -> attack missiles -> attack hvy turrets : to disable something for destroyers to mop up
	
	* Attack engines -> attack shields (repeat on new target) : if you have shield piercing weapons to rapidly remove hostile defences.
	
	* Attack station storage (repeat on new target) : to cripple a hostile economy quickly and efficiently

See here for a demonstration: https://youtu.be/lxINgqgoo7U

1.1 update video here w/ fixed icon: https://www.youtube.com/watch?v=XuIgBJZ86S4

2.0 update video here: https://youtu.be/FqfZG0Jiw-Q

2.1 update video here: https://youtu.be/7WC-eeMZ7EY

3.0 update video here: https://youtu.be/f5ppEomVwYQ

3.2 update video here: https://youtu.be/fpB0R7qzkwk

Install:
========
-Unzip to 'X4 Foundations/extensions/al_subsystem_targeting_orders'.

-Make sure the sub-folders and files are in 'X4 Foundations/extensions/al_subsystem_targeting_orders' and not in 'X4 Foundations/extensions/al_subsystem_targeting_orders'.

-Installation is savegame safe

Uninstall:
==========
-Delete the mod folder / unsubscribe on steam.

My Thanks:
============
-Forleyor, the maker of the wonderful Info Center mod ( http://www.nexusmods.com/x4foundations/mods/268 ) went to great pains to help me with the icon issue and was instrumental in resolving it.  He was also provided a large fraction of the turret UI code

-SirNukes for the Mod Support API ( http://www.nexusmods.com/x4foundations/mods/503 )that made the right click integration possible

-Rovermicrover, the maker of several Improved * mods ( https://github.com/rovermicrover ) for some tips on how to better identify turret types and improve script performance

-runekn, the maker of the reactive docking mod (https://www.nexusmods.com/x4foundations/mods/676) for some lua simplification assistance

-Egosoft for making such a great game and supporting the mod community

History:
========
* 1.0, 2021-03-27: Initial release

* 1.1, 2021-03-27: Substantial refactor to address "question mark" icon issue.  Thanks to Forleyor for helping figure it out.

* 1.2, 2021-03-28: Added German translation; modified heaviest weapon targeting routine to allow multiple instances of the order to select different targets from the list of heaviest available weapons instead of always selecting the same target (avoids massive overkill for torp runs, but will make standard gun runs a little less effective--though more cinematic!).

* 1.3, 2021-03-29: Improved target handling for wings. Wingmates with the "attack" assignment should now properly follow the targeting priorities of their wing leader.

* 2.0, 2021-04-02: Major feature release to support station targeting, provide generic disable command, and provide finer control over weapon targeting

* 2.1, 2021-04-03: Changed capital ship aggressor requirement when targeting subsystems other than station modules to require line of sight to the target subsystem on order initiation.  Should reduce the number of destroyers trying to (ineffectually) fly around targets to gen a firing solution on targeted subsystems.
	
* 3.0, 2021-04-10: Added additional targeting priorities/commands for turrets

* 3.1, 2021-04-11: Fixed Steam version being unable to load UI.

* 3.2, 2021-04-14: Added clear turrets command and CN translation; Also improved xpath specificity to improve mod compatibility 

* 3.2.1, 2021-04-15: Corrected CN translation file to remove invalid ampersand 

* 3.3, 2021-04-16: Added optional check against Kuertee's UI Extension to allow for high compatibility mode to be triggered if present.

* 3.4, 2021-05-11: Added support for Wing Hotkeys Mod; Altered disable all targeting priority to target heavy turrets before light turrets. Altered the Line of Sight requirement for capital ships to NOT apply to carriers, so they may send their subordinates appropriately.  Added attack all enemies as lowest priority targeting option for attack fighters turret commands. Lua refactored to unify library functions (thanks to runekn)