/*
 * Copyright 2021 feserr. All rights reserved.
 * License: https://github.com/feserr/Suada#License
 */

#include "DialogueSystem.h"

#include <Color.hpp>
#include <Engine.hpp>
#include <InputEvent.hpp>
#include <ResourceLoader.hpp>
#include <Sprite.hpp>
#include <Texture.hpp>
#include <Viewport.hpp>

#include "Utils/Log.hpp"

namespace godot {

const int kScaleFactor = 1;
const int kXOffset = 10;
const int kYOffset = 18;

DialogueSystem::DialogueSystem()
    : m_config{"key_a", "key_up", "key_down", 1, {10, 18}, {0, 0}, 0, 0, 0, {0, 0}, 0, 4, 2},
      m_portrait_frame_box(),
      m_dialogue_box(),
      m_name_box(),
      m_finish_effect(),
      m_name_box_text{-1, -1},
      m_default_font(
          ResourceLoader::get_singleton()->load("res://Assets/Fonts/FixedsysExcelsior.tres")),
      m_portrait_frame(),
      m_audio_player(),
      m_voice_snd_effect(),
      m_text_default_col(1.0f, 1.0f, 1.0f),
      m_dialog_state{'\0', 0, 0, 0, 0, 0, false, false, false} {}

DialogueSystem::~DialogueSystem() { m_viewport = nullptr; }

void DialogueSystem::_register_methods() {
  // inherited methods.
  register_method("_ready", &DialogueSystem::_ready);
  register_method("_process", &DialogueSystem::_process);
  register_method("_draw", &DialogueSystem::_draw);
  register_method("_input", &DialogueSystem::_input);

  // Class methods.
  register_method("setup", &DialogueSystem::Setup);

  // Signal methods.
  register_method("on_portrait_animation_finished", &DialogueSystem::OnPortraitAnimationFinished);

  register_property<DialogueSystem, Ref<DynamicFont>>(
      "Default font", &DialogueSystem::m_default_font, Ref<DynamicFont>(),
      GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT,
      GODOT_PROPERTY_HINT_RESOURCE_TYPE, "DynamicFont");

  register_property<DialogueSystem, Ref<AudioStream>>(
      "Vocal voice", &DialogueSystem::m_voice_snd_effect, Ref<AudioStream>(),
      GODOT_METHOD_RPC_MODE_DISABLED, GODOT_PROPERTY_USAGE_DEFAULT,
      GODOT_PROPERTY_HINT_RESOURCE_TYPE, "AudioStream");

  register_property<DialogueSystem, Color>("Text colour", &DialogueSystem::m_text_default_col,
                                           {1.0f, 1.0f, 1.0f}, GODOT_METHOD_RPC_MODE_DISABLED,
                                           GODOT_PROPERTY_USAGE_DEFAULT,
                                           GODOT_PROPERTY_HINT_RESOURCE_TYPE, "Color");
}

void DialogueSystem::_init() {}

void DialogueSystem::_ready() {
  m_config.target_fps = Engine::get_singleton()->get_target_fps();

  m_dialogue_box.box = get_node<Node2D>("DialogueBox");
  m_name_box.box = get_node<Node2D>("NameBox");
  m_portrait_frame_box.box = get_node<Node2D>("PortraitBox");
  m_finish_effect.box = get_node<Node2D>("FinishEffect");

  m_finish_effect.box->hide();

  m_portrait_frame = get_node<AnimatedSprite>("PortraitBox/PortraitBoxSprite");
  m_portrait_frame->connect("animation_finished", this, "on_portrait_animation_finished");

  m_audio_player = get_node<AudioStreamPlayer2D>("DialogueAudioPlayer");

  m_config.target_fps =
      !Engine::get_singleton()->get_target_fps() ? 60 : Engine::get_singleton()->get_target_fps();
  m_config.finish_num = 0;
  m_config.finish_spd = 15 / m_config.target_fps;

  SetupDialogue();
}

void DialogueSystem::_process(float delta) {
  // Call the _draw method.
  update();
}

void DialogueSystem::_draw() {}

void DialogueSystem::_input(Variant event) {
  Ref<InputEvent> input_map = event;

  m_dialog_state.interact_pressed = input_map->is_action_pressed(m_config.interact_action);
  m_dialog_state.up_pressed = input_map->is_action_pressed(m_config.up_action);
  m_dialog_state.down_pressed = input_map->is_action_pressed(m_config.down_action);
}

void DialogueSystem::InitDialogueSystem() {
  auto portrait_frame_texture =
      get_node<Sprite>("PortraitBox/PortraitBoxFrameSprite")->get_texture();
  auto dialogue_box_texture = get_node<Sprite>("DialogueBox/DialogueBoxSprite")->get_texture();
  auto name_box_texture = get_node<Sprite>("NameBox/NameBoxSprite")->get_texture();

  m_config.char_size = {m_default_font->get_string_size("M").width,
                        m_default_font->get_string_size("M").height};

  m_dialogue_box.size = dialogue_box_texture->get_size() * m_config.scale_factor;

  m_config.gui_diff = m_config.vis_rect_size.width - m_dialogue_box.size.width;

  m_portrait_frame_box.size.width = portrait_frame_texture->get_width() * m_config.scale_factor;

  // Set dialogue box position.
  m_dialogue_box.box->set_position(
      Vector2(m_config.gui_diff + m_portrait_frame_box.size.width,
              m_config.vis_rect_size.height - (m_dialogue_box.size.height / 2) - 4));
  auto dialogue_box_pos = m_dialogue_box.box->get_position();

  // Set name box position.
  m_name_box.box->set_position(Vector2(dialogue_box_pos.x - (m_dialogue_box.size.width / 2) +
                                           (name_box_texture->get_width() / 2) +
                                           (8 * m_config.scale_factor),
                                       dialogue_box_pos.y - (m_dialogue_box.size.height / 2) -
                                           ((name_box_texture->get_height() - 1) / 2)));
  auto name_box_pos = m_name_box.box->get_position();

  // Set portrait position.
  m_portrait_frame_box.box->set_position(
      {dialogue_box_pos.x - (m_dialogue_box.size.width / 2) - (m_portrait_frame_box.size.width / 2),
       dialogue_box_pos.y});

  m_name_box_text.x = name_box_pos.x + (name_box_texture->get_width() * m_config.scale_factor / 2);
  m_name_box_text.y = name_box_pos.y + m_config.offset.y;

  // Set finish effect position.
  m_finish_effect.box->set_position(
      Vector2(dialogue_box_pos.x + (m_dialogue_box.size.width / 2) - m_config.offset.x,
              dialogue_box_pos.y - (m_dialogue_box.size.height / 2) - m_config.offset.y));
}

void DialogueSystem::OnPortraitAnimationFinished() {}

void DialogueSystem::Setup(Rect2 vis_rect_size, String interact_action, String up_action,
                           String down_action, int8_t scale_factor, Vector2 offset,
                           int8_t amplitude, int8_t frequency) {
  m_config.vis_rect_size =
      vis_rect_size.size;  // TODO(feserr): Move this to _init when move the project to Godot 4.
  m_config.interact_action = interact_action;
  m_config.up_action = up_action;
  m_config.down_action = down_action;
  m_config.scale_factor = scale_factor;
  m_config.offset = offset;
  m_config.amplitude = amplitude;
  m_config.frequency = frequency;

  InitDialogueSystem();
}

void DialogueSystem::SetupDialogue() {
  // Reset variables
  m_dialog_state.char_count = 0;
}

}  // namespace godot
