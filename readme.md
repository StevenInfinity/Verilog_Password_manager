# 🔐 Hardware-based secure password storage using verilog

## 🎯 Aim

To design and implement a simple **hardware-based secure password storage and validation system** using Verilog HDL. The system demonstrates **encryption, decryption, secure storage**, and **access control** through a master password mechanism.

---

## 🛠️ Tools Used

- **Simulation**: ModelSim  
- **Synthesis & Implementation**: Xilinx Vivado

---

## 🧠 FPGA Family Used

- **Board**: Basys 3  
- **FPGA Family**: Xilinx Artix-7

---

## 📚 Theory

### 🔎 Introduction

This project implements a **basic secure password manager** using Verilog HDL. It provides:

- Symmetric encryption and decryption using XOR and bit rotation
- Storage of **10 encrypted passwords**
- Access control through a **master password mechanism**

The system is hardware-friendly, modular, and simple, suitable for basic security demonstration and learning.

---

## 📦 Block Diagram

> *(Insert your Block Diagram here as an image or ASCII-art if needed)*

---

## ⚙️ Working Principle

### 🔐 Encryption Process
- The **plaintext password** is XOR’ed with an 8-bit **master key**.
- The result is then **rotated left by 1 bit**.
- This output is **stored** as the encrypted password.

### 🧠 Storage
- A memory module **stores up to 10 encrypted passwords**.
- Passwords are written **synchronously** using a clock signal and a write-enable control.

### 🔓 Validation
- The **master password** entered by the user is **compared** with a predefined constant.
- If the master password is **correct**, access to stored passwords is granted.

### 🔁 Decryption Process
- Stored encrypted data is **rotated right by 1 bit**.
- The result is then **XOR’ed** with the master key to retrieve the **original password**.

### 🧪 Testbench
- A simulation testbench is used to:
  - Verify encryption & decryption
  - Validate correct/incorrect master password scenarios
  - Ensure proper storage and retrieval logic

---

## ✅ Advantages

- Simple and efficient logic for **hardware implementation**
- **Symmetric encryption** – easy to implement and reverse
- Modular design allows **easy extension or modification**

---

## ⚠️ Disadvantages

- XOR-based encryption is **not secure** against sophisticated attacks
- Limited to storing **10 passwords** due to fixed memory

---

## 📂 File Structure (Suggested)

```bash
secure-password-verilog/
├── src/
│   ├── encryption.v
│   ├── decryption.v
│   ├── storage.v
│   ├── master_password_check.v
│   └── top_module.v
├── tb/
│   └── top_module_tb.v
├── README.md
└── reports/
    └── synthesis_summary.txt
