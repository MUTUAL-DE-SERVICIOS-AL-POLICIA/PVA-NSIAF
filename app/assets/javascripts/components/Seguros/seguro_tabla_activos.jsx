class SeguroTablaActivos extends React.Component {
  tabla_detalle(cantidad) {
      const activos = this.props.activos.map((activo, i) => {
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

      const sumatoria = (
            <tr key>
              <td colSpan='3'>
              </td>
              <td className = "text-right">
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

    return(
      <table className="table table-bordered table-striped table-hover table-condensed">
        <thead>
          <tr>
            <th className="text-center">
              <strong className="badge" title="Total">
                {cantidad}
              </strong>
            </th>
            <th className="text-center">Código</th>
            <th className="text-center">Descripción</th>
            <th className="text-center">Cuenta</th>
            <th className="text-center">Precio</th>
          </tr>
        </thead>
        <tbody>
          { activos }
          { sumatoria }
        </tbody>
      </table>
    );
  }

  tabla_resumen(){
    let cantidad_total = 0;
    const cuentas = this.props.resumen.map((cuenta, i) => {
      cantidad_total = cantidad_total + cuenta.cantidad;
      return (
        <tr key = {i}>
          <td className="text-center">
            {i + 1}
          </td>
          <td>
            {cuenta.nombre}
          </td>
          <td className = "number">
            {cuenta.cantidad}
          </td>
          <td className="number">
            {cuenta.sumatoria}
          </td>
        </tr>
      )
    });

    const sumatoria_resumen = (
          <tr key>
            <td>
            </td>
            <td className = "text-right">
              <strong>
                TOTAL:
              </strong>
            </td>
            <td className = "number">
              <strong>
                {cantidad_total}
              </strong>
            </td>
            <td className = "number">
              <strong>
                {this.props.sumatoria_resumen}
              </strong>
            </td>
          </tr>
    );

    return(
      <table className="table table-bordered table-striped table-hover table-condensed">
        <thead>
          <tr>
            <th></th>
            <th className="text-center">Monto</th>
            <th className="text-center">Cantidad</th>
            <th className="text-center">Cuenta</th>
          </tr>
        </thead>
        <tbody>
          { cuentas }
          { sumatoria_resumen }
        </tbody>
      </table>
    );
  }

  render() {
    const botones_descarga =
      <div className="pull-right">
        <span>Descargar:</span>
        <div className="btn-group btn-group-xs">
          <button name="button" type="submit" className="download-assets btn btn-default">CSV</button>
          <button name="button" type="submit" className="download-assets btn btn-default">PDF</button>
        </div>
      </div>;

    const cantidad_activos  = this.props.activos.length;
    if(cantidad_activos > 0){
      return (
        <div role="tabpanel">
          {botones_descarga}
          <ul className="nav nav-tabs" role="tablist">
            <li className="nav-item active">
              <a aria-controls={'resumen-' + this.props.name} aria-expanded="true" className="nav-link active" data-toggle="tab" href={'#resumen-' + this.props.name} id={'resumen-' + this.props.name + '-tab'} role="tab">Resumen</a>
            </li>
            <li className="nav-item">
              <a aria-controls={'detalle-' + this.props.name} aria-expanded="false" className="nav-link" data-toggle="tab" href={'#detalle-' + this.props.name} id={'detalle-' + this.props.name + '-tab'} role="tab">Detalle</a>
            </li>
          </ul>
          <div className="tab-content">
            <div aria-expanded="true" aria-labelledby={'resumen-' + this.props.name + '-tab'} className="tab-pane fade active in" id={'resumen-' + this.props.name} role="tabpanel">
              {this.tabla_resumen()}
            </div>
            <div aria-expanded="false" aria-labelledby={'detalle-' + this.props.name + '-tab'} className="tab-pane fade" id={'detalle-' + this.props.name} role="tabpanel">
              {this.tabla_detalle(cantidad_activos)}
            </div>
          </div>
        </div>
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
