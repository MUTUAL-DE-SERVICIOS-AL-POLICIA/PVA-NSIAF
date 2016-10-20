var AutoCompleteProveedores = React.createClass({
  getInitialState() {
    return {
      value: '',
      suggestions: []
    }
  },

  onChange (event, { newValue, method }) {
    this.setState({
      value: newValue
    });
  },

  componentdidMount() {
    $(".date").datepicker({
      autoclose: true,
      format: "dd-mm-yyyy",
      language: "es"
    });
  },

  escapeRegexCharacters(str) {
    return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  },

  getSuggestionValue(suggestion) {
    this.props.capturarProveedor(suggestion);
    return suggestion.name;
  },

  renderSuggestion(suggestion) {
    return (
      <span>{suggestion.name}</span>
    );
  },

  onSuggestionsFetchRequested ({ value }) {
    this.props.capturarProveedor(null);
    const escapedValue = this.escapeRegexCharacters(value.trim());
    if (escapedValue === '') {
      this.setState({
        suggestions: []
      });
    }
    const regex = new RegExp(escapedValue, 'i');
    $.getJSON(this.props.url_data + "?q=" + escapedValue, (response) => {
      this.setState({
        suggestions: response.filter(proveedor => regex.test(proveedor.name))
      });
    })
  },

  onSuggestionsClearRequested () {
    this.setState({
      suggestions: []
    });
  },

  render() {
    const { value, suggestions } = this.state;
    const inputProps = {
      id: "proveedores",
      placeholder: "Proveedor",
      value,
      onChange: this.onChange,
      className: "form-control"
    };
    return (
        <Autosuggest
          suggestions={suggestions}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          getSuggestionValue={this.getSuggestionValue}
          renderSuggestion={this.renderSuggestion}
          inputProps={inputProps}/>
    );
  }
});

var SeguroForm = React.createClass({
  capturaDatosFactura(){
    this.props.capturarFactura({
      factura_numero: this.refs.factura_numero.value,
      factura_autorizacion: this.refs.factura_autorizacion.value,
      factura_fecha: this.refs.factura_fecha.value
    });
  },

  capturaDatosContrato(){
    this.props.capturarContrato({
      numero_contrato: this.refs.numero_contrato.value,
      fecha_inicio_vigencia: this.refs.fecha_inicio_vigencia.value,
      fecha_fin_vigencia: this.refs.fecha_fin_vigencia.value
    });
  },

  render() {
    return(
      <div className='form-horizontal' id='factura-form' role='form'>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Proveedor</label>
          <div className='col-sm-3'>
            <AutoCompleteProveedores url_data = { this.props.url_data } capturarProveedor = { this.props.capturarProveedor }/>
          </div>
          <div className='col-sm-3'>
            <input type="text" name="nit" id="nit" value= {this.props.proveedor ? this.props.proveedor.nit : ''} className="form-control" placeholder="NIT proveedor" disabled="disabled" autoComplete="off" />
          </div>
          <div className='col-sm-3'>
            <input type="text" name="telefono" id="telefono" value = {this.props.proveedor ? this.props.proveedor.telefono : ''} className="form-control" placeholder="Teléfonos proveedor" disabled="disabled" autoComplete="off" />
          </div>
        </div>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Factura</label>
          <div className='col-sm-3'>
            <input type="text" name="factura_numero" ref="factura_numero" id="factura_numero" className="form-control" placeholder="Número de factura" autoComplete="off" onChange= { this.capturaDatosFactura }/>
          </div>
          <div className='col-sm-3'>
            <input type="text" name="factura_autorizacion" ref="factura_autorizacion" id="factura_autorizacion" className="form-control" placeholder="Número autorización" autoComplete="off" onChange= { this.capturaDatosFactura }/>
          </div>
          <div className='col-sm-3'>
            <div className='input-group'>
              <input type="text" ref="factura_fecha" name="factura_fecha" id="factura_fecha" className="form-control date" placeholder="Fecha de factura" autoComplete="off" onChange= { this.capturaDatosFactura }/>
              <div className='input-group-addon'>
                <span className='glyphicon glyphicon-calendar'></span>
              </div>
            </div>
          </div>
        </div>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Número de contrato</label>
          <div className='col-sm-3'>
            <input type="text" ref="numero_contrato" name="numero_contrato" id="numero_contrato" className="form-control" placeholder="Número de contrato" autoComplete="off" onChange= {this.capturaDatosContrato}/>
          </div>
          <div className='col-sm-3'>
            <div className='input-group'>
              <input type="text" ref="fecha_inicio_vigencia" name="fecha_inicio_vigencia" id="fecha_inicio_vigencia" className="form-control date" placeholder="Fecha inicio vigencia" autoComplete="off" onChange= {this.capturaDatosContrato}/>
              <div className='input-group-addon'>
                <span className='glyphicon glyphicon-calendar'></span>
              </div>
            </div>
          </div>
          <div className='col-sm-3'>
            <div className='input-group'>
              <input type="text" ref="fecha_fin_vigencia" name="fecha_fin_vigencia" id="fecha_fin_vigencia" className="form-control date" placeholder="Fecha fin vigencia" autoComplete="off" onChange= {this.capturaDatosContrato}/>
              <div className='input-group-addon'>
                <span className='glyphicon glyphicon-calendar'></span>
              </div>
            </div>
          </div>
        </div>
        <div className='form-group' >
          <div className="col-md-offset-2 col-sm-offset-2 col-xs-offset-2 col-md-6 col-sm-6 col-xs-6">
            <input type="text" name="code" ref = "code" id="code" className="form-control input-lg" placeholder="Código de Barras de Activos Fijos (ej. 1-10, 12-15, 17, 20, ...)" autofocus="autofocus" autoComplete="off"/>
          </div>
          <div className="col-md-3 col-sm-3 col-xs-3">
            <button name="button" type="submit" className="btn btn-success btn-lg"><span className="glyphicon glyphicon-search"></span>
            Buscar
          </button>
          </div>
        </div>
      </div>);
  }
});

