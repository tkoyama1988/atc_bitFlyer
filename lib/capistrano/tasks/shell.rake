namespace :shell do
  task :restart do
    set :api_key, ENV["api_key"]
    set :api_secret, ENV["api_secret"]
    set :webhook_url, ENV["webhook_url"]
    set :periods, ENV["periods"]
    set :size, ENV["size"]
    on roles(:app) do
      cmd = <<-EOS
        cd Cryptocurrency/current
        echo API_KEY='\"#{fetch(:api_key)}\"' > .env
        echo API_SECRET='\"#{fetch(:api_secret)}\"' >> .env
        echo WEBHOOK_URL='\"#{fetch(:webhook_url)}\"' >> .env
        echo ORDER_PERIODS='\"#{fetch(:periods)}\"' >> .env
        echo ORDER_SIZE='\"#{fetch(:size)}\"' >> .env
        mkdir -p log
        bash ./deploy_cap.sh
      EOS
      execute cmd
    end
  end
end