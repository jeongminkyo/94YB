class Notice < ApplicationRecord
  resourcify
  include Authority::Abilities

end
