require 'spec_helper'

RSpec.describe "seguros/show", type: :view do
  before(:each) do
    @seguro = assign(:seguro, Seguro.create!(
      :supplier => "",
      :user => "",
      :numero_contrato => "Numero Contrato",
      :factura_numero => "Factura Numero",
      :factura_autorizacion => "Factura Autorizacion",
      :baja_logica => false
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(//)
    expect(rendered).to match(/Numero Contrato/)
    expect(rendered).to match(/Factura Numero/)
    expect(rendered).to match(/Factura Autorizacion/)
    expect(rendered).to match(/false/)
  end
end
