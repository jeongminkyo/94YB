class Wallet < ApplicationRecord

  def income_to_wallet(income)
    if(self.whole_money != nil)

      whole = self.whole_money += income
      current = self.current_money += income
      result = self.update_attributes(:whole_money => whole, :current_money => current)
      result
    end
  end

  def expenditure_to_wallet(expenditure)
    current = self.current_money -= expenditure
    result = self.update_attributes(:current_money => current)
    result
  end

end
