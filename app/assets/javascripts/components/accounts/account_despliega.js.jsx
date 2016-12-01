class AccountDespliega extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      account: {
        id: '',
        codigo: '',
        nombre: '',
        vida_util: '',
        actualizar: '',
        auxiliar: [],
        asset: []
      }
    }
  }

  componentWillMount(){
    $.getJSON(this.props.data.urls.show_account, (response) => {
      this.setState ({account: response})
    });
  }

  render() {
    return (
        <div>
           Hello test!
        </div>
    )
  }
}