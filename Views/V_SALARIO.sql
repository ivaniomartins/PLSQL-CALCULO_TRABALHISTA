PROMPT CREATE OR REPLACE VIEW v_salario
CREATE OR REPLACE VIEW v_salario (
  competencia,
  salario_bruto,
  valor_plantao,
  valor_hora_extra,
  valor_inss,
  valor_irff,
  salario_liquido
) AS
SELECT sb.dt_competencia competencia,
       sb.vl_salario_bruto salario_bruto,
       sb.vl_plantao valor_plantao,
       sb.vl_hora_extra valor_hora_extra,
       sl.vl_inss valor_inss,
       sl.vl_irff valor_irff,
       sl.vl_salario_liquido salario_liquido
FROM dba_usuario.salario_bruto sb,
     dba_usuario.salario_liquido sl
WHERE sb.dt_competencia = sl.dt_competencia
/

