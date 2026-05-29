
local engine_scene_event = scene_event

function scene_event(instance, signalKey, argsTable)
    if engine_scene_event then
        engine_scene_event(instance, signalKey, argsTable)
    end
    if not instance or not instance:isValid() then
        return
    end
    if signalKey == "client_create_instance" then
        Lib.emitEvent(Event.EVENT_SCENE_OBJECT_CLIENT_CREATE_INSTANCE, instance)
    end
end