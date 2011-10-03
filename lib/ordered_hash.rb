class OrderedHash < Array
  
  def []=(key, value)
    if pair = assoc(key)
      pair.pop
      pair << value
    else
      self << [key, value]
    end
  end

  def [](key)
    pair = assoc(key)
    pair ? pair.last : nil
  end

  def keys
    collect { |key, value| key }
  end

  def values
    collect { |key, value| value }
  end

end
