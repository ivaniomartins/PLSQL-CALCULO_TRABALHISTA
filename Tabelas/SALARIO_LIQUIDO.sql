PROMPT CREATE TABLE salario_liquido
CREATE TABLE salario_liquido (
  dt_competencia     DATE         NULL,
  perc_inss          NUMBER(5,2)  NULL,
  vl_inss            NUMBER(5,2)  NULL,
  perc_irff          NUMBER       NULL,
  vl_irff            NUMBER(5,2)  NULL,
  vl_salario_liquido NUMBER(14,2) NULL,
  vl_salario_bruto   NUMBER(14,2) NULL
)
  STORAGE (
    NEXT       1024 K
  )
/

PROMPT ALTER TABLE salario_liquido ADD CONSTRAINT competencia_fk FOREIGN KEY
ALTER TABLE salario_liquido
  ADD CONSTRAINT competencia_fk FOREIGN KEY (
    dt_competencia
  ) REFERENCES salario_bruto (
    dt_competencia
  )
/


