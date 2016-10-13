var Celda = React.createClass({
  render() {
    if(typeof this.props.td != 'undefined'){
      return (
        <td>
          { this.props.td }
        </td>
      );
    }
    else if (typeof this.props.th != 'undefined') {
      return (
        <th>
          { this.props.th }
        </th>
      );
    }
    else {
      return(
        <td></td>
      );
    }
  }
});

var Opcion = React.createClass({
  render() {
    var clave = this.props.opcion.clave;
    var descripcion = this.props.opcion.descripcion;
    return(
        <option value = { clave }>
          { descripcion }
        </option>
    );
  }
});

var Fila = React.createClass({
  render() {
    var indice = this.props.indice;
    var codigo = this.props.fila.codigo;
    var factura = this.props.fila.factura;
    var fecha = this.props.fila.fecha;
    var descripcion = this.props.fila.descripcion;
    var cuenta = this.props.fila.cuenta;
    var precio = this.props.fila.precio;
    return (
      <tr>
        <Celda td = { indice }/>
        <Celda td = { codigo }/>
        <Celda td = { factura }/>
        <Celda td = { fecha }/>
        <Celda td = { descripcion }/>
        <Celda td = { cuenta }/>
        <Celda td = { precio }/>
      </tr>
    );
  }
});

var TablaReportes = React.createClass({
  componentDidUpdate(){
    var blob, blobURL, csv;
    csv = '';
    $('table > thead').find('tr').each(function() {
      var sep;
      sep = '';
      $(this).find('th').each(function() {
        csv += sep + $(this)[0].innerHTML;
        return sep = ';';
      });
      return csv += '\n';
    });
    $('table > tbody').find('tr').each(function() {
      var sep;
      sep = '';
      $(this).find('td').each(function() {
        csv += sep + $(this)[0].innerHTML;
        return sep = ';';
      });
      return csv += '\n';
    });
    $('table > tbody').find('tr:last').each(function() {
      var sep;
      sep = ';;;;';
      $(this).find('th').each(function() {
        csv += sep + $(this)[0].innerHTML;
        return sep = ';';
      });
      csv += '\n';
    });
    window.URL = window.URL || window.webkiURL;
    blob = new Blob([csv]);
    blobURL = window.URL.createObjectURL(blob);
    return $('#obtiene_csv').attr('href', blobURL).attr('download', 'data.csv');
  },
  render() {
    if(this.props.cabecera.length > 0){
      var columnas = this.props.cabecera.map((col, i) => {
        return (
          <Celda key = { i }
                 th = { col.th }/>
        )
      });
    }
    if(this.props.tabla.length > 0){
      var filas = this.props.tabla.map((fila, i) => {
        return (
          <Fila key = { i + 1 }
                indice = { i + 1 }
                fila = { fila }/>
        )
      });
      return (
        <div>
          <div className="pull-right">
            <span >Descargar:</span>
            <div className="btn-group btn-group-xs">
              <a id="obtiene_csv" className="btn btn-default" href= {  }>CSV</a>
              <a id="obtiene_pdf" className="btn btn-default">PDF</a>
            </div>
          </div>
          <table className = "table table-condensed table-striped table-bordered valorado">
            <thead>
              <tr>
                { columnas }
              </tr>
            </thead>
            <tbody>
              { filas }
            </tbody>
          </table>
        </div>
      );
    }
    else {
      return (
        <table className = "table table-condensed table-striped table-bordered valorado">
          <thead>
            <tr>
              { columnas }
            </tr>
          </thead>
          <tbody>
          </tbody>
        </table>
      );
    }
  }
});

