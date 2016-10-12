
var Celda = React.createClass({
  render() {
    if(typeof this.props.td != 'undefined'){
      return (
        <td>
          <p>
            { this.props.td }
          </p>
        </td>
      );
    }
    else if (typeof this.props.th != 'undefined') {
      return (
        <th>
          <p>
            { this.props.th }
          </p>
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

var FilaCabecera = React.createClass({
  render() {
    var columnas = this.props.cabecera.map((col, i) => {
      return (
        <Celda th = { col }/>
      )
    });
    return (
      <tr>
        { columnas }
      </tr>
    );
  }
});

var TablaReportes = React.createClass({
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
        <table className = "table table-condensed table-striped table-bordered valorado">
          <thead>
            { columnas }
          </thead>
          <tbody>
            { filas }
          </tbody>
        </table>
      );
    }
    else {
      return (
        <table className = "table table-condensed table-striped table-bordered valorado">
          <thead>
            { columnas }
          </thead>
          <tbody>
          </tbody>
        </table>
      );
    }

  }
});

var BuscadorReportes = React.createClass({
  aplicandoBuscador(){
    var col = this.refs.col.value;
    var q = this.refs.q.value;
    var cuentas = this.refs.cuentas.value;
    var desde = this.refs.desde.value;
    var hasta = this.refs.hasta.value;
    var url = this.props.url_activos + "?col=" + col + "&q=" + q + "&cuentas=" + cuentas + "&desde=" + desde + "&hasta=" + hasta;
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
    return(
      <div className="page-header">
               <div className= 'form-inline'>
                  <div className="pull-right" data-action="reportes-activos">
                    <div className="form-group">
                      <label className="sr-only" for="cuentas">Columna</label>
                      <select ref= "col" name="col" id="col" className="form-control"><option value="all">Todas</option>
                      <option value="code">Código</option>
                      <option value="invoice">Número Factura</option>
                      <option value="description">Descripción</option></select>
                    </div>
                    <div className="form-group">
                      <label className="sr-only" for="buscar">Buscar</label>
                      <input ref = "q" type="text" name="q" id="buscar" className="form-control" placeholder="Buscar activos" autofocus="autofocus" autocomplete="off"/>
                    </div>
                    <div className="form-group">
                      <label className="sr-only" for="cuentas">Cuentas</label>
                      <select  ref = "cuentas" namresponsee="cuentas" id="cuentas" className="form-control"><option value="">Seleccionar cuentas</option><option value="1">1 - EDIFICACIONES</option>
                      <option value="2">2 - MUEBLES Y ENSERES DE OFICINA</option>
                      <option value="3">3 - MAQUINARIA EN GENERAL</option>
                      <option value="31">4 - EQUIPO MEDICO Y DE LABORATORIO</option>
                      <option value="32">5 - EQUIPO DE COMUNICACIONES</option>
                      <option value="33">6 - EQUIPO EDUCACIONAL Y RECREATIVO</option>
                      <option value="4">7 - BARCOS Y LANCHAS EN GENERAL</option>
                      <option value="5">8 - VEHICULOS AUTOMOTORES</option>
                      <option value="6">9 - AVIONES</option>
                      <option value="7">10 - MAQUINARIA PARA LA CONSTRUCCION</option>
                      <option value="8">11 - MAQUINARIA AGRICOLA</option>
                      <option value="9">12 - ANIMALES DE TRABAJO</option>
                      <option value="10">13 - HERRAMIENTAS EN GENERAL</option>
                      <option value="11">14 - REPRODUCTORES Y HEMBRAS DE PEDIGREE</option>
                      <option value="12">15 - EQUIPOS DE COMPUTACION</option>
                      <option value="13">16 - CANALES DE REGADIO Y POZOS</option>
                      <option value="14">17 - ESTANQUES, BA¥ADEROS Y ABREVADEROS</option>
                      <option value="15">18 - ALAMBRADOS, TRANQUERAS Y VALLAS</option>
                      <option value="16">19 - VIVIENDAS PARA EL PERSONAL</option>
                      <option value="17">20 - MUEBLES Y ENSERES EN VIVIENDAS DE PERSONAL</option>
                      <option value="18">21 - SILOS, ALMACENES Y GALPONES</option>
                      <option value="19">22 - TINGLADOS Y COBERTIZOS DE MADERA</option>
                      <option value="20">23 - TINGLADOS Y COBERTIZOS DE METAL</option>
                      <option value="21">24 - INSTALACION DE ELECTRIFICACION Y TELEFONIA RURAL</option>
                      <option value="22">25 - CAMINOS INTERIORES</option>
                      <option value="23">26 - CA¥A DE AZUCAR</option>ref = "desde"
                      <option value="24">27 - VIDES</option>
                      <option value="25">28 - FRUTALES</option>
                      <option value="27">29 - LINEAS DE RECOLECCION DE LA INDUSTRIA PETROLERA</option>
                      <option value="26">30 - POZOS PETROLEROS</option>
                      <option value="28">31 - EQUIPOS DE CAMPO DE LA INDUSTRIA PETROLERA</option>
                      <option value="29">32 - PLANTA DE PROCESAMIENTO DE LA INDUSTRIA PETROLERA</option>
                      <option value="30">33 - DUCTOS DE LA INDUSTRIA PETROLERA</option>
                      <option value="34">34 - TERRENOS</option>
                      <option value="35">36 - OTROS ACTIVOS FIJOS</option>
                      <option value="36">37 - ACTIVOS INTANGIBLES</option>
                      <option value="37">38 - EQUIPO E INSTALACIONES</option>
                      <option value="38">39 - OTRAS PLANTACIONES</option>
                      <option value="39">40 - ACTIVOS MUSEOLOGICOS Y CULTURALES</option></select>
                    </div>
                    <div className="form-group">
                      <label for="fecha-desde">Fechas</label>
                      <input ref = "desde" type="text" name="desde" id="fecha-desde" className="form-control fecha-buscador" placeholder="Desde fecha" autocomplete="off"/>
                    </div>
                    <div className="form-group">
                      <label className="sr-only" for="fecha-hasta">Hasta</label>
                      <input ref = "hasta" type="text" name="hasta" id="fecha-hasta" className="form-control fecha-buscador" placeholder="Hasta fecha" autocomplete="off"/>
                    </div>
                    <button className="btn btn-primary" title="Generar kardexes de todos los subartículos" type="#" onClick={ this.aplicandoBuscador } >
                      <span className="glyphicon glyphicon-search"></span>
                    </button>
                  </div>
                </div>
                  <h2>Reporte de activos fijos</h2>
                </div>
    );
  }
});

var ReporteActivos = React.createClass({
  getInitialState() {
    return { tabla: [],
             cabecera: [{th: "Nro"}, {th: "Código"}, {th: "Factura"}, {th: "Fecha"}, {th: "Descripción"}, {th: "Cuenta"}, {th: "Precio"}]}
  },
  componentWillMount() {
    $.getJSON(this.props.url_activos, (response) => {
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
        <BuscadorReportes url_activos =  { this.props.url_activos } actualizacionTabla={ this.actualizarTabla }/>
        <div className='row'>
          <div className='col-sm-12'>
            <div className="pull-right">
              <span >Descargar:</span>
              <div className="btn-group btn-group-xs">
                <button name="button" type="submit" className="download-assets btn btn-default" data-url="http://localhost:3000/users/11/download.csv" >CSV</button>
                <button name="button" type="submit" className="download-assets btn btn-default" data-url="http://localhost:3000/users/11/download.pdf" >PDF</button>
              </div>
            </div>
            <TablaReportes key = "1"
                           cabecera = { this.state.cabecera }
                           tabla = { this.state.tabla } />
          </div>
        </div>
      </div>
    );
  }
});
