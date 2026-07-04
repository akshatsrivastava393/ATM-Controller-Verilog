# ATM Controller Using Verilog HDL

## Overview

This project implements a Dual-FSM (Finite State Machine) based ATM Controller in Verilog HDL.

The design is divided into two independent finite state machines:

- FSM1 – User Authentication and Session Management
- FSM2 – Transaction Management

Both FSMs communicate using a handshake protocol (`tx_start` and `tx_done`) to ensure synchronized operation.

---

## Features

- Card Insertion Detection
- 4-Digit PIN Authentication
- PIN Retry Counter
- Card Blocking after Multiple Incorrect Attempts
- Balance Inquiry
- Cash Withdrawal
- Cash Deposit
- Insufficient Balance Detection
- Handshake Communication Between Two FSMs
- Modular Verilog Design
- Simulation using Vivado

---

## Project Structure

```
ATM-Controller-Verilog/
│
├── atm_fsm.v
├── tx_fsm.v
├── atm_top.v
├── tb_tx.v
└── README.md
```

---

## FSM1 States

- IDLE
- CARD_INSERTED
- WAIT_PIN
- VERIFY_PIN
- PIN_ERROR
- CARD_BLOCKED
- AUTHENTICATED
- PROCESSING
- DONE

---

## FSM2 States

- TX_IDLE
- SELECT_TX
- ENTER_AMOUNT
- CHECK_BALANCE
- DISPENSE
- DEPOSIT
- SHOW_BAL
- INSUFFICIENT_FUNDS
- TX_COMPLETE

---

## Handshake Protocol

```
FSM1 ---- tx_start ----> FSM2

FSM2 ---- tx_done -----> FSM1
```

---

## Simulation

The design was simulated in Xilinx Vivado.

The simulation verifies:

- Correct PIN Authentication
- Wrong PIN Detection
- Card Blocking
- Balance Inquiry
- Cash Withdrawal
- Cash Deposit
- Insufficient Funds Handling
- FSM Handshake Communication

---

## Tools Used

- Verilog HDL
- Xilinx Vivado
- Git
- GitHub

---

## Author

Akshat Srivastava
National Institute of Technology Karnataka (NITK)
