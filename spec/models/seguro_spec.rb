require 'spec_helper'

RSpec.describe Seguro, type: :model do
  it "verificacion la validacion al crear un seguro" do
    expect(FactoryGirl.create(:seguro)).to be_valid
  end
end
