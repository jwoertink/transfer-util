module Nokogiri
  module XML
    class Element < Node

      def alter_inner_text
        children.each do |child|
          if child.class.is_a? Nokogiri::XML::Text
            unless child.text.eql?("\302\240")
              child = "|" + child
            end
          end
        end
      end

    end
  end
end
