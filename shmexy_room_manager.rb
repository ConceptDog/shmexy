require 'shmexy_room'

class ShmexyRoomManager
	attr_reader :rooms
	attr_reader :membership
	attr_reader :server

	def initialize server
		@rooms = {}
		@membership = {}
		@server = server
	end

	def [](signature)
		@rooms[signature] if @rooms.has_key?(signature)
  end

  def exists?(signature)
    @rooms.has_key? signature
  end

	def find_membership id
		@membership[id]
	end

	def join_room user, signature = nil
		room = nil

		if signature.nil?
			room = ShmexyRoom.create
			@rooms[room.id] = room
			return room[]= user
		end

		room = self[ signature ]

		if room.nil?
			EM.next_tick { user.send_message( shmexy_response( false, "room not found" ) ) }
		else
			EM.next_tick { room.joined_room( user ) }
		end

	end

	def leave_room user, signature = nil
		if signature.nil?
			rooms = find_membership user.id
			return EM.next_tick { user.send_message( shmexy_response( false, "no rooms" ) ) } if rooms.size == 0

			rooms.each do |current_id|
				EM.next_tick do
					target = self[current_id]
					target.left_room(user)
					@rooms.delete(current_id) if target.size == 0
				end
			end

			return
		end

		room = self[ signature ]

		if room.nil?
			EM.next_tick { user.send_message( shmexy_response( false, "room not found" ) ) }
		else
			EM.next_tick do
				room.left_room( user )
				@rooms.delete(room.id) if room.size == 0	
			end
		end
	end
end