require 'rubygems'
require 'eventmachine'
require 'json'
require 'shmexy'

class ShmexyConnection < EventMachine::Connection
  include Shmexy::MessageGenerator
	attr_accessor :id
	attr_accessor :server
  attr_accessor :active

	def receive_data data
		decode = nil
		
		begin
			decode = JSON data
		rescue StandardError => error
			send_message( shmexy_error_response( "syntax error" ) )
			return
		end

		server.receive self, decode
	end

	def send_message data
		send_data("#{data.to_json}\n")
	end
	
	def unbind
    @active = false
		@server.drop self
  end

  def serialize
    { "id" => @id }
  end

  def id=(value)
    @id = value.to_s
  end

  def active?
    @active
  end
end