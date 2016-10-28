class BusquedaActivos extends React.Component {
  constructor(props) {
    super(props);
    this.capturaEnter = this.capturaEnter.bind(this);
    this.capturaDatosBarcode = this.capturaDatosBarcode.bind(this);
  }

  escapeRegexCharacters(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
  }

  escapeValor(value){
    return this.escapeRegexCharacters(value.trim());
  }

  capturaEnter(e){
    if(e.which == 13){
      this.capturaDatosBarcode();
    }
  }

  componentDidMount(){
    _ = this;
    $.getJSON(this.props.urls.activos, (response) => {
      _.props.capturaActivos(response.activos, response.sumatoria, response.resumen, response.sumatoria_resumen);
    });
  }

  capturaDatosBarcode(){
    var barcode = this.escapeValor(this.refs.barcode.value);
    _ = this;
    $.getJSON(this.props.urls.activos + "?barcode=" + barcode, (response) => {
      _.props.capturaActivos(response.activos, response.sumatoria, response.resumen, response.sumatoria_resumen);
    });
  }

  render () {
    return (
      <div className='form-group' >
        <div className="col-md-offset-2 col-sm-offset-2 col-xs-offset-2 col-md-6 col-sm-6 col-xs-6">
          <input type="text" ref="barcode" name={this.props.id} id={this.props.id} className="form-control input-lg" placeholder="Código de Barras de Activos Fijos (ej. 1-10, 12-15, 17, 20, ...)" autofocus="autofocus" autoComplete="off" onKeyPress={this.capturaEnter} />
        </div>
        <div className="col-md-3 col-sm-3 col-xs-3">
          <button name="button" type="submit" className="btn btn-success btn-lg" onClick={this.capturaDatosBarcode}>
            <span className="glyphicon glyphicon-search"></span>
            Adicionar Activos
          </button>
        </div>
      </div>
    );
  }
}
