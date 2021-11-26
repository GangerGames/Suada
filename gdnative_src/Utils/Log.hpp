/*
 * Copyright 2021 feserr. All rights reserved.
 * License: https://github.com/feserr/Suada#License
 */

#ifndef LOG_H_
#define LOG_H_

#include <inttypes.h>

#include <GodotGlobal.hpp>
#include <string>

namespace godot {

enum LogLevel { info = 0, warning = 1, error = 2 };

static const char* loglevel_string[] = {
    "INFO",
    "WARNING",
    "ERROR",
};

/**
 * @brief Extracts the file name from __FILE__
 */
#define __FILENAME__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

/**
 * @brief Call Log_ with the file and line where it is call.
 */
#define Log(LogLevel, description) Log_(LogLevel, __FILENAME__, __FUNCTION__, __LINE__, description)

/**
 * @brief Prints the message as printf and adds the log level, file and line
 * where it was called.
 *
 * @param log_level The log level of the message.
 * @param file_name The file name where it was called.
 * @param line      The line where it was called.
 * @param format    Format of the message.
 * @param ...       Variables use in the message.
 */
template <class... Args>
void Log_(enum LogLevel log_level, const char* file_name, const char* function_name, uint32_t line,
          const std::string& description) {
  switch (log_level) {
    case 0:
      Godot::print(description.c_str());
      break;
#ifndef NDEBUG
    case 1:
      Godot::print_warning(description.c_str(), function_name, file_name, line);
      break;
    case 2:
      Godot::print_error(description.c_str(), function_name, file_name, line);
      break;
#endif
    default:
      break;
  }
  //   va_list args;
  //   va_start(args, format);
  //   vprintf(format, args);
  //   va_end(args);
}

}  // namespace godot

#endif  // LOG_H_
