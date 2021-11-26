/*
 * Copyright 2021 feserr. All rights reserved.
 * License: https://github.com/feserr/Suada#License
 */

#ifndef DIALOGUE_SYSTEM_H_
#define DIALOGUE_SYSTEM_H_

#include <vector>

#include <AnimatedSprite.hpp>
#include <AudioStream.hpp>
#include <AudioStreamPlayer2D.hpp>
#include <DynamicFont.hpp>
#include <Godot.hpp>
#include <Node2D.hpp>
#include <Viewport.hpp>

#include "Objects/Dialog.h"
#include "Objects/DialogueBox.h"
#include "Objects/DialogueConfig.h"
#include "Objects/DialogueState.h"

namespace godot {

/**
 * @brief Dialogue system class.
 *
 */
class DialogueSystem : public Node2D {
  GODOT_CLASS(DialogueSystem, Node2D)

 public:
  /**
   * @brief Construct a new Dialogue System object.
   */
  DialogueSystem();

  /**
   * @brief Destroy the Dialogue System object.
   */
  ~DialogueSystem();

  /**
   * @brief Registers the object methods to be used on godot and the properties
   * for the editor.
   */
  static void _register_methods();

  /**
   * @brief Called when the object is initialized.
   */
  void _init();

  /**
   * @brief Called when the node is "ready", i.e. when both the node and its children have entered
   * the scene tree.
   */
  void _ready();

  /**
   * @brief Called during the processing step of the main loop. Processing happens at every frame
   * and as fast as possible.
   *
   * @param delta time since the previous frame in seconds.
   */
  void _process(float delta);

  /**
   * @brief Draw the dialogue system.
   */
  void _draw();

  /**
   * @brief Called when there is an input event.
   *
   * @param event
   */
  void _input(Variant event);

  /**
   * @brief Setup the dialogue syste,
   *
   * @param gui_size Visible rect size.
   * @param interact_key The interact action name.
   * @param up_action The up action name.
   * @param down_action The down action name.
   * @param scale_factor The scale factor.
   * @param offset The offset for the text at name and dialogue box.
   * @param amplitude The amplitude factor for the effects.
   * @param frequency The frequency factor for the effects.
   */
  void Setup(Rect2 vis_rect_size, String interact_action, String up_action, String down_action,
             int8_t scale_factor = 1, Vector2 offset = {10, 18}, int8_t amplitude = 4,
             int8_t frequency = 2);

  /**
   * @brief Portrait animation finished callback.
   */
  void OnPortraitAnimationFinished();

 private:
  /**
   * @brief Initialize the dialogue system.
   *
   * Needs to be call after setup().
   */
  void InitDialogueSystem();

  /**
   * @brief Setups the state to show a new dialog of the dialogue.
   */
  void SetupDialogue();

  DialogueConfig m_config;

  DialogueBox m_portrait_frame_box;
  DialogueBox m_dialogue_box;
  DialogueBox m_name_box;
  DialogueBox m_finish_effect;

  Vector2 m_name_box_text;

  Ref<DynamicFont> m_default_font;

  AnimatedSprite* m_portrait_frame;

  AudioStreamPlayer2D* m_audio_player;

  Ref<AudioStream> m_voice_snd_effect;

  Color m_text_default_col;

  DialogueState m_dialog_state;

  Viewport* m_viewport;

  std::vector<Dialog> m_conversation;
};

}  // namespace godot

#endif  // DIALOGUE_SYSTEM_H_
