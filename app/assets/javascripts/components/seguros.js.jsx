function escapeRegexCharacters(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}

function escapeValor(value){
  return escapeRegexCharacters(value.trim());
}

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
    escapedValue = escapeValor(value);
    if (escapedValue === '') {
      this.setState({
        suggestions: []
      });
    }
    const regex = new RegExp(escapedValue, 'i');
    $.getJSON(this.props.urls.proveedores + "?q=" + escapedValue, (response) => {
      this.setState({
        suggestions: response.filter(proveedor => regex.test(proveedor.name))
      });
    });
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
          onSuggestionsFetchRequested = { this.onSuggestionsFetchRequested }
          onSuggestionsClearRequested = { this.onSuggestionsClearRequested }
          getSuggestionValue = { this.getSuggestionValue }
          renderSuggestion = { this.renderSuggestion }
          inputProps = { inputProps }/>
    );
  }
});

var SeguroForm = React.createClass({
  componentDidMount() {
    _ = this;
    $(".date").datepicker({
      autoclose: true,
      format: "dd-mm-yyyy",
      language: "es"
    }).on("changeDate",function(){
      if(this.id == "factura_fecha"){
        _.capturaDatosFactura();
      }
      if(this.id == "fecha_inicio_vigencia" || this.id == "fecha_fin_vigencia"){
        _.capturaDatosContrato();
      }
    });
  },

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

  capturaEnter(e){
    if(e.which == 13){
      this.capturaDatosBarcode();
    }
  },

  capturaDatosBarcode(){
    var barcode = escapeValor(this.refs.barcode.value);
    var activos = []
    if (barcode === '') {
      this.props.capturarActivos([]);
    }
    else {
      $.getJSON(this.props.urls.activos + "?barcode=" + barcode, (response) => {
        this.props.capturarActivos(response);
      });
    }
  },

  render() {
    return(
      <div className='form-horizontal' id='factura-form' role='form'>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Proveedor</label>
          <div className='col-sm-3'>
            <AutoCompleteProveedores urls = { this.props.urls } capturarProveedor = { this.props.capturarProveedor }/>
          </div>
          <div className='col-sm-3'>
            <input type="text" name="nit" id="nit" value= { this.props.proveedor ? this.props.proveedor.nit : '' } className="form-control" placeholder="NIT proveedor" disabled="disabled" autoComplete="off" />
          </div>
          <div className='col-sm-3'>
            <input type="text" name="telefono" id="telefono" value = { this.props.proveedor ? this.props.proveedor.telefono : '' } className="form-control" placeholder="Teléfonos proveedor" disabled="disabled" autoComplete="off" />
          </div>
        </div>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Factura</label>
          <div className='col-sm-3'>
            <input type="text" name="factura_numero" ref="factura_numero" id="factura_numero" className="form-control" placeholder="Número de factura" autoComplete="off" onChange= { this.capturaDatosFactura } value = {this.props.factura.factura_numero }/>
          </div>
          <div className='col-sm-3'>
            <input type="text" name="factura_autorizacion" ref="factura_autorizacion" id="factura_autorizacion" className="form-control" placeholder="Número autorización" autoComplete="off" onChange= { this.capturaDatosFactura } value = {this.props.factura.factura_autorizacion}/>
          </div>
          <div className='col-sm-3'>
            <div className='input-group'>
              <input type="text" ref="factura_fecha" name="factura_fecha" id="factura_fecha" className="form-control date" placeholder="Fecha de factura" autoComplete="off" onChange= { this.capturaDatosFactura } value = {this.props.factura.factura_fecha}/>
              <div className='input-group-addon'>
                <span className='glyphicon glyphicon-calendar'></span>
              </div>
            </div>
          </div>
        </div>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Número de contrato</label>
          <div className='col-sm-3'>
            <input type="text" ref="numero_contrato" name="numero_contrato" id="numero_contrato" className="form-control" placeholder="Número de contrato" autoComplete="off" onChange= {this.capturaDatosContrato} value = {this.props.contrato.numero_contrato}/>
          </div>
          <div className='col-sm-3'>
            <div className='input-group'>
              <input type="text" ref="fecha_inicio_vigencia" name="fecha_inicio_vigencia" id="fecha_inicio_vigencia" className="form-control date" placeholder="Fecha inicio vigencia" autoComplete="off" onChange= {this.capturaDatosContrato} value = {this.props.contrato.fecha_inicio_vigencia}/>
              <div className='input-group-addon'>Nuevo
                <span className='glyphicon glyphicon-calendar'></span>
              </div>
            </div>
          </div>
          <div className='col-sm-3'>
            <div className='input-group'>
              <input type="text" ref="fecha_fin_vigencia" name="fecha_fin_vigencia" id="fecha_fin_vigencia" className="form-control date" placeholder="Fecha fin vigencia" autoComplete="off" onChange= { this.capturaDatosContrato } value = {this.props.contrato.fecha_fin_vigencia}/>
              <div className='input-group-addon'>
                <span className='glyphicon glyphicon-calendar'></span>
              </div>
            </div>
          </div>
        </div>
        <div className='form-group' >
          <div className="col-md-offset-2 col-sm-offset-2 col-xs-offset-2 col-md-6 col-sm-6 col-xs-6">
            <input type="text" name="barcode" ref = "barcode" id="code" className="form-control input-lg" placeholder="Código de Barras de Activos Fijos (ej. 1-10, 12-15, 17, 20, ...)" autofocus="autofocus" autoComplete="off" onKeyPress= { this.capturaEnter }/>
          </div>
          <div className="col-md-3 col-sm-3 col-xs-3">
            <button name="button" type="submit" className="btn btn-success btn-lg" onClick= { this.capturaDatosBarcode }><span className="glyphicon glyphicon-search"></span>
              Buscar
            </button>
          </div>
        </div>
      </div>);
  }
});

