require 'bundler'
Bundler::GemHelper.install_tasks

# the following lines are so that resque workers can be run from rake within this project. mainly for testing
require 'resque/tasks'
task 'resque:setup' => :environment
task :environment do
  require 'cheetah'
end
