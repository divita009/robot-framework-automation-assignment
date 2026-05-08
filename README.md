# 🤖 Robot Framework Automation Assignment

## 📌 Objective

Automate a Google search using **Robot Framework** and **SeleniumLibrary**.
The automation script searches for **"robotframework"**, extracts the top 4–5 search results, prints them to the console, and saves them to a text file.

---

## 🚀 Features

* Opens Google in browser
* Searches for **"robotframework"**
* Extracts top search result links
* Prints results to console
* Saves results to `results/output.txt`
* Captures screenshots during execution
* Generates Robot Framework execution reports

---

## 🛠️ Tech Stack

* Python
* Robot Framework
* SeleniumLibrary

---

# ⚙️ Environment Setup

## 1️⃣ Create Virtual Environment (One-Time Setup)

```bash
python -m venv venv
```

---

## 2️⃣ Activate Virtual Environment

> ⚠️ Important: Activate the virtual environment every time you open a new terminal.

### Windows

```bash
venv\Scripts\activate
```

---

## 3️⃣ Install Required Dependencies

### Install Robot Framework

```bash
pip install robotframework
```

### Install SeleniumLibrary

```bash
pip install robotframework-seleniumlibrary
```

### (Optional) Install all dependencies from requirements.txt

```bash
pip install -r requirements.txt
```

---

# ▶️ Execute the Test

Run the following command after activating the virtual environment:

```bash
python -m robot -d results tests/google_search.robot
```

---

# 📸 Output

### Console

* Displays top search result links

### Generated Files

* `results/output.txt`
* `results/log.html`
* `results/report.html`
* `results/output.xml`

### Screenshots

* Stored inside `results/` or `Snapshot/` folder

---

# ⚠️ Note

Google may occasionally trigger CAPTCHA verification during automation.
Manual verification may be required in such cases.

---

# 📂 Project Structure

```text
robot-framework-automation-assignment/
│
├── venv/                      # Virtual environment (ignored by Git)
│
├── results/                   # Execution result files
│   ├── output.txt
│   ├── log.html
│   ├── report.html
│   └── output.xml
│
├── Snapshot/                  # Console screenshot captured(manually)
│
├── tests/
│   └── google_search.robot    # Main Robot Framework test script
│
├── requirements.txt           # Project dependencies
├── .gitignore                 # Ignored files/folders for Git
└── README.md                  # Project documentation
```

---

# 👩‍💻 Author

**Divita Varshney**
