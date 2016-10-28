var SeguroForm = React.createClass({
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


  capturaActualizaDatos(){
    this.props.capturarFactura({
      factura_numero: this.refs.factura_numero ? this.refs.factura_numero.value : '',
      factura_autorizacion: this.refs.factura_autorizacion ? this.refs.factura_autorizacion.value : '',
      factura_fecha: this.refs.factura_fecha ? this.refs.factura_fecha.refs.datepicker.value : ''
    });
    this.props.capturarContrato({
      numero_contrato: this.refs.numero_contrato ? this.refs.numero_contrato.value : '',
      fecha_inicio_vigencia: this.refs.fecha_inicio_vigencia ? this.refs.fecha_inicio_vigencia.refs.datepicker.value : '',
      fecha_fin_vigencia: this.refs.fecha_fin_vigencia ? this.refs.fecha_fin_vigencia.refs.datepicker.value : ''
    });
  },

  render() {
    return(
      <div className='form-horizontal' id='factura-form' role='form'>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Proveedor</label>
          <div className='col-sm-4'>
            <AutoCompleteProveedor urls = { this.props.urls } capturarProveedor = { this.props.capturarProveedor } proveedor = {this.props.proveedor}/>
          </div>
          <div className='col-sm-2'>
            <input type="text" name="nit" id="nit" value= { this.props.proveedor ? this.props.proveedor.nit : '' } className="form-control" placeholder="NIT proveedor" disabled="disabled" autoComplete="off" readOnly />
          </div>
          <div className='col-sm-2'>
            <input type="text" name="telefono" id="telefono" value = { this.props.proveedor ? this.props.proveedor.telefono : '' } className="form-control" placeholder="Teléfonos proveedor" disabled="disabled" autoComplete="off" readOnly />
          </div>
        </div>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Factura</label>
          <div className='col-sm-2'>
            <input type="text" name="factura_numero" ref="factura_numero" id="factura_numero" className="form-control" placeholder="Número de factura" autoComplete="off" onChange={ this.capturaActualizaDatos } value={ this.props.factura.factura_numero }/>
          </div>
          <div className='col-sm-2'>
            <input type="text" name="factura_autorizacion" ref="factura_autorizacion" id="factura_autorizacion" className="form-control" placeholder="Número autorización" autoComplete="off" onChange= { this.capturaActualizaDatos } value={this.props.factura.factura_autorizacion}/>
          </div>
          <div className='col-sm-2'>
            <input type="text" name="factura_monto" ref="factura_monto" id="factura_monto" className="form-control" placeholder="Monto" autoComplete="off" onChange= { this.capturaActualizaDatos } value={this.props.factura.factura_monto}/>
          </div>
          <div className='col-sm-2'>
            <div className='input-group'>
              <DatePicker ref="factura_fecha" id="factura_fecha" placeholder={"Fecha de factura"} valor={this.props.factura.factura_fecha} classname="form-control" captura_fecha={this.capturaActualizaDatos}/>
              <div className='input-group-addon'>
                <span className='glyphicon glyphicon-calendar'></span>
              </div>
            </div>
          </div>
        </div>
        <div className='form-group'>
          <label className='col-sm-2 control-label'>Número de contrato</label>
            <div className='col-sm-2'>
              <input type="text" ref="numero_poliza" name="numero_poliza" id="numero_poliza" className="form-control" placeholder="Poliza" autoComplete="off" onChange= {this.capturaActualizaDatos}/>
            </div>
          <div className='col-sm-2'>
            <input type="text" ref="numero_contrato" name="numero_contrato" id="numero_contrato" className="form-control" placeholder="Número de contrato" autoComplete="off" onChange= {this.capturaActualizaDatos} value = {this.props.contrato.numero_contrato}/>
          </div>
          <div className='col-sm-2'>
            <div className='input-group'>
              <DateTimePicker ref="fecha_inicio_vigencia"  id="fecha_inicio_vigencia" placeholder={"Fecha inicio de vigencia"} valor={this.props.contrato.fecha_inicio_vigencia} classname="form-control" captura_fecha={this.capturaActualizaDatos} />
              <div className='input-group-addon'>
                <span className='glyphicon glyphicon-calendar'></span>
              </div>
            </div>
          </div>
          <div className='col-sm-2'>
            <div className='input-group'>
              <DateTimePicker ref="fecha_fin_vigencia" id="fecha_fin_vigencia" placeholder={"Fecha fin de vigencia"} valor={this.props.contrato.fecha_fin_vigencia} classname="form-control" captura_fecha={this.capturaActualizaDatos}/>
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
    var metodo = 'POST';
    if(this.props.data.seguro){
      url = url + "/" + this.props.data.seguro.id
      metodo = 'PUT';
    }
    var _ = this
    $.ajax({
      url: url,
      type: metodo,
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
             proveedor = {this.state.proveedor}
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
