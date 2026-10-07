(*
    sps/application/Types.st
    Zentrale Datentypen: Zustaende, Betriebsarten, Alarm-IDs, Strukturen.
*)

(* Zustandsautomat (State Machine) *)
TYPE E_State :
(
    INIT,           (* Initialisierung *)
    IDLE,           (* Bereit / wartet auf Start *)
    FILLING,        (* Fuellen des Tanks *)
    PROCESS_READY,  (* Prozessbereit *)
    PUMPING,        (* Abpumpen *)
    STOPPING,       (* Stoppphase *)
    MANUAL,         (* Handbetrieb *)
    FAULT,          (* Stoerung *)
    EMERGENCY,      (* Not-Aus *)
    RESET           (* Ruecksetzen / Wiederanlauf *)
);
END_TYPE

(* Betriebsart *)
TYPE E_Mode :
(
    MODE_AUTO,
    MODE_MANUAL
);
END_TYPE

(* Alarmprioritaet *)
TYPE E_Severity :
(
    SEV_INFO,
    SEV_WARNING,
    SEV_CRITICAL
);
END_TYPE

(* Alarmkennungen *)
TYPE E_AlarmId :
(
    A_NONE,
    A_ESTOP,
    A_PUMP_FAULT,
    A_OVERLOAD,
    A_HIGH_LEVEL,
    A_CRITICAL_LEVEL,
    A_SENSOR_ERROR,
    A_VALVE_FEEDBACK,
    A_CONFLICT,
    A_GENERAL_FAULT
);
END_TYPE

(* Darstellung eines Alarms (fuer HMI / Auswertung) *)
TYPE ST_Alarm :
STRUCT
    id : E_AlarmId;
    severity : E_Severity;
    xActive : BOOL;      (* Bedingung aktuell anliegend *)
    xLatched : BOOL;     (* gespeichert bis Reset *)
    xAck : BOOL;         (* quittiert *)
END_STRUCT
END_TYPE
