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
          <h2>Cotización</h2>
        </div>
        <div className='row'>
          <div className="col-lg-1 col-md-1 col-sm-12">
            <button type="button" className="btn btn-warning btn-lg pull-right" data-toggle="tooltip" title="Asegurar" onClick={this.asegurar}>
              <span className="glyphicon glyphicon-lock" aria-hidden="true"></span>
            </button>
          </div>
          <div className="col-lg-11 col-md-11 col-sm-12">
            <SeguroTablaActivos activos={this.state.activos} sumatoria={this.state.sumatoria} resumen={this.state.resumen} sumatoria_resumen={this.state.sumatoria_resumen} />
          </div>
        </div>
      </div>
    );
  }
}
