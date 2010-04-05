require 'revactor'

class ShmexyRoom
	attr_reader :id
	attr_accessor :name
	attr_accessor :members

	def initialize id, name = nil
		@id = id
		@name = name
		@members = {}
	end

	def []= (*params)
		params.each { |value| @members[value.id] = value }
	end

	def [] (value)
		@members[value] if @members.key(value)
	end

	def joined_room user

	end

	def left_room user

	end

	def message_room sender, message

	end

end