require 'vendor/gems/environment'
require 'cramp/controller'
require 'uuid'
require 'mq'

Cramp::Controller::Websocket.backend = :thin

class TweetsController < Cramp::Controller::Websocket
  @@uuid = UUID.new
  
  on_start :display
  on_finish :close
  
  def display
    puts "WebSocket opened"

    twitter = MQ.new
    twitter.queue(@@uuid.generate).bind(twitter.fanout('twitter')).subscribe do |t|
      render t
    end
  end
  
  def close
    puts "WebSocket closed"
  end
end


Rack::Handler::Thin.run TweetsController, :Port => 3000