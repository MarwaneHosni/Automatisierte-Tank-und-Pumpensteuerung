(*
    sps/application/PLC_PRG.st
    Hauptprogramm der SPS-Steuerung.

    Wird zyklisch aufgerufen (SPS-Simulation am PC) und strukturiert die
    Abarbeitung:
      1. Zeitbasis
      2. Eingangsverarbeitung / Füllstandsauswertung
      3. Betriebsarten / Taster
      4. Sicherheits- und Verriegelungslogik
      5. Zustandsautomat (Automatik / Hand)
      6. Ausgangssteuerung (Pumpe, Ventile)
      7. Alarmmanagement
      8. Meldeleuchten
      9. HMI-Daten
     10. Betriebsstatistik
*)

PROGRAM PLC_PRG
VAR
    (* Bausteine *)
    fbTank       : FB_TankControl;
    fbMode       : FB_ModeManager;
    fbSafety     : FB_Safety;
    fbPump       : FB_Pump;
    fbFillValve  : FB_Valve;
    fbDrainValve : FB_Valve;
    fbStats      : FB_Stats;

    (* Alarme *)
    alEStop       : FB_Alarm;
    alPumpFault   : FB_Alarm;
    alOverload    : FB_Alarm;
    alHighLevel   : FB_Alarm;
    alCritical    : FB_Alarm;
    alSensor      : FB_Alarm;
    alValve       : FB_Alarm;
    alConflict    : FB_Alarm;

    (* interne Signale *)
    initDone        : BOOL;
    xSystemFault    : BOOL;
    xImmediateFault : BOOL;
    xValveFaultAggr : BOOL;
    xConflict       : BOOL;
    cmdFill         : BOOL;
    cmdPump         : BOOL;
    cmdDrain        : BOOL;
    xFillDonePulse  : BOOL;
    prevState       : E_State;
