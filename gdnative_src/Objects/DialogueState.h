/*
 * Copyright 2021 feserr. All rights reserved.
 * License: https://github.com/feserr/Suada#License
 */

#ifndef DIALOGUE_STATE_H_
#define DIALOGUE_STATE_H_

#include <inttypes.h>

/**
 * @brief Dialogue state struct.
 *
 * Holds the state of a dialogue, like constant, configuration, etc.
 */
struct DialogueState {
  char letter;
  int32_t page;

  // Counts
  int32_t char_count;
  int32_t finished_count;
  int32_t audio_count;
  int32_t str_len;

  // Key pressed states.
  bool interact_pressed;
  bool up_pressed;
  bool down_pressed;
};

#endif  // DIALOGUE_STATE_H_
