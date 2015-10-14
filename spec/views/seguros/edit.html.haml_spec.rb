require 'spec_helper'

RSpec.describe "seguros/edit", type: :view do
  before(:each) do
    @seguro = assign(:seguro, Seguro.create!(
      :supplier => "",
      :user => "",
      :numero_contrato => "MyString",
      :factura_numero => "MyString",
      :factura_autorizacion => "MyString",
      :baja_logica => false
    ))
  end

  it "renders the edit seguro form" do
    render

    assert_select "form[action=?][method=?]", seguro_path(@seguro), "post" do

      assert_select "input#seguro_supplier[name=?]", "seguro[supplier]"

      assert_select "input#seguro_user[name=?]", "seguro[user]"

      assert_select "input#seguro_numero_contrato[name=?]", "seguro[numero_contrato]"

      assert_select "input#seguro_factura_numero[name=?]", "seguro[factura_numero]"

      assert_select "input#seguro_factura_autorizacion[name=?]", "seguro[factura_autorizacion]"

      assert_select "input#seguro_baja_logica[name=?]", "seguro[baja_logica]"
    end
  end
end
