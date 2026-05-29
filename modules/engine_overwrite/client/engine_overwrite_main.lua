


local old_handle_render_tick = handle_render_tick
function handle_render_tick(frameTime, interpolationFraction)
    old_handle_render_tick(frameTime, interpolationFraction)
    Lib.emitEvent(Event.EVENT_HANDLE_RENDER_TICK_CLIENT, frameTime, interpolationFraction)
end