var ReportesBuscadorBasico = React.createClass({
  aplicandoBuscador(){
    var host = this.props.url;
    var cuenta = this.refs.cuenta.value;
    var desde = this.refs.desde.value;
    var hasta = this.refs.hasta.value;
    var col = this.refs.col.value;
    var q = this.refs.q.value;
    parametros = "?col=" + col + "&q=" + q + "&cu=" + cuenta + "&desde=" + desde + "&hasta=" + hasta;
    url = host + parametros;
    $.ajax({
        url:  url,
        type: 'GET',
        success: (response) => {
          this.props.actualizacionTabla(response);
        },
        error:(xhr) => {
          this.props.actualizacionTabla([]);
        }
    });
  },

  render(){
    if(this.props.cuentas.length > 0){
      var cuentas = this.props.cuentas.map((opcion, i) => {
        return (
          <Opcion key = { i }
                  opcion = { opcion }/>
        )
      });
    }
    var columnas = this.props.columnas.map((opcion, i) => {
      return (
        <Opcion key = { i }
                opcion = { opcion }/>
      )
    });
    return(
      <div className="pull-right" data-action="reportes-activos">
        <div className="form-group">
          <label className="sr-only" htmlFor= "columnas">columnas</label>
          <select ref = "col" name = "col" id="columnas" className = "form-control">
            { columnas }
          </select>
        </div>
        &nbsp;
        <div className="form-group">
          <label className="sr-only" htmlFor="buscar">Buscar</label>
          <input ref = "q" type="text" name="q" id="q" className="form-control" placeholder="Buscar" autofocus="autofocus" autoComplete="off"/>
        </div>
        &nbsp;
        <div className="form-group">
          <label className="sr-only" htmlFor="cuenta">cuenta</label>
          <select ref = "cuenta" name = "cuenta" id ="cuenta" className = "form-control">
            { cuentas }
          </select>
        </div>
        &nbsp;
        &nbsp;
        <div className="form-group">
          <label htmlFor="fecha-desde">Fechas</label>
          <input ref = "desde" type="text" name="desde" id="fecha-desde" className="form-control fecha-buscador" placeholder="Desde fecha" autoComplete="off"/>
        </div>
        &nbsp;
        <div className="form-group">
          <label className="sr-only" htmlFor="fecha-hasta">Hasta</label>
          <input ref = "hasta" type="text" name="hasta" id="fecha-hasta" className="form-control fecha-buscador" placeholder="Hasta fecha" autoComplete="off"/>
        </div>
        &nbsp;
        <button className="btn btn-primary" title="Generar kardexes de todos los subartículos" type="#" onClick={ this.aplicandoBuscador } >
          <span className="glyphicon glyphicon-search"></span>
        </button>
      </div>
    );
  }
});

var ReportesBuscadorAvanzado = React.createClass({
  aplicandoBuscador(){
    var host = this.props.url;
    var cuenta = this.refs.cuenta.value;
    var desde = this.refs.desde.value;
    var hasta = this.refs.hasta.value;
    var codigo = this.refs.codigo.value;
    var numero_factura = this.refs.numero_factura.value;
    var descripcion = this.refs.descripcion.value;
    var precio = this.refs.precio.value;
    parametros = "?co=" + codigo + "&nf=" + numero_factura + "&de=" + descripcion +  "&cu=" + cuenta +  "&pr=" + precio + "&desde=" + desde + "&hasta=" + hasta;
    url = url + parametros;
    $.ajax({
        url:  url,
        type: 'GET',
        success: (response) => {
          this.props.actualizacionTabla(response);
        },
        error:(xhr) => {
          this.props.actualizacionTabla([]);
        }
    });
  },

  render(){
    if(this.props.cuentas.length > 0){
      var cuentas = this.props.cuentas.map((opcion, i) => {
        return (
          <Opcion key = { i }
                  opcion = { opcion }/>
        )
      });
    }
    return(
      <div className="pull-right" data-action="reportes-activos">
        <div className="form-group">
          <label className="sr-only">Código</label>
          <input ref = "codigo" type="text" name="codigo" id="codigo" className="form-control" placeholder="Código" autofocus="autofocus" autoComplete="off"/>
        </div>
        &nbsp;
        <div className="form-group">
          <label className="sr-only">Factura</label>
          <input ref = "numero_factura" type="text" name="numero_factura" id="factura" className="form-control" placeholder="Número Factura" autofocus="autofocus" autoComplete="off"/>
        </div>
        &nbsp;
        <div className="form-group">
          <label className="sr-only">Descripción</label>
          <input ref = "descripcion" type="text" name="descripcion" id="descripcion" className="form-control" placeholder="Descripción" autofocus="autofocus" autoComplete="off"/>
        </div>
        &nbsp;
        <div className="form-group">
          <label className="sr-only">Precio</label>
          <input ref = "precio" type="text" name="precio" id="precio" className="form-control" placeholder="Precios" autofocus="autofocus" autoComplete="off"/>
        </div>
        &nbsp;
        <div className="form-group">
          <label className="sr-only" htmlFor="cuenta">cuenta</label>
          <select ref = "cuenta" id="cuenta" name = "cuenta" className = "form-control">
            { cuentas }
          </select>
        </div>
        &nbsp;
        &nbsp;
        <div className="form-group">
          <label htmlFor="fecha-hasta">Fechas</label>
          <input ref = "desde" type="text" name="desde" className="form-control fecha-buscador" placeholder="Desde fecha" autoComplete="off"/>
        </div>
        &nbsp;
        <div className="form-group">
          <label className="sr-only" htmlFor="fecha-hasta">Hasta</label>
          <input ref = "hasta" type="text" name="hasta" className="form-control fecha-buscador" placeholder="Hasta fecha" autoComplete="off"/>
        </div>
        &nbsp;
        <button className="btn btn-primary" title="Generar kardexes de todos los subartículos" type="#" onClick={ this.aplicandoBuscador } >
          <span className="glyphicon glyphicon-search"></span>
        </button>
      </div>
    );
  }
});

