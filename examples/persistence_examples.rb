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

# saving unstructured data
#  e.g. add a mod which allows ingame chess playing, saves in-progress games and elo
#  which layers do we touch to modify persisted data model?

# transactions:
## i) do we need transactions
## ii) do transactions require relational?

# persistence api
# load MudObject from persistence (i.e. the use-case where we don't start with the MudObject)
# save MudObject
# mark MudObject as persistent
# mark MudObject as transient

# persistence abstraction stack
# i) game:
  "save this MudObject... and do nothing if transient"
  "save these objects... and skip the ones that are transient"
  mud_object.save; MudObject.save_all player1, player2
# ii) persistence:
  "asynchronously update this data model and save it"
  "asynchronously start a transaction, update/save these models, end transaction"
  Note: "transaction at this layer doesn't know about data storage solution"
# iii) data model:
  "copy these persisted attributes and save"
  Note: transient MudObjects penetrate data model layer (to be copied) but go no further
# iv) data store:
  api: CRUD
  "CRUD these entities using a specific (3rd-party) storage solution e.g. activerecord"
  ? does data store layer support multiple storage layers at same time? No. But, in future might want to storage rooms in activerecord/postgres and player data in right_aws/dynamoDB, etc.
# v) third-party storage
  api: e.g. ActiveRecord::Base
  "CRUD with an underlying (physical) storage technology e.g. sqlite or dynamoDB"
# vi) physical storage