var SeguroTablaActivos = React.createClass({
  render() {
    return (
      <table className="table table-bordered table-striped table-hover table-condensed" id="ingresos-tbl">
        <thead>
          <tr>
            <th className="text-center">
              <strong className="badge" title="Total">1</strong>
            </th>
            <th className="text-center">Código</th>
            <th>Descripción</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td className="text-center">1</td>
            <td className="text-center">121</td>
            <td>PIZARRA DE CORCHO MEDIDAS LARGO 0.60X ALTO 0.40 MATERIAL CORCHO COLOR CAFÉ</td>
          </tr>
        </tbody>
      </table>
    );
  }
});

var SeguroBotonesAcciones = React.createClass({
  render() {
    return (
      <div className="row">
        <div className="col-md-12 col-sm-12 text-center">
          <a className="btn btn-danger cancelar-btn" href="/ingresos">
            <span className="glyphicon glyphicon-ban-circle"></span>
          Cancelar
        </a>
        &nbsp;
        <button name="button" type="submit" className="btn btn-primary guardar-btn" data-disable-with="Guardando...">
          <span className="glyphicon glyphicon-floppy-save"></span>
          Guardar
        </button>
        </div>
      </div>
    );
  }
});

var SeguroNuevo = React.createClass({
  getInitialState() {
    return {
            activos:[],
            proveedor:{},
            factura: {},
            contrato: {},
            seguro: {},
            barcode: ''
           }
  },

  jsonSeguro () {
    var datos_seguro;
    var proveedor_id;
    if(this.state.proveedor){
      proveedor_id = this.state.proveedor.id;
    }
    else {
      proveedor_id = null;
    }
    datos_seguro = {
      asset_ids: this.state.activos.map(function(e) {
        return e.id;
      }),
      supplier_id: proveedor_id
    };
    datos_seguro = $.extend({}, datos_seguro, this.state.factura);
    datos_seguro = $.extend({}, datos_seguro, this.state.contrato);
    this.setState({
      seguro: datos_seguro
    });
  },

  capturarProveedor(value){
    this.setState({
      proveedor: value
    });
  },

  capturarFactura(value){
    this.setState({
      factura: value
    });
  },

  capturarContrato(value){
    this.setState({
      contrato: value
    });
  },

  capturarBarcode(value){
    this.setState({
      barcode: value
    });
  },

  actualizacionTablaActivos(activos){
    this.setState({
        activos: activos,
    });
  },

  guardarDatos(){
    this.jsonSeguro();
    debugger
    console.log(this.state.seguro);
  },

  render() {
    console.log(this.state.proveedor);
    console.log(this.state.factura);
    console.log(this.state.contrato);
    console.log(this.state.activos);
    console.log(this.state.seguro);
    return (
      <div>
        <div className="row" data-action="seguros">
          <div className="col-md-12">
              <h3 className="text-center">Nuevo Seguro</h3>
          </div>
          <SeguroForm
            url_data= { this.props.url_data }
            capturarProveedor = { this.capturarProveedor }
            capturarFactura = { this.capturarFactura }
            capturarContrato = { this.capturarContrato }
            proveedor= {this.state.proveedor}/>
        </div>
        <SeguroTablaActivos/>
        <SeguroBotonesAcciones/>
      </div>
    );
  }
});
