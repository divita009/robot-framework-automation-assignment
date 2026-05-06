# 🤖 Robot Framework Automation Assignment

## 📌 Objective

Automate a Google search using Robot Framework and Selenium. Extract top 4–5 results for **"robotframework"**, print them to console, and save to a file.

---

## 🚀 Features

* Opens Google and performs search
* Extracts top results
* Prints results to console
* Saves results to `output.txt`
* Captures execution screenshots

---

## 🛠️ Tech Stack

* Python
* Robot Framework
* SeleniumLibrary

---

## 📂 Project Structure

```
robot-framework-automation-assignment/
│
├── tests/google_search.robot
├── results/
│   ├── output.txt
│   ├── log.html
│   ├── report.html
│   ├── output.xml
│   └── screenshots/
├── README.md
└── .gitignore
```

---

## ▶️ Run the Test

```bash
pip install robotframework robotframework-seleniumlibrary
python -m robot -d results tests/google_search.robot
```

---

## 📸 Output

* Console: Top results
* File: `results/output.txt`
* Reports: `log.html`, `report.html`
* Screenshots in `results/screenshots/`

---

## ⚠️ Note

Google may show CAPTCHA during automation. Manual resolution may be required.

---

## 👩‍💻 Author

Divita Varshney
