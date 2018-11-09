class IncomeHistory < ApplicationRecord
  belongs_to :user
  belongs_to :cash

end
