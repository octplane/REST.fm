#! /usr/bin/env ruby
require 'rubygems'
require 'sinatra'

require 'socket'

class ShellFmClient
	def initialize()
		@host = "192.168.0.1"
		@port = 54310
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

s = ShellFmClient.new()

get '/api/info' do
	s.info()
end

require 'erb'

get '/info' do
	@artist, @title, @album, @duration, @station, @remain, @image =  s.info().split(/\|/)
	print @image
	erb :info
end

get '/api/info/:criteria' do
	s.info(params[:criteria])
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
"stop"].each do |command|
	get "/api/#{command}" do
		s.send_command(command)
	end
end
