
# NoricMud

A long-time hobby project, NoricMud is a game engine for a text-based online game.

# Branches

The "playable" branch is a prototype of the combat engine. A handful of spells and melee combat allow connected players to fight each other in a smaller, sandbox world. There's some cool special behaviors too, called "procs" in MUD parlance.

The "master" branch has a new object and persistence model and represents significant work over the "playable" branch.

# Requirements

NoricMud runs on ruby 1.9.2 and was designed for JRuby. As of 2014, the dependencies are a few years stale, as I haven't touched this project in awhile.

# Why JRuby?

When I switched to jruby, JRuby had true parallelism and superior memory management. This genre of online games is sensitive to latency: similar to a first-person shooter, it's no fun if you add even a few hundred milliseconds of latency. JRuby helps keep the player experience snappy.
