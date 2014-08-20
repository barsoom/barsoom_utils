require "lolcat"

module BarsoomUtils
  module Spec
    module DebugHelpers
      def show_page
        path = Rails.root.join("public/show_page.html")
        File.write(path, page.source)
        Lol.println "show_page: http://#{hostname}/show_page.html", os: 10, freq: 0.1, spread: 1
      end

      def hostname
        raise "Implement me. Ex: def hostname; \"auctionet.dev\"; end"
      end
    end
  end
end
