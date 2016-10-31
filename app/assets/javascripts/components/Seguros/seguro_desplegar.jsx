class SeguroDesplegar extends React.Component {
  constructor(props) {
    super(props);
    this.asegurar = this.asegurar.bind(this);
    this.state = {
      seguro: {},
      activos: [],
      sumatoria: 0,
      resumen: [],
      sumatoria_resumen: 0
    };
  }

  componentWillMount() {
    this.setState({
      seguro: this.props.data.seguro,
      activos: this.props.data.activos,
      sumatoria: this.props.data.sumatoria,
      resumen: this.props.data.resumen,
      sumatoria_resumen: this.props.data.sumatoria_resumen
    });
  }

  asegurar() {
    window.location = this.props.data.urls.asegurar
  }

  render() {
    let titulo;
    let datos_seguro;
    let boton_asegurar;
    if(this.props.data.seguro.numero_poliza){
      let poliza = this.props.data.seguro.numero_poliza;
      let fecha_inicio = new Date(this.props.data.seguro.fecha_inicio_vigencia);
      let fecha_fin = new Date(this.props.data.seguro.fecha_fin_vigencia);
      titulo = <h2>Póliza: {poliza} desde {moment(fecha_inicio).format("DD/MM/YYYY HH:MM")} hasta {moment(fecha_fin).format("DD/MM/YYYY HH:MM")}</h2>;
      boton_asegurar =
          <button type="button" className="btn btn-success btn-lg pull-right" data-toggle="tooltip" title="Asegurar">
            <span className="glyphicon glyphicon-lock" aria-hidden="true"></span>
          </button>;
      datos_seguro =
        <div>
          <div className="col-lg-4 col-md-5 col-sm-12">
            <dl className="dl-horizontal">
              <dt>Número de contrato</dt>
              <dd>{this.props.data.seguro.numero_contrato}</dd>
              <dt>Número de autorización</dt>
              <dd>{this.props.data.seguro.factura_autorizacion}</dd>
              <dt>Monto de factura</dt>
              <dd>{this.props.data.seguro.factura_monto}</dd>
            </dl>
          </div>
          <div className="col-lg-4 col-md-5 col-sm-12">
            <dl className="dl-horizontal">
              <dt>Número de factura</dt>
              <dd>{this.props.data.seguro.factura_numero}</dd>
              <dt>Fecha de factura</dt>
              <dd>{this.props.data.seguro.factura_fecha}</dd>
            </dl>
          </div>
          <div className="clearfix visible-xs-block"></div>
        </div>;
    }
    else {
      titulo = <h2>Cotización</h2>;
      boton_asegurar =
        <button type="button" className="btn btn-warning btn-lg pull-right" data-toggle="tooltip" title="Asegurar" onClick={this.asegurar}>
          <span className="glyphicon glyphicon-lock" aria-hidden="true"></span>
        </button>;
    }
    return(
      <div className="col-md-12">
        <div className='page-header'>
          <div className='pull-right'>
            &nbsp;
            <a className="btn btn-primary" href=""><span className='glyphicon glyphicon-edit'></span>
            Editar
            </a>
            &nbsp;
            <a className="btn btn-default" href={this.props.data.urls.listado_seguros}><span className='glyphicon glyphicon-list'></span>
            Seguros
            </a>
            &nbsp;
          </div>
          {titulo}
        </div>
      </div>
    );
  }
}
