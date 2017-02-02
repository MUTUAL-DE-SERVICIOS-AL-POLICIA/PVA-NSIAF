require 'rails_helper'

describe 'Subartículos' do
  def fill_autocomplete(field, options = {})
    fill_in field, with: options[:with]
    expect(page).to have_css(".tt-suggestion p", text: options[:select], visible: false)
    script = %Q{ $('.tt-suggestion:contains("#{options[:select]}")').click() }
    page.execute_script(script); wait_for_ajax
  end

  let(:usuario_almacenes) { create(:user_almacenes) }
  let(:usuario) { create(:user) }
  let!(:material) { create(:material, :papel) }
  let!(:subarticulo) { create(:subarticle, :papel_carta) }
  let!(:entry_subarticle) { create(:entry_subarticle, :trescientos, subarticle: subarticulo) }


  before { iniciar_sesion(usuario_almacenes) }
  after  { cerrar_sesion(usuario_almacenes) }

  it 'listado subarticulo', js: true do
    visit subarticles_path
    expect(page).to have_content('Mostrando 1 al 1 de 1 registros')
    expect(page).to have_content(300)
  end

  it 'solicitud de materiales', js: true do
    visit subarticle_path(subarticulo)
    expect(page).to have_content('SALDO INICIAL')
    expect(page).to have_content('300')
    expect(page).to have_content('Kardex')
    click_on 'Kardex'
    expect(page).to have_content('KARDEX DE EXISTENCIAS')
    expect(page).to have_content('Imprimir')
    expect(page).to have_content('300')
    expect(page).to have_content('540')
    expect(page).to have_content('SALDO INICIAL')
    expect(page).to have_content('SALDO FINAL')
    visit requests_path
    expect(page).to have_content('Solicitud de Materiales')
    click_on 'Nueva Solicitud'
    fill_autocomplete 'people', with: usuario.name, select: usuario.name
    fill_autocomplete 'subarticle', with: subarticulo.code, select: "#{subarticulo.code} - #{subarticulo.description}"
    expect(page).to have_content('300')
    fill_in 'quantity', with: 50
    click_on 'Ver Solicitud'
    expect(page).to have_content('Guardar Solicitud')
    click_on 'Guardar Solicitud'
    expect(page).to have_content('Entregar producto')
    click_on 'Entregar producto'
    expect(page).to have_content('Aceptar')
    fill_in 'amount', with: 50
    click_on 'Aceptar'
    expect(page).to have_content('Entregar')
    click_on 'Entregar'
    visit requests_path(subarticulo, format: :html)
    expect(page).to have_content('Estado: Entregado')
    expect(page).to have_content('Imprimir Solicitud')
    expect(page).to have_content('Imprimir Entrega')
    visit subarticle_path(subarticulo)
    expect(page).to have_content('SALDO INICIAL')
    expect(page).to have_content('-50')
    expect(page).to have_content('250')
    expect(page).to have_content("#{usuario.name} - #{usuario.title}")
    expect(page).to have_content('Kardex')
    click_on 'Kardex'
    expect(page).to have_content('KARDEX DE EXISTENCIAS')
    expect(page).to have_content('Imprimir')
    expect(page).to have_content('300')
    expect(page).to have_content('50')
    expect(page).to have_content('250')
    expect(page).to have_content('540')
    expect(page).to have_content('450')
    expect(page).to have_content('SALDO INICIAL')
    expect(page).to have_content('SALDO FINAL')
  end
end
