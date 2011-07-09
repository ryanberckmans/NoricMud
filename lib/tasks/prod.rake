#!/usr/bin/env ruby

namespace :mud do

  desc "stop, deploy, start"
  task update:[:stop, :deploy, :start]

  desc "deploy"
  task :deploy do
    puts `ssh mud@noric.org 'cd mud; git pull origin'`
  end

  desc "start"
  task :start do
    system "ssh -f mud@noric.org 'source ~/.bash_profile; cd mud/bin; export RAILS_ENV=development; ./mud'"
  end

  desc "stop"
  task :stop do
    `ssh mud@noric.org 'ps -C ruby -f | grep mud | sed "s/ \\{1,\\}/ /g" | cut -d" " -f2 | xargs kill -9 2> /dev/null'`
  end

  desc "stop then start"
  task bounce:[:stop, :start]
end
