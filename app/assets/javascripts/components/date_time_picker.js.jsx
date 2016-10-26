class DateTimePicker extends React.Component {
  getInitialState() {
    return {
      fecha: this.props.valor|| '',
    }
  }

  componentDidMount() {
    _ = this;
    $("#" + this.props.id).datetimepicker({
      format: 'DD/MM/YYYY HH:mm',
      locale: 'es'
    });
  }

  capturaFecha(){
    this.setState({
      fecha: this.refs.datepicker.value
    });
    this.props.captura_fecha();
  }

  render(){
    return(
      <input type="text" ref='datepicker' id={this.props.id} className={this.props.classname} placeholder={this.props.placeholder} autoComplete="off" onChange={this.capturaFecha} />
    )
  }
}
