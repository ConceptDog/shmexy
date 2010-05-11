class ShmexyCommandGenerator
	include Shmexy::MessageGenerator
	attr_reader :server
	attr_reader :room_manager

	def initialize server, room_manager = nil
		@server = server
		@room_manager = ( room_manager or server.room_manager )
	end

	def command connection, command
    return false unless validate_command(command)

		EM.next_tick { self.receive_command( connection, command ) }

    true
	end

	def receive_command connection, command
		puts "Received command #{command} from #{connection.id}"
		case command["action"]
			when "join"
				if command.has_key?('parameters') and command['parameters'].has_key?('target')
					EM.next_tick { @room_manager.join_room connection, command['parameters']['target']  }
				end

				EM.next_tick { @room_manager.join_room connection }
			when "leave"
				EM.next_tick { @room_manager.leave_room connection }
      when "send"
        EM.next_tick {shmexy_error_response( "message required" ) } unless command.has_key( 'message' )

				if command.has_key( 'room' )
					EM.next_tick { @room_manager[ command['room'] ].message_room( connection, command['message'] ) }
				else
				 	@room_manager.find_membership.each { |current| EM.next_tick { current.message_room( connection, command['message'] ) } }
				end
			else
				@server.send( connection, shmexy_response( false, "invalid command" ) )
    end
    
    true
	end

	def validate_command command
		true if command.has_key?('action')
	end
end