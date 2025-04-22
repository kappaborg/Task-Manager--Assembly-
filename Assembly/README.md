# 🧠 RISC-V Assembly Task Manager

**RISC-V Assembly Task Manager** is a task and process management application written entirely in **RISC-V Assembly**, designed to run on the [RARS (RISC-V Assembler and Runtime Simulator)](https://github.com/TheThirdOne/rars) environment. This project showcases low-level systems programming techniques by simulating core functionalities of a basic task manager.

---

## 📸 Preview

> _**Menu Interface:**_

![RISC-V Task Manager Menu](https://via.placeholder.com/600x200?text=RISC-V+Task+Manager+Menu)

---

## 🚀 Features

- 🧾 **List all processes**  
- 🔍 **Filter processes by name**  
- 🔎 **Search processes by PID**  
- ❌ **Terminate a process**  
- ⏰ **Task scheduling system**, including:
  - One-time tasks
  - Interval-based tasks
  - Daily recurring tasks

---

## 📁 File Structure

.
├── main.s             # Main program with user interface and menu logic
├── process_manager.s  # Handles simulated process list and operations
├── scheduler.s        # Task scheduling logic and data handling


---

## 🛠️ Installation & Running

1. Download and open **RARS**:  
   👉 [RARS GitHub Repository](https://github.com/TheThirdOne/rars)

2. Load all `.s` files (`main.s`, `process_manager.s`, `scheduler.s`) into RARS.

3. Click the **"Assemble & Run"** button to start the program.

---

## 📟 Application Menu

==== RISC-V Task Manager ====
1. List all processes
2. Filter processes by name
3. Find process by PID
4. Terminate a process
5. Task scheduler
0. Exit

---

## ⏳ Task Scheduler

The built-in task scheduler allows for management of simulated automated tasks.

### 📋 Task Options:
- Add a new task
- List scheduled tasks
- Delete existing tasks

### 📦 Each task includes:
- Command (64 bytes max)
- Type: One-time / Interval / Daily
- Execution time
- Interval (in seconds)
- Status (Active / Inactive)

> _Example Interface:_  
![Task Scheduler](https://via.placeholder.com/600x200?text=Task+Scheduler+Simulation)

---

## 🧱 Architecture

This application follows a **modular design**:

| Module | Description |
|--------|-------------|
| `main.s` | Handles the UI and main loop |
| `process_manager.s` | Manages the process simulation and operations |
| `scheduler.s` | Controls the task scheduling logic |

---

## ⚙️ Technical Notes

- Developed entirely in **RISC-V Assembly**
- Uses **standard RISC-V ABI** for function calls
- Data structures implemented with **fixed-size buffers**
- **Simulated processes** (not real OS processes due to RARS limitations)

---

## ⚠️ Limitations

- This is a **simulation**; it does not interact with actual OS-level processes.
- Due to **RARS constraints**, system calls are mocked or simplified.

---

## 🙋‍♂️ Author

**kappasutra** – _Project Developer_  

---

## 📜 License

This project is licensed under the **MIT License**.  
Feel free to fork, modify, and contribute!

