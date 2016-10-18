require 'spec_helper'

RSpec.describe Seguro, type: :model do

  context "cuando tenemos 2 registros de seguros uno vigente y otro no vigente" do
    before :each do
      @seguro_vigente = FactoryGirl.create(:seguro, :vigente)
      @seguro_no_vigente = FactoryGirl.create(:seguro, :no_vigente)
    end

    it "verificacion la validacion al crear un seguros" do
      expect(@seguro_vigente).to be_valid, "seguro valido"
      expect(@seguro_no_vigente).to be_valid, "seguro valido"
    end

    it "verificando antes de la fecha inicio de vigencia" do
      expect(Seguro.vigentes("13-07-2016".to_date)).to be_empty, "no existe seguros validos"
    end

    it "verificando  en la fecha inicio de vigencia" do
      expect(Seguro.vigentes("14-07-2016".to_date)).not_to be_empty, "existe seguros validos"
    end

    it "verificando antes de la fecha fin de vigencia" do
      expect(Seguro.vigentes("14-07-2016".to_date)).not_to be_empty
    end

    it "verificando en la fecha fin de vigencia" do
      expect(Seguro.vigentes("14-11-2016".to_date)).not_to be_empty
    end

    it "verificando posterior a la fecha fin de vigencia" do
      expect(Seguro.vigentes("15-11-2016".to_date)).to be_empty
    end
  end

  context "cuando tenemos 2 seguros uno vigente y otro no vigente" do
    before :each do
      @seguro_vigente = FactoryGirl.create(:seguro, :vigente)
      @seguro_no_vigente = FactoryGirl.create(:seguro, :no_vigente)

      @activo_1 = FactoryGirl.create(:asset)
      @activo_2 = FactoryGirl.create(:asset)
      @activo_3 = FactoryGirl.create(:asset)
      @activo_4 = FactoryGirl.create(:asset)
      @activo_5 = FactoryGirl.create(:asset)
      @activo_6 = FactoryGirl.create(:asset)
      @activo_7 = FactoryGirl.create(:asset)
      @activo_8 = FactoryGirl.create(:asset)

      @seguro_vigente.assets << @activo_1
      @seguro_vigente.assets << @activo_2
      @seguro_vigente.assets << @activo_3
      @seguro_vigente.assets << @activo_4
      @seguro_vigente.assets << @activo_5
      @seguro_no_vigente.assets << @activo_6
      @seguro_no_vigente.assets << @activo_7
      @seguro_no_vigente.assets << @activo_8

    end

    it "verificando la existencia de activos sin seguro" do
      expect(Asset.sin_seguro_vigente.size).to eq(3), "existen 3 activos sin seguro"
    end

    it "verificando la no existencia de activos sin seguro" do
      Timecop.freeze("20-08-2016".to_date)
      @seguro_vigente.assets << @activo_6
      @seguro_vigente.assets << @activo_7
      @seguro_vigente.assets << @activo_8
      expect(Asset.sin_seguro_vigente).to be_empty
      Timecop.return
    end

    it "verificando la existencia de activos no asegurados posterior fecha fin de vigencia del seguro" do
      Timecop.freeze("20-11-2016".to_date)
      expect(Asset.sin_seguro_vigente.size).to eq(8), "existen 8 activos sin seguro"
      Timecop.return
    end

    it "verificando la alerta de la vigencia antes de los 60 dias" do
      Timecop.freeze("20-07-2016".to_date)
      expect(@seguro_vigente.expiracion_a_dias(60)).to eq(false)
      Timecop.return
    end

    it "verificando la alerta de la vigencia a los 60 dias" do
      Timecop.freeze("18-09-2016".to_date)
      expect(@seguro_vigente.expiracion_a_dias(60)).to eq(true)
      Timecop.return
    end
  end

  context "Probando la vigencia de un seguro" do
    let(:seguro) { FactoryGirl.create :seguro, { fecha_inicio_vigencia: "01-01-2015", fecha_fin_vigencia:"31-12-2015" } }

    it "Fecha antes de la fecha de inicio de vigencia" do
      Timecop.freeze("13-04-2014")
      expect(seguro.vigente?).to eq(false)
      Timecop.return
    end

    it "Fecha en la fecha de inicio de vigencia" do
      Timecop.freeze("01-01-2015")
      expect(seguro.vigente?).to eq(true)
      Timecop.return
    end

    it "Fecha en la fecha de fin de vigencia" do
      Timecop.freeze("31-12-2015")
      expect(seguro.vigente?).to eq(true)
      Timecop.return
    end

    it "Fecha posterior a la fecha de fin de vigencia" do
      Timecop.freeze("02-01-2016")
      expect(seguro.vigente?).to eq(false)
      Timecop.return
    end

  end

end
