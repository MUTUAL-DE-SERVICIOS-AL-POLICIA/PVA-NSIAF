require 'spec_helper'

RSpec.describe Request, type: :model do

  context 'Consultas' do
    before :each do
      # Creación de materiales
      @request1 = FactoryGirl.create(:request, :julio)
      @request2 = FactoryGirl.create(:request, :agosto)
      @request3 = FactoryGirl.create(:request, :septiembre, nro_solicitud: nil)
      @request3 = FactoryGirl.create(:request, :anio_anterior, nro_solicitud: nil)
    end

    it 'de la gestión' do
      expect(Request.del_anio_por_fecha_creacion("2016-08-13".to_datetime).size).to eq(3)
    end

    it 'mayor a la fecha de creacion' do
      expect(Request.mayor_a_fecha_creacion("2016-07-08".to_datetime).size).to eq(2)
    end

    it 'menor igual a la fecha de creacion' do
      expect(Request.menor_igual_a_fecha_creacion("2016-07-05".to_datetime).size).to eq(2)
    end

    it 'con fecha de creación' do
      expect(Request.con_fecha_creacion.size).to eq(4)
    end

    it 'con nro solicitud' do
      expect(Request.con_nro_solicitud.size).to eq(2)
    end
  end

  context 'generacion de números de solicitud' do
    before :each do
      # Creación de materiales
      @request1 = FactoryGirl.create(:request, :julio, nro_solicitud: 10)
      @request2 = FactoryGirl.create(:request, :agosto, nro_solicitud: 11)
      @request3 = FactoryGirl.create(:request, :septiembre, nro_solicitud: 12)
      @request3 = FactoryGirl.create(:request, :anio_anterior)
    end

    it 'posterior a la ultima fecha' do
      expect(Request.obtiene_siguiente_numero_solicitud("23/09/2016".to_datetime)).to eq({ codigo_numerico: 13 })
    end

    it 'entre 2 fechas' do
      expect(Request.obtiene_siguiente_numero_solicitud("01/08/2016".to_datetime)).to eq({ tipo_respuesta: "confirmacion",
                                                                                           numero: "10-A",
                                                                                           codigo_numerico: 10,
                                                                                           codigo_alfabetico: "A",
                                                                                           ultima_fecha: "23/09/2016" })
    end

    it 'anterior a todas las fechas' do
      expect(Request.obtiene_siguiente_numero_solicitud("01/04/2016".to_datetime)).to eq({ codigo_numerico: 9 })
    end

    it 'en una gestion posterior a la actual' do
      expect(Request.obtiene_siguiente_numero_solicitud("01/04/2016".to_datetime)).to eq({ codigo_numerico: 9 })
    end

  end
end
