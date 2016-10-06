var Activo = React.createClass({
    getLinkAsset(){
      return "/assets/" + this.props.activo.code;
    },

    render() {
        var indice = this.props.indice;
        var descripcion = this.props.activo.description;
        var codigo = this.props.activo.code;
        var link = this.getLinkAsset();
        return (
            <tr>
              <td>{ indice }</td>
              <td>{ descripcion }</td>
              <td className = 'nowrap text-center'>
                <a href = {link}>{codigo}</a>
              </td>
            </tr>
        )
    }
});

var Activos = React.createClass({
  render() {
    var activos = this.props.activos.map((activo, i) => {
      return (
        <Activo indice = { i + 1 }
                activo = { activo }/>
      )
    });
    return (
      <table className="table table-striped table-condensed table-bordered alineacion-media">
      <thead>
        <tr>
          <th></th>
          <th>Descripción</th>
          <th>Código</th>
        </tr>
      </thead>
      <tbody>
        { activos }
      </tbody>
      </table>
    );
  }
});

var CodigoUsuario = React.createClass({
  render: function() {
    var code = this.props.code;
    return (
      <div>
        <dt>Código</dt>
        <dd>{ code }</dd>
      </div>
    );
  }
});

var Usuario = React.createClass({
  obtCodeUsuario(){
    if(this.props.usuario.code){
      return(
        <CodigoUsuario code = {this.props.usuario.code}/>
      );
    }
  },
  render: function() {
    return (
      <div className="col-lg-4 col-md-5 col-sm-12">
        <dl className="dl-horizontal">
          <dt>Código</dt>
          <dd>{ this.props.usuario.code }</dd>
          <dt>Cargo</dt>
          <dd>{ this.props.usuario.title }</dd>
          <dt>C.I.</dt>
          <dd>{ this.props.usuario.ci } </dd>
          <dt>Email</dt>
          <dd>{ this.props.usuario.email }</dd>
          <dt>Usuario</dt>
          <dd>{ this.props.usuario.username }</dd>
          <dt>Teléfono</dt>
          <dd>{ this.props.usuario.phone }</dd>
          <dt>Celular</dt>
          <dd>{ this.props.usuario.mobile }</dd>
          <dt>Unidad</dt>
          <dd>{ this.props.usuario.department_name }</dd>
          <dt>Rol</dt>
          <dd>{ this.props.usuario.role }</dd>
          <dt>Estado</dt>
          <dd>{ this.props.usuario.estado }</dd>
        </dl>
      </div>
    );
  }
});

var Cuerpo = React.createClass({
  render: function() {
    return (
      <div>
        <Activos activos={this.props.activos}/>
      </div>
    );
  }
});

var Cabecera = React.createClass({
  render: function() {
    return (
      <div>
        <div className="pull-right">
          <div class="btn-group" data-toggle="buttons">
            <label class="btn btn-default">
              <input type="radio" name="reports" id="reports_historical" value="historical" data-url="/users/126/historical"/>
              <span class="glyphicon glyphicon-list-alt"></span>
              Histórico
            </label>
            <label class="btn btn-default active">
              <input type="radio" name="reports" id="reports_current" value="current" checked="checked"/>
              <span class="glyphicon glyphicon-th-list"></span>
            </label>
          </div>
          <a class="btn btn-primary" href="/users/126/edit"><span class="glyphicon glyphicon-edit"></span>
          Editar
        </a>
        <a class="btn btn-default" href="/users"><span class="glyphicon glyphicon-list"></span>
        Funcionarios
      </a>
    </div>
    <h2>{this.props.usuario.name}</h2>
  </div>
    );
  }
});

var Funcionario = React.createClass({
  render: function() {
    return (
      <div>
        <div className="page-header" >
          <Cabecera usuario = {this.props.usuario} />
        </div>
        <div className="row">
          <div className="col-lg-4 col-md-5 col-sm-12">
            <Usuario usuario= { this.props.usuario }/>
          </div>
          <div className="col-lg-8 col-md-7 col-sm-12" id="current-assets">
            <Cuerpo activos = {this.props.activos} />
          </div>
        </div>
      </div>
    );
  }
});
