class Buron
  def initialize(name, second) #constructor
    @name = name
    @second = second
  end
  def name #getter
    @name
  end
  def second #getter
    @second
    end
    def name=(name) #setter
    @name = name

  end
  
end

buron = Buron.new("buron", "PUTA")
puts buron.name
buron.name = "perkinazo"
puts buron.name + " is a good person" + " and " + buron.second + " is a bad person"