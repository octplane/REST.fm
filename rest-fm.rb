#! /usr/bin/env ruby
require 'rubygems'
require 'sinatra/base'

require 'sinatra/reloader'
require 'json'
require 'socket'
class ShellFmClient  
  
  attr_reader :current_status
  def initialize(host, port)
    @host = host
    @port = port
    refresh
  end
  def get_connection()
    TCPSocket.open(@host, @port)
  end
  META = { 'creator'=>'a',
    'title'=>'t',
    'album'=>'l',
    'artistpage'=>'A',
    'trackpage'=>'T',
    'albumpage'=>'L',
    'duration'=>'d',
    'station'=>'s',
    'stationURL'=>'S',
    'remain'=>'R',
    'image'=>'I',
    'paused'=>'p'}
  def resolve_meta(param)
    META[param]
  end
  # This is what we ask to shell-fm
  INFO_FORMAT = ['creator', 'title', 'album', 'duration', 'station', 'remain', 'image', 'paused']
  def info(meta=nil)
    cx = get_connection
    if meta != nil
      command = "info %#{resolve_meta(meta)}"
    else
      command = "info "+INFO_FORMAT.map{ |f| "%#{ META[f]}" }.join("|")
    end
    cx.puts(command)
    out = ""
    while line = cx.gets
      out += line
    end
    cx.close()
    @stopped = (out == "||||||")
    puts out
    if meta == nil 
      @current_status ={}
      out.split(/\|/).each_with_index do |ret, index|
        @current_status[INFO_FORMAT[index]] = ret
      end
			@current_status['stopped'] = @stopped
    end
    return out
  end
  def refresh
    info()
  end
  def get(what)
    puts @current_status.inspect
    @current_status[what]
  end
  def send_command(cmd)
    get_connection.puts(cmd)
		refresh
  end
end


require 'erb'
class RESTfmApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :public, Proc.new { File.join(root, "public")}
  def RESTfmApp.configure(host, port)
    @@s = ShellFmClient.new(host, port)
    @@s.refresh
  end
  get '/info/_json' do
		@@s.refresh
		@@s.current_status.to_json
  end

	get '/info/image' do
		@@s.refresh
		@@s.info("image")
	end
  
  get '/api/exit' do
    exit(0)
  end
  
  ["play",
    "love",
    "ban",
    "skip",
    "quit",
    "pause",
    "discovery",
    "tag-artist",
    "tag-album",
    "tag-track",
    "artist-tags",
    "album-tags",
    "track-tags",
    "stop",
    "vol_up",
    "vol_down"].each do |command|
      get "/api/#{command}" do
        if params[:param] != nil
          c = command + " " + params[:param]
        else
          c = command
        end
        puts c
        @@s.send_command(c)
        redirect "/info"
      end
    end
    
    ['tag','artist'].each do |crit|
      get "/listen/#{crit}" do
        @@s.send_command("play lastfm://#{crit}/#{params[crit]}")
        redirect "/info"
      end
    end
  end
  
  if ARGV.length!=2
    print "Usage: rest.fm.rb <hostname> <port>"
    exit(-1)
  end
  
  RESTfmApp.configure(ARGV[0], ARGV[1].to_i)
  RESTfmApp.run!
