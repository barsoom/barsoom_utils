require "attr_extras"

module BarsoomUtils
  class ParseSpaceSeparatedTokenValues
     attr_private :minimum_key_size, :value, :token_name

     # @param token_name [String] name of ENV key to look up
     # @param minimum_key_size [Integer] required size of each element
     # @param data [Hash] defaults to ENV
     def initialize(token_name, minimum_key_size:, data: ENV)
       @value = data[token_name].to_s
       @token_name = token_name
       @minimum_key_size = minimum_key_size
     end

     def self.call(token_name, minimum_key_size:, data: ENV)
       new(token_name, minimum_key_size: minimum_key_size, data: data).call
     end

     def call
       keys = value.split

       raise "Missing #{token_name}. Quitting." if keys.empty?

       raise "Invalid #{token_name}: a too-short element found. Did a key contain a space? Quitting!" if keys.any? { |api_key| api_key.size < minimum_key_size }

       keys.freeze
     end
   end
 end
