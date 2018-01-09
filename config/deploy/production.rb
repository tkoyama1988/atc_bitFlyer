
server ENV["host"], user: ENV["user"], roles: %w{app}

set :ssh_options, {
  port: ENV["port"],
  forward_agent: true,
}

set :deploy_to, "/home/#{ENV["user"]}/atc_bitFlyer "
set :deploy_target, 'app'
set :branch, :master