END_VAR

    (* ---------------- 1. Zeitbasis ---------------- *)
    gSimTimeMs := gSimTimeMs + SCAN_PERIOD_MS;

    (* ---------------- 2. Eingangsverarbeitung ---------------- *)
    fbTank(iwRaw          := iwLevelRaw,
           xLowLevel      := xLowLevel,
           xHighLevel     := xHighLevel,
           xVeryHighLevel := xVeryHighLevel);
    gLevelPct := fbTank.rLevelPct;

    (* ---------------- 3. Betriebsart / Taster ---------------- *)
    fbMode(xModeAuto := xModeAuto,
           xStartBtn := xStartBtn,
           xStopBtn  := xStopBtn,
           xResetBtn := xResetBtn);
    gMode := fbMode.eMode;

    (* ---------------- 4. Sicherheits- / Verriegelungslogik ---------------- *)
    xValveFaultAggr := fbFillValve.xFault OR fbDrainValve.xFault;
    xSystemFault := fbTank.xSensorError OR fbTank.xCriticalHigh
                    OR fbPump.xFault OR xValveFaultAggr OR xPumpOverload;

    (* aktuelle (nicht gespeicherte) Stoerungsursachen fuer das Verlassen
       des FAULT-Zustands: gespeicherte FB-Fehler werden durch Reset geloescht *)
    xImmediateFault := fbTank.xSensorError OR fbTank.xCriticalHigh OR xPumpOverload;

    fbSafety(xEStop             := xEStop,
             xPumpOverload      := xPumpOverload,
             xPumpFeedbackFault := fbPump.xFeedbackFault,
             xValveFault        := xValveFaultAggr,
             xSensorError       := fbTank.xSensorError,
             xCriticalHigh      := fbTank.xCriticalHigh,
             xCriticalLow       := fbTank.xCriticalLow);

    (* ---------------- 5. Zustandsautomat ---------------- *)
    cmdFill  := FALSE;
    cmdPump  := FALSE;
    cmdDrain := FALSE;
    xConflict := FALSE;

    (* Not-Aus hat hoechste Prioritaet *)
    IF xEStop THEN
        gState := E_State#EMERGENCY;
    END_IF

    CASE gState OF
        E_State#EMERGENCY:
            IF (NOT xEStop) AND fbMode.xResetPulse THEN
                gState := E_State#RESET;
            END_IF

        E_State#FAULT:
            IF (NOT xImmediateFault) AND fbMode.xResetPulse THEN
                gState := E_State#RESET;
            END_IF

        E_State#RESET:
            gState := E_State#IDLE;

        E_State#INIT:
            IF initDone THEN
                gState := E_State#IDLE;
            END_IF

        E_State#MANUAL:
            IF xSystemFault THEN
                gState := E_State#FAULT;
            ELSIF gMode = E_Mode#MODE_AUTO THEN
                gState := E_State#IDLE;
            ELSE
                cmdFill  := xManFill;
                cmdDrain := xManDrain;
                cmdPump  := xManPump;
                (* Konflikt: Zulauf gleichzeitig mit Ablauf/Pumpe -> alle AUS *)
                xConflict := (cmdFill AND cmdDrain) OR (cmdFill AND cmdPump);
                IF xConflict THEN
                    cmdFill  := FALSE;
                    cmdDrain := FALSE;
                    cmdPump  := FALSE;
                END_IF
            END_IF

    ELSE
        (* Automatikbetrieb *)
        IF xSystemFault THEN
            gState := E_State#FAULT;
        ELSIF gMode = E_Mode#MODE_MANUAL THEN
            gState := E_State#MANUAL;
        ELSE
            CASE gState OF
                E_State#IDLE:
                    IF fbMode.xRunRequest THEN
                        IF fbTank.xFillDemand THEN
                            gState := E_State#FILLING;
                        ELSE
                            gState := E_State#PROCESS_READY;
                        END_IF
                    END_IF

                E_State#FILLING:
                    IF NOT fbMode.xRunRequest THEN
                        gState := E_State#STOPPING;
                    ELSIF NOT fbTank.xFillDemand THEN
                        gState := E_State#PROCESS_READY;
                    ELSE
                        cmdFill := TRUE;
                    END_IF

                E_State#PROCESS_READY:
                    IF NOT fbMode.xRunRequest THEN
                        gState := E_State#IDLE;
                    ELSIF xDemand THEN
                        gState := E_State#PUMPING;
                    END_IF

                E_State#PUMPING:
                    IF NOT fbMode.xRunRequest THEN
                        gState := E_State#STOPPING;
                    ELSIF fbTank.xCriticalLow THEN
                        gState := E_State#STOPPING;
                    ELSIF (NOT xDemand) AND (NOT fbTank.xFillDemand) THEN
                        gState := E_State#IDLE;
                    ELSE
                        cmdPump := TRUE;
                    END_IF

                E_State#STOPPING:
                    gState := E_State#IDLE;
            ELSE
                gState := E_State#INIT;
            END_CASE
        END_IF
    END_CASE

    (* Flanke: Fuellzyklus abgeschlossen *)
    xFillDonePulse := (prevState = E_State#FILLING) AND (gState = E_State#PROCESS_READY);

    (* ---------------- 6. Ausgangssteuerung / Aktoren ---------------- *)
    fbFillValve(xCommand        := cmdFill,
                xEnable         := fbSafety.xFillEnable,
                xFeedbackOpen   := xValveFeedbackOpen,
                xFeedbackClosed := xValveFeedbackClosed,
                xReset          := fbMode.xResetPulse,
                tFeedbackMs     := VALVE_FEEDBACK_TIMEOUT_MS);

    fbDrainValve(xCommand        := cmdDrain,
                 xEnable         := fbSafety.xDrainEnable,
                 xFeedbackOpen   := xDrainFeedbackOpen,
                 xFeedbackClosed := xDrainFeedbackClosed,
                 xReset          := fbMode.xResetPulse,
                 tFeedbackMs     := VALVE_FEEDBACK_TIMEOUT_MS);

    fbPump(xCommand    := cmdPump,
           xEnable     := fbSafety.xPumpEnable,
           xFeedback   := xPumpFeedback,
           xOverload   := xPumpOverload,
           xReset      := fbMode.xResetPulse,
           tFeedbackMs := PUMP_FEEDBACK_TIMEOUT_MS);

    yFillValve  := fbFillValve.xOpen;
    yDrainValve := fbDrainValve.xOpen;
    yPump       := fbPump.xRun;

    (* harte Absicherung: Not-Aus schaltet alle Aktoren ab *)
    IF xEStop THEN
        yFillValve  := FALSE;
        yDrainValve := FALSE;
        yPump       := FALSE;
    END_IF

    (* ---------------- 7. Alarmmanagement ---------------- *)
    alEStop(xTrigger := xEStop, xReset := fbMode.xResetPulse,
            id := E_AlarmId#A_ESTOP, severity := E_Severity#SEV_CRITICAL,
            xDelay := FALSE, tDelayMs := 0);

    alPumpFault(xTrigger := fbPump.xFeedbackFault, xReset := fbMode.xResetPulse,
                id := E_AlarmId#A_PUMP_FAULT, severity := E_Severity#SEV_CRITICAL,
                xDelay := FALSE, tDelayMs := 0);

    alOverload(xTrigger := xPumpOverload, xReset := fbMode.xResetPulse,
               id := E_AlarmId#A_OVERLOAD, severity := E_Severity#SEV_CRITICAL,
               xDelay := FALSE, tDelayMs := 0);

    alHighLevel(xTrigger := fbTank.xHighAlarm, xReset := fbMode.xResetPulse,
                id := E_AlarmId#A_HIGH_LEVEL, severity := E_Severity#SEV_WARNING,
                xDelay := TRUE, tDelayMs := ALARM_DELAY_MS);

    alCritical(xTrigger := fbTank.xCriticalHigh, xReset := fbMode.xResetPulse,
               id := E_AlarmId#A_CRITICAL_LEVEL, severity := E_Severity#SEV_CRITICAL,
               xDelay := FALSE, tDelayMs := 0);

    alSensor(xTrigger := fbTank.xSensorError, xReset := fbMode.xResetPulse,
             id := E_AlarmId#A_SENSOR_ERROR, severity := E_Severity#SEV_CRITICAL,
             xDelay := FALSE, tDelayMs := 0);

    alValve(xTrigger := xValveFaultAggr, xReset := fbMode.xResetPulse,
            id := E_AlarmId#A_VALVE_FEEDBACK, severity := E_Severity#SEV_CRITICAL,
            xDelay := FALSE, tDelayMs := 0);

    alConflict(xTrigger := xConflict, xReset := fbMode.xResetPulse,
               id := E_AlarmId#A_CONFLICT, severity := E_Severity#SEV_WARNING,
               xDelay := TRUE, tDelayMs := ALARM_DELAY_MS);

    (* Meldeleuchten/Alarme ueber SPEICHERZUSTAND (latched): bleiben bis zur
       Quittierung/Reset aktiv, auch wenn die Bedingung bereits weg ist *)
    gAnyCritical := alEStop.xLatched OR alPumpFault.xLatched OR alOverload.xLatched
                    OR alCritical.xLatched OR alSensor.xLatched OR alValve.xLatched;
    gAnyWarning  := alHighLevel.xLatched OR alConflict.xLatched;
    gAlarmActive := gAnyCritical OR gAnyWarning;

    (* hoechste anstehende Alarmkennung fuer das HMI *)
    IF alEStop.xLatched THEN
        gAlarmId := E_AlarmId#A_ESTOP;          gAlarmSeverity := E_Severity#SEV_CRITICAL;
    ELSIF alOverload.xLatched THEN
        gAlarmId := E_AlarmId#A_OVERLOAD;       gAlarmSeverity := E_Severity#SEV_CRITICAL;
    ELSIF alCritical.xLatched THEN
        gAlarmId := E_AlarmId#A_CRITICAL_LEVEL; gAlarmSeverity := E_Severity#SEV_CRITICAL;
    ELSIF alPumpFault.xLatched THEN
        gAlarmId := E_AlarmId#A_PUMP_FAULT;     gAlarmSeverity := E_Severity#SEV_CRITICAL;
    ELSIF alSensor.xLatched THEN
        gAlarmId := E_AlarmId#A_SENSOR_ERROR;   gAlarmSeverity := E_Severity#SEV_CRITICAL;
    ELSIF alValve.xLatched THEN
        gAlarmId := E_AlarmId#A_VALVE_FEEDBACK; gAlarmSeverity := E_Severity#SEV_CRITICAL;
    ELSIF alHighLevel.xLatched THEN
        gAlarmId := E_AlarmId#A_HIGH_LEVEL;     gAlarmSeverity := E_Severity#SEV_WARNING;
    ELSIF alConflict.xLatched THEN
        gAlarmId := E_AlarmId#A_CONFLICT;       gAlarmSeverity := E_Severity#SEV_WARNING;
    ELSE
        gAlarmId := E_AlarmId#A_NONE;           gAlarmSeverity := E_Severity#SEV_INFO;
    END_IF

    (* ---------------- 8. Meldeleuchten / Hupe ---------------- *)
    yLampRed    := gAnyCritical;
    yLampYellow := gAnyWarning;
    yBuzzer     := gAnyCritical;
    yLampGreen  := (NOT gAlarmActive) AND
                   ((gState = E_State#IDLE) OR (gState = E_State#PROCESS_READY) OR
                    (gState = E_State#FILLING) OR (gState = E_State#PUMPING) OR
                    (gState = E_State#MANUAL));

    (* ---------------- 9. HMI-Daten ---------------- *)
    (* gState, gMode, gLevelPct, gAlarm* bereits gesetzt *)
    gFillDemand   := fbTank.xFillDemand;
    gHighAlarm    := fbTank.xHighAlarm;
    gCriticalHigh := fbTank.xCriticalHigh;
    gCriticalLow  := fbTank.xCriticalLow;
    gSensorError  := fbTank.xSensorError;
    gPumpEnable   := fbSafety.xPumpEnable;
    gFillEnable   := fbSafety.xFillEnable;
    gDrainEnable  := fbSafety.xDrainEnable;
    gPumpFault    := fbPump.xFault;
    gValveFault   := xValveFaultAggr;

    (* ---------------- 10. Betriebsstatistik ---------------- *)
    fbStats(xProcessRunning := (gState = E_State#FILLING) OR (gState = E_State#PUMPING),
            xPumpRunning    := yPump,
            xFillDone       := xFillDonePulse);
    gCycleCount    := fbStats.diCycles;
    gRunTimeMs     := fbStats.diRunTimeMs;
    gPumpRunTimeMs := fbStats.diPumpRunTimeMs;
    gFillCycles    := fbStats.diFillCycles;

    (* ---------------- Abschluss ---------------- *)
    prevState := gState;
    initDone  := TRUE;
END_PROGRAM
