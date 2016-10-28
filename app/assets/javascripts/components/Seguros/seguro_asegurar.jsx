class SeguroAsegurar extends React.Component {
  constructor(props) {
    super(props);
    this.guardarDatos = this.guardarDatos.bind(this);
    this.capturarDatos = this.capturarDatos.bind(this);
    this.state={
      seguro: {},
      supplier_id: '',
      factura_numero: '',
      factura_autorizacion: '',
      factura_monto: '',
      factura_fecha: '',
      numero_poliza: '',
      numero_contrato: '',
      fecha_inicio_vigencia: '',
      fecha_fin_vigencia: '',
      activos: [],
      sumatoria: 0,
      resumen: [],
      sumatoria_resumen: 0
    };
  }

  capturarDatos(data) {
    debugger
    this.setState({
      supplier_id: data.supplier_id,
      factura_numero: data.factura_numero,
      factura_autorizacion: data.factura_autorizacion,
      factura_monto: data.factura_monto,
      factura_fecha: data.factura_fecha,
      numero_poliza: data.numero_poliza,
      numero_contrato: data.numero_contrato,
      fecha_inicio_vigencia: data.fecha_inicio_vigencia,
      fecha_fin_vigencia: data.fecha_fin_vigencia
    });
    console.log(this.state);
  }

  componentWillMount(){
    this.setState({
        activos: this.props.data.activos,
        sumatoria: this.props.data.sumatoria,
        resumen: this.props.data.resumen,
        sumatoria_resumen: this.props.data.sumatoria_resumen
    });
  }

  guardarDatos(e){
    var alert = new Notices({ ele: 'div.main' });
    var url = this.props.data.urls.seguros;
    _ = this;
    $.ajax({
      url: url,
      type: 'POST',
      dataType: 'JSON',
      data: {
        seguro: this.jsonGuardar()
      }
    }).done(function(seguro) {
      alert.success("Se guardó correctamente la cotización.");
      return window.location = _.props.data.urls.listado_seguros + "/" + seguro.id;
    }).fail(function(xhr, status) {
      alert.danger("Error al guardar la cotización.");
    });
  }

  render() {
    return(
      <div>
        <div className="row">
          <div className="col-md-12">
            <h3 className="text-center">
              {this.props.data.titulo}
            </h3>
          </div>
          <SeguroFormulario urls={this.props.data.urls} capturarDatos={this.capturarDatos}/>
        </div>
        <SeguroTablaActivos activos={this.state.activos} sumatoria={this.state.sumatoria} resumen={this.state.resumen} sumatoria_resumen={this.state.sumatoria_resumen} />
        <div className="row">
          <div className="action-buttons col-md-12 col-sm-12 text-center">
            <a className="btn btn-danger cancelar-btn" href={this.props.data.urls.listado_seguros}>
              <span className="glyphicon glyphicon-ban-circle"></span>
              Cancelar
            </a>
            &nbsp;
            <button name="button" type="submit" className="btn btn-primary guardar-btn" data-disable-with="Guardando..." onClick={this.guardarDatos}>
              <span className="glyphicon glyphicon-floppy-save"></span>
              Guardar
            </button>
          </div>
        </div>
      </div>
    );
  }
}
