/*
 * Copyright 2021 feserr. All rights reserved.
 * License: https://github.com/feserr/Suada#License
 */

#ifndef DIALOGUE_BOX_H_
#define DIALOGUE_BOX_H_

#include <Godot.hpp>
#include <Node2D.hpp>

namespace godot {

/**
 * @brief Dialogue box struct.
 *
 * Holds the Node2D of the box and it's size and position.
 */
struct DialogueBox {
  Node2D* box;
  Vector2 size;
};

}  // namespace godot

#endif  // DIALOGUE_BOX_H_
