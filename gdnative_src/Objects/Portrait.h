/*
 * Copyright 2021 feserr. All rights reserved.
 * License: https://github.com/feserr/Suada#License
 */

#ifndef PORTRAIT_H_
#define PORTRAIT_H_

#include <utility>
#include <vector>

#include <String.hpp>

namespace godot {

/**
 * @brief Portrait struct.
 *
 * Hold the data of a portrait.
 */
struct Portrait {
  String portrait_path;
  int32_t animation_trigger;
  int32_t animation_rnd_start;
  int32_t animation_rnd_end;
};

}  // namespace godot

#endif  // PORTRAIT_H_
