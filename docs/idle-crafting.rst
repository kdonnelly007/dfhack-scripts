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

This script provides an overlay to the "Tasks" tab of craftsdwarf's workshops,
allowing you to designate that workshop for use by idle dwarfs to satisfy their
needs to craft objects. Workshops that have a master assigned cannot be used in
this way.

When a workshop is designated for idle crafting, this tool will create crafting
jobs and assign them to idle dwarfs who have a need for crafting
objects. Currently, bone carving and stone crafting are supported, with stone
crafting being the default option. This script respects the setting for
permitted general work orders from the "Workers" tab. Thus, to designate a
workshop for bone carving, disable the stone crafting labor on for their
workshop, will keeping bone carving enabled.
