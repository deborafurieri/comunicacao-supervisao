TYPE
  LOGLEVEL : (CRITICAL, WARNING, INFO, DEBUG) := INFO;
END_TYPE

FUNCTION_BLOCK LOGGER
  VAR_INPUT
    TRIG : BOOL;
    MSG : STRING;
    LEVEL : LOGLEVEL := INFO;
  END_VAR
  VAR
    TRIG0 : BOOL;
  END_VAR

  IF TRIG AND NOT TRIG0 THEN
  {{
   LogMessage(GetFbVar(LEVEL),(char*)GetFbVar(MSG, .body),GetFbVar(MSG, .len));
  }}
  END_IF;
  TRIG0:=TRIG;
END_FUNCTION_BLOCK



FUNCTION_BLOCK python_eval
  VAR_INPUT
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    STATE : DWORD;
    BUFFER : STRING;
    PREBUFFER : STRING;
    TRIGM1 : BOOL;
    TRIGGED : BOOL;
  END_VAR

  {extern void __PythonEvalFB(int, PYTHON_EVAL*);__PythonEvalFB(0, data__);}
END_FUNCTION_BLOCK

FUNCTION_BLOCK python_poll
  VAR_INPUT
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    STATE : DWORD;
    BUFFER : STRING;
    PREBUFFER : STRING;
    TRIGM1 : BOOL;
    TRIGGED : BOOL;
  END_VAR

  {extern void __PythonEvalFB(int, PYTHON_EVAL*);__PythonEvalFB(1,(PYTHON_EVAL*)(void*)data__);}
END_FUNCTION_BLOCK

FUNCTION_BLOCK python_gear
  VAR_INPUT
    N : UINT;
    TRIG : BOOL;
    CODE : STRING;
  END_VAR
  VAR_OUTPUT
    ACK : BOOL;
    RESULT : STRING;
  END_VAR
  VAR
    py_eval : python_eval;
    COUNTER : UINT;
    ADD10_OUT : UINT;
    EQ13_OUT : BOOL;
    SEL15_OUT : UINT;
    AND7_OUT : BOOL;
  END_VAR

  ADD10_OUT := ADD(COUNTER, 1);
  EQ13_OUT := EQ(N, ADD10_OUT);
  SEL15_OUT := SEL(EQ13_OUT, ADD10_OUT, 0);
  COUNTER := SEL15_OUT;
  AND7_OUT := AND(EQ13_OUT, TRIG);
  py_eval(TRIG := AND7_OUT, CODE := CODE);
  ACK := py_eval.ACK;
  RESULT := py_eval.RESULT;
END_FUNCTION_BLOCK


PROGRAM controle
  VAR
    button : BOOL;
    button_scada : BOOL;
    lamp : BOOL;
    lamp_scada : BOOL;
    IN : UINT;
    IN_SCADA : UINT;
    OUT : INT;
    OUT_SCADA : INT;
    SP_SCADA : UINT;
  END_VAR
  VAR
    PID0 : PID;
  END_VAR
  VAR
    KP_SCADA : UINT;
    TI_SCADA : UINT;
    TD_SCADA : UINT;
  END_VAR
  VAR
    UINT_TO_REAL31_OUT : REAL;
    UINT_TO_REAL5_OUT : REAL;
    UINT_TO_REAL6_OUT : REAL;
    UINT_TO_REAL7_OUT : REAL;
    UINT_TO_REAL8_OUT : REAL;
    REAL_TO_INT3_OUT : INT;
    EQ33_OUT : BOOL;
    OR37_OUT : BOOL;
  END_VAR

  IN_SCADA := IN;
  UINT_TO_REAL31_OUT := UINT_TO_REAL(IN);
  UINT_TO_REAL5_OUT := UINT_TO_REAL(SP_SCADA);
  UINT_TO_REAL6_OUT := UINT_TO_REAL(KP_SCADA);
  UINT_TO_REAL7_OUT := UINT_TO_REAL(TI_SCADA);
  UINT_TO_REAL8_OUT := UINT_TO_REAL(TD_SCADA);
  PID0(AUTO := button_scada, PV := UINT_TO_REAL31_OUT, SP := UINT_TO_REAL5_OUT, X0 := 0.0, KP := UINT_TO_REAL6_OUT, TR := UINT_TO_REAL7_OUT, TD := UINT_TO_REAL8_OUT, CYCLE := t#100ms);
  REAL_TO_INT3_OUT := REAL_TO_INT(PID0.XOUT);
  OUT := REAL_TO_INT3_OUT;
  OUT_SCADA := OUT;
  EQ33_OUT := EQ(IN, SP_SCADA);
  lamp := EQ33_OUT;
  lamp_scada := lamp;
  OR37_OUT := OR(button, button_scada);
  button_scada := OR37_OUT;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : controle;
  END_RESOURCE
END_CONFIGURATION
