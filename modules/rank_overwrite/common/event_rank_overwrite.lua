if World.isClient then
    Event.EVENT_FRIEND_RANK = Event.register("EVENT_FRIEND_RANK")
    Event.EVENT_All_RANK = Event.register("EVENT_All_RANK")
    Event.EVENT_ALL_SINGLE_RANK = Event.register("EVENT_ALL_SINGLE_RANK")
    Event.EVENT_GET_TOP3_SKIN = Event.register("EVENT_GET_TOP3_SKIN")
    Event.EVENT_UPDATE_TOP3_RANK = Event.register("EVENT_UPDATE_TOP3_RANK")
else
    Event.EVENT_RECEIVE_NEW_RANK_DATA = Event.register("EVENT_RECEIVE_NEW_RANK_DATA")
end
