class SeguroTablaActivos extends React.Component {
  sumatoria() {
    return(
      <tr key>
        <td colSpan='3'>
        </td>
        <td>
          <strong>
            TOTAL:
          </strong>
        </td>
        <td className = "number">
          <strong>
            {this.props.sumatoria}
        </strong>
        </td>
      </tr>
    );
  }

  render() {
    var cantidad_activos  = this.props.activos.length;
    if(cantidad_activos > 0){
      let activos = this.props.activos.map((activo, i) => {
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
            <td>
              { activo.cuenta }
            </td>
            <td className = "number">
              { activo.precio }
            </td>
          </tr>
        )
      });

      return (
        <table className="table table-bordered table-striped table-hover table-condensed" id="ingresos-tbl">
          <thead>
            <tr>
              <th className="text-center">
                <strong className="badge" title="Total">
                  {cantidad_activos}
                </strong>
              </th>
              <th className="text-center">Código</th>
              <th>Descripción</th>
              <th>Cuenta</th>
              <th>Precio</th>
            </tr>
          </thead>
          <tbody>
            { activos }
            { this.sumatoria() }
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
}
