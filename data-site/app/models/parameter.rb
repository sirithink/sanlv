class Parameter
  include Mongoid::Document
  #include Mongoid::Timestamps
  
  field :name, :type => String
  field :value, :type => String


  embedded_in :qqcar
  embedded_in :car
end