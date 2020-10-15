PROMPT CREATE OR REPLACE PACKAGE pkg_salario
CREATE OR REPLACE PACKAGE pkg_salario
IS
  PROCEDURE prc_insere_salario_bruto (
    psalario        IN salario_bruto.vl_salario_bruto%TYPE,
    pcompetencia    DATE,
    phr_plantao     IN salario_bruto.hr_plantao%TYPE,
    pqtd_hora_extra IN salario_bruto.qtd_hora_extra%TYPE,
    psn_quiquenio   IN CHAR DEFAULT 'N');
  PROCEDURE prc_calcula_desconto(
    pdata DATE );
END;
/

PROMPT CREATE OR REPLACE PACKAGE BODY pkg_salario
CREATE OR REPLACE PACKAGE BODY pkg_salario
IS
  PROCEDURE Prc_insere_salario_bruto (psalario        IN
  salario_bruto.vl_salario_bruto%TYPE,
                                      pcompetencia    DATE,
                                      phr_plantao     IN
  salario_bruto.hr_plantao%TYPE,
                                      pqtd_hora_extra IN
  salario_bruto.qtd_hora_extra%TYPE,
  psn_quiquenio   IN CHAR DEFAULT 'N' )
  IS
    /*
    *VARI?VEIS
    */

    vquinquenio  NUMBER := 0.00;
    vrepousoremunerado NUMBER := 188.00 ;
    vcalc_vl_plantao    NUMBER := psalario / 600 * phr_plantao;

    vcalc_vl_hora_extra NUMBER := ( ( psalario / 200 ) * 1.5 * pqtd_hora_extra )
  ;
    vsalario_bruto      NUMBER := psalario + vcalc_vl_plantao + vquinquenio + vrepousoremunerado
                                                                       + vcalc_vl_hora_extra;
    ncompetencia        NUMBER;

  /*
  *FIM VARI?VEIS
  */
  BEGIN
      SELECT Count(dt_competencia)
      INTO   ncompetencia
      FROM   dba_usuario.salario_bruto
      WHERE  dt_competencia = pcompetencia;

      IF ncompetencia >= 1 THEN
        DELETE FROM dba_usuario.salario_liquido
        WHERE  dt_competencia = pcompetencia;

        DELETE FROM dba_usuario.salario_bruto
        WHERE  dt_competencia = pcompetencia;

        COMMIT;

        IF  psn_quiquenio = 'S' THEN
         vquinquenio := 53.00;
         END IF;


        INSERT INTO dba_usuario.salario_bruto
                    (vl_salario_base,
                     dt_competencia,
                     hr_plantao,
                     vl_plantao,
                     qtd_hora_extra,
                     vl_hora_extra,
                     vl_salario_bruto,
                     vl_quiquenio,
                     vl_descanso_remunerado
                     )
        VALUES      ( psalario,
                     pcompetencia,
                     phr_plantao,
                     vcalc_vl_plantao,
                     pqtd_hora_extra,
                     vcalc_vl_hora_extra,
                     vsalario_bruto,
                     vquinquenio,
                     vrepousoremunerado );

        COMMIT;
      ELSE
        INSERT INTO dba_usuario.salario_bruto
                    (vl_salario_base,
                     dt_competencia,
                     hr_plantao,
                     vl_plantao,
                     qtd_hora_extra,
                     vl_hora_extra,
                     vl_salario_bruto)
        VALUES      ( psalario,
                     pcompetencia,
                     phr_plantao,
                     vcalc_vl_plantao,
                     pqtd_hora_extra,
                     vcalc_vl_hora_extra,
                     vsalario_bruto );

        COMMIT;
      END IF;

      BEGIN
          dba_usuario.pkg_salario.Prc_calcula_desconto(pcompetencia);
      END;
  EXCEPTION
    WHEN OTHERS THEN
               Raise_application_error(-20001, 'Erro2: '
                                               ||SQLERRM);

               dbms_output.Put_line('Erro2:  '
                                    ||SQLERRM);
  /*
  *FIM PROGRAMA
  */
  END;
  PROCEDURE Prc_calcula_desconto(pdata DATE)
  IS
    /*
    *VARI?VEIS
    */
    vperc_inss    NUMBER := 0;
    vvl_inss      NUMBER := 0;
    vretorno      NUMBER := 0;
    vsal_liq_inss NUMBER := 0;
    vperc_irff    NUMBER := 0;
    vvl_irff      NUMBER := 0;
    v_sal_liq     NUMBER := 0;
    vvl_liq_irff  NUMBER := 0;
    /*
    * FIM VARI?VEIS
    */
    /*
    *CURSORES
    */
    CURSOR csal_bruto IS
      SELECT vl_salario_bruto
      FROM   dba_usuario.salario_bruto
      WHERE  dt_competencia = pdata;
    CURSOR csal_liq IS
      SELECT Count(*)
      FROM   dba_usuario.salario_liquido
      WHERE  dt_competencia = pdata;
  /*
  *FIM CURSORES
  */
  /*
  *CALCULO DO INSS
  */
  BEGIN
      OPEN csal_bruto;

      FETCH csal_bruto INTO vretorno;

      CLOSE csal_bruto;

      FOR s IN csal_bruto LOOP
          IF Nvl(vretorno, 0) = 1751.81 THEN
            vperc_inss := 8 / 100;

            vvl_inss := vretorno * vperc_inss;
          ELSIF Nvl(vretorno, 0) >= 1751.82
                 OR vretorno <= 2919.72 THEN
            vperc_inss := 9 / 100;

            vvl_inss := vretorno * vperc_inss;
          ELSIF Nvl(vretorno, 0) >= 2919.73
                 OR vretorno <= 5839.45 THEN
            vperc_inss := 11 / 100;

            vvl_inss := vretorno * vperc_inss;
          END IF;

          vsal_liq_inss := vretorno - vvl_inss;
      END LOOP;

      vsal_liq_inss := vretorno - vvl_inss;

      /*
      * FIM DO CALCULO DO INSS
      */
      /*
      * CALCULO DO IRFF
      */
      IF vsal_liq_inss >= 1903.99
          OR vsal_liq_inss <= 2826.65 THEN
        vperc_irff := 7.50 / 100;

        vvl_irff := vsal_liq_inss * vperc_irff;
      ELSIF vsal_liq_inss >= 2826.66
             OR vsal_liq_inss <= 3751.05 THEN
        vperc_irff := 15 / 100;

        vvl_irff := vsal_liq_inss * vperc_irff;
      ELSIF vsal_liq_inss >= 3751.06
             OR vsal_liq_inss <= 4664.68 THEN
        vperc_irff := 22.50 / 100;

        vvl_irff := vsal_liq_inss * vperc_irff;
      ELSIF vsal_liq_inss >= 4664.69 THEN
        vperc_irff := 27.5 / 100;

        vvl_irff := vsal_liq_inss * vperc_irff;
      END IF;

      vvl_liq_irff := vsal_liq_inss - vvl_irff;

      /*
      *FIM CALCULO IRFF
      */
      /*
      *INSERE NA TABELA SALARIO_LIQUIDO/DELETE NA TABELE SALARIO_LIQUIDO
      */
      BEGIN
          OPEN csal_liq;

          FETCH csal_liq INTO v_sal_liq;

          CLOSE csal_liq;

          FOR n IN csal_liq LOOP
              IF v_sal_liq = 0 THEN
                INSERT INTO dba_usuario.salario_liquido
                VALUES      (pdata,
                             vperc_inss,
                             vvl_inss,
                             vperc_irff,
                             vvl_irff,
                             vvl_liq_irff,
                             vretorno );

                COMMIT;
              ELSE
                DELETE FROM dba_usuario.salario_liquido
                WHERE  dt_competencia = pdata;

                /* DELETE
                 FROM dba_usuario.salario_bruto
                 WHERE dt_competencia = pData;  */
                COMMIT;

                INSERT INTO dba_usuario.salario_liquido
                VALUES      (pdata,
                             vperc_inss,
                             vvl_inss,
                             vperc_irff,
                             vvl_irff,
                             vvl_liq_irff,
                             vretorno );

                COMMIT;
              END IF;
          END LOOP;
      END;
  END;
END;
/

