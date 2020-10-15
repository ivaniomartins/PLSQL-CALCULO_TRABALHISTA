PROMPT CREATE TABLE salario_bruto
CREATE TABLE salario_bruto (
  vl_salario_base        NUMBER(14,2) NULL,
  dt_competencia         DATE         NOT NULL,
  hr_plantao             NUMBER(14,2) NULL,
  vl_plantao             NUMBER(14,2) NULL,
  qtd_hora_extra         NUMBER(14,2) NULL,
  vl_hora_extra          NUMBER(14,2) NULL,
  vl_salario_bruto       NUMBER(14,2) NULL,
  vl_quiquenio           NUMBER(4,2)  NULL,
  vl_descanso_remunerado NUMBER(14,2) NULL
)
  STORAGE (
    NEXT       1024 K
  )
/

PROMPT ALTER TABLE salario_bruto ADD CONSTRAINT pk_competencia PRIMARY KEY
ALTER TABLE salario_bruto
  ADD CONSTRAINT pk_competencia PRIMARY KEY (
    dt_competencia
  )
  USING INDEX
    STORAGE (
      NEXT       1024 K
    )
/

PROMPT CREATE OR REPLACE TRIGGER trg_salario
CREATE OR REPLACE TRIGGER trg_salario
before INSERT OR update
ON salario_bruto

DECLARE
CURSOR cData is
SELECT dt_competencia
FROM dba_usuario.salario_bruto;

vData salario_bruto.dt_competencia%TYPE;

BEGIN


OPEN cData;
FETCH cData INTO vData;
CLOSE cData;

INSERT INTO dba_usuario.salario_audit
  VALUES( vData, sysdate, sysdate);



  EXCEPTION
  WHEN OTHERS then
 raise_application_error(-20001, 'Erro1: '||sqlerrm );
   Dbms_Output.Put_Line('Erro1: '||sqlerrm);


  END trg_salario;
/


