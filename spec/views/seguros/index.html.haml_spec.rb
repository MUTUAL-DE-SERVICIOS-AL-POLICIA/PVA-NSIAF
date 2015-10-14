require 'spec_helper'

RSpec.describe "seguros/index", type: :view do
  before(:each) do
    assign(:seguros, [
      Seguro.create!(
        :supplier => "",
        :user => "",
        :numero_contrato => "Numero Contrato",
        :factura_numero => "Factura Numero",
        :factura_autorizacion => "Factura Autorizacion",
        :baja_logica => false
      ),
      Seguro.create!(
        :supplier => "",
        :user => "",
        :numero_contrato => "Numero Contrato",
        :factura_numero => "Factura Numero",
        :factura_autorizacion => "Factura Autorizacion",
        :baja_logica => false
      )
    ])
  end

  it "renders a list of seguros" do
    render
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "Numero Contrato".to_s, :count => 2
    assert_select "tr>td", :text => "Factura Numero".to_s, :count => 2
    assert_select "tr>td", :text => "Factura Autorizacion".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
