CREATE TABLE salario_bruto 
  ( 
     vl_salario_base  NUMBER(14, 2) NULL, 
     dt_competencia   DATE NOT NULL, 
     hr_plantao       NUMBER(14, 2) NULL, 
     vl_plantao       NUMBER(14, 2) NULL, 
     qtd_hora_extra   NUMBER(14, 2) NULL, 
     vl_hora_extra    NUMBER(14, 2) NULL, 
     vl_salario_bruto NUMBER(14, 2) NULL 
  ) 
STORAGE ( NEXT 1024 k ) 

/ 
ALTER TABLE salario_bruto 
  ADD CONSTRAINT pk_competencia PRIMARY KEY ( dt_competencia ) USING INDEX 
  STORAGE ( NEXT 1024 k ) 

/ 