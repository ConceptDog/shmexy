class ShmexyRoom
	include Shmexy::MessageGenerator
	
	attr_reader :id
	attr_accessor :name
	attr_accessor :members

	def initialize id, name = nil
		@id = id.to_s
		@name = name
		@members = {}
	end

	def self.create
		self.new UUIDTools::UUID.timestamp_create, "Default Room Name"
	end

	def []= (*params)
		params.each { |value| joined_room( value ) }
	end

	def [] (value)
		@members[value] if @members.key(value)
	end

	def joined_room user
    return false if @members.key(user.id)

    room_users = []

    @members.values do |current|
      EM.next_tick { current.send_message shmexy_message( "join", user.serialize, user.id ) }
      room_users.push( current.serialize )
    end

    EM.next_tick { user.send_message shmexy_message( "joined", room_users, @id ) }

    @members[user.id] = user
  end
  
	def left_room user
    return false unless @members.key(user.id)

    @members.delete( user.id )

    @members.values do |current|
      EM.next_tick { current.send_message shmexy_message( "left", user.id, @id ) }
    end

    user.send_message shmexy_response( true, @id )
  end

	def message_room sender, message
    return false unless @members.key(sender.id)

    @members.values do |current|
      EM.next_tick { current.send_message shmexy_message( "message", message.to_s, sender.id ) } unless current.id.eql?( sender.id )
    end

    sender.send_message shmexy_response( true, "message sent" )
	end

end