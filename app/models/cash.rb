class Cash < ApplicationRecord
  resourcify
  include Authority::Abilities

end
