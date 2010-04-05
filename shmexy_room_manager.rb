require 'revactor'

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
		@rooms[signature] if @rooms.key?(signature)
	end

	def join_room user, signature = nil

	end

	def leave_room user
		
	end

	private

	def create_room signature

	end

	def destroy_room signature

	end
	
end