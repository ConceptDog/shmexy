require 'rubygems'
require 'eventmachine'
require 'uuidtools'

class Shmexy
	attr_reader :signature
	attr_reader :connections
	attr_accessor :room_manager
	attr_accessor :command_generator

	def initialize
		@connections = {}
		@settings = { "ip" => '0.0.0.0', "port" => 3303 }
	end

	def Shmexy.create
		shmexy = self.new
		shmexy.room_manager = ShmexyRoomManager.new
		shmexy.command_generator = ShmexyCommandGenerator.new
		shmexy
	end

	def settings conf
		@settings = conf
	end

	def start
		puts "Attempting to start Shmexy on #{@settings['ip']}:#{@settings['port']}"
		EM.run do
			begin
				@signature = EM.start_server @settings['ip'], @settings['port'], ShmexyConnection do |con|
					con.id = UUIDTools::UUID.timestamp_create
					con.server = self
					@connections[con.id] = con
				end
			rescue StandardError => error
				puts "Unable to start Shmexy on #{@settings['ip']}:#{@settings['port']}"
				EM.stop
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

		send connection, { "hello" => connection.id }
	end

	def send id, data
		if id.is_a? ShmexyConnection
			id.send_message(data)
		else
			@connections[id].send_message(data) if @connections.has_key? id
		end
	end
end