
module Shmexy
	module ResponseGenerator
		def shmexy_response result, message
			{ "result" => result, "message" => message }
		end
	end
end