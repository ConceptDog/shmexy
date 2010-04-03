require 'rubygems'
require 'eventmachine'
require 'json'

class ShmexyConnection < EventMachine::Connection
	attr_accessor :id
	attr_accessor :server

	def receive_data data
		decode = nil
		
		begin
			decode = JSON data
		rescue StandardError => error
			send_message( { "error" => "syntax error" } )
			return
		end

		server.receive self, decode
	end

	def send_message data
		send_data("#{data.to_json}\n")
	end
	
	def unbind
		@server.drop self
	end
end