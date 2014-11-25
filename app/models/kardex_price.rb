class KardexPrice < ActiveRecord::Base
  belongs_to :kardex

  def decrease_amount(amount)
    self.input_quantities = 0
    self.input_amount = 0
    balance = self.balance_quantities - amount
    if balance < 0
      balance = balance.abs
      self.output_quantities = self.balance_quantities
      self.balance_quantities = 0
      amount = balance
    else
      self.output_quantities = amount
      self.balance_quantities = balance
      amount = 0
    end
    self.output_amount = self.output_quantities * self.unit_cost
    self.balance_amount = self.balance_quantities * self.unit_cost
    amount
  end
end