var SeguroTablaActivos = React.createClass({
  render() {
    var cantidad_activos  = this.props.activos.length;
    if(cantidad_activos > 0){
      var activos = this.props.activos.map((activo, i) => {
        return (
          <tr key = {i}>
            <td className="text-center">
              { i + 1 }
            </td>
            <td className="text-center">
              { activo.code }
            </td>
            <td>
              { activo.description }
            </td>
          </tr>
        )
      });
      return (
        <table className="table table-bordered table-striped table-hover table-condensed" id="ingresos-tbl">
          <thead>
            <tr>
              <th className="text-center">
                <strong className="badge" title="Total">{cantidad_activos}</strong>
              </th>
              <th className="text-center">Código</th>
              <th>Descripción</th>
            </tr>
          </thead>
          <tbody>
            { activos }
          </tbody>
        </table>
      );
    }
    else {
      return(
        <div>
        </div>
      );
    }

  }
});

var SeguroBotonesAcciones = React.createClass({
  render() {
    return (
      <div className="row">
        <div className="col-md-12 col-sm-12 text-center">
          <a className="btn btn-danger cancelar-btn" href= {this.props.urls.seguros}>
            <span className="glyphicon glyphicon-ban-circle"></span>
          Cancelar
        </a>
        &nbsp;
        <button name="button" type="submit" className="btn btn-primary guardar-btn" data-disable-with="Guardando..." onClick={this.props.guardarDatos}>
          <span className="glyphicon glyphicon-floppy-save"></span>
          Guardar
        </button>
        </div>
      </div>
    );
  }
});

var SeguroFormulario = React.createClass({
  getFactura(data){
    return {
      factura_numero: data.factura_numero,
      factura_autorizacion: data.factura_autorizacion,
      factura_fecha: data.factura_fecha
    }
  },

  getContrato(data){
    return {
      numero_contrato: data.numero_contrato,
      fecha_inicio_vigencia: data.fecha_inicio_vigencia,
      fecha_fin_vigencia: data.fecha_fin_vigencia
    }
  },

  getInitialState() {
    if(this.props.data.seguro){
      return{
        activos: this.props.data.seguro.assets,
        proveedor: this.props.data.seguro.supplier,
        factura: this.getFactura(this.props.data.seguro),
        contrato: this.getContrato(this.props.data.seguro),
        seguro: {},
        barcode: ''
      }
    }
    else{
      return {
              activos:[],
              proveedor:{},
              factura: {},
              contrato: {},
              seguro: {},
              barcode: ''
             }
    }
  },

  jsonSeguro() {
    var datos_seguro;
    var proveedor_id;
    var id;
    if(this.state.proveedor){
      proveedor_id = this.state.proveedor.id;
    }
    else {
      proveedor_id = null;
    }
    if(this.props.seguro){
      id = this.props.seguro.id;
    }
    datos_seguro = {
      id: id,
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
    this.jsonSeguro();
  },

  capturarFactura(value){
    this.setState({
      factura: value
    });
    this.jsonSeguro();
  },

  capturarContrato(value){
    this.setState({
      contrato: value
    });
    this.jsonSeguro();
  },

  capturarBarcode(value){
    this.setState({
      barcode: value
    });
    this.jsonSeguro();
  },

  capturarActivos(activos){
    this.setState({
        activos: activos,
    });
    this.jsonSeguro();
  },

  guardarDatos(e){
    var alert = new Notices({ ele: 'div.main' });
    var url = this.props.data.urls.seguros;
    if(this.props.seguro){
      url = url + "/" + this.props.seguro.id
    }
    var _ = this
    $.ajax({
      url: url,
      type: 'POST',
      dataType: 'JSON',
      data: {
        seguro: this.state.seguro
      }
    }).done(function(seguro) {
      alert.success("Se guardó correctamente el seguro");
      return window.location = _.props.data.urls.seguro + "/" + seguro.id;
    }).fail(function(xhr, status) {
      alert.danger("Error al guardar el seguro");
    });
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
              <h3 className="text-center">{this.props.data.titulo}</h3>
          </div>
          <SeguroForm
            urls = { this.props.data.urls }
            capturarProveedor = { this.capturarProveedor }
            capturarFactura = { this.capturarFactura }
            capturarContrato = { this.capturarContrato }
            capturarActivos = { this.capturarActivos }
            proveedor = {this.state.seguro}
            factura = { this.state.factura }
            contrato = { this.state.contrato }
            />
        </div>
        <SeguroTablaActivos
          activos = { this.state.activos }/>
        <SeguroBotonesAcciones
          urls = { this.props.data.urls }
          guardarDatos = { this.guardarDatos }/>
      </div>
    );
  }
});
