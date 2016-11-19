class AuxiliarDespliega extends React.Component {
  constructor(props) {
    super(props);
    this.state ={
      auxiliar: {
        code: '',
        name: '',
        status: '',
        account: {
          id: '',
          name: ''
        }
      }
    };
  }

  componentWillMount() {
    $.getJSON(this.props.data.urls.show, (response) => {
      this.setState({ auxiliar: response })
    });
  }

  obtieneEstado() {
    if(this.state.auxiliar.status == 1){
      return 'ACTIVO';
    }
    else if(this.state.auxiliar.status == 1) {
      return 'INACTIVO';
    }
  }

  render() {
    return(
      <div>
        <div className="page-header">
          <div className="pull-right">
            <a className="btn btn-primary" href={this.props.data.urls.edit}>
              <span className="glyphicon glyphicon-edit"></span>
              Editar
            </a>
            &nbsp;
            <a className="btn btn-default" href={this.props.data.urls.list}>
              <span className="glyphicon glyphicon-list"></span>
              Auxiliares
            </a>
          </div>
          <h2>Auxiliar</h2>
        </div>
        <dl className="dl-horizontal">
          <dt>Código</dt>
          <dd>{this.state.auxiliar.code}</dd>
          <dt>Nombre</dt>
          <dd>{this.state.auxiliar.name}</dd>
          <dt>Cuenta</dt>
          <dd><a title="15" href={'/accounts/'+this.state.auxiliar.account.id}>{this.state.auxiliar.account.name}</a></dd>
          <dt>Estado</dt>
          <dd>{this.obtieneEstado()}</dd>
        </dl>
      </div>
    );
  }
}
