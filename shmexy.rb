require 'rubygems'
require 'eventmachine'
require 'uuidtools'

module Shmexy

	module MessageGenerator
		def shmexy_response result, message
			{ "result" => result, "message" => message }
    end

    def shmexy_error_response message
      { "error" => message }
    end
	end

	require 'shmexy_command_generator'
	require 'shmexy_room_manager'
	require 'shmexy_connection'
  require 'shmexy_exception'

	def self.create
		shmexy = ShmexyServer.new
		shmexy.room_manager = ShmexyRoomManager.new shmexy
		shmexy.command_generator = ShmexyCommandGenerator.new shmexy
		shmexy
	end

	class ShmexyServer
		attr_reader :signature
		attr_reader :connections
		attr_accessor :room_manager
		attr_accessor :command_generator

		def initialize
			@connections = {}
			@settings = { "ip" => '0.0.0.0', "port" => 3303 }
		end

		def settings conf
			@settings = conf
		end

		def start
			puts "Attempting to start Shmexy on #{@settings['ip']}:#{@settings['port']}"
			EM.epoll
			EM.kqueue
			EM.run do
				begin
					@signature = EM.start_server @settings['ip'], @settings['port'], ShmexyConnection do |con|
						con.id = UUIDTools::UUID.timestamp_create
						con.server = self
						@connections[con.id] = con
					end
				rescue StandardError => error
					puts "Unable to start Shmexy on #{@settings['ip']}:#{@settings['port']}"
					puts error
					EM.stop
				end
			end
		end

		def stop
			@connections.each_value { |con| con.close_connection }
			EM.stop if EM.reactor_running?
		end

		def disconnect id
			@connections[id].close_connection if @connections.has_key? id
		end

		def drop connection
			@connections.delete connection.id
			@room_manager.leave_room connection
		end

		def receive connection, data
			raise ShmexyException, "Invalid Command" unless @command_generator.command( connection, data )
		end

		def send id, data
			if id.is_a? ShmexyConnection
				EM.next_tick( id.send_message(data) )
			else
				EM.next_tick( @connections[id].send_message(data) ) if @connections.has_key? id
			end
		end
	end
end