idle-crafting
=============

.. dfhack-tool::
    :summary: Allow dwarfs to automatically satisfy their need to craft objects.
    :tags: fort gameplay

This script allows dwarves to automatically satisfy their crafting needs. The
script is configured through an overlay that is added to the main page of
craftsdwarf's workshops, as described below.

Usage
-----

::

    idle-crafting status

Overlay
-------

This script provides an overlay to the "Tasks" tab of craftsdwarf's workshops,
allowing you to designate that workshop for use by idle dwarfs to satisfy their
needs to craft objects. Workshops that have a master assigned cannot be used in
this way.

When a workshop is designated for idle crafting, this tool will create crafting
jobs and assigns them to idle dwarfs who have a need for crafting
objects. Currently, bone carving and stone crafting are supported, with bone
carving being the preferred option. This script respects linked stockpiles and
the setting for permitted general work orders from the "Workers" tab. Thus, to
designate a workshop for stone crafting only, simply disable the bone carving
labor on that tab.


