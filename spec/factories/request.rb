FactoryGirl.define do
  factory :request do
    user
    association :admin, factory: :user, title: 'Encargado Almacenes'

    sequence(:nro_solicitud)
    status 'initiation' # Inicial
    delivery_date nil

    trait :agosto do
      created_at '2016-08-16 17:36:51'
    end

    trait :delivered do
      status 'delivered' # Entregado
      delivery_date { created_at }
    end

    factory :request_delivered, traits: [:delivered]
    factory :request_delivered_agosto, traits: [:agosto, :delivered]
  end
end
