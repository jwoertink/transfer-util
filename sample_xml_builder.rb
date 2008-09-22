# This is the ruby version of the
# sample_rtml_doc.xml version
# The goal is to use the builder gem to dynamically
# generate the RTML in XML format. This file is
# longer then the normal XML doc. I may need to come
# up with a better format. Possibly stick to the
# old YSW-tools *.rtml format.....
# maybe use a format similar to HAML?? 
require 'builder'

xml = Builder::XmlMarkup.new(:indent => 2)

xml.instruct!(:xml, :version => "1.1", :encoding => "US-ASCII")
xml.rtml do
  xml.head do
    xml.title("vwd-display-item")
    xml.parameters("align	headel imgclass")
  end
  xml.body do
    xml.operator do
      xml.type("WITH=")
      xml.attribute do
        xml.key("variable")
        xml.value("itemimg")
        xml.key("value")
        xml.value do
          xml.operator do
            xml.type("AND")
            xml.operator { xml.type("@image") }
            xml.operator do
              xml.type("POSITION")
              xml.attribute do
                xml.key("element")
                xml.value(":image")
                xml.key("sequence")
                xml.value("headel")
              end
            end
          end
        end
      end
    end
  end
end