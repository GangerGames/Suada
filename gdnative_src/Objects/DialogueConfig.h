/*
 * Copyright 2021 feserr. All rights reserved.
 * License: https://github.com/feserr/Suada#License
 */

#ifndef DIALOGUE_CONFIG_H_
#define DIALOGUE_CONFIG_H_

#include <String.hpp>
#include <Vector2.hpp>

namespace godot {

/**
 * @brief Dialogue config struct.
 *
 * Dialogue configuration related properties.
 */
struct DialogueConfig {
  // Key properties.
  String interact_action;
  String up_action;
  String down_action;

  // GUI properties.
  int8_t scale_factor;
  Vector2 offset;
  Vector2 vis_rect_size;
  float gui_diff;

  // Finish effect
  int32_t finish_num;
  float finish_spd;

  // Char sizes.
  Vector2 char_size;

  // Engine properties.
  int64_t target_fps;

  // Effect properties.
  int8_t amplitude;
  int8_t frequency;
};

}  // namespace godot

#endif  // DIALOGUE_CONFIG_H_
