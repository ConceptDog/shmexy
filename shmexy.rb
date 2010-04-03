require 'rubygems'
require 'eventmachine'
require 'uuidtools'
require 'shmexy_connection'

class Shmexy
	attr_reader :signature
	attr_reader :connections

	def initialize
		@connections = {}
		@settings = { "ip" => '0.0.0.0', "port" => 3303 }
	end

	def Shmexy.create
		self.new
	end

	def settings conf
		@settings = conf
	end

	def start
		pp @settings
		EM.run do
			@signature = EM.start_server @settings['ip'], @settings['port'], ShmexyConnection do |con|
				con.id = UUIDTools::UUID.timestamp_create
				con.server = self
				@connections[con.id] = con
			end
		end
	end

	def stop
		@connections.each_value { |con| con.close_connection }
		EM.stop
	end

	def disconnect id
		@connections[id].close_connection if @connections.has_key? id
	end

	def drop connection
		@connections.delete connection.id
	end

	def receive connection, data
		puts "Recieved message from #{connection.id}, they said #{data}"
	end

	def send id, data
		
	end
end