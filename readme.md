Subsystem Targeting Orders
by Allectus

Mod effects:
============
Adds several new orders that allows you to direct your owned ships to explicitly target ship subsystems:

-AI order: Attack Engines
-AI order: Attack Shields
-AI order: Attack Turrets, Prioritizing Light Weapons
-AI order: Attack Turrets, Prioritizing Heavy Weapons
-AI order: Attack Missile Turrets

Requirements:
=============
SirNukes Mod Suppot API

What the mod does:
==================

This mod adds several orders to the right click menu on the map that allow you to explicitly target subsystems on hostile capital ships.

-AI order: Attack Engines -- destroy engines
-AI order: Attack Shields -- destroy shield generators, focussing on the active shield generators that provide the most maximum shield
-AI order: Attack Turrets, Prioritizing Light Weapons -- destroy weapons, focussing on weapons with the lowest max hp (correlates with anti-fighter weapons)
-AI order: Attack Turrets, Prioritizing Heavy Weapons -- destroy weapons, focussing on weapons with the highest max hp (correlates with anti-capital weapons)
-AI order: Attack Missile Turrets  -- destroy missile turrets

Once the subsystems covered by a given order have been destroyed the order concludes and wing may be tasked elsewhere.

See here for a demonstration: https://youtu.be/lxINgqgoo7U
1.1 update video here w/ fixed icon: https://www.youtube.com/watch?v=XuIgBJZ86S4

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
-Forleyor, the maker of the wonderful info center mod ( http://www.nexusmods.com/x4foundations/mods/268 ) went to great pains to help me with the icon issue and was instrumental in resolving it

-SirNukes for the Mod Support API ( http://www.nexusmods.com/x4foundations/mods/503 )that made the right click integration possible

-Vali_Lutzifer for the German translation

-Egosoft for making such a great game and supporting the mod community

History:
========
1.0, 2021-03-27: Initial release
1.1, 2021-03-27: Substantial refactor to address "question mark" icon issue.  Thanks to Forleyor for helping figure it out.
1.2, 2021-03-27: Added German translation; modified heaviest weapon targeting routine to allow multiple instances of the order to select different targets from the list of heaviest available weapons instead of always selecting the same target (avoids massive overkill for torp runs, but will make standard gun runs a little less effective--though more cinematic!).