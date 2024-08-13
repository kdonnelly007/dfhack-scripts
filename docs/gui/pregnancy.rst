gui/pregnancy
=============

.. dfhack-tool::
    :summary: Generate pregnancies with pairings of your choice.
    :tags: adventure fort armok animals units

This tool provides an interface for producing pregnancies with specific mothers
and fathers.

If a unit is selected when you run `gui/pregnancy`, they will be pre-selected
as a parent. If the unit has a spouse of a different gender, they will be
automatically selected as the other parent. You can click on other units on the
map and choose them as alternate mothers or fathers as desired.

If a unit is selected as a mother or father, or is listed as a spouse, you can
zoom the map to their location by clicking on their name in the `gui/pregnancy`
UI.

A unit must be on the map to participate in a pregnancy. For example, you
cannot designate a father that is not on-site, even if they are the selected
mother's spouse.

Children cannot be selected as a parent, and, due to game limitations,
cross-species pregnancies are not supported.

Usage
-----

::

    gui/pregnancy
