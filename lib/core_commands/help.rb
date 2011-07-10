
module CoreCommands
  class << self
    def help( game, mob, rest )
      game.send_msg mob, HELP_CMDS.find(rest)[:value]
    end

    private
    def help_basic
      help = <<eos
HELP ?

#{basic}
#{help_options}
eos
      help
    end

    def help_spells
      help = <<eos
HELP SPELLS  ? SPELLS

#{spells}
eos
      help
    end

    def help_combat
      help = <<eos
HELP COMBAT  ? COMBAT

#{combat}
eos
      help
    end

    def help_tips
      help = <<eos
HELP TIPS  ? TIPS

#{tips}
eos
      help
    end

    def help_cmds
      m = AbbrevMap.new help_basic, help_basic
      m.add "tips", HELP_TIPS
      m.add "spells", HELP_SPELLS
      m.add "combat", HELP_COMBAT
      m
    end

    def tips
      tips = <<eos
{!{FYTips:
{@abbreviate commands and targets{!{FG:{FC
  h s        {FG->{FC help spells
  c n fr     {FG->{FC cast nuke fred
  gl s       {FG->{FC glance samantha
{@target yourself with 'me'{!{FG:{FC
  c h me     {FG->{FC cast heal me
  c ref me   {FG->{FC cast reflect me
{@in combat, all spells will auto-target the enemy{!{FG:{FC
  cast burst {FG->{FC cast burst [your combat target]
{@don't get caught meditating :-D
eos
      tips
    end
    
    def format( cmds )
      s = ""
      cmds.each do |cmd| s += "#{cmd}\n" end
      s
    end

    def help_options
      commands = []
      commands << "{!{FChelp, ?     {FG-{@ show basic help"
      commands << "{!{FChelp combat {FG-{@ show combat help"
      commands << "{!{FChelp spells {FG-{@ show spells help"
      commands << "{!{FChelp tips   {FG-{@ show l33t tips"
      "{!{FYMore Help:\n" + format(commands)
    end
    
    def building
      commands = []
      commands << "{!{FCroom create"
      commands << "{!{FCroom default name"
      commands << "{!{FCroom toggle id"
      commands << "{!{FCroom name"
      commands << "{!{FCroom description"
      commands << "{!{FCroom exit"
      commands << "{!{FCroom unexit"
      commands << "{!{FCroom list"
      commands << "{!{FCroom safe"
      commands << "{!{FCroom quit"
      "{!{FYBuilding:\n" + format(commands)
    end
    
    def combat
      commands = []
      commands << "{!{FCkill <target>   {FG-{@ engage in combat"
      commands << "{!{FCflee            {FG-{@ attempt to run away from combat"
      commands << "{!{FCglance <target> {FG-{@ see health condition"
      commands << "{!{FCrest            {FG-{@ increases regeneration, but disables most commands"
      commands << "{!{FCstand           {FG-{@ get up from resting"
      commands << "{!{FCmeditate        {FG-{@ grants greatly increased regen, but stuns you for a short while"
      commands << "{!{FCweapon          {FG-{@ cycle through available weapons: dagger, sword, axe"      
      commands << "{!{FCexits           {FG-{@ show exits in current room"
      commands << "{!{FC--              {FG-{@ sending -- cancels all previously sent, pending, commands"
      "{!{FYCombat Commands:\n" + format(commands)
    end
    
    def basic
      commands = []
      commands << "{!{FCnorth       {FG-{@ move north"
      commands << "{!{FCeast        {FG-{@ move east"
      commands << "{!{FCsouth       {FG-{@ move south"
      commands << "{!{FCwest        {FG-{@ move west"
      commands << "{!{FCup          {FG-{@ move up"
      commands << "{!{FCdown        {FG-{@ move down"
      commands << "{!{FClook        {FG-{@ show what's in current room"
      commands << "{!{FCsay <msg>   {FG-{@ send msg to current room, also use single quote '<msg>"
      commands << "{!{FCshout <msg> {FG-{@ send msg to all players"
      commands << "{!{FCwhere, who  {FG-{@ show a list of online players"
      commands << "{!{FCquit"
      "{!{FYBasic Commands:\n" + format(commands)
    end

    def spells
      spells = []
      spells << "{!{FCcooldowns, cds           {FG-{@ show spells cooling down"
      spells << "{!{FCcast heal <target>       {FG-{@ massive heal"
      spells << "{!{FCcast burst <target>      {FG-{@ medium damage, medium cost"
      spells << "{!{FCcast pitter <target>     {FG-{@ low damage, very low cost"
      spells << "{!{FCcast nuke <target>       {FG-{@ after channeling a few seconds, unleash massive damage"
      spells << "{!{FCcast stun <target>       {FG-{@ target can't do anything for a few seconds; cancels channeling"
      spells << "{!{FCcast regenerate <target> {FG-{@ bestow a healing-over-time"
      spells << "{!{FCcast poison <target>     {FG-{@ bestow a damage-over-time"
      spells << "{!{FCcast shield <target>     {FG-{@ very temporary barrier absorbs flat amount of hp"
      spells << "{!{FCcast reflect <target>    {FG-{@ reflect the next hostile spell back to caster"
      "{!{FYSpell Commands:\n" + format(spells)
    end

  end # class << self

  HELP_BASIC = help_basic
  HELP_TIPS = help_tips
  HELP_COMBAT = help_combat
  HELP_SPELLS = help_spells
  HELP_CMDS = help_cmds
end
