# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'thread'

module Covered
	module Eval
		@mutex = Mutex.new
		@handler = nil
		
		def self.enable(handler)
			@mutex.synchronize do
				@handler = handler
			end
		end
		
		def self.disable(handler)
			@mutex.synchronize do
				@handler = nil
			end
		end
		
		def self.intercept_eval(*args)
			@mutex.synchronize do
				@handler.intercept_eval(*args) if @handler
			end
		end
	end
end

module Kernel
	class << self
		alias_method :__eval__, :eval
		
		def eval(*args)
			Covered::Eval.intercept_eval(*args)
			
			__eval__(*args)
		end
	end
	
	private
	
	alias_method :__eval__, :eval
	
	def eval(*args)
		Covered::Eval.intercept_eval(*args)
		
		__eval__(*args)
	end
end

class Binding
	alias_method :__eval__, :eval
	
	def eval(*args)
		Covered::Eval.intercept_eval(*args)
		
		__eval__(*args)
	end
end
