require "common.config.sound_config"
require "common.event_sound_manager"
require "common.define_sound_manager"


if World.isClient then
    require "client.manager.sound_manager"
    require "client.player.packet_sound_manager"
else
    require "server.player.packet_sound_manager"
    require "server.player.player_sound_manager"
    require "server.entity_sound_manager"
end