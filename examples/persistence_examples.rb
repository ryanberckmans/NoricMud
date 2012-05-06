problems with persistence api:
  * mud_object.save always calls async_save, need sync and async saves

# jim picks up tyche
tyche = picked_up
move_item tyche, jim 

# move an item from its location to destination
def move_item item, destination
  # key insight: because persistence is abstracted by MudObjects, moving the item in the game *is* moving it in persistence. The save(s) must be in a transaction and occur immediately (but of course, aysnchoronously). Facility to jump async queue
  # move item in game
  # transaction to move item in persistence
  NoricMud::async do
    NoricMud::transaction do
      previous_parent = item.parent # previous_parent is_a MudObject
      item.parent = jim
      jim.save # must be synchronous save, already in async block
      previous_parent.save if previous_parent # must be synchronous save, already in async block
    end
  end
end

# periodic save; each sovereign persisted mud_object saves itself on an independent timer
save_timer = PeriodicTimer Config::SAVE_INTERVAL do |sovereign_mud_object|
  sovereign_mud_object.async_save # all slave objects saved, e.g. inventory
end
sovereign_mud_object.bind(:logout) { save_timer.cancel }
