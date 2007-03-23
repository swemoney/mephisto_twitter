class REXML::Element
  def to_hash(default_hash = {})
    convert_node_to_hash(self, default_hash)
  end
  
  protected
    def convert_node_to_hash(node, hash)
      node.elements.each do |elm|
        hash[elm.name] = elm.elements.empty? ? elm.text : convert_node_to_hash(elm, hash)
      end
      return hash
    end
end
