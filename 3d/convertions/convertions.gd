extends Node

## Provides helpers for converting between different coordinate systems.
class_name Convertions

## Minecraft flips the X location axis (it points towards the left side of the
## model). Multiply location vector by this value to convert between Minecraft
## and Godot coordinates.
const MC_GD_LOC = Vector3(-1, 1, 1)

## Minecraft flips the Y rotation axis (unlike the other rotations it's
## clockwise, not counter clockwise when the axis is facing towards the
## observer).
## The X axis is rotating counter clockwise (like in Godot), but since the X
## axis is flipped, the rotation on this axis also must be flipped. Rotating
##
## Multiply rotation vector by this value to convert betwee Minecraft
## and Godot rotations.
const MC_GD_ROT = Vector3(-1, -1, 1)
