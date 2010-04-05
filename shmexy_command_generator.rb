require 'shmexy_module'

class ShmexyCommandGenerator
	include Shmexy::ResponseGenerator
	attr_reader :server
	attr_reader :room_manager

	def initialize server, room_manager
		@server = server
		@room_manager = room_manager
	end

	def recieve_command connection, command
		return false unless validate_command(command)

		case command
			when command['action'] == 'join'
				if command['parameters'].has_key?('target')
					return @room_manager.join( connection, command['parameters']['target'] )
				end

				@room_manager.join(connection)
			when command['action'] == 'leave'
				@room_manager.leave_room connection
			when command['action'] == 'send'
		end
	end

	def validate_command command
		true if command.has_key?('action')
	end
end