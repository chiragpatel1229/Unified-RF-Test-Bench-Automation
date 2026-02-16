# 📡 Automated RF Radiation Pattern Measurement System

A unified, MATLAB-based Automated Test Equipment (ATE) solution for high-fidelity antenna characterization, reducing manual calibration time and ensuring high-resolution directional analysis.

## 📖 Executive Summary

This project replaces legacy manual testing workflows with a turnkey "One-Button" automation system. It integrates motion control (stepper motors) with high-frequency RF instrumentation (Signal Analyzers/Generators) into a single synchronous loop.

The system was architected to validate Monopole, Dipole, and Yagi-Uda antenna arrays, providing real-time polar plotting and automatic data logging. It bridges the gap between FEKO simulations and physical RF measurements.

## ⚙️ System Architecture & Tech Stack

The solution is built on a modular architecture separating the GUI Layer, Business Logic, and Hardware Abstraction Layer (HAL).

- Core Language: MATLAB (Object-Oriented Programming)
- GUI Framework: MATLAB App Designer
- Instrument Communication:
  - Keysight Stack: TCP/IP (Ethernet) via VISA protocol / SCPI commands
- Motion Control: USB Serial communication via custom wrapper
- Data Serialization: Automated export to .xlsx for post-processing

## 🛠️ Hardware Ecosystem

The software orchestrates a complex hardware-in-the-loop (HiL) setup:

```
|-------------------|------------------------|----------------------------------------------|-------------------|
| Device            | Model                  | Role                                         | Communication     |
|-------------------|------------------------|----------------------------------------------|-------------------|
| Signal Analyzer   | Keysight EXA N9010A    | Peak Power & Freq. Search (9 kHz - 7 GHz)    | Ethernet (LXI)    |
| Signal Generator  | Keysight MXG N5182A    | Ref. Signal Injection (100 kHz - 6 GHz)      | Ethernet (LXI)    |
| Network Analyzer  | Keysight PNA N5222A    | S-Parameter & Impedance Matching             | Ethernet (LXI)    |
| Stepper Motor     | Arcus DMX-J-SA-17      | Precision DUT Rotation                       | USB / ASCII       |
```

## 🚀 Key Engineering Challenges & Solutions

### 1. Custom Driver Wrapper (MyArcus Class)

The Arcus motor firmware required proprietary ASCII text commands via a legacy executable (GUI_CMD.exe).

Problem: MATLAB could not natively "speak" to the motor firmware.

Solution: Developed a custom MATLAB class MyArcus that acts as a wrapper. It translates high-level method calls (e.g., Motor.PositionTo(90)) into the specific ASCII strings required by the firmware, enabling seamless object-oriented control.

### 2. Latency Compensation Algorithm

To ensure data integrity, the system must wait for mechanical vibration to settle and for the VISA bus to handshake before taking a measurement.

Analysis: I developed a stress-test script to measure the "Ping-to-Power-Read" time, isolating a 30ms (0.03s) hardware communication lag.

The Formula: I derived the exact Settlement Time required per step to avoid measuring noise:

```
matlab

% Derived Formula for System Latency
Total_Time = ((MicroSteps / Pulse_Rate) * Gear_Ratio) + Comm_Latency + Struct_Settling;

% Result: 0.113 seconds delay strictly enforced per measurement step.
```
### 3. High-Precision Mechanical Resolution

Standard stepper motor resolution (1.8°) was insufficient for high-fidelity RF profiling.

Optimization: Engineered a 5:1 gear ratio system (16-tooth motor gear / 80-tooth mount gear).

Impact: Improved angular resolution from 1.8° to 0.36°, allowing for sub-degree directional accuracy.

### 4. "Poka-Yoke" Error Handling

Implemented robust input validation to prevent hardware crashes or invalid datasets:

- Geometry Check: Validates if Step_Size is a factor of 360. If not (e.g., 7°), the algorithm calculates and suggests the nearest valid resolution.
- Safety Interlock: Checks RF_Output state before initiating motion to prevent "ghost" scans.

## 📊 Results & Validation

The system was rigorously validated against FEKO Simulation Software using complex antenna arrays to ensure high-fidelity directional analysis.

### 1. Complex Array Validation (Monopole Antenna Array)

- Test Subject: Dual Monopole Antenna Array at 4.8 GHz.

- Simulation vs. Physical Data:
  - FEKO Prediction: Reflection Coefficient of -24.02 dB with a VSWR of 1.13.
  - Physical Testbed: Validated the 65.82° phase shift required for coherent beamforming.

- Outcome: The system successfully characterized the beamforming capabilities, matching the simulated gain drops at specific angular nulls (0° and 180°).

### 2. Directional Beam Validation (5-Element Yagi-Uda)

- Test Subject: 5-Element Yagi-Uda Antenna at 2.418 GHz.

- Impedance Matching:
  - Smith Chart Analysis: Measured varying impedance of 51.16 $\Omega$ (Physical) vs. 50.71 $\Omega$ (Simulated).
  - Return Loss: Achieved a physical Return Loss (S11) of -10.91 dB, confirming efficient power transfer.

- Gain Ratio Analysis: The automated system calculated a Min/Max Gain Ratio of -39 dB, closely mirroring the FEKO simulation ratio of -36 dB, proving the system's dynamic range accuracy.


## 📂 Usage

- Connect: Ensure all instruments (MXG, EXA, Arcus) are connected via Ethernet/USB.
- Launch: Run the Antenna_App.mlapp in MATLAB.
- Configure: Set Start Freq, Stop Freq, and Step Size (e.g., 5°).
- Run: Click "Start Auto Measurement". The system will:
  - Validate inputs.
  - Auto-home the motor.
  - Execute the scan loop (Move to Stabilize 0.113s to Measure).
  - Generate a Polar Plot in real-time.
  - Export data to Excel.

## 👨‍💻 Author

Chirag Patel  
Specialist in Test Automation & Hardware-in-the-Loop (HiL) Systems


![GUI](GUI.png)
