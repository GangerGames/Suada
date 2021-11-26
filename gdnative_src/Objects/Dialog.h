/*
 * Copyright 2021 feserr. All rights reserved.
 * License: https://github.com/feserr/Suada#License
 */

#ifndef DIALOG_H_
#define DIALOG_H_

#include <optional>
#include <utility>
#include <vector>

#include <Color.hpp>
#include <String.hpp>

#include "Portrait.h"

namespace godot {

/**
 * @brief Dialog struct.
 *
 * Hold the data of a dialog.
 */
struct Dialog {
  String text;
  std::optional<Portrait> portrait;
  int8_t type;
  std::vector<std::pair<int, int>> effects;
  std::vector<std::pair<int, Color>> _colours;
};

}  // namespace godot

#endif  // DIALOG_H_
