idle-crafting
=============

.. dfhack-tool::
    :summary: Allow dwarves to independently craft objects when they have the need.
    :tags: fort gameplay

This script allows you to mark specific Craftsdwarf's Workshops for use as
"recreational crafting" stations. Dwarves who feel the need to craft objects
will be able to go there to independently satisfy their crafting needs without
manual intervention from the player.

There will be a toggle on the workshop info sheet ("Tasks") tab when you
select a Craftsdwarf's Workshop in the UI. More details below.

Usage
-----

::

    idle-crafting status
    idle-crafting disable
    disable idle-crafting

The ``status`` command prints statistics about the status of the tool and the
satisfaction of "craft item" needs in your fort. Both variants of the
``disable`` command disallow idle crafting at all workshops and disable the
tool.

Examples
--------

``idle-crafting -t 10000,1000,500 status``
    Reset all thresholds to defaults and print status information.

Options
-------

``-t <number list>``, ``--thresholds <number list>``
    Sets the threshold(s) for the "craft item" need (i.e. the negated
    ``focus_level``) at which the tool starts to generate crafting jobs for a
    given unit. Units meeting earlier (higher) thresholds will be
    prioritized. Defaults to ``10000,1000,500``.


Overlay
-------

This script provides an overlay on the "Tasks" tab of Craftsdwarf's workshops,
allowing you to designate that workshop for use by idle dwarves to satisfy their
needs to craft objects. Workshops that have a master assigned cannot be used in
this way.

When a workshop is designated for idle crafting, this tool will create crafting
jobs and assign them to idle dwarves who have a need for crafting
objects. Currently, bone carving and stone crafting are supported, with stone
crafting being the default option. This script respects the setting for
permitted general work orders from the "Workers" tab. Thus, to designate a
workshop for bone carving, disable the stone crafting labor on for their
workshop, will keeping bone carving enabled.
