gui/pregnancy
=============

.. dfhack-tool::
    :summary: Generate pregnancies with pairings of your choice.
    :tags: adventure fort armok animals units

This tool provides an interface for producing pregnancies with specific mothers
and fathers. It can also assign or unassign spouses.

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

You can make the selected parents spouses by clicking on the "Set selected
<parent> as spouse" button, but the button is only enabled if you first
dissolve existing spouse relationships for both partners. If either new spouse
has existing lovers, you'll get a confirmation dialog, and if you choose to
proceed, the lover relationships will be removed.

Children and units that are insane cannot be selected as a parent, and, due to
game limitations, cross-species pregnancies are not supported.

Usage
-----

::

    gui/pregnancy

Technical notes
---------------

The reason for the requirement that a father must be on the map to contribute
to a pregnancy is that the genes used for the pregnancy are associated with the
physical unit. They are not stored with the "historical figure" that represents
the father when he is off-map.
