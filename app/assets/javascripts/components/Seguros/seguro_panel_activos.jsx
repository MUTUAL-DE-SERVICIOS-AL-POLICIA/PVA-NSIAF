class SeguroPanelActivos extends React.Component {
  constructor(props) {
    super(props);
    this.asegurar = this.asegurar.bind(this);
    this.verificaAsegurado = this.verificaAsegurado.bind(this);
  }

  verificaAsegurado() {
    return (this.props.seguro.state == "asegurado" ? true : false);
  }

  asegurar() {
    window.location = this.props.urls.asegurar
  }

  render() {
    let titulo;
    let datos_seguro;
    let boton_asegurar;
    let boton_incorporar;
    let incorporaciones;
    if(this.verificaAsegurado()){
      let poliza = this.props.seguro.numero_poliza;
      let fecha_factura = new Date(this.props.seguro.factura_fecha);
      boton_asegurar =
        <button type="button" className="btn btn-success btn-lg pull-right" data-toggle="tooltip" title="Asegurado">
          <span className="glyphicon glyphicon-lock" aria-hidden="true"></span>
        </button>;
      datos_seguro =
        <div>
          <div className="col-lg-4 col-md-5 col-sm-12">
            <dl className="dl-horizontal">
              <dt>Número de contrato</dt>
              <dd>{this.props.seguro.numero_contrato}</dd>
              <dt>Número de autorización</dt>
              <dd>{this.props.seguro.factura_autorizacion}</dd>
              <dt>Monto de factura</dt>
              <dd>{this.props.seguro.factura_monto}</dd>
            </dl>
          </div>
          <div className="col-lg-4 col-md-5 col-sm-12">
            <dl className="dl-horizontal">
              <dt>Número de factura</dt>
              <dd>{this.props.seguro.factura_numero}</dd>
              <dt>Fecha de factura</dt>
              <dd>{moment(fecha_factura).format("DD/MM/YYYY")}</dd>
            </dl>
          </div>
          <div className="clearfix visible-xs-block"></div>
        </div>;
    }
    else {
      boton_asegurar =
        <button type="button" className="btn btn-warning btn-lg pull-right" data-toggle="tooltip" title="Asegurar" onClick={this.asegurar}>
          <span className="glyphicon glyphicon-lock" aria-hidden="true"></span>
        </button>;
    }
    return(
      <div className='row'>
        <div className="col-lg-1 col-md-1 col-sm-12">
          {boton_asegurar}
        </div>
        <div className="col-lg-11 col-md-11 col-sm-12">
          {datos_seguro}
          <SeguroTablaActivos name={this.props.name} activos={this.props.activos} sumatoria={this.props.sumatoria} resumen={this.props.resumen} sumatoria_resumen={this.props.sumatoria_resumen} />
        </div>
      </div>
    );
  }
}
