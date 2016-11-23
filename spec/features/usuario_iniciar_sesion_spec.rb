require 'rails_helper'

describe 'Inicio de sesión de usuarios' do
  let(:usuario) { create(:user) }

  it 'con credenciales válidos' do
    visit new_user_session_path
    fill_in 'user_username', with: usuario.username
    fill_in 'user_password', with: usuario.password

    click_on 'INGRESAR'

    expect(page).to have_content('Has iniciado sesión correctamente.')
  end


  it 'con credenciales inválidos' do
    visit new_user_session_path
    fill_in 'user_username', with: usuario.username
    fill_in 'user_password', with: 'contraseña-equivocada'

    click_on 'INGRESAR'

    expect(page).to have_content('Nombre de Usuario o contraseña inválidos.')
  end
end
