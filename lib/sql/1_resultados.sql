SELECT s.code, s.description AS material, d.name AS unidad, -t.cantidad AS cantidad, r.nro_solicitud, t.fecha
FROM subarticles s LEFT JOIN entradas_salidas t ON s.id = t.subarticle_id
INNER JOIN requests r ON r.id = t.modelo_id
INNER JOIN users u ON u.id = r.user_id
INNER JOIN departments d ON d.id = u.department_id
WHERE t.tipo = 'salida' AND t.fecha BETWEEN %{desde} AND %{hasta}
ORDER BY s.code, s.description, d.name, r.delivery_date, r.nro_solicitud
