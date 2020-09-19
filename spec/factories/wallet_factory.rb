class WalletFactory
  FactoryBot.define do
    factory :wallet, class: Wallet do
      current_money { 0 }
      whole_money { 0 }
    end
  end
end