var ReportesBuscador = React.createClass({
  getInitialState() {
    return { tipo_buscador: "basico"}
  },

  componentDidUpdate(){
    $(".fecha-buscador").datepicker({
      autoclose: true,
      format: "dd-mm-yyyy",
      language: "es"
    });
  },

  cambioBuscador(){
    if(this.state.tipo_buscador == "basico"){
      this.setState({ tipo_buscador: "avanzado" });
    }
    else{
      this.setState({ tipo_buscador: "basico" });
    }
  },

  render(){
    if(this.state.tipo_buscador == "basico"){
      return(
        <div>
          <div className="page-header buscador-2">
            <div className= 'form-inline'>
              <ReportesBuscadorBasico cuentas = { this.props.cuentas }
                                      columnas = { this.props.columnas }
                                      actualizacionTabla = {this.props.actualizacionTabla }
                                      url = { this.props.url }/>
              <h2>Reporte de Activos Fijos</h2>
            </div>
            <div className="pull-right">
              <a onClick= { this.cambioBuscador }>Búsqueda Avanzada</a>
            </div>
            <br/>
          </div>
        </div>
      );
    }
    else {
      if(this.props.columnas.length > 0){
        return(
          <div>
            <div className="page-header buscador-2">
              <div className= 'form-inline'>
                <ReportesBuscadorAvanzado cuentas = { this.props.cuentas}
                                          actualizacionTabla = {this.props.actualizacionTabla}
                                          url = { this.props.url }/>
                <h2>Reporte de Activos Fijos</h2>
              </div>
              <div className="pull-right">
                <a onClick= { this.cambioBuscador }>Búsqueda Básica</a>
              </div>
              <br/>
            </div>
          </div>
        );
      }
    }
  }
});

var ReporteActivos = React.createClass({
  getInitialState() {
    return { tabla: [],
             cabecera: [{th: "Nro"}, {th: "Código"}, {th: "Factura"}, {th: "Fecha"}, {th: "Descripción"}, {th: "Cuenta"}, {th: "Precio"}]}
  },
  componentWillMount() {
    $.getJSON(this.props.url, (response) => {
      this.setState({ tabla: response }) });
  },

  actualizarTabla(tabla) {
      this.setState({
          tabla: tabla
      });
  },

  render() {
    return (
      <div>
        <ReportesBuscador url =  { this.props.url } actualizacionTabla={ this.actualizarTabla } cuentas = { this.props.cuentas } columnas = { this.props.columnas }/>
        <div className='row'>
          <div className='col-sm-12'>
            <TablaReportes key = "1"
                           cabecera = { this.state.cabecera }
                           tabla = { this.state.tabla } />
          </div>
        </div>
      </div>
    );
  }
});
