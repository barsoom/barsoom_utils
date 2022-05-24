require "attr_extras"

module BarsoomUtils
  class ParseSpaceSeparatedTokenValues
     method_object :value, [ :minimum_key_size!, :token_name! ]

     def call
       keys = value.split

       raise "Missing #{token_name}. Quitting." if keys.empty?

       raise "Invalid #{token_name}: a too-short element found. Did a key contain a space? Quitting!" if keys.any? { |api_key| api_key.size < minimum_key_size }

       keys.freeze
     end
   end
 end
