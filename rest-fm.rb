#! /usr/bin/env ruby
require 'rubygems'
require 'sinatra/base'

require 'sinatra/reloader'

require 'socket'
class ShellFmClient
	attr_reader :playing

	def initialize(host, port)
		@host = host
		@port = port
		send_command("play lastfm://user/recommended")
		send_command("skip")
		@playing = true
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
			'image'=>'I'}
	def resolve_meta(param)
		META[param]
	end
#          case 'Z':
#            // artist tags
#            taggingItem = 'a';
#            break;
#          case 'D':
#            // album tags
#            taggingItem = 'l';
#            break;
#          case 'z':
#            // track tags
#            taggingItem = 't';
#            break;
	def info(meta=nil)
		cx = get_connection
		if meta != nil
			command = "info %#{resolve_meta(meta)}"
		else
			command = "info %a|%t|%l|%d|%s|%R|%I"
		end
		cx.puts(command)
		out = ""
		while line = cx.gets
			 out += line
		end
		cx.close()	
		return out	
	end
	def send_command(cmd)
		case cmd
		when /pause/
			@playing = false
		when /play/
			@playing = true
		end
		puts cmd
		get_connection.puts(cmd)
	end
end


require 'erb'
class RESTfmApp < Sinatra::Base
	set :root, File.dirname(__FILE__)
	set :public, Proc.new { File.join(root, "public")}
	def RESTfmApp.configure(host, port)
		@@s = ShellFmClient.new(host, port)

	end
	get '/api/info' do
		@@s.info()
	end


	get '/info' do
		@artist, @title, @album, @duration, @station, @remain, @image =  @@s.info().split(/\|/)
		@playing = @@s.playing
		erb :info
	end

	get '/api/info/:criteria' do
		@@s.info(params[:criteria])
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
