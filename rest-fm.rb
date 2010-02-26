#! /usr/bin/env ruby
require 'rubygems'
require 'sinatra/base'

require 'socket'
class ShellFmClient
	def initialize(host, port)
		@host = host
		@port = port
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
		get_connection.puts(cmd)
	end
end


require 'erb'
class RESTfmApp < Sinatra::Base
	def RESTfmApp.configure(host, port)
		@@s = ShellFmClient.new(host, port)
	end
	get '/api/info' do
		@@s.info()
	end


	get '/info' do
		@artist, @title, @album, @duration, @station, @remain, @image =  @@s.info().split(/\|/)
		print @image
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
			@@s.send_command(command)
		end
	end
end

if ARGV.length!=2
	print "Usage: rest.fm.rb <hostname> <port>"
	exit(-1)
end

RESTfmApp.configure(ARGV[0], ARGV[1].to_i)
RESTfmApp.run!
