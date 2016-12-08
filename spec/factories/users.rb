FactoryGirl.define do
  factory :user do
    sequence(:code)
    sequence(:name, 'a') { |n| "Juan José Rocha #{n}" }
    title 'Profesional de Desarrollo'
    ci '1234567 LP'
    sequence(:email) { |n| "jrocha#{n}@agetic.gob.bo" }
    sequence(:username, 'a') { |n| "jrocha#{n}" }
    password { 'Demo1234' }
    phone '212345'
    mobile '70612345'
    department
    role nil

    trait :super_admin do # Super administrador
      role 'super_admin'
    end

    trait :activos do # Activos fijos
      role 'admin'
    end

    trait :almacenes do # Almacenes
      role 'admin_store'
    end

    factory :user_super_admin, traits: [:super_admin]
    factory :user_activos, traits: [:activos]
    factory :user_almacenes, traits: [:almacenes]
  end
